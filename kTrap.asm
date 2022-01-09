.386p

include kDebugger.asm

Kernel Segment public para use32
assume cs:Kernel

;32位堆栈压入32位，即使只有一个字节
;exception stack:
;1 error code(if has)
;2 ip
;3 cs
;4 eflags
;5 esp
;6 ss
align 10h
__tDivExceptionProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tDivExceptionProcEnd
push dword ptr 0
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tDivExceptionProcEnd


mov ebp,esp
add ebp,32

push dword ptr 0
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kDivExpKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kDivExpShowExpInfo
_kDivExpKernelModeInt:
push dword ptr 0
push dword ptr 0
_kDivExpShowExpInfo:
call  __exceptionInfo
add esp,28
mov ebp,esp

__tDivExceptionProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tDivExceptionProc endp









align 10h
__tNmiProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tNmiProcEnd
push dword ptr 2
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tNmiProcEnd

mov ebp,esp
add ebp,32

push dword ptr 2
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kNmiKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kNmiShowExpInfo
_kNmiKernelModeInt:
push dword ptr 0
push dword ptr 0
_kNmiShowExpInfo:
call  __exceptionInfo
add esp,28

__tNmiProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tNmiProc endp









align 10h
__tOverFlowProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tOverFlowProcEnd
push dword ptr 4
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tOverFlowProcEnd

mov ebp,esp
add ebp,32

push dword ptr 4
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktOverflowKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktOverflowShowExpInfo
_ktOverflowKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktOverflowShowExpInfo:
call  __exceptionInfo
add esp,28

__tOverFlowProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tOverFlowProc endp




align 10h
__tBoundErrProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tBoundErrProcEnd
push dword ptr 5
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tBoundErrProcEnd

mov ebp,esp
add ebp,32

push dword ptr 5
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktBoundErrKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktBoundErrShowExpInfo
_ktBoundErrKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktBoundErrShowExpInfo:
call  __exceptionInfo
add esp,28

__tBoundErrProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tBoundErrProc endp




align 10h
__tUnlawfulOpcodeProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tUnlawfulOpcodeProcEnd
push dword ptr 6
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tUnlawfulOpcodeProcEnd

mov ebp,esp
add ebp,32

push dword ptr 6
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]

test dword ptr [ebp + 4],3
jz _ktUnlawOpcodeKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktUnlawOpcodeShowExpInfo
_ktUnlawOpcodeKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktUnlawOpcodeShowExpInfo:
call  __exceptionInfo
add esp,28

__tUnlawfulOpcodeProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tUnlawfulOpcodeProc endp




align 10h
__tNoneCoprocessorProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4

cmp dword ptr ds:[ebx + offset _kCoprocessor],0
jz __tNoneCoprocessorProcEnd
call dword ptr ds:[ebx + offset _kCoprocessor]
jmp __tNoneCoprocessorProcEnd


cmp dword ptr ds:[ebx + _kException],0
jz __tNoneCoprocessorProcEnd
push dword ptr 7
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tNoneCoprocessorProcEnd

mov ebp,esp
add ebp,32

push dword ptr 7
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktNCorprocKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktNCorprocShowExpInfo
_ktNCorprocKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktNCorprocShowExpInfo:
call  __exceptionInfo
add esp,28

__tNoneCoprocessorProcEnd:
;in al,0f0h
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tNoneCoprocessorProc endp




;exception with error code need to pop error code,then iretd
align 10h
__tDoubleFaultProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tDoubleFaultProcEnd
push dword ptr 8
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tDoubleFaultProcEnd

mov ebp,esp
add ebp,32

push dword ptr 8
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]

test dword ptr [ebp + 8],3
jz _ktDoubleFKernelModeInt
push dword ptr [ebp + 16]
push dword ptr [ebp + 20]
jmp _ktDoubleFShowExpInfo
_ktDoubleFKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktDoubleFShowExpInfo:
call  __exceptionInfo
add esp,28

__tDoubleFaultProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd
__tDoubleFaultProc endp




align 10h
__tCoprocessorBoundProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tCoprocessorBoundProcEnd
push dword ptr 09h
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tCoprocessorBoundProcEnd

mov ebp,esp
add ebp,32

push dword ptr 9
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktCorprocBKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktCorprocBShowExpInfo
_ktCorprocBKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktCorprocBShowExpInfo:
call  __exceptionInfo
add esp,28

__tCoprocessorBoundProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tCoprocessorBoundProc endp




align 10h
__tInvalidTssProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tInvalidTssProcEnd
push dword ptr 0ah
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tInvalidTssProcEnd

mov ebp,esp
add ebp,32

push dword ptr 0ah
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]

test dword ptr [ebp + 8],3
jz _ktInvalidTssKernelModeInt
push dword ptr [ebp + 16]
push dword ptr [ebp + 20]
jmp _ktInvalidTssShowExpInfo
_ktInvalidTssKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktInvalidTssShowExpInfo:
call  __exceptionInfo
add esp,28

__tInvalidTssProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd
;task gate entry
jmp __tInvalidTssProc
__tInvalidTssProc endp




align 10h
__tSegNonePresentProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tSegNonePresentProcEnd
push dword ptr 0bh
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tSegNonePresentProcEnd

mov ebp,esp
add ebp,32

push dword ptr 0bh
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]

test dword ptr [ebp + 8],3
jz _ktSegNonePKernelModeInt
push dword ptr [ebp + 16]
push dword ptr [ebp + 20]
jmp _ktSegNonePShowExpInfo
_ktSegNonePKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktSegNonePShowExpInfo:
call  __exceptionInfo
add esp,28

__tSegNonePresentProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd
__tSegNonePresentProc endp




align 10h
__tStackSegErrProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tStackSegErrProcEnd
push dword ptr 0ch
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tStackSegErrProcEnd

mov ebp,esp
add ebp,32

push dword ptr 0ch
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]

test dword ptr [ebp + 8],3
jz _ktStackSegErrKernelModeInt
push dword ptr [ebp + 16]
push dword ptr [ebp + 20]
jmp _ktStackSegErrShowExpInfo
_ktStackSegErrKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktStackSegErrShowExpInfo:
call  __exceptionInfo
add esp,28

__tStackSegErrProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd
__tStackSegErrProc endp




align 10h
__tGPProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tGPProcEnd
push dword ptr 0dh
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tGPProcEnd

mov ax,rwData32Seg
mov ds,ax
cmp dword ptr ds:[GP_EXEPTION_SHOW_TOTAL],5
ja __tGPProcEnd

inc dword ptr ds:[GP_EXEPTION_SHOW_TOTAL]

mov ebp,esp
add ebp,36

push dword ptr 0dh
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]

test dword ptr [ebp + 8],3
jz _ktGPKernelModeInt
push dword ptr [ebp + 16]
push dword ptr [ebp + 20]
jmp _ktGPShowExpInfo
_ktGPKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktGPShowExpInfo:
call  __exceptionInfo
add esp,28

__tGPProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd
__tGPProc endp




align 10h
__tPageFaultProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tPageFaultProcEnd
push dword ptr 0eh
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tPageFaultProcEnd

mov ebp,esp
add ebp,32

push dword ptr 0eh
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]

test dword ptr [ebp + 8],3
jz _ktPageFKernelModeInt
push dword ptr [ebp + 16]
push dword ptr [ebp + 20]
jmp _ktPageFShowExpInfo
_ktPageFKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktPageFShowExpInfo:
call  __exceptionInfo
add esp,28

__tPageFaultProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd
__tPageFaultProc endp




align 10h
__tFpuFaultProc proc 
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4

cmp dword ptr ds:[ebx + offset _kCoprocessor],0
jz __tFpuFaultProcEnd
call dword ptr ds:[ebx + offset _kCoprocessor]
jmp __tFpuFaultProcEnd

cmp dword ptr ds:[ebx + _kException],0
jz __tFpuFaultProcEnd
push dword ptr 10h
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tFpuFaultProcEnd

mov ebp,esp
add ebp,32

push dword ptr 010h
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktFPUFKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktFPUFShowExpInfo
_ktFPUFKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktFPUFShowExpInfo:
call  __exceptionInfo
add esp,28

__tFpuFaultProcEnd:

in al,0f0h
;clts
;wait
;finit
;FNCLEX

pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tFpuFaultProc endp




align 10h
__tAlignmentCheckErrProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tAlignmentCheckErrProcEnd
push dword ptr 11h
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tAlignmentCheckErrProcEnd

mov ebp,esp
add ebp,32

push dword ptr 11h
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]
push dword ptr [ebp + 12]

test dword ptr [ebp + 8],3
jz _ktAlignCEKernelModeInt
push dword ptr [ebp + 16]
push dword ptr [ebp + 20]
jmp _ktAlignCEShowExpInfo
_ktAlignCEKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktAlignCEShowExpInfo:
call  __exceptionInfo
add esp,28

__tAlignmentCheckErrProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd
__tAlignmentCheckErrProc endp




align 10h
__tMachineCheckErrProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tMachineCheckErrProcEnd
push dword ptr 12h
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tMachineCheckErrProcEnd

mov ebp,esp
add ebp,32

push dword ptr 12h
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktMCEKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktMCEShowExpInfo
_ktMCEKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktMCEShowExpInfo:
call  __exceptionInfo
add esp,28

__tMachineCheckErrProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tMachineCheckErrProc endp




align 10h
__tSimdFaultProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tSimdFaultProcEnd
push dword ptr 13h
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tSimdFaultProcEnd

mov ebp,esp
add ebp,32

push dword ptr 13h
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktSimDKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktSimDShowExpInfo
_ktSimDKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktSimDShowExpInfo:
call  __exceptionInfo
add esp,28

__tSimdFaultProcEnd:

pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tSimdFaultProc endp




align 10h
__tVirtualErrorProc proc
pushad
push ds
push es 
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + _kException],0
jz __tVirtualErrorProcEnd
push dword ptr 14h
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __tVirtualErrorProcEnd

mov ebp,esp
add ebp,32

push dword ptr 14h
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktVEKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktVEShowExpInfo
_ktVEKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktVEShowExpInfo:
call  __exceptionInfo
add esp,28

__tVirtualErrorProcEnd:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__tVirtualErrorProc endp
Kernel ends
