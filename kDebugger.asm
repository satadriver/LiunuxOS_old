.686p

;BT、BTS、BTR、BTC: 位测试指令
;BT(Bit Test):                 位测试
;BTS(Bit Test and Set):        位测试并置位
;BTR(Bit Test and Reset):      位测试并复位
;BTC(Bit Test and Complement): 位测试并取反
;它们的结果影响 CF

DATA_BREAKPOINT 		EQU 1
PORT_BREAKPOINT			equ 2
INSTRUCTION_BREAKPOINT 	EQU 3
BD_BREAKPOINT 			EQU 4
BS_BREAKPOINT 			EQU 5
BT_BREAKPOINT 			EQU 6
INT3_BREAKPOINT			EQU 7

;当处理器进行算术操作时，如果最高位有向前进位或借位的情况发生，则 CF=1；否则 CF=0。
;假定你进行的是有符号数运算，如果结果超出了目标操作数所能容纳的范围，OF=1；否则，OF=0。
;mov ah,0x70 
;add ah,ah
;OF=1


Kernel segment para use32
assume cs:Kernel


align 10h
__tDebugProc proc
pushad
push ds
push es

mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebx,kernelData
shl ebx,4

CMP dword ptr ds:[ebx + _kDebugger],0
JZ _debugIntShowErr
mov eax, esp
add eax,8
push eax
call dword ptr ds:[ebx + _kDebugger]
add esp,4

_debuggerProcEnd:
pop es
pop ds
popad
;1 每次成功执行一条指令把RF清零
;2 iretd不会把RF清零
;3 RF==1,忽略调试故障和陷阱,RF==0，不忽略，引起中断故障处理程序执行
;4 发生非调试故障时RF==1,发生调试故障时RF==0
;bts dword ptr ss:[esp + 8],16
iretd
__tDebugProc endp



_debugIntShowErr:
mov ebp,esp
add ebp,32

add ebp,8

push dword ptr 1
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktDebugKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktDebugShowExpInfo
_ktDebugKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktDebugShowExpInfo:
call  __exceptionInfo
add esp,28
jmp _debuggerProcEnd



align 10h
__tBreakPointProc proc
pushad
push ds
push es

mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebx,kernelData
shl ebx,4

cmp dword ptr ds:[ebx + _kBreakPoint],0
jz __breakPointProcNotExist
mov eax, esp
add eax,8
push eax
call dword ptr ds:[ebx + _kBreakPoint]
add esp,4
jmp __tBreakPointProcEnd

__breakPointProcNotExist:
mov ebp,esp
add ebp,32
add ebp,8

push dword ptr 3
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _ktBreadPointKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _ktBreadPointShowExpInfo
_ktBreadPointKernelModeInt:
push dword ptr 0
push dword ptr 0
_ktBreadPointShowExpInfo:
call  __exceptionInfo
add esp,28

__tBreakPointProcEnd:
pop es
pop ds
popad
iretd
__tBreakPointProc endp


Kernel ends