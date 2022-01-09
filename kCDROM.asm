.386p


Kernel Segment public para use32
assume cs:Kernel


__kCDROMProc proc
pushad
push ds
push es
mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebp,esp
add ebp,32

push dword ptr ICW2_SLAVE_INT_NO + 7
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kCdromKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kCdromShowExpInfo
_kCdromKernelModeInt:
push dword ptr 0
push dword ptr 0
_kCdromShowExpInfo:
call  __exceptionInfo
add esp,28

;bit2 =1,reset controller
;bit1 =1,disable interrupt 0x0e;bit1 = 0,enable interrupt 0x0e
mov dx,376h
in al,dx
mov al,0
out dx,al

mov al,20h
out 20h,al
out 0a0h,al

pop es
pop ds
popad
iretd
__kCDROMProc endp

Kernel ends
