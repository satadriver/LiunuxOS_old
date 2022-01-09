.386p



Kernel Segment public para use32
assume cs:Kernel


__kCoProcessorProc proc
pushad
push ds
push es

mov ax,rwData32Seg
mov ds,ax
mov es,ax
mov ebx,KernelData
shl ebx,4

cmp dword ptr ds:[ebx + offset _kCoprocessor],0
jz __kCoProcessorProcEnd
call dword ptr ds:[ebx + offset _kCoprocessor]
jmp __kCoProcessorProcEnd

cmp dword ptr ds:[ebx + _kException],0
jz __kCoProcessorProcEnd
push dword ptr 4dh
push esp
call dword ptr ds:[ebx+_kException]
add esp,8
jmp __kCoProcessorProcEnd

mov ebp,esp
add ebp,32
push dword ptr ICW2_SLAVE_INT_NO + 5
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kCoProcKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kCoProcShowExpInfo
_kCoProcKernelModeInt:
push dword ptr 0
push dword ptr 0
_kCoProcShowExpInfo:
call  __exceptionInfo
add esp,28

__kCoProcessorProcEnd:
;clts
;wait
;finit
;FNCLEX

mov al,0
out 0f0h,al
in al,0f0h

mov al,20h
out 0a0h,al
out 20h,al

pop es
pop ds
popad
iretd
__kCoProcessorProc endp

Kernel ends


;整数 (CPU) 和 FPU 是相互独立的单元，因此，在执行整数和系统指令的同时可以执行浮点指令。这个功能被称为并行性(concurrency)，当发生未屏蔽的浮点异常时，
;它可能是个潜在的问题。反之，已屏蔽异常则不成问题，因为，FPU 总是可以完成当前操作并保存结果。
;发生未屏蔽异常时，中断当前的浮点指令，FPU 发异常事件信号。当下一条浮点指令或 FWAIT(WAIT) 指令将要执行时，FPU 检查待处理的异常。如果发现有这样的异常，FPU 就调用浮点异常处理程序（子程序）。
;如果引发异常的浮点指令后面跟的是整数或系统指令，情况又会是怎样的呢？很遗憾，指令不会检查待处理异常，它们会立即执行。
;假设第一条指令将其输出送入一个内存操作数，而第二条指令又要修改同一个内存操作数，那么异常处理程序就不能正确执行。示例如下：
;设置 WAIT 和 FWAIT 指令是为了在执行下一条指令之前，强制处理器检查待处理且未屏蔽的浮点异常。
;这两条指令中的任一条都可以解决这种潜在的同步问题，直到异常处理程序结束，才执行 INC 指令。