.386p

include tss.inc
include pe.h

PDE_ENTRY_VALUE equ 20000h
REALMODE_FILEBUF_ADDR equ 8000h
reCode32Seg equ 20h
reCode16Seg equ 30h
rwData32Seg	equ 40h
int13CodeSeg equ 50h
kerneldata segment 

idtReg df 0


_sectorNumber		dd 0
_sectorCount		dd 0
_fileBuffer			dd 0
_fileBufferSize		dd 0
_int13ESP			dd 0
_int13SS			dd 0
_int13Result		dd 0

HdPciPortBuf db 1024 dup (0)
HdSlaveFlag db 0
HdPortBase dw 0
AscHdPortBase dd 0

MultiModeSecNum db 256 dup (0)
ParamBuf db 1024 dup (0)
AscHdSlaveFlag dd 0
MsgHdPortBase dd 0
SataFlag db 0
BmHdPortBase dw 0
hdintlinepin dd 0
kerneldata ends


kernel2 segment 
HdPciPortBuf1 db 1024 dup (0)
HdSlaveFlag2 db 0
HdPortBase3 dd 0
AscHdPortBase4 dd 0
kernel2 ends



code segment public para use32

assume cs:code

start:
mov eax,offset _test2
sub eax,offset _test1

db 0eah
dw offset _test2 - offset _test1
dw 20h


_test1:
mov eax,3

mov edx,2
mov ecx,4
mov edx,20
mov ecx,21

_test2:




align 10h
;param:edi->secno,edi+4->seccnt,edi+8->buf,edi + 12->bufsize
__int13hProc proc
cli
pushad
push ds
push es
push fs
push gs
push ss

mov ebx,kernelData
shl ebx,4
mov eax,ds:[edi]
mov dword ptr ds:[ebx + _sectorNumber],eax
mov eax,ds:[edi + 4]
mov dword ptr ds:[ebx + _sectorCount],eax
mov eax,ds:[edi + 8]
mov dword ptr ds:[ebx + _fileBuffer],eax
mov eax,ds:[edi +12]
mov dword ptr ds:[ebx + _fileBufferSize],eax
mov eax,esp
mov dword ptr ds:[ebx + _int13ESP],eax
mov eax,ss
mov dword ptr ds:[ebx + _int13SS],eax

mov eax,cr3
and eax,7fffffffh
mov cr3,eax
jmp _int13CloseCr3

_int13CloseCr3:
mov eax,cr0
and eax,0fffffffeh
mov cr0,eax

;不能从32位代码段返回实模式,而只能从16位代码段返回
;对于normal的描述符，其最重要是段界限一定要设置为0ffffh，如果不是这样，那莫在由保护模式跳转到实模式后会发生错误
;可以从16位实模式直接跳转32位保护模式
db 0eah
dd offset __int13Pm16Entry
dw reCode16Seg

_int13Pm32Entry:
mov eax,kernelData
mov ds,ax
mov es,ax
mov ss,ax

lidt fword ptr ds:[idtReg]

;进入保护模式之前必须使cr4为0
;must set cr4 to 0
mov eax,0
;mov cr4,eax
db 0fh,22h,0e0h

mov eax,cr0
or al,1
mov cr0,eax

;跳过16位保护模式,直接进入32位保护模式
db 0eah
dw offset _int13SwitchCode32Seg
dw int13CodeSeg

_int13SwitchCode32Seg:
					db 0eah
__int13RetPm32EIP	dd 0
					dw reCode32Seg

_int13RetPm32:
mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,kernelData
shl ebx,4
mov esp,ds:[ebx + _int13ESP]
mov ss,word ptr ds:[ebx + _int13SS]

mov eax,PDE_ENTRY_VALUE
mov cr3,eax

mov eax,cr0
or eax,80000000h
mov cr0,eax
jmp _int13ReflushPage

_int13ReflushPage:
mov ecx,ds:[ebx + _int13Result]
shl ecx,9
mov edi,ds:[ebx + _fileBuffer]
mov esi,REALMODE_FILEBUF_ADDR
cld
rep movsb

pop ss
pop gs
pop fs
pop es
pop ds
popad
sti
iretd
jmp __int13hProc
__int13hProc endp



__int13Pm16Entry:


mov eax,offset AscHdPortBase4
mov eax,offset AscHdPortBase
mov ax,5000h
mov ds,ax
mov es,ax

mov dx,0d006h
mov al,0e0h
out dx,al

mov dx,0d002h
mov al,1
out dx,al

mov dx,0d001h
mov al,0
out dx,al

mov dx,0d007h
mov al,0ech
out dx,al

mov ecx,1000h
in al,dx


mov edi,0
mov ecx,100h
rep insw



mov dx,0d006h
mov al,0f0h
out dx,al

mov dx,0d002h
mov al,1
out dx,al

mov dx,0d001h
mov al,0
out dx,al

mov dx,0d007h
mov al,0ech
out dx,al

in al,dx
mov edi,0
mov ecx,100h
rep insw






mov dx,0d00eh
mov al,0e0h
out dx,al

mov dx,0d00ah
mov al,1
out dx,al

mov dx,0d009h
mov al,0
out dx,al

mov dx,0d00fh
mov al,0ech
out dx,al

in al,dx
mov edi,0
mov ecx,100h
rep insw



mov dx,0d00eh
mov al,0f0h
out dx,al

mov dx,0d00ah
mov al,1
out dx,al

mov dx,0d009h
mov al,0
out dx,al

mov dx,0d00fh
mov al,0ech
out dx,al

in al,dx
mov edi,0
mov ecx,100h
rep insw


;call GetHdPortBase
mov ah,4ch
int 21h






code ends
end start

