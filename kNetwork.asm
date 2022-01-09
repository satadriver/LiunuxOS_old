.386p
.386p



Kernel Segment public para use32
assume cs:Kernel


__kNetworkProc proc
pushad

mov ebp,esp
add ebp,32
push dword ptr ICW2_SLAVE_INT_NO + 1
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kNetworkKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kNetworkShowExpInfo
_kNetworkKernelModeInt:
push dword ptr 0
push dword ptr 0
_kNetworkShowExpInfo:
call  __exceptionInfo
add esp,28

mov al,20h
out 0a0h,al
out 20h,al

popad
iretd
__kNetworkProc endp

Kernel ends
