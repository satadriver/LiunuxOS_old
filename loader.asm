.386p
.model small


;注意不同于com文件，不能加org 100伪指令
;include pe.h

FIRST_SEGMENT		EQU 0
LOADER_BASE_SEGMENT EQU 800H
KERNEL_BASE_SEGMENT EQU 1000H
VSKDLL_LOAD_SEG 	EQU 4000H

BAKMBR_BASE			EQU 7A00H
INFO_BASE			EQU 7800H
LOADER_SEC_OFFSET	EQU (INFO_BASE + 6)
LOADER_SEC_CNT		EQU (INFO_BASE + 4)
KERNEL_SEC_OFFSET	EQU (INFO_BASE + 12)
KERNEL_SEC_CNT		EQU (INFO_BASE + 10)
BAKMBR_SEC_OFFSET	EQU (INFO_BASE + 16)
BAKMBR2_SEC_OFFSET	EQU (INFO_BASE + 20)
FONT_SEC_CNT		EQU (INFO_BASE + 24)
FONT_SEC_OFFSET		EQU (INFO_BASE + 26)
KERDLL_SEC_CNT		EQU (INFO_BASE + 30)
KERDLL_SEC_OFFSET	EQU (INFO_BASE + 32)

RM_SEG_LIMIT		EQU 10000H
RM_STACK_TOP		EQU (RM_SEG_LIMIT - 10H)


Loader segment para use16
	assume cs:Loader
	
	start:

	mov eax,0
	mov ecx,0
	mov edx,0
	mov ebx,0
	mov esi,0
	mov edi,0
	mov esp,RM_STACK_TOP
	mov ebp,esp

	mov ax,FIRST_SEGMENT
	mov es,ax

	call near ptr _loaderTag

	mov byte ptr cs:[patlen],10h
	mov byte ptr cs:[reserved],0
	mov word ptr cs:[seccnt],1
	mov eax,FIRST_SEGMENT
	shl eax,16
	mov ax,BAKMBR_BASE
	mov cs:[segoff],eax
	mov eax, dword ptr es:[BAKMBR_SEC_OFFSET]
	mov dword ptr cs:[secofflow],eax
	mov dword ptr cs:[secoffhigh] ,0
	mov ax,cs
	mov ds,ax
	lea si,patlen
	mov ax,4200h
	mov dx,80h
	int 13h
	cmp ah,0
	jnz _readMbrErr

	call near ptr _readMbrOK

	mov byte ptr cs:[patlen],10h
	mov byte ptr cs:[reserved],0
	mov word ptr cs:[seccnt],1
	mov eax,FIRST_SEGMENT
	shl eax,16
	mov ax,BAKMBR_BASE
	mov cs:[segoff],eax
	mov dword ptr cs:[secofflow],0
	mov dword ptr cs:[secoffhigh] ,0
	mov ax,cs
	mov ds,ax
	lea si, patlen
	mov ax,4300h
	mov dx,80h
	int 13h
	cmp ah,0
	jnz _writeMbrErr

	call near ptr _writeMbrOK
	
comment *
	mov byte ptr cs:[patlen],10h
	mov byte ptr cs:[reserved],0
	mov ax, word ptr es:[FONT_SEC_CNT]
	mov word ptr cs:[seccnt],ax
	mov eax,FIRST_SEGMENT
	shl eax,16
	mov ax,FONT_BASE
	mov cs:[segoff],eax
	mov eax, dword ptr es:[FONT_SEC_OFFSET]
	mov dword ptr cs:[secofflow],eax
	mov dword ptr cs:[secoffhigh] ,0
	mov ax,cs
	mov ds,ax
	lea si, patlen
	mov ax,4200h
	mov dx,80h
	int 13h
	cmp ah,0
	jnz _readFontErr
*

	mov byte ptr cs:[patlen],10h
	mov byte ptr cs:[reserved],0
	mov ax, word ptr es:[KERNEL_SEC_CNT]
	mov word ptr cs:[seccnt],ax
	mov eax,KERNEL_BASE_SEGMENT
	shl eax,16
	mov ax,0
	mov cs:[segoff],eax
	mov eax, dword ptr es:[KERNEL_SEC_OFFSET]
	mov dword ptr cs:[secofflow],eax
	mov dword ptr cs:[secoffhigh] ,0
	mov ax,cs
	mov ds,ax
	lea si, patlen
	mov ax,4200h
	mov dx,80h
	int 13h
	cmp ah,0
	jnz _readKernelErr
	
	call near ptr _readKernelOK
	
comment *	
	mov byte ptr cs:[patlen],10h
	mov byte ptr cs:[reserved],0
	mov ax, word ptr es:[KERDLL_SEC_CNT]
	mov word ptr cs:[seccnt],ax
	mov eax,VSKDLL_LOAD_SEG
	shl eax,16
	mov ax,0
	mov cs:[segoff],eax
	mov eax, dword ptr es:[KERDLL_SEC_OFFSET]
	mov dword ptr cs:[secofflow],eax
	mov dword ptr cs:[secoffhigh] ,0
	mov ax,cs
	mov ds,ax
	lea si, patlen
	mov ax,4200h
	mov dx,80h
	int 13h
	cmp ah,0
	jnz _readKernelDllErr
*

	call near ptr __CheckPE
	cmp ax,-1
	jz __runBin
	cmp ax,1
	jz __runExe16
	cmp ax,2
	jz __runExe32
	HLT

_loaderTag:
	push word ptr 0ah
	lea ax, loadertag
	push ax
	push cs
	call __showMsg
	add sp,6
	retn

_readMbrOK:
	push word ptr 0ah
	lea ax, rbmbrok
	push ax
	push cs
	call __showMsg
	add sp,6
	retn

_writeMbrOK:
	push word ptr 0ah
	lea ax, wbmbrok
	push ax
	push cs
	call __showMsg
	add sp,6
	retn

_readKernelOK:
	push word ptr 0ah
	lea ax, rkerok
	push ax
	push cs
	call __showMsg
	add sp,6
	retn

_readMbrErr:
	push word ptr 8ch
	lea ax, rbmbrerr
	push ax
	push cs
	call __showMsg
	add sp,6
	hlt

_writeMbrErr:
	push word ptr 8ch
	lea ax, wbmbrerr
	push ax
	push cs
	call __showMsg
	add sp,6
	hlt

_readKernelErr:
	push word ptr 8ch
	lea ax, rkererr
	push ax
	push cs
	call __showMsg
	add sp,6
	hlt





__runExe32 proc near
	hlt
__runExe32 endp



;重定位地址的基地址是以EXE文件头长度加上装载地址之和，而不是以CS:IP为基地址
;把exe文件从硬盘读入到内存以后，加上exe头部的长度，exe重定位是以这个地址为坐标进行的定位
__runExe16 proc near
	push ebp
	mov ebp,esp
	
	push ds
	push es
	push ecx
	push edx
	push ebx
	push esi
	push edi
	sub esp,100h
	
	mov ax,KERNEL_BASE_SEGMENT
	mov ds,ax
	
	mov ax,ds
	;exe16 文件头大小
	add ax,word ptr ds:[8]
	;定位的基地址
	mov ss:[esp + 8],ax

	;开始的ip指针
	mov ax,word ptr ds:[14h]
	mov ss:[esp],ax

	;cs段地址
	mov ax,word ptr ds:[16h]
	add ax,word ptr ss:[esp + 8]
	mov ss:[esp+2],ax

	;sp原始地址
	mov ax,word ptr ds:[10h]
	mov ss:[esp + 4],ax

	;ss段地址
	mov ax,ss:[esp + 8]
	add ax,word ptr ds:[0eh]
	mov ss:[esp + 6],ax

	;重定位的项数
	mov cx,word ptr ds:[6]
	cmp cx,0
	jz _setregcall

	;重定位在文件头中的开始偏移
	mov bx,word ptr ds:[18h]
	cld
	_reallocate:
	movzx edi,word ptr ds:[bx]
	
	mov ax,word ptr ds:[bx + 2]
	add ax,word ptr ss:[esp+8]
	mov es,ax
	
	mov dx,es:[edi]
	add dx,word ptr ss:[esp+8]
	mov es:[edi],dx
	add bx,4
	loop _reallocate

	_setregcall:
	mov ax,ss:[esp]
	mov cs:[exe16_ip],ax
	mov ax,ss:[esp + 2]
	mov cs:[exe16_cs],ax

	mov ax,ss:[esp+8]
	sub ax,10h
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax

	mov ax,ss:[esp + 4]
	mov dx,ss:[esp + 6]
	mov ss,dx
	mov sp,ax
	mov bp,ax

	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0
	mov si,0
	mov di,0
	;mov sp,RM_STACK_TOP
	;mov bp,sp

	db 0Eah            
	exe16_ip  dw 0
	exe16_cs  dw 0
	
	add esp,100h
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	pop es
	pop ds
	mov esp,ebp
	pop ebp
	ret
__runExe16 endp



__runBin proc near
	mov word ptr cs:[com_ip],100h
	mov ax,KERNEL_BASE_SEGMENT
	sub ax,10h
	mov word ptr cs:[com_cs],ax
	
	mov ax,KERNEL_BASE_SEGMENT
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax
	mov sp,RM_STACK_TOP
	mov bp,sp
	mov ax,0        ;command line parameters,but is 0 here as no command line parameters
	mov cx,0
	mov bx,0        ;pagehigh of file,but here is 0 as only less 64kbs lenth file can be executed
	mov dx,0
	mov si,0
	mov di,0
	db 0EAh        ;长跳转 JMP FAR PTR XXXX 或JMP DWORD PTR XXXX:[XXXX]
	com_ip  dw 0
	com_cs  dw 0
__runBin endp



;bit 7 high ground
;bit 6 red ground
;bit 5 yellow ground
;bit 4 blue ground
;bit 3 high character
;bit 2 red character
;bit 1 yellow character
;bit 0 blue character
__showMsg proc near
	push bp
	mov bp,sp

	push ds
	push es
	
	push cx
	push dx
	push bx
	push si
	push di
	
	sub sp,100h
	
	mov ax,word ptr ss:[bp + 4]
	mov ds,ax
	mov ax,0b800h
	mov es,ax
	mov si,word ptr ss:[bp+6]
	mov di, word ptr cs:[_showPos]

	cld
	_showchar:
	lodsb
	cmp al,0
	jz _showend
	mov ah,byte ptr ss:[bp + 8]
	stosw
	jmp _showchar
	
	_showend:
	mov ax,si
	sub ax,word ptr ss:[bp + 6]
	
	push ax
	mov dx,0
	mov cx,160
	div cx
	cmp dx,0
	jz _nomodLine
	inc ax
	_nomodLine:
	mov cx,160
	mul cx
	add ax,word ptr cs:[_showPos]
	cmp ax,4000	;25x160
	jb _rollScreen
	mov ax,0
	_rollScreen:
	mov word ptr cs:[_showPos],ax
	pop ax
	
	add sp,100h
	pop di
	pop si
	pop bx
	pop dx
	pop cx
	
	pop es
	pop ds

	mov sp,bp
	pop bp
	retn
_showPos dw 160
__showMsg endp


;6d6f63h com
;4d4f43h 
;657865h exe
;455845h
__CheckPE proc near
	push ds
	mov ax,KERNEL_BASE_SEGMENT
	mov ds,ax

	cmp word ptr ds:[0],5a4dh
	jnz _notPE

	mov eax,dword ptr ds:[3ch]
	cmp eax,0
	jle _pe16
	cmp eax,1000h
	jge _pe16
	mov eax,dword ptr ds:[eax]
	cmp eax,dword ptr 00004550h
	jz _pe32

	_pe16:
	pop ds
	mov ax,1
	ret

	_pe32:
	pop ds
	mov ax,2
	ret

	_notPE:
	pop ds
	mov ax,-1
	ret
__CheckPE endp


align 		16
patlen 		db 0
reserved 	db 0
seccnt 		dw 0
segoff		dd 0
secofflow 	dd 0
secoffhigh 	dd 0

loadertag 	db 'loader running',0
rbmbrok 	db 'read bak mbr ok',0
rbmbrerr 	db 'read bak mbr error',0
wbmbrok 	db 'rewrite bak mbr ok',0
wbmbrerr 	db 'rewrite bak mbr error',0
rkerok 		db 'read kernel ok',0
rkererr 	db 'read kernel error',0

Loader ends
end start