.386p


Kernel Segment public para use32
assume cs:Kernel


__kCom2Proc proc
pushad
push ds
push es

comment *
mov ebp,esp
add ebp,32
push dword ptr ICW2_MASTER_INT_NO + 3
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kCom2KernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kCom2ShowExpInfo
_kCom2KernelModeInt:
push dword ptr 0
push dword ptr 0
_kCom2ShowExpInfo:
call  __exceptionInfo
add esp,28
*

mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx+_kCom2Proc],0
jz _kcom2ProcEnd

call dword ptr ds:[ebx+_kCom2Proc]

_kcom2ProcEnd:
mov al,20h
out 20h,al

pop es
pop ds
popad
iretd
__kCom2Proc endp

Kernel ends