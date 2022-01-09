.386p



Kernel Segment public para use32
assume cs:Kernel


__kParallelProc proc
pushad

mov ebp,esp
add ebp,32
push dword ptr ICW2_MASTER_INT_NO + 7
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kParallelKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kParallelShowExpInfo
_kParallelKernelModeInt:
push dword ptr 0
push dword ptr 0
_kParallelShowExpInfo:
call  __exceptionInfo
add esp,28

mov al,20h
out 20h,al

popad
iretd
__kParallelProc endp

Kernel ends