.386p
.model Tiny

LOADER SEGMENT para use16

;org 100h
assume cs:LOADER

start:

jmp __comentry

__comentry:
cli
mov ax,0
mov cx,0
mov dx,0
mov bx,0
mov si,0
mov di,0
mov sp,0fffeh
mov bp,sp

mov ax,4000h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
add ax,1000h
mov ss,ax

push word ptr 0
push word ptr 0
push word ptr 1
push word ptr 1
push word ptr 0
push es
call __readSector
add sp,12
cmp ax,-1
jz __error

mov bx,0
movzx eax,dword ptr es:[bx + 8]
and eax,0ff0000h
shr eax,16
push ax

movzx eax,dword ptr es:[bx + 8]
and eax,0ff00h
shr eax,8
push ax

movzx eax,dword ptr es:[bx + 8]
and eax,0ffh
push ax

mov ecx,dword ptr es:[bx + 4]
push cx

push bx
push ds
call __readSector
add sp,12
cmp ax,-1
jz __error

jmp es:[bx]


__error proc near
	hlt
	ret
__error endp

;AH＝02H
;AL＝扇区数
;CL＝扇区
;CH＝柱面
;DH＝磁头
;DL＝驱动器(00H~7FH:软盘,80H~0FFH:硬盘)
;ES:BX＝缓冲区的地址
;CF＝0 操作成功,AH＝00H,AL＝传输的扇区数,否则AH＝状态代码
__readSector proc near

push bp
mov bp,sp
sub sp,40h

mov ax,word ptr ss:[bp + 4]
mov es,ax
mov bx,word ptr ss:[bp+6]

_readsec:
mov al,byte ptr ss:[bp + 8]
mov ah,2
mov cl,byte ptr ss:[bp + 10]
mov ch,byte ptr ss:[bp + 12]
mov dh,byte ptr ss:[bp + 14]
mov dl,80h
int 13h
cmp ah,0
jnz _readerror

mov eax,dword ptr es:[bx]
cmp eax,dword ptr 00474a4ch
jz _readok

inc byte ptr ss:[bp + 10]
cmp byte ptr ss:[bp + 10],40h
jae _readerror
jmp _readsec

_readok:
mov sp,bp
pop bp

mov ax,word ptr ss:[bp + 8]
ret

_readerror:
mov sp,bp
pop bp
mov ax,-1
ret

__readSector endp

MYLOADERHEADER struc
id 			dd 0
loadersize 	dd 0
sectorno	dd 0
MYLOADERHEADER ends

LOADER ends
end start
