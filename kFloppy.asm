;.386p


;interrupption 46h
Kernel Segment public para use32
assume cs:Kernel

__kFloppyProc proc
pushad
test dword ptr ss:[esp + 40],20000h
jz _floppyintrNotV86

mov edi,1

_floppyintrNotV86:

push ds
push es

mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebx,kernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kFloppyIntrProc],0
jz _flopppyIntrEnd

call dword ptr ds:[ebx + _kFloppyIntrProc]

jmp _flopppyIntrEnd

mov ebp,esp
add ebp,32
push dword ptr ICW2_MASTER_INT_NO + 6
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kFloppyKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kFloppyShowExpInfo
_kFloppyKernelModeInt:
push dword ptr 0
push dword ptr 0
_kFloppyShowExpInfo:
call  __exceptionInfo
add esp,28

_flopppyIntrEnd:
mov al,20h
out 20h,al

cmp edi,1
jz _floppyV86NotSetSeg

pop es
pop ds
jmp _v86PopRet

_floppyV86NotSetSeg:
add esp,8

_v86PopRet:
popad
iretd
__kFloppyProc endp

Kernel ends
