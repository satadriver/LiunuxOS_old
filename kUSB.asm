;.386p



Kernel Segment public para use32
assume cs:Kernel

__kUSBProc proc
pushad
push ds
push es
mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebp,esp
add ebp,32
push dword ptr ICW2_SLAVE_INT_NO + 2
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp+4],3
jz _kusbKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kusbShowExpInfo
_kusbKernelModeInt:
push dword ptr 0
push dword ptr 0
_kusbShowExpInfo:
call  __exceptionInfo
add esp,28

mov al,20h
out 0a0h,al
out 20h,al

pop es
pop ds
popad
iretd
__kUSBProc endp

Kernel ends
