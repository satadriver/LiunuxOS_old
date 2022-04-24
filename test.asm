
include vesadata.asm

.386

kernelData segment para use16

_videoInfo			VESAInformation <?>

_videoBlockInfo		VESAInfoBlock <>

_videoTypes			dw 32 dup (0)		;800*600 1024*768 1280*1024 1600*1200
_videoMode			dw 0
kernelData ends

Kernel Segment public para use16
assume cs:Kernel




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

	MOV eDI,offset _videoBlockInfo
	
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
	lodsw
	cmp ax,0
	jz __getVesaModeOver
	cmp ax,0ffffh
	jz __getVesaModeOver
	mov bp,ax
	mov cx,ax
	mov ax,4f01h
	mov edi, offset _videoInfo
	int 10h
	cmp ax,4fh
	jnz __getVesaModeOver
	movzx ax,es:[di + VESAInformation.BitsPerPixel]
	cmp ax,24
	jb __getVesaMode_checkmode
	mov ax,es:[di + VESAInformation.XRes]
	cmp ax,800
	jb __getVesaMode_checkmode
	cmp ax,1600
	ja __getVesaMode_checkmode
	mov dx,ax
	and dx,0fff0h
	cmp dx,0
	jz __getVesaMode_checkmode
	mov cx,es:[di + VESAInformation.YRes]
	cmp cx,600
	jb __getVesaMode_checkmode
	cmp cx,1200
	ja __getVesaMode_checkmode
	mov dx,cx
	and dx,0fff0h
	cmp dx,0
	jz __getVesaMode_checkmode
	
	mov es:[ebx+0],bp
	mov es:[ebx+2],ax
	mov es:[ebx + 4],cx
	movzx ax,es:[di + VESAInformation.BitsPerPixel]
	mov es:[ebx+6],ax
	
	add ebx,8
	mov eax,ebx
	sub eax,offset _videoTypes
	cmp eax,64
	jae __getVesaModeOver
	jmp __getVesaMode_checkmode

	__getVesaModeOver:
	mov eax,ebx
	sub eax,offset _videoTypes
	shr eax,3
	
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


start:
mov ax,kernelData
mov ds,ax
mov es,ax

call __getVesaMode
mov ah,4ch
int 21h

kernel ends

end start





