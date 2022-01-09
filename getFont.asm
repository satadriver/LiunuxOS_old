.386
;.model small

stack segment  para use16
db 1024 dup (0)
stack ends


data segment para use16
errinfo 	db 'open file or write file error',0dh,0ah,24h
fname		db 'font.db',0
openfok		db 'open file ok',0dh,0ah,24h,0
writefok	db 'write file ok',0dh,0ah,24h,0
fhandle 	dw 0
data ends

code segment para use16
assume cs:code

start:
mov ax,stack
mov ss,ax
mov sp,512

;mov ax,0f000h
;mov ds,ax
;mov ax,cs
;mov es,ax
;mov si,0fa6eh
;lea di, fontbytes
;mov cx,1024
;cld
;rep movsb


mov ax,data
mov ds,ax
mov es,ax

MOV AX,3c00h
mov dx,offset fname
mov cx,20h			;FILE_ATTRIBUTE_ARCHIVE
int 21h
cmp ax,0
jbe _openFile
mov ds:[fhandle],ax
jmp _writeFile

_openFile:
mov ax,3d01h
mov dx,offset fname
int 21h
cmp ax,0
jbe _openfErr
mov word ptr ds:[fhandle],ax


_writeFile:
mov ah,9
mov al,0
mov dx,offset openfok
int 21h

mov bx,word ptr es:[fhandle]
mov ax,0f000h
mov ds,ax
mov dx,0fa6eh
mov ax,4000h
mov cx,1024
int 21h
cmp ax,1024
jnz _openfErr

mov ax,data
mov ds,ax
mov ah,9
mov al,0
mov dx,offset writefok
int 21h

mov ax,3e00h
mov bx,word ptr es:[fhandle]
int 21h

mov ax,4c00h
int 21h

_openfErr:
mov ax,data
mov ds,ax
mov es,ax
mov ah,9
mov al,0
mov dx,offset errinfo
int 21h
__getkey:
mov ah,0
int 16h
cmp al,1ch
jnz __getkey
mov ah,4ch
int 21h



code ends
end start