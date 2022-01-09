.386p
.model Tiny

MBR_BUFFER_SEG 		EQU 6000H
NEWMBR_BUFFER_SEG 	EQU 6200H
FLAG_SECTOR_SEG		EQU 6400H
FONT_SECTOR_SEG		EQU 6600H
LOADER_BUFFER_SEG 	EQU 7000H
KERNEL_BUFFER_SEG	EQU 8000h

SETUP_SECTOR_LIMIT	EQU 1000H
INSTALL_FLAG		EQU 00474a4ch

BAKMBR_SECTOR_OFFSET	EQU 1
BAKMBR2_SECTOR_OFFSET	EQU 2
FONT_SECTOR_OFFSET		EQU 3
LOADER_SECTOR_OFFSET	EQU 5
SECTOR_SIZE				equ 512

;FLAG_SECTOR_NO		EQU 16
;BAKMBR_SECTOR_NO	EQU (FLAG_SECTOR_NO + 1)
;BAKMBR2_SECTOR_NO	EQU (FLAG_SECTOR_NO + 2)
;LOADER_SECTOR_NO	EQU (FLAG_SECTOR_NO + 3)

code segment para use16
assume cs:code
start:

;find empty sectors
mov dword ptr cs:[freesecno],6
_readnextsec:
inc dword ptr cs:[freesecno]
cmp dword ptr cs:[freesecno],SETUP_SECTOR_LIMIT
jae _notFound
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov eax,KERNEL_BUFFER_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
;read once 7f=127 sectors mostly
mov word ptr cs:[seccnt],128
mov eax,dword ptr cs:[freesecno]
mov dword ptr cs:[secofflow],eax
mov dword ptr cs:[secoffhigh],0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,42h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr
mov ax,KERNEL_BUFFER_SEG
mov ds,ax
mov eax,dword ptr ds:[0]
cmp eax,INSTALL_FLAG
jnz _checkbytes

mov word ptr cs:[existflag],1
jmp _findOK

_checkbytes:
cld
mov ecx,8000h
mov esi,0
mov ax,KERNEL_BUFFER_SEG
mov ds,ax
_checkzero:
lodsw
cmp ax,0
jnz _readnextsec
loop _checkzero

_findOK:
mov eax,cs:[freesecno]
call __i2strhex
mov ax,cs
mov ds,ax
mov ax,900h
lea dx,showinfo
int 21h

;read files
lea bx,mbr_filename
mov si,NEWMBR_BUFFER_SEG
call __readFile
cmp ax,0
jz _readFileErr
mov cs:[newmbrfs],ax

lea bx,loader_fn
mov si,LOADER_BUFFER_SEG
call __readFile
cmp ax,0
jz _readFileErr
mov cs:[loaderfs],ax

lea bx,kernel_fn
mov si,KERNEL_BUFFER_SEG
call __readFile
cmp ax,0
jz _readFileErr
mov cs:[kernelfs],ax

lea bx,font_fn
mov si,FONT_SECTOR_SEG
call __readFile
cmp ax,0
jz _readFileErr
mov cs:[fontfs],ax

;make first info sector
MOV ax,FLAG_SECTOR_SEG
mov es,ax
mov al,'L'
mov bx,0
mov byte ptr es:[bx],al
mov al,'J'
mov byte ptr es:[bx+1],al
mov al,'G'
mov byte ptr es:[bx+2],al
mov al,0
mov byte ptr es:[bx+3],al

mov ax,cs:[loaderfs]
mov dx,0
mov cx,SECTOR_SIZE
div cx
cmp dx,0
jz _lseccnt
inc ax
_lseccnt:
mov word ptr es:[bx + 4],ax
mov word ptr cs:[loadersc],ax
mov eax,cs:[freesecno]
add eax,LOADER_SECTOR_OFFSET
mov dword ptr es:[bx + 6],eax

mov ax,cs:[kernelfs]
mov dx,0
mov cx,SECTOR_SIZE
div cx
cmp dx,0
jz _kseccnt
inc ax
_kseccnt:
mov word ptr es:[bx + 10],ax
mov word ptr cs:[kernelsc],ax
movzx eax,word ptr es:[bx + 4]
add eax,dword ptr es:[bx + 6]
mov dword ptr es:[bx + 12],eax
mov cs:[kernelsn],eax

mov eax,cs:[freesecno]
add eax,BAKMBR_SECTOR_OFFSET
mov dword ptr es:[bx + 16],eax
mov eax,cs:[freesecno]
add eax,BAKMBR2_SECTOR_OFFSET
mov dword ptr es:[bx + 20],eax

mov eax,cs:[freesecno]
add eax,FONT_SECTOR_OFFSET
mov dword ptr es:[bx + 26],eax
mov eax,2
mov dword ptr es:[bx + 24],eax

;write info sector
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov word ptr cs:[seccnt],1
mov eax,FLAG_SECTOR_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov eax,cs:[freesecno]
mov dword ptr cs:[secofflow],eax
mov dword ptr cs:[secoffhigh],0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,43h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr


;read mbr
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov word ptr cs:[seccnt],1
mov eax,MBR_BUFFER_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov dword ptr cs:[secofflow],0
mov dword ptr cs:[secoffhigh],0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,42h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr

;mov ax,MBR_BUFFER_SEG
;mov ds,ax
;mov ax,NEWMBR_BUFFER_SEG
;mov es,ax
;mov si,0
;mov di,0
;mov cx,cs:[newmbrfs]
;cld
;rep cmpsb
;jz _writeMyMbr
cmp word ptr cs:[existflag],1
jz _writeMyMbr


;write mbr into bak
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov word ptr cs:[seccnt],1
mov eax,MBR_BUFFER_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov eax,cs:[freesecno]
add eax,BAKMBR_SECTOR_OFFSET
mov dword ptr cs:[secofflow],eax
mov dword ptr cs:[secoffhigh] ,0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,43h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr

;write mbr into bak2
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov word ptr cs:[seccnt],1
mov eax,MBR_BUFFER_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov eax,cs:[freesecno]
add eax,BAKMBR2_SECTOR_OFFSET
mov dword ptr cs:[secofflow],eax
mov dword ptr cs:[secoffhigh] ,0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,43h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr


_writeMyMbr:
;copy hpt and write my mbr into mbr
mov ax,NEWMBR_BUFFER_SEG
mov es,ax
mov ax,MBR_BUFFER_SEG
mov ds,ax
mov di,1bah
mov eax,cs:[freesecno]
stosd
mov si,1beh
mov cx,66
cld
rep movsb

mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov word ptr cs:[seccnt],1
mov eax,NEWMBR_BUFFER_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov dword ptr cs:[secofflow],0
mov dword ptr cs:[secoffhigh] ,0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,43h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr


;write font into sectors
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov ax,2
mov word ptr cs:[seccnt],ax
mov eax,FONT_SECTOR_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov eax,cs:[freesecno]
add eax,FONT_SECTOR_OFFSET
mov dword ptr cs:[secofflow],eax
mov dword ptr cs:[secoffhigh] ,0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,43h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr

;write loader into sectors
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov ax,cs:[loadersc]
mov word ptr cs:[seccnt],ax
mov eax,LOADER_BUFFER_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov eax,cs:[freesecno]
add eax,LOADER_SECTOR_OFFSET
mov dword ptr cs:[secofflow],eax
mov dword ptr cs:[secoffhigh] ,0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,43h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr

;write kernel into sectors
mov byte ptr cs:[patlen],10h
mov byte ptr cs:[reserved],0
mov ax,cs:[kernelsc]
mov word ptr cs:[seccnt],ax
mov eax,KERNEL_BUFFER_SEG
shl eax,16
mov ax,0
mov cs:[segoff],eax
mov eax,cs:[kernelsn]
mov dword ptr cs:[secofflow],eax
mov dword ptr cs:[secoffhigh] ,0
mov ax,cs
mov ds,ax
lea si,patlen
mov ah,43h
mov al,0
mov dx,80h
int 13h
cmp ah,0
jnz _rwerr

_installEnd:
mov ax,cs
mov ds,ax
mov ax,900h
lea dx ,okinfo
int 21h
MOV AH,4CH
INT 21H

_rwerr:
mov ax,cs
mov ds,ax
mov ax,900h
lea dx ,rwSectorErr
int 21h
MOV AH,4CH
INT 21H

_readFileErr:
mov ax,cs
mov ds,ax
mov ax,900h
lea dx ,readFileErr
int 21h
MOV AH,4CH
INT 21H

_notFound:
mov ax,cs
mov ds,ax
mov ax,900h
lea dx ,notFoundErr
int 21h
MOV AH,4CH
INT 21H



__readFile proc near
mov ax,cs
mov ds,ax

mov ax,3d00h
mov dx,bx
int 21h
cmp ax,0
jbe _readerror

mov ds:[handle],ax
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov cs:[filesize],ax
mov cs:[fileSizeHigh],dx

mov ax,4200h
mov bx,ds:[handle]
mov cx,0
mov dx,0
int 21h

mov ax,si
mov ds,ax

mov ax,3f00h
mov bx,cs:[handle]
mov cx,cs:[filesize]
mov dx,0
int 21h

mov ax,3e00h
mov bx,cs:[handle]
int 21h

mov ax,cs:[filesize]
ret

_readerror:
mov ax,0
ret
__readFile endp



__ch2strhex proc
cmp al,9
jae _ch2str
add al,30h
ret
_ch2str:
add al,55
ret 
mov byte ptr cs:[digitbuf + 1],al
__ch2strhex endp


__i2strhex proc near
mov edx,eax
shr eax,28
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf],al

mov eax,edx
shr eax,24
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf+1],al

mov eax,edx
shr eax,20
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf+2],al

mov eax,edx
shr eax,16
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf+3],al

mov eax,edx
shr eax,12
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf+4],al

mov eax,edx
shr eax,8
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf+5],al

mov eax,edx
shr eax,4
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf+6],al

mov eax,edx
shr eax,0
and al,0fh
call __ch2strhex
mov byte ptr cs:[digitbuf+7],al

ret
__i2strhex endp


existflag		dw 0
fontfs			dw 0
fontsc			dw 0
kernelsn		dd 0
newmbrfs		dw 0
kernelsc		dw 0
kernelfs		dw 0
loadersc		dw 0
loaderfs		dw 0
fileSizeHigh	dw 0
filesize 		dw 0
handle 			dw 0
freesecno		dd 0
mbr_filename 	db 'mbr.com',0
loader_fn		db 'loader.com',0
kernel_fn		db 'kernel.exe',0
font_fn			db 'font.db',0
kerneldll_fn	db 'kernel.dll',0
maindll_fn		db 'main.dll',0
flagstr 		db 'LJG',0

okinfo			db 'write ok$',0dh,0ah,'$',0
readFileErr		db 'read file error$',0dh,0ah,'$',0
notFoundErr 	db 'not found sectors to write$',0dh,0ah,'$',0
rwSectorErr		db 'read or write sector error$',0dh,0ah,'$',0
showinfo		db 'get start sector:0x'
digitbuf		db 8 dup (0)
digitend		db 0dh,0ah,'$',0

align 		16
patlen 		db 0
reserved 	db 0
seccnt 		dw 0
segoff		dd 0
secofflow 	dd 0
secoffhigh 	dd 0

code ends

end start