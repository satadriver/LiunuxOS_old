.386p

Kernel Segment public para use32
assume cs:Kernel

__kAudioProc proc
pushad
push ds
push es
mov ax,rwData32Seg
mov ds,ax
mov es,ax

jmp _kaudioProcIoe

mov ebp,esp
add ebp,32
push dword ptr ICW2_MASTER_INT_NO + 5
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kaudioKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kaudioShowExpInfo
_kaudioKernelModeInt:
push dword ptr 0
push dword ptr 0
_kaudioShowExpInfo:
call  __exceptionInfo
add esp,28

_kaudioProcIoe:
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + offset _kSoundCardInt],0
jz _kaudioProcEnd

call dword ptr ds:[ebx + offset _kSoundCardInt]

_kaudioProcEnd:
mov al,20h
out 20h,al

pop es
pop ds
popad
iretd
__kAudioProc endp

Kernel ends

