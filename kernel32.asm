.686p

include kutils.asm
include kdevice32.asm
include kintr.asm
include kpower.asm
include kvideo.asm
include kmemory.asm

include kdloader.asm


Kernel32 Segment public para use32
assume cs:Kernel32

__kernel32Entry proc
mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,0
mov ecx,0
mov edx,0
mov ebx,0
mov esi,0
mov edi,0
mov esp,KERNEL_TASK_STACK_TOP
mov ebp,esp

mov ebx,kernelData
shl ebx,4

;db 0fh,20h,0e0h
;or eax,1			;vme
;or eax,40600h		;OSFXSR(bit9) and OSXMMEXCPT(bit10) and OSXSAVE(bit18)
;db 0fh,22h,0e0h

;如果启动分页机制,在tss中必须传递cr3
;call __startPage

;call __initCmosTimerTss

;call __initSysTimerTss

;CALL __initV86Tss

comment *

;注意类型定义和变量定义寻址的不同，类型定义的成员寻址是相对于定义的偏移，变量成员的寻址是变量的实际地址加上成员的偏移地址
mov ecx,SYSTEM_TSS_SIZE
mov edi,CURRENT_TASK_TSS_BASE
mov al,0
cld
rep stosb

mov word ptr ds:[CURRENT_TASK_TSS_BASE + TASKSTATESEG.mIomap],136
mov byte ptr ds:[CURRENT_TASK_TSS_BASE + TASKSTATESEG.mIomapEnd + 32 + 8192],0ffh
MOV dword ptr ds:[CURRENT_TASK_TSS_BASE + TASKSTATESEG.mEsp0],TASKS_STACK0_BASE + TASK_STACK0_SIZE - STACK_TOP_DUMMY
MOV dword ptr ds:[CURRENT_TASK_TSS_BASE + TASKSTATESEG.mSS0],rwData32Seg	;stackTssSeg
mov dword ptr ds:[CURRENT_TASK_TSS_BASE + TASKSTATESEG.mCr3],PDE_ENTRY_VALUE

mov eax,CURRENT_TASK_TSS_BASE
mov word ptr ds:[ebx + kTssDescriptor + 2],ax
shr eax,16
mov byte ptr ds:[ebx + kTssDescriptor + 4],al
mov byte ptr ds:[ebx + kTssDescriptor + 7],ah

mov word ptr ds:[ebx + kTssDescriptor ],SYSTEM_TSS_SIZE - 1
mov ax,kTssSelector
ltr ax

mov ax,ldtSelector
lldt ax
*

;在P6以后的内核中，将紧跟着TSS正文的32字节解释为V86模式下的中断重定向位，
;如果存在IO映射表，那么紧跟着IO映射表的那个字节的位应全部为1，如果没有IO映射表，那么紧跟着中断重定向表的那个字节的位应全部为1，并将TSS偏移第65H处的字节置零

cmp word ptr ds:[ebx + _videoMode],VIDEO_MODE_3
jz _useKernelTextMode

;call __setDesktopBackground
;call __setTaskbarColor
;call __setTimerBackground
;call __mouseInit

;int 255

;mov ax,kTssV86Selector
;call ax

_useKernelTextMode:
;push dword ptr USER_TASK_DATA_BASE
;push dword ptr VSMAINDLL_LOAD_ADDRESS
;call __vsDllLoader
;add esp,8
;cmp eax,0
;jz _DllEntryEnd

push dword ptr KERNEL_DLL_BASE
push dword ptr VSKDLL_LOAD_ADDRESS
call __vsDllLoader
;mov ds:[ebx + _dllLoadAddr],eax
add esp,8
cmp eax,0
jz _DllEntryEnd

mov eax,ebx
add eax,offset _kernelDllEntryFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kernelDllEntry],eax

mov eax,ebx
add eax,offset _kTaskScheduleFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kTaskSchedule],eax

mov eax,ebx
add eax,offset _kDebuggerFz 
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kDebugger],eax

mov eax,ebx
add eax,offset _kBreakPointFz 
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kBreakPoint],eax

mov eax,ebx
add eax,offset _kSoundCardIntFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kSoundCardInt],eax

mov eax,ebx
add eax,offset _kPrintScreenFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kPrintScreen],eax

mov eax,ebx
add eax,offset _kscreenProtectFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kscreenProtect],eax
mov dword ptr ds:[TIMER0_FREQUENCY_ADDR],SYSTEM_TIMER0_FACTOR

mov eax,ebx
add eax,offset _kCmosAlarmProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kCmosAlarmProc],eax

mov eax,ebx
add eax,offset _kCom1ProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kCom1Proc],eax

mov eax,ebx
add eax,offset _kCom2ProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kCom2Proc],eax

mov eax,ebx
add eax,offset _kMouseProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kMouseProc],eax

mov eax,ebx
add eax,offset _kExceptionFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kException],eax


mov eax,ebx
add eax,offset _kCmosTimerFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kCmosTimer],eax


mov eax,ebx
add eax,offset _kKbdProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kKbdProc],eax


mov eax,ebx
add eax,offset _kServicesProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kServicesProc],eax

mov eax,ebx
add eax,offset _kCmosExactTimerProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kCmosExactTimerProc],eax

mov eax,ebx
add eax,offset __kApInitProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + __kApInitProc],eax

mov eax,ebx
add eax,offset _kFloppyIntrProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kFloppyIntrProc],eax


mov eax,ebx
add eax,offset _kCoprocessorFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kCoprocessor],eax


mov eax,ebx
add eax,offset _kCallGateProcFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kCallGateProc],eax


mov eax,ebx
add eax,offset _kTextModeEntryFz
push eax
push dword ptr KERNEL_DLL_BASE
call __getProcAddress
add esp,8
mov ds:[ebx + _kTextModeEntry],eax

cmp dword ptr ds:[ebx + _kernelDllEntry],0
jz _DllEntryEnd


;1 lea可以处理局部变量而 offset 则不能
;2 假设要bx+10h->bx但又不想影响flag那就只能用lea bx,[bx+10h]了
mov eax,Kernel32
;shl eax,4
push eax

mov eax,Kernel16
;shl eax,4
push eax

mov eax,kernelData
;shl eax,4
push eax

;mov eax,Kernel16
;shl eax,4
;add eax,offset __v86Process
mov eax,offset __v86Process
push eax

mov eax,__v86VMIntrProcEnd
sub eax,__v86VMIntrProc
push eax

mov eax,Kernel16
shl eax,4
add eax,offset __v86VMIntrProc
push eax

push dword ptr ds:[ebx + _graphCharBase]

mov eax,ebx
add eax,offset _videoInfo
push eax

;IFDEF TEXTMODE_TAG
;ELSE
;ENDIF
cmp dword ptr ds:[ebx + text_mode_tag],0
jnz __setTextVideoMode

mov eax,ds:[ebx + _kernelDllEntry]
call  eax
add esp,28
jmp _DllEntryEnd

__setTextVideoMode:
mov eax,ds:[ebx + _kTextModeEntry]
call eax
add esp,28

_DllEntryEnd:
sti

_waitVsDll:
hlt
jmp _waitVsDll

;中断(包括NMI和SMI)，debug exception，BINIT# signal，INIT# signal，或者RESET# signal
;CPU的HALT状态，在APCI规范中，对应于CPU的C1状态，属于CPU睡眠状态中的最低级别，即最浅的睡眠
;hlt will execute the next instructions after waked by interruptions

__kernel32Entry endp



__tmp32Entry proc
db 0eah
__kernel32EntryOffset 		dd 0
__kernel32EntrySelector		dw reCode32Seg
__tmp32Entry endp


__initAP32 proc
db 0eah
__initAP32EntryOffset 		dd 0
__initAP32EntrySelector		dw reCode32Seg
__initAP32 endp



__initAP32Entry proc
mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,0
mov ecx,0
mov edx,0
mov ebx,0
mov esi,0
mov edi,0

mov ebx,kernelData
shl ebx,4
inc dword ptr ds:[ebx+__APCounter]
mov  eax,ds:[ebx+__APCounter]
mov ecx,KTASK_STACK_SIZE
mul ecx
add eax,AP_KSTACK_BASE
mov esp,eax
mov ebp,esp

mov eax,ds:[ebx + __kApInitProc]
call eax

__initAP32Entry endp


__kernel32Exit proc
cli
db 0eah
dd offset _pmCode16Entry
dw reCode16Seg
__kernel32Exit endp




comment *

__initSysTimerTss proc
push ebp
mov ebp,esp

push ecx
push edx
push ebx
push esi
push edi

sub esp,40h

mov ebx,kernel32
shl ebx,4

mov eax,ebx
add eax,offset __iSystemTimerProc
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEip],eax
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mCs],reCode32Seg
;任务的代码数据段可以相同，堆栈选择子也可以相同
MOV dword ptr DS:[TIMER_TSS_BASE + TASKSTATESEG.mEsp0],TSSTIMER_STACK0_TOP
MOV dword ptr DS:[TIMER_TSS_BASE + TASKSTATESEG.mEsp],TSSTIMER_STACK_TOP
MOV dword ptr DS:[TIMER_TSS_BASE + TASKSTATESEG.mEbp],TSSTIMER_STACK_TOP
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mSs0],rwData32Seg	;stackTimerSeg
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mSs],rwData32Seg	;stackTimerSeg
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mDs],rwData32Seg
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEs],rwData32Seg
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mFs],rwData32Seg
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mGs],rwData32Seg
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEax],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEcx],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEdx],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEbx],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEsi],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEdi],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mPrev],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mEflags],0
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mCr3],PDE_ENTRY_VALUE
mov dword ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mLdt],0
mov word ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mTrap],0
mov word ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mIomap],104
mov byte ptr ds:[TIMER_TSS_BASE + TASKSTATESEG.mIomapEnd],0ffh

mov ebx,kernelData
shl ebx,2

mov eax,TIMER_TSS_BASE
mov word ptr ds:[ebx + kTssTimerDescriptor + 2],ax
shr eax,16
mov byte ptr ds:[ebx + kTssTimerDescriptor + 4],al
mov byte ptr ds:[ebx + kTssTimerDescriptor + 7],ah
mov word ptr ds:[ebx + kTssTimerDescriptor],sizeof TASKSTATESEG -1

mov ax,ktssTimerSelector
mov word ptr ds:[ebx + iSysTimerEntry + 2],ax

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__initSysTimerTss endp



__initCmosTimerTss proc
push ebp
mov ebp,esp

push ecx
push edx
push ebx
push esi
push edi

sub esp,40h

mov ebx,kernel32
shl ebx,4

mov eax,ebx
add eax,offset __iCmosTimerProc
mov ds:[CMOS_TSS_BASE + TASKSTATESEG.mEip],eax
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mCs],reCode32Seg
MOV dword ptr DS:[CMOS_TSS_BASE + TASKSTATESEG.mEsp0],TSSCMOS_STACK0_TOP
MOV dword ptr DS:[CMOS_TSS_BASE + TASKSTATESEG.mEsp],TSSCMOS_STACK_TOP
MOV dword ptr DS:[CMOS_TSS_BASE + TASKSTATESEG.mEbp],TSSCMOS_STACK_TOP
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mSs0],rwData32Seg;stackCmosSeg
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mSs],rwData32Seg;stackCmosSeg
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mDs],rwData32Seg
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEs],rwData32Seg
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mFs],rwData32Seg
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mGs],rwData32Seg
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEax],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEcx],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEdx],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEbx],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEsi],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEdi],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mPrev],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mEflags],0
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mCr3],PDE_ENTRY_VALUE
mov dword ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mLdt],0
mov word ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mTrap],0
mov word ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mIomap],104
mov byte ptr ds:[CMOS_TSS_BASE + TASKSTATESEG.mIomapEnd],0ffh

mov ebx,kernelData
shl ebx,2

mov eax,CMOS_TSS_BASE
mov word ptr ds:[ebx + kTssCmosDescriptor + 2],ax
shr eax,16
mov byte ptr ds:[ebx + kTssCmosDescriptor + 4],al
mov byte ptr ds:[ebx + kTssCmosDescriptor + 7],ah
mov word ptr ds:[ebx + kTssCmosDescriptor],sizeof TASKSTATESEG -1

mov ax,ktssCmosSelector
mov word ptr ds:[ebx + iCMOSEntry + 2],ax

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__initCmosTimerTss endp

*

Kernel32 ends





;任务门描述符可以放在GDT,LDT和IDT中。
;任务门描述符中的TSS段选择符字段指向GDT中的TSS描述符。
;中断和call引起的任务切换都是所谓“嵌套式”任务切换。
;从旧任务切换到新任务时，旧任务以TSS选择子的方式反向链接在新任务的TSS中，且新任务EFLAG中的NT(Nested Flag)位被置1。
;同时，虽然CPU已经从旧任务切换到新任务，但是旧任务TSS中的B(Busy)位依然保持为1。
;jmp所引起的任务切换并不导致嵌套关系的发生。旧任务的B位清零，新任务EFLAG中的NT位被清零,目标任务的入口点由目标任务 TSS 内的 CS 和 EIP 字段所规定的指针确定
;对于任务门所指向的 TSS 描述符的 DPL 不进行特权级检查
;堆栈段使用的是 TSS 中的 SS和 SP 字段的值,而不是使用内层栈保存区中的指针,即使发生了向内层特权级的变换。这与任务内的通过调用门的转移不同

;中断发生后，ss esp切换为tss中设置的ss esp而不是esp0,esp1,esp2或者ss0,ss1,ss2这三者中的任意一者
;在执行 IRET 指令时引起任务切换,那么实施解链。要求目标任务是忙的任务。在切换过程中把原任务置为“可用”,目标任务仍保持“忙”
;在段间转移指令 JMP 引起任务切换时,不实施链接,不导致任务的嵌套。它要求目标任务是可用任务。切换过程中把原任务置为“可用”,目标任务置为“忙”。
;在段间调用指令 CALL 引起任务切换时,实施链接,导致任务的嵌套。它要求目标任务是可用的任务。
;在切换过程中把目标任务置为“忙”,原任务仍保持“忙”;标志寄存器 EFLAGS 中的 NT ;位被置为 1,表示任务是嵌套任务
;TSS 的 busy 状态主要用来支持任务的嵌套。TSS descriptor 为 busy 状态时是不可进入执行的。同时防止 TSS 进程切换机制出现递归现象。


;当任务静态字段可读，不可写： 
;（1）LDT
;（2）CR3 CR3也被称为page directory base register(PDBR)页目录基址寄存器。 
;（3）特权级0,1,2栈指针字段
;（4）T标志（调试陷阱，100字节，位0）—如果设置，当切换任务时，会引起调试异常。 
;（5）I/O映射基址

;在任务切换时，处理器并不自动保存协处理器的上下文，而是会设置TS标志。这个标志会使得处理器遇到一条协处理器指令时产生设备不存在异常。
;设备不存在异常的处理程序可使用CLTS指令清除TS标志，并且保存协处理器的上下文。