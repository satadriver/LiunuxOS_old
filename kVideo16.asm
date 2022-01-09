.386p

Kernel16 segment para use16
assume cs:kernel16

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
	mov bx,8000h
	or bx,word ptr es:[_videoMode]
	;mov bx,word ptr es:[_videoMode]
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

	mov cx,word ptr es:[_videoMode]
	cmp cx,VIDEO_MODE_112
	jz _check112
	cmp cx, VIDEO_MODE_115
	jz _check115
	cmp cx,VIDEO_MODE_118
	jz _check118
	cmp cx, VIDEO_MODE_11b
	jz _check11b
	cmp cx, VIDEO_MODE_11F
	jz _check11F
	cmp cx, VIDEO_MODE_3
	jz _check3
	jmp _initVideoEnd

	_check112:
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
	jmp _setVideoParams

	_check115:
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
	jmp _setVideoParams
	_check118:
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
	jmp _setVideoParams
	_check11b:
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
	jmp _setVideoParams
	
	_check11F:
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
	jmp _setVideoParams
	
	_check3:
	mov dword ptr es:[_bytesPerPixel],2
	mov dword ptr es:[_bytesPerLine],160
	mov dword ptr es:[_videoHeight],25
	
	jmp _initVesaError
	jmp _initVideoEnd

	_setVideoParams:
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
	mov eax,es:[di+28h]
	mov es:[_videoBase],eax
	mov eax,es:[di + 2ch]
	add dword ptr es:[_videoBase],eax
	
	mov eax,es:[_videoBase]
	
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
	
	jmp _initVideoEnd
	
	_initvesaInfoErr db 'init vesa get information error',0ah,0
	_initvesaScanlineErr db 'init vesa set scan line error',0ah,0
	_initvesaSetErr db 'init vesa set video mode error',0ah,0
__initVesa endp





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
	sub sp,40h

	mov ax,kernelData
	mov es,ax
	mov ds,ax

	;mov ax,4f02h
	;mov bx,3
	;int 10h

	push word ptr 0ah
	push offset _videoSelection
	push cs
	call __textModeShow16
	add sp,6

	_getvideoselect:
	mov ah,0
	int 16h
	cmp al,'1'
	jz _video1select
	cmp al,'2'
	jz _video2select
	cmp al,'3'
	jz _video3select
	cmp al,'4'
	jz _video4select
	cmp al,'0'
	jz _getvideoselect
	jz _videotextselect
	cmp al,'5'
	jz _video5select
	jmp _getvideoselect

	_videotextselect:
	mov word ptr es:[_videoMode],VIDEO_MODE_3
	jmp __initVideoOver
	_video1select:
	mov word ptr es:[_videoMode],VIDEO_MODE_112
	jmp _selectVideoEnd
	_video2select:
	mov word ptr es:[_videoMode],VIDEO_MODE_115
	jmp _selectVideoEnd
	_video3select:
	mov word ptr es:[_videoMode],VIDEO_MODE_118
	jmp _selectVideoEnd
	_video4select:
	mov word ptr es:[_videoMode],VIDEO_MODE_11b
	jmp _selectVideoEnd
	_video5select:
	mov word ptr es:[_videoMode],VIDEO_MODE_11F
	jmp _selectVideoEnd
	
	_selectVideoEnd:
	call __initVesa

	__initVideoOver:
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

_videoSelection db 'please select vido mode:',0ah
				db '0: command line',0ah
				db '1: 640x480x16M',0ah
				db '2: 800x600x16M',0ah
				db '3: 1024x768x16M',0ah
				db '4: 1280x1024x16M',0ah
				db '5: 1600x1200x16M',0ah,0,0
				
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


;param:strseg,stroff,color
__textModeShow16 proc 
	push bp
	mov bp,sp

	push ds
	push es
	push fs
	
	push cx
	push dx
	push bx
	push si
	push di
	sub sp,40h
	
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
	
	add sp,40h
	pop di
	pop si
	pop bx
	pop dx
	pop cx
	
	pop fs
	pop es
	pop ds

	mov sp,bp
	pop bp
	ret
__textModeShow16 endp

kernel16 ends


