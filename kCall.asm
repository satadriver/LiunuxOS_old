.386p

Kernel Segment public para use32
assume cs:Kernel

;useless function
__callGateEntry proc
pushad
push ds
push es

mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kCallGateProc],0
jz __callGateExit
call dword ptr ds:[ebx + _kCallGateProc]

__callGateExit:
pop es
pop ds
popad
ret
__callGateEntry endp

Kernel ends