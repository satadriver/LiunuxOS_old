
include vesadata.asm

.386

VIDEOMODE_TEXT_DATASEG 		EQU 0b800h
VIDEOMODE_TEXT_DATABASE 	EQU (VIDEOMODE_TEXT_DATASEG * 16)
VIDEOMODE_TEXT_BYTESPERLINE EQU 160
VIDEOMODE_TEXT_MAX_LINE 	EQU 25
VIDEOMODE_TEXT_MAX_OFFSET 	equ (VIDEOMODE_TEXT_MAX_LINE * VIDEOMODE_TEXT_BYTESPERLINE )

kernelData segment para use16

_videoInfo			VESAInformation <?>

_videoBlockInfo		VESAInfoBlock <>

_videoTypes			dw 128 dup (0)	
_videoMode			dw 0


_textShowPos		dw 160
kernelData ends



stackseg segment

db 4096 dup (0)

stackseg ends

Kernel Segment public para use16
assume cs:Kernel







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
	
	SUB ESP,200H
	
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
	JNZ __getVesaModeOver
	
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
	
	movzx ax,es:[di + VESAInformation.BitsPerPixel]
	cmp ax,24
	jb __getVesaMode_checkmode
	cmp ax,32
	ja __getVesaMode_checkmode
	
	mov ax,es:[di + VESAInformation.XRes]
	cmp ax,800
	jb __getVesaMode_checkmode
	cmp ax,1600
	ja __getVesaMode_checkmode
	mov dx,ax
	and dx,0fh
	cmp dx,0
	jnz __getVesaMode_checkmode
	
	mov cx,es:[di + VESAInformation.YRes]
	cmp cx,600
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

mov ecx,0

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

add edi,8
add ecx,8

add ebx,4
jmp __formatstr_loop

__formatstr_str:
push es
push di
push ds
push si
call __strcpy16
add esp,8
add edi,eax
add ecx,eax

add bx,4
jmp __formatstr_loop

__formatstr_end:
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

mov ecx,8

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
stosb
sub dl,4
pop ecx
loop __hex3str_loop

mov eax,8
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

mov ecx,0

__strcpy_loop:
lodsb
cmp al,0
jz __strcpy_end
stosb
inc ecx
jmp __strcpy_loop

__strcpy_end:
mov eax,ecx
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



start:

__initVideo proc

	mov ax,stackseg
	mov ss,ax
	
	;sub sp,400h
	mov sp,400h

	mov ax,kernelData
	mov es,ax
	mov ds,ax

	;mov ax,4f02h
	;mov bx,3
	;int 10h
	
	call __getVesaMode

	push word ptr 0ch
	push offset _videoWelcome
	push cs
	call __textModeShow16
	add sp,6
	
	;jmp __initVideo_getmode
	
	mov bx,sp
	add bx,400h
	
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
	
	push word ptr 0ch
	push  bx
	push ss
	call __textModeShow16
	add sp,6
	
	inc ecx
	
	;add word ptr ds:[_textShowPos],160

	add si,16
	mov ax,si
	sub ax,offset _videoTypes
	cmp ax,128
	jb  __initVideo_showmode
	

	
__initVideo_getmode:

	mov ah,00
	int 16h


	__initVideoOver:
	
	mov ah,4ch
	int 21h


_videoWelcome 				db 'welcome to Liunux OS,please choose the display resolution:',0ah,0

_videoModeSelection 		db '%x. mode:%x,width:%x,height:%x,bits:%x,base:%x,size:%x',0ah,0

;_videoModeSelection 		db 'hello how are you?',0ah,0
	
__initVideo endp





kernel ends

end start





