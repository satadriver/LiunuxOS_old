.386p

Kernel16 segment para use16
assume cs:kernel16


;AH = 4Fh 超级VGA支持   
;AL = 00h 返回超级VGA信息   
;ES:DI = 缓冲区指针 

;AH = 4Fh 超级VGA支持   
;AL = 01h 返回超级VGA模式信息   
;CX = 超级VGA模式号（模式号必须为函数00h返回值之一）   
;ES:DI = 256字节缓冲区指针   

__getVesaMode proc
	PUSH ECX
	PUSH EDX
	PUSH EBX
	PUSH ESI
	PUSH EDI
	PUSH EBP
	PUSH DS
	PUSH ES
	
	mov ebp,ESP
	
	SUB ESP,200H
	
	mov ss:[ebp - 4],0
	
	mov ebx,offset _videoTypes
	
	MOV AX,kernelData
	MOV ES,AX
	mov ds,ax

	MOV edi,offset _videoBlockInfo
	
	mov ax,4f00h
	int 10h
	
	cmp ax,4fh
	JNZ __getVesaModeOver
	
	mov eax,es:[edi + VESAInfoBlock.VESASignature]
	cmp eax,41534556h
	;JNZ __getVesaModeOver
	
	movzx eax,es:[edi + VESAInfoBlock.TotalMemory]
	shl eax,16
	mov es:[_videoBufTotal],eax
	
	MOV SI,ES:[DI + VESAInfoBlock.VideoModeOffset ]
	MOV AX,ES:[DI + VESAInfoBlock.VideoModeSeg]
	MOV DS,AX
	cld
	
	
	__getVesaMode_checkmode:
	mov ax,ds:[si]
	add si,2
	
	cmp ax,0
	jz __getVesaModeOver
	cmp ax,0ffffh
	jz __getVesaModeOver

	mov cx,ax
	mov ax,4f01h
	mov di, offset _videoInfo
	int 10h
	cmp ax,4fh
	jnz __getVesaModeOver
	
	mov ax,es:[di + VESAInformation.ModeAttr]
	and ax,80h
	cmp ax,80h
	jnz __getVesaMode_checkmode
	
	mov al,es:[di + VESAInformation.MemoryModel]
	cmp al,4
	jz __getVesaMode_checkbits
	cmp al,6 
	jnz __getVesaMode_checkmode
	
	__getVesaMode_checkbits:
	movzx ax,es:[di + VESAInformation.BitsPerPixel]
	cmp ax,24
	jb __getVesaMode_checkmode
	cmp ax,32
	ja __getVesaMode_checkmode
	
	mov ax,es:[di + VESAInformation.XRes]
	cmp ax,640
	jb __getVesaMode_checkmode
	cmp ax,1600
	ja __getVesaMode_checkmode
	mov dx,ax
	and dx,0fh
	cmp dx,0
	jnz __getVesaMode_checkmode
	
	mov cx,es:[di + VESAInformation.YRes]
	cmp cx,480
	jb __getVesaMode_checkmode
	cmp cx,1200
	ja __getVesaMode_checkmode
	mov dx,cx
	and dx,0fh
	cmp dx,0
	jnz __getVesaMode_checkmode
	
	mov ax,ds:[si - 2]
	mov es:[ebx+0],ax
	
	mov ax,es:[di + VESAInformation.XRes]
	mov es:[ebx+2],ax
	
	mov ax,es:[di + VESAInformation.YRes]
	mov es:[ebx + 4],ax
	
	movzx ax,es:[di + VESAInformation.BitsPerPixel]
	mov es:[ebx+6],ax
	
	mov eax,es:[di + VESAInformation.PhyBasePtr]
	add eax,es:[di + VESAInformation.OffScreenMenOffset]
	mov es:[ebx + 8],eax
	
	movzx eax,es:[di + VESAInformation.OffScreenMemSize]
	mov es:[ebx +12],eax
	
	inc dword ptr ss:[ebp - 4]
		
	add ebx,16
	mov eax,ebx
	sub eax,offset _videoTypes
	cmp eax,128
	jae __getVesaModeOver
	
	jmp __getVesaMode_checkmode

	__getVesaModeOver:
	sub ebx,16
	;mov ebx,offset _videoTypes
	mov ax,es:[ebx]
	mov es:[_videoMode],ax
	
	mov eax,ebx
	mov eax,ss:[ebp - 4]
	
	ADD ESP,200H
	POP ES
	POP DS
	POP EBP
	POP EDI
	POP ESI
	POP EBX
	POP EDX
	POP ECX
	RET
__getVesaMode endp


__initVesa proc
	push bp
	mov bp,sp

	push cx
	push dx
	push bx
	push si
	push di
	push ds
	push es
	sub sp,40h
	
	mov ax,kernelData
	mov ds,ax
	mov es,ax
	
;VBE返回值一般在AX中：
;1）AL=4FH：支持该功能
;2）AL!=4FH：不支持该功能；
;3）AH=00H：调用成功；
;4）AH=01H：调用失败；
;5）AH=02H：当前硬件配置不支持该功能；
;6）AH=03H：当前的显示模式不支持该功能；

;BX = 模式号
;	D0～D8：9位模式号
;	D9～D13：保留，必须为0
;	D14 = 0：使用普通的窗口页面缓存模式，用VBE功能05H切换显示页面
;		= 1：使用大的线性缓存区，其地址可从VBE功能01H的返回信息ModeInfo获得
;	D15 = 0：清除显示内存
;		= 1：不清除显示内存



	mov ax,4f02h
	mov bx,4000h
	or bx,word ptr es:[_videoMode]

	int 10h
	cmp ax,4fh
	mov bx, offset _initvesaSetErr
	mov [esp],bx
	jnz _initVesaError
	
	;ES:DI指向预先保留的256字节空间,这里将保存int 10h传来的参数,其中第40个字节开始存有显存地址的32位值
	mov ax,4f01h
	mov di, offset _videoInfo
	mov cx,es:[_videoMode]
	int 10h
	cmp ax,4fh
	mov bx,offset _initvesaInfoErr
	mov [esp],bx
	jnz _initVesaError
	
	mov ax,4f06h
	mov bx,0
	mov si,offset _videoInfo
	mov cx,es:[si + VESAInformation.XRes]
	int 10h
	cmp ax,4fh
	mov bx,offset _initvesaScanlineErr
	mov [esp],bx
	jnz _initVesaError
	
	mov si,offset _videoInfo
	movzx eax,es:[si + VESAInformation.BytesPerScanLine]
	movzx ecx,es:[si + VESAInformation.BitsPerPixel]
	shr ecx,3
	movzx edx,es:[si + VESAInformation.YRes]
	movzx ebx,es:[si + VESAInformation.XRes]
	
	mov dword ptr es:[_videoWidth],ebx
	mov dword ptr es:[_bytesPerPixel],ecx
	mov dword ptr es:[_bytesPerLine],eax
	mov dword ptr es:[_videoHeight],edx

	mov eax,es:[_bytesPerLine]
	mov ecx,es:[_videoHeight]
	mul ecx
	mov es:[_videoFrameTotal],eax

	mov eax,es:[_videoWidth]
	mov ecx,BIOS_GRAPHCHAR_WIDTH
	mov edx,0
	div ecx
	mov es:[_graphFontLines],eax

	mov eax,es:[_videoHeight]
	sub eax,GRAPH_TASK_HEIGHT
	mov es:[_windowHeight],eax
	push eax
	mov edx,0
	mov ecx,BIOS_GRAPHCHAR_HEIGHT
	div ecx
	mov es:[_graphFontRows],eax
	pop eax
	mov ecx,es:[_bytesPerLine]
	mul ecx
	mov es:[_graphwindowLimit],eax
	
	mov eax,es:[_bytesPerPixel]
	mov ecx,BIOS_GRAPHCHAR_WIDTH
	mul ecx
	mov es:[_bytesXPerChar],eax

	mov eax,es:[_bytesPerLine]
	mov ecx,BIOS_GRAPHCHAR_HEIGHT
	mul ecx
	mov es:[_graphFontLSize],eax

	lea di, _videoInfo
	;mov dword ptr es:[di+28h],0f0000000h
	mov eax,es:[di+28h]
	mov es:[_videoBase],eax
	mov eax,es:[di + 2ch]
	add dword ptr es:[_videoBase],eax
	
	;mov eax,es:[_videoBase]
	;mov ecx,es:[di + 48]
	;mov ecx,es:[_videoFrameTotal]
	;shl ecx,2
	;add eax,ecx
	;sub eax,MOUSE_DATA_LIMIT_SIZE
	;mov es:[_mouseCoverData],eax
	

	mov eax,es:[_graphFontLSize]
	mov edx,es:[_videoFrameTotal]
	sub edx,eax
	mov ecx,es:[_bytesPerLine]
	shr ecx,1
	add edx,ecx
	mov es:[_screenInfoPos],edx
	
	mov eax,es:[_mouseBorderSize]
	mov ecx,es:[_bytesPerPixel]
	mul ecx
	mov es:[_mouseBorderSize],eax
	
	call __getGraphCharBase
	mov eax,1

	_initVideoEnd:
	add sp,40h
	pop es
	pop ds
	pop di
	pop si
	pop bx
	pop dx
	pop cx
	
	mov sp,bp
	pop bp
	ret
	
	_initVesaError:
	mov ax,4f02h
	mov bx,3
	int 10h
	
	mov ax,[esp]
	push word ptr TEXTMODE_FONTCOLOR_ERR
	push ax
	push cs
	call __textModeShow16
	add sp,6
	
	mov eax,0
	jmp _initVideoEnd
	
	_initvesaInfoErr db 'init vesa get information error',0ah,0
	_initvesaScanlineErr db 'init vesa set scan line error',0ah,0
	_initvesaSetErr db 'init vesa set video mode error',0ah,0
__initVesa endp
















;word src offset,word src seg,word dst offset,word dst seg
__formatstr proc
push bp
mov bp,sp
sub sp,100h

push ecx
push edx
push ebx
push esi
push edi
push ds
push es

mov si,ss:[bp+4]
mov ax,ss:[bp+6]
mov ds,ax

mov di,ss:[bp+8]
mov ax,ss:[bp+10]
mov es,ax

mov bx,bp
add bx,12

cld



__formatstr_loop:
lodsb
cmp al,0
jz __formatstr_end
cmp al,'%'
jz __formatstr_make
stosb
inc ecx
jmp __formatstr_loop

__formatstr_make:
lodsb
cmp al,'x'
jz __formatstr_number
cmp al,'s'
jz __formatstr_str
jmp __formatstr_end

__formatstr_number:
push es
push di
mov eax,ss:[bx]
push eax
call __hex3str
add esp,8

add edi,eax

add ebx,4
jmp __formatstr_loop

__formatstr_str:
push es
push di
push word ptr ss:[bx+2]
push word ptr ss:[bx]
call __strcpy16
add esp,8
add edi,eax

add bx,4
jmp __formatstr_loop

__formatstr_end:
mov al,0
stosb
movzx eax,di
sub ax,ss:[bp + 8]
pop es
pop ds
pop edi
pop esi
pop ebx
pop edx
pop ecx

add sp,100h
mov sp,bp
pop bp
ret
__formatstr endp





;dword v,word offset,word seg
__hex3str proc 
push bp
mov bp,sp
sub sp,100h

push ecx
push edx
push ebx
push esi
push edi
push ds
push es

mov di,ss:[bp+8]
mov ax,ss:[bp+10]
mov es,ax


mov eax,ss:[bp+4]
cmp eax,0
jnz __hex3str_not_zero

__hex3str_not_zero:
mov ecx,8

mov ebx,0

mov dl,28
cld
__hex3str_loop:
push ecx
mov eax,ss:[bp+4]
mov cl,dl
shr eax,cl
and eax,0fh
cmp al,9
jbe __decimalchar
add al,7
__decimalchar:
add al,30h

cmp ebx,0
jnz __hex3str_keep

cmp al,'0'
jz __hex3str_neglect_0

__hex3str_show_prefix:
mov cl,al
mov al,'0'
stosb
mov al,'x'
stosb
mov al,cl
mov ebx,1
jmp __hex3str_keep


__hex3str_neglect_0:
cmp dl,0
jz __hex3str_show_prefix
mov al,' '
jmp __hex3str_keep_end

__hex3str_keep:
stosb
__hex3str_keep_end:
sub dl,4
pop ecx
loop __hex3str_loop

movzx eax,di
sub ax,ss:[bp+8]
pop es
pop ds
pop edi
pop esi
pop ebx
pop edx
pop ecx

add sp,100h
mov sp,bp
pop bp
ret
__hex3str endp


















;word src offset,word src seg,word dst offset,word dst seg
__strcpy16 proc
push bp
mov bp,sp
sub sp,100h

push ecx
push edx
push ebx
push esi
push edi
push ds
push es

mov di,ss:[bp+8]
mov ax,ss:[bp+10]
mov es,ax

mov si,ss:[bp+4]
mov ax,ss:[bp+6]
mov ds,ax
cld

__strcpy_loop:
lodsb
cmp al,0
jz __strcpy_end
stosb
jmp __strcpy_loop

__strcpy_end:
movzx eax,di
sub ax,ss:[bp+8]
pop es
pop ds
pop edi
pop esi
pop ebx
pop edx
pop ecx

add sp,100h
mov sp,bp
pop bp
ret
__strcpy16 endp




;param:strseg,stroff,color
__textModeShow16 proc 
	push bp
	mov bp,sp
	sub sp,40h

	push cx
	push dx
	push bx
	push si
	push di
	push ds
	push es
	push fs
	
	
	mov ax,kernelData
	mov fs,ax
	
	mov ax,word ptr ss:[bp + 4]
	mov ds,ax
	mov ax,VIDEOMODE_TEXT_DATASEG
	mov es,ax
	mov si,word ptr ss:[bp+6]
	mov di, word ptr fs:[_textShowPos]
	mov ax,di
	mov dx,0
	mov cx,VIDEOMODE_TEXT_BYTESPERLINE
	div cx
	cmp dx,0
	jnz _rmTextShowNewPos
	inc ax
	_rmTextShowNewPos:
	mul cx
	mov di,ax
	cld
	
	_rmTextShowChar:
	lodsb
	cmp al,0
	jz _rmTextShowOver
	cmp al,0ah
	jz _rmTextNewLine
	cmp al,0dh
	jz _rmTextEnterLine
	jmp _rmOutputChar

	_rmTextNewLine:
	mov ax,di
	mov dx,0
	mov cx,VIDEOMODE_TEXT_BYTESPERLINE
	div cx
	cmp dx,0
	jz _rmTextShowNewLine
	inc ax
	_rmTextShowNewLine:
	mul cx
	mov di,ax
	;mov dx,VIDEOMODE_TEXT_BYTESPERLINE
	;dec dx
	;not dx
	;and di,dx
	;add di,VIDEOMODE_TEXT_BYTESPERLINE
	jmp _rmTextShowChar
	
	_rmTextEnterLine:
	mov ax,di
	mov dx,0
	mov cx,VIDEOMODE_TEXT_BYTESPERLINE
	div cx
	mul cx
	mov di,ax
	jmp _rmTextShowChar

	_rmOutputChar:
	mov ah,byte ptr ss:[bp + 8]
	
	cmp di,VIDEOMODE_TEXT_MAX_OFFSET
	jb _rmToShowChar
	
	mov di,0
	
	_rmToShowChar:
	stosw
	jmp _rmTextShowChar
	
	_rmTextShowOver:
	mov word ptr fs:[_textShowPos],di
	
	mov ax,si
	sub ax,word ptr ss:[bp + 6]
	
	pop fs
	pop es
	pop ds
	pop di
	pop si
	pop bx
	pop dx
	pop cx

	add sp,40h
	mov sp,bp
	pop bp
	ret
__textModeShow16 endp





__initVideo proc
	push bp
	mov bp,sp
	push cx
	push dx
	push bx
	push si
	push di
	push ds
	push es
	sub sp,400h
	
	mov ax,kernelData
	mov es,ax
	mov ds,ax

	mov ax,4f02h
	mov bx,3
	int 10h
	mov word ptr ds:[_textShowPos],0
	
	call __getVesaMode
	cmp eax,0
	jnz __checkVideoMode
	
	mov ax,3
	int 10h
	mov eax,0
	mov dword ptr ds:[text_mode_tag],1
	jmp __initVideoOver
	
__checkVideoMode:
	mov bx,sp
	;add bx,200h
	
	mov edi,offset _videoBlockInfo

	mov ax,es:[edi + VESAInfoBlock.OEMStringSeg]
	push ax
	mov ax,es:[edi + VESAInfoBlock.OEMStringOffset]
	push ax
	
	movzx eax,es:[edi + VESAInfoBlock.TotalMemory]
	shl eax,16
	push eax
	
	movzx eax,es:[edi + VESAInfoBlock.VESAVersion]
	push eax
	
	push ss
	push bx
	
	push cs
	mov ax, offset _videoWelcome
	push ax
	
	call __formatstr
	add sp,20
	
	push word ptr 0ah
	push bx
	push ss
	call __textModeShow16
	add sp,6
	

	
	mov ecx,0
	mov si,offset _videoTypes
	__initVideo_showmode:
	cmp word ptr ds:[si],0
	jz __initVideo_getmode
	
	cmp word ptr ds:[si+2],0
	jz __initVideo_getmode
	
	cmp word ptr ds:[si+4],0
	jz __initVideo_getmode
	
	cmp word ptr ds:[si+6],0
	jz __initVideo_getmode
	
	;cmp word ptr ds:[si+8],0
	;jz __initVideo_getmode
	
	mov eax,dword ptr ds:[si + 12]
	push eax
	mov eax,dword ptr ds:[si + 8]
	push eax
	movzx eax,word ptr 	ds:[si+6]
	push eax
	movzx eax,word ptr 	ds:[si+4]
	push eax
	movzx eax,word ptr 	ds:[si+2]
	push eax
	movzx eax,word ptr 	ds:[si+0]
	push eax
	
	push ecx
	
	push ss
	push bx
	
	push cs
	mov ax, offset _videoModeSelection
	push ax
	
	call __formatstr
	add sp,36
	
	push word ptr 0fh
	push bx
	push ss
	call __textModeShow16
	add sp,6
	
	inc ecx
	

	add si,16
	mov ax,si
	sub ax,offset _videoTypes
	cmp ax,128
	jb  __initVideo_showmode
	
__initVideo_getmode:
	mov ah,0
	int 16h
	sub al,30h
	cmp al,0
	jb __initVideo_getmode
	cmp al,9
	ja __initVideo_getmode
	movzx eax,al
	cmp eax,ecx
	ja __initVideo_getmode
	
	shl eax,4
	add eax,offset _videoTypes
	mov dx,ds:[eax]
	mov word ptr ds:[_videoMode],dx
	
	call __initVesa

	__initVideoOver:
	add sp,400h
	pop es
	pop ds
	pop di
	pop si
	pop bx
	pop dx
	pop cx
	mov sp,bp
	pop bp
	ret

_videoWelcome 				db 'Welcome to Liunux OS! VESA Version:%x,Size:%x,Description:%s,please choose the display show mode:',0dh,0

_videoModeSelection 		db '[%x]. Screen VESA mode:%x, Width:%x, Height:%x, Bits:%x, Base Address:%x, Reserved Size:%x',0dh,0

_videoSelectionError 		db 'invalid item,please reinput again',0dh,0
	
__initVideo endp









;bit 7 high ground
;bit 6 red ground
;bit 5 yellow ground
;bit 4 blue ground
;bit 3 high character
;bit 2 red character
;bit 1 yellow character
;bit 0 blue character


__getGraphCharBase proc
push cx
push dx
push si
push ds
push es

;mov ax,0
mov ax,BIOS_GRAPHCHARS_SEG
mov ds,ax

mov ax,kernelData
mov es,ax

mov dx,0

mov si,BIOS_GRAPHCHARS_OFFSET
mov cx,4
cld
_getGaraphChar8Bytes:
lodsw
add dx,ax
loop _getGaraphChar8Bytes
cmp dx,0
;jnz _useBiosGraphChar

mov dword ptr es:[_graphCharBase],GRAPHFONT_LOAD_ADDRESS
jmp __getGraphCharBaseEnd

_useBiosGraphChar:
mov eax,BIOS_GRAPHCHARS_BASE
mov dword ptr es:[_graphCharBase],eax

__getGraphCharBaseEnd:
pop es
pop ds
pop si
pop dx
pop cx
ret
__getGraphCharBase endp




kernel16 ends


