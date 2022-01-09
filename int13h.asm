.386p

KERNEL segment public para use32
assume cs:KERNEL

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

mov ax,rwData32Seg
mov ds,ax
mov es,ax

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

;clts

mov eax,cr3
and eax,7fffffffh
mov cr3,eax
jmp _int13CloseCr3

_int13CloseCr3:
db 0eah
dd offset __int13Pm16Entry
dw reCode16Seg

_int13SwitchCode32Seg:
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
mov esi,INT13_RM_FILEBUF_ADDR
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


kernel ends





Kernel16 Segment public para use16
assume cs:Kernel16

__int13Pm16Entry proc
mov ax,rwData16Seg
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov gs,ax
mov esp,BIT16_STACK_TOP
mov ebp,esp

mov eax,0
;mov cr4,eax
db 0fh,22h,0e0h

;不能从32位代码段返回实模式,而只能从16位代码段返回
;对于normal的描述符，其最重要是段界限一定要设置为0ffffh，如果不是这样，那在由保护模式跳转到实模式后会发生错误
;可以从16位实模式直接跳转32位保护模式
mov eax,cr0
and eax,0fffffffeh
mov cr0,eax

db 0eah
dw offset _int13RmReadSectors
dw KERNEL16

_int13RmReadSectors:
mov eax,kernelData
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov esp,BIT16_STACK_TOP
mov ebp,esp

;sidt fword ptr ds:[idtReg]

;lgdt fword ptr ds:[_rmGdtReg]
;lidt fword ptr ds:[_rmModeIdtReg]
;jmp _testover

sub esp,40h
mov byte ptr ss:[esp],10h
mov byte ptr ss:[esp + 1],0
mov ax, word ptr ds:[_sectorCount]
mov word ptr ss:[esp + 2],ax
mov eax,INT13_RM_FILEBUF_SEG
shl eax,16
mov ax,0
mov ss:[esp + 4],eax
mov eax, dword ptr ds:[_sectorNumber]
mov dword ptr ss:[esp + 8],eax
mov dword ptr ss:[esp + 12] ,0
mov ax,ss
mov ds,ax
mov esi,esp
mov ax,4200h
mov dx,80h
int 13h
cmp ah,0
jnz _int13readSectorErr
mov eax,kernelData
mov ds,ax
mov es,ax
mov edx,es:[_sectorCount]
mov dword ptr ds:[_int13Result],edx
jmp _toint13Pm32
_int13readSectorErr:
mov eax,kernelData
mov ds,ax
mov es,ax
mov edx,0
mov dword ptr ds:[_int13Result],edx
_toint13Pm32:

;sidt fword ptr ds:[_rmModeIdtReg]

;_testover:
;lgdt fword ptr ds:[gdtReg]
;lidt fword ptr ds:[idtReg]

;进入保护模式之前必须使cr4为0
;must set cr4 to 0
mov eax,0
;mov cr4,eax
db 0fh,22h,0e0h

mov eax,cr0
or eax,1
mov cr0,eax

;跳过16位保护模式,直接进入32位保护模式
db 0eah
dw (offset _int13SwitchCode32Seg - offset __int13hProc)
dw int13CodeSeg
__int13Pm16Entry endp
KERNEL16 ends