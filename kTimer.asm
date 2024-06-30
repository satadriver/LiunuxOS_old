.386p

include descriptor.asm




Kernel Segment public para use32
assume cs:Kernel

align 10h
__iSystemTimerProc proc
pushad
push ds
push es
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax
MOV FS,ax
MOV GS,AX

mov ebx,kernelData
shl ebx,4

;1.1931816MHZ = 1193181.6hz

cmp dword ptr ds:[ebx + _kScreenProtect],0
jz _timer0CheckTaskCounter
call dword ptr ds:[ebx + _kScreenProtect]
_timer0CheckTaskCounter:

cmp dword ptr ds:[ebx + _kTaskSchedule],0
jz _sysTimerEnd

push esp
mov eax,dword ptr ds:[ebx + _kTaskSchedule]
call eax
add esp,4

IFDEF SINGLE_TASK_TSS
mov eax,ds:[CURRENT_TASK_TSS_BASE + TASKSTATESEG.mCr3]
mov cr3,eax
ENDIF

mov al,20h
out 20h,al

pop ss
pop gs
pop fs
pop es
pop ds
popad

IFDEF SINGLE_TASK_TSS
mov esp,ss:[esp - 20]
ENDIF

iretd
jmp __iSystemTimerProc

_sysTimerEnd:
mov al,20h
out 20h,al
pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
jmp __iSystemTimerProc

__iSystemTimerProc endp




_timerShowInfo proc
mov ebp,esp
add ebp,32
push dword ptr ICW2_MASTER_INT_NO + 0
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp+4],3
jz _kTimerKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kTimerShowExpInfo
_kTimerKernelModeInt:
push dword ptr 0
push dword ptr 0
_kTimerShowExpInfo:
call  __exceptionInfo
add esp,28
mov ebp,esp
ret
_timerShowInfo endp



;32 bit
;iretd 	== cf
;iret	== 66cf
;iretf	== 66cf
;retd	== 66 cb
;ret	== c3
;ret 8	== c2 08 00
;retn	== c3
;retf	== cb

;16 bit
;iretd 	== 66 cf
;iret 	== cf
;iretf 	== cf
;retd 	== 66 cb
;ret 	== c3
;ret 8 	== c2 08 00
;retn 	== c3
;retf 	== cb

Kernel ends
