.386p

include ktrap.asm
include kservice.asm

include kTimer.asm
include kkbd.asm
include k8259Slave.asm
include kcom2.asm
include kcom.asm
include kprlll.asm
include kaudio.asm
include kfloppy.asm

include kcmos.asm
include knetwork.asm
include kusb.asm
include kscsi.asm
include kmouse.asm
include kcoproc.asm
include kdriver.asm
include kcdrom.asm


kernel16 segment public para use16

__initVector proc

push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
push ds
push es
sub esp,40h

mov eax,kernelData
mov ds,ax
mov es,ax

mov ebx,KERNEL
shl ebx,4

;SETGATEADDR <tDivEntry>,<KERNEL>,<__tDivExceptionProc>,<reCode32Seg>

mov eax,ebx
add eax,offset __tDivExceptionProc
mov word ptr ds:[tDivEntry],ax
shr eax,16
mov word ptr ds:[tDivEntry + 6],ax
mov word ptr ds:[tDivEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tDebugProc
mov word ptr ds:[tDebugEntry],ax
shr eax,16
mov word ptr ds:[tDebugEntry + 6],ax
mov word ptr ds:[tDebugEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tNmiProc
mov word ptr ds:[tNmiEntry],ax
shr eax,16
mov word ptr ds:[tNmiEntry + 6],ax
mov word ptr ds:[tNmiEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tBreakPointProc
mov word ptr ds:[tBreakPointEntry],ax
shr eax,16
mov word ptr ds:[tBreakPointEntry + 6],ax
mov word ptr ds:[tBreakPointEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tOverFlowProc
mov word ptr ds:[tOverFlowEntry],ax
shr eax,16
mov word ptr ds:[tOverFlowEntry + 6],ax
mov word ptr ds:[tOverFlowEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tBoundErrProc
mov word ptr ds:[tBoundErrEntry],ax
shr eax,16
mov word ptr ds:[tBoundErrEntry + 6],ax
mov word ptr ds:[tBoundErrEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tUnlawfulOpcodeProc
mov word ptr ds:[tUnlawfulOpcodeEntry],ax
shr eax,16
mov word ptr ds:[tUnlawfulOpcodeEntry + 6],ax
mov word ptr ds:[tUnlawfulOpcodeEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tNoneCoprocessorProc
mov word ptr ds:[tNoneCoprocessorEntry],ax
shr eax,16
mov word ptr ds:[tNoneCoprocessorEntry + 6],ax
mov word ptr ds:[tNoneCoprocessorEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tDoubleFaultProc
mov word ptr ds:[tDoubleFaultEntry],ax
shr eax,16
mov word ptr ds:[tDoubleFaultEntry + 6],ax
mov word ptr ds:[tDoubleFaultEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tCoprocessorBoundProc
mov word ptr ds:[tCoprocessorBoundEntry],ax
shr eax,16
mov word ptr ds:[tCoprocessorBoundEntry + 6],ax
mov word ptr ds:[tCoprocessorBoundEntry + 2],reCode32Seg


COMMENT *
mov eax,ebx
add eax,offset __tInvalidTssProc
mov word ptr ds:[tInvalidTssEntry],ax
shr eax,16
mov word ptr ds:[tInvalidTssEntry + 6],ax
mov word ptr ds:[tInvalidTssEntry + 2],reCode32Seg
*

;set invalid tss exception,must use task gate
mov eax,ebx
add eax,offset __tInvalidTssProc
mov ds:[_tssExp.mEip],eax
mov ds:[_tssExp.mCs],reCode32Seg
;必须要设置esp0,esp,ss0,ss四个寄存器的值，少一个都不行?????
;如果分页，必须设置cr3
MOV dword ptr DS:[_tssExp.mEsp0],TSSEXP_STACK0_TOP
MOV dword ptr DS:[_tssExp.mEsp],TSSEXP_STACK_TOP
MOV dword ptr DS:[_tssExp.mEbp],TSSEXP_STACK_TOP
mov dword ptr ds:[_tssExp.mSs0],rwData32Seg
mov dword ptr ds:[_tssExp.mSs],rwData32Seg
mov dword ptr ds:[_tssExp.mDs],rwData32Seg
mov dword ptr ds:[_tssExp.mEs],rwData32Seg
mov dword ptr ds:[_tssExp.mFs],rwData32Seg
mov dword ptr ds:[_tssExp.mGs],rwData32Seg
mov dword ptr ds:[_tssExp.mEax],0
mov dword ptr ds:[_tssExp.mEcx],0
mov dword ptr ds:[_tssExp.mEdx],0
mov dword ptr ds:[_tssExp.mEbx],0
mov dword ptr ds:[_tssExp.mEsi],0
mov dword ptr ds:[_tssExp.mEdi],0
mov dword ptr ds:[_tssExp.mPrev],0
mov dword ptr ds:[_tssExp.mEflags],0
mov dword ptr ds:[_tssExp.mCr3],PDE_ENTRY_VALUE
mov dword ptr ds:[_tssExp.mLdt],0
mov word ptr ds:[_tssExp.mTrap],0
mov byte ptr ds:[_tssExp.mIomapEnd],0ffh
mov word ptr ds:[_tssExp.mIomap],104

mov eax,kernelData
shl eax,4
add eax,offset _tssExp
mov word ptr ds:[kTssExpDescriptor + 2],ax
shr eax,16
mov byte ptr ds:[kTssExpDescriptor + 4],al
mov byte ptr ds:[kTssExpDescriptor + 7],ah
mov word ptr ds:[kTssExpDescriptor],sizeof TASKSTATESEG - 1

mov ax,ktssExpSelector
;rpl = 0
mov word ptr ds:[tInvalidTssEntry + 2],ax




mov eax,ebx
add eax,offset __tSegNonePresentProc
mov word ptr ds:[tSegNonePresentEntry],ax
shr eax,16
mov word ptr ds:[tSegNonePresentEntry + 6],ax
mov word ptr ds:[tSegNonePresentEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tStackSegErrProc
mov word ptr ds:[tStackSegErrEntry],ax
shr eax,16
mov word ptr ds:[tStackSegErrEntry + 6],ax
mov word ptr ds:[tStackSegErrEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tGPProc
mov word ptr ds:[tGPEntry],ax
shr eax,16
mov word ptr ds:[tGPEntry + 6],ax
mov word ptr ds:[tGPEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tPageFaultProc
mov word ptr ds:[tPageFaultEntry],ax
shr eax,16
mov word ptr ds:[tPageFaultEntry + 6],ax
mov word ptr ds:[tPageFaultEntry + 2],reCode32Seg

;0fh replace with general protection
mov eax,ebx
add eax,offset __tGPProc
mov word ptr ds:[tGPEntry],ax
shr eax,16
mov word ptr ds:[tGPEntry + 6],ax
mov word ptr ds:[tGPEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tFpuFaultProc
mov word ptr ds:[tFpuFaultEntry],ax
shr eax,16
mov word ptr ds:[tFpuFaultEntry + 6],ax
mov word ptr ds:[tFpuFaultEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tAlignmentCheckErrProc
mov word ptr ds:[tAlignmentCheckErrEntry],ax
shr eax,16
mov word ptr ds:[tAlignmentCheckErrEntry + 6],ax
mov word ptr ds:[tAlignmentCheckErrEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tMachineCheckErrProc
mov word ptr ds:[tMachineCheckErrEntry],ax
shr eax,16
mov word ptr ds:[tMachineCheckErrEntry + 6],ax
mov word ptr ds:[tMachineCheckErrEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tSimdFaultProc
mov word ptr ds:[tSimdFaultEntry],ax
shr eax,16
mov word ptr ds:[tSimdFaultEntry + 6],ax
mov word ptr ds:[tSimdFaultEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __tVirtualErrorProc
mov word ptr ds:[tVirtualErrorEntry],ax
shr eax,16
mov word ptr ds:[tVirtualErrorEntry + 6],ax
mov word ptr ds:[tVirtualErrorEntry + 2],reCode32Seg



IFDEF SINGLE_TASK_TSS
mov eax,ebx
add eax,offset __iSystemTimerProc
mov word ptr ds:[iSysTimerEntry],ax
shr eax,16
mov word ptr ds:[iSysTimerEntry + 6],ax
mov word ptr ds:[iSysTimerEntry + 2],reCode32Seg
ELSE
;user timer to switch tasks,task gate settings
mov eax,ebx
add eax,offset __iSystemTimerProc
mov ds:[_tssTimer.mEip],eax
mov ds:[_tssTimer.mCs],reCode32Seg

MOV dword ptr DS:[_tssTimer.mEsp0],TSSTIMER_STACK0_TOP
MOV dword ptr DS:[_tssTimer.mEsp],TSSTIMER_STACK_TOP
MOV dword ptr DS:[_tssTimer.mEbp],TSSTIMER_STACK_TOP
mov dword ptr ds:[_tssTimer.mSs0],rwData32Seg	
mov dword ptr ds:[_tssTimer.mSs],rwData32Seg
mov dword ptr ds:[_tssTimer.mDs],rwData32Seg
mov dword ptr ds:[_tssTimer.mEs],rwData32Seg
mov dword ptr ds:[_tssTimer.mFs],rwData32Seg
mov dword ptr ds:[_tssTimer.mGs],rwData32Seg
mov dword ptr ds:[_tssTimer.mEax],0
mov dword ptr ds:[_tssTimer.mEcx],0
mov dword ptr ds:[_tssTimer.mEdx],0
mov dword ptr ds:[_tssTimer.mEbx],0
mov dword ptr ds:[_tssTimer.mEsi],0
mov dword ptr ds:[_tssTimer.mEdi],0
mov dword ptr ds:[_tssTimer.mPrev],0
mov dword ptr ds:[_tssTimer.mEflags],0
mov dword ptr ds:[_tssTimer.mCr3],PDE_ENTRY_VALUE
mov dword ptr ds:[_tssTimer.mLdt],0
mov word ptr ds:[_tssTimer.mTrap],0
mov word ptr ds:[_tssTimer.mIomap],104
mov byte ptr ds:[_tssTimer.mIomapEnd],0ffh

mov eax,kernelData
shl eax,4
add eax,offset _tssTimer
mov word ptr ds:[kTssTimerDescriptor + 2],ax
shr eax,16
mov byte ptr ds:[kTssTimerDescriptor + 4],al
mov byte ptr ds:[kTssTimerDescriptor + 7],ah
mov word ptr ds:[kTssTimerDescriptor],sizeof TASKSTATESEG -1

mov ax,ktssTimerSelector
mov word ptr ds:[iSysTimerEntry + 2],ax
ENDIF




mov eax,ebx
add eax,offset __kKeyBoardProc
mov word ptr ds:[iKbdEntry],ax
shr eax,16
mov word ptr ds:[iKbdEntry + 6],ax
mov word ptr ds:[iKbdEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __k8259SlaveEntry
mov word ptr ds:[iNmiEntry],ax
shr eax,16
mov word ptr ds:[iNmiEntry + 6],ax
mov word ptr ds:[iNmiEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kCom2Proc
mov word ptr ds:[iCom2Entry],ax
shr eax,16
mov word ptr ds:[iCom2Entry + 6],ax
mov word ptr ds:[iCom2Entry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kComProc
mov word ptr ds:[iCom1Entry],ax
shr eax,16
mov word ptr ds:[iCom1Entry + 6],ax
mov word ptr ds:[iCom1Entry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kAudioProc
mov word ptr ds:[iAudioEntry],ax
shr eax,16
mov word ptr ds:[iAudioEntry + 6],ax
mov word ptr ds:[iAudioEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kFloppyProc
mov word ptr ds:[iFloppyEntry],ax
shr eax,16
mov word ptr ds:[iFloppyEntry + 6],ax
mov word ptr ds:[iFloppyEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kParallelProc
mov word ptr ds:[iParallelEntry],ax
shr eax,16
mov word ptr ds:[iParallelEntry + 6],ax
mov word ptr ds:[iParallelEntry + 2],reCode32Seg




mov eax,ebx
add eax,offset __iCmosTimerProc
mov word ptr ds:[iCMOSEntry],ax
shr eax,16
mov word ptr ds:[iCMOSEntry + 6],ax
mov word ptr ds:[iCMOSEntry + 2],reCode32Seg


comment *
;task gate dpl = 3,cpl = 3,rpl = 0(rpl is defined by kernel,now it is 0)
;user timer to switch tasks,task gate settings
mov eax,ebx
add eax,offset __iCmosTimerProc
mov ds:[_tssCmos.mEip],eax
;rpl = 0
mov ds:[_tssCmos.mCs],reCode32Seg
MOV dword ptr DS:[_tssCmos.mEsp0],TSSCMOS_STACK0_TOP
MOV dword ptr DS:[_tssCmos.mEsp],TSSCMOS_STACK_TOP
MOV dword ptr DS:[_tssCmos.mEbp],TSSCMOS_STACK_TOP
mov dword ptr ds:[_tssCmos.mSs0],rwData32Seg
mov dword ptr ds:[_tssCmos.mSs],rwData32Seg
mov dword ptr ds:[_tssCmos.mDs],rwData32Seg
mov dword ptr ds:[_tssCmos.mEs],rwData32Seg
mov dword ptr ds:[_tssCmos.mFs],rwData32Seg
mov dword ptr ds:[_tssCmos.mGs],rwData32Seg
mov dword ptr ds:[_tssCmos.mEax],0
mov dword ptr ds:[_tssCmos.mEcx],0
mov dword ptr ds:[_tssCmos.mEdx],0
mov dword ptr ds:[_tssCmos.mEbx],0
mov dword ptr ds:[_tssCmos.mEsi],0
mov dword ptr ds:[_tssCmos.mEdi],0
mov dword ptr ds:[_tssCmos.mPrev],0
mov dword ptr ds:[_tssCmos.mEflags],0
mov dword ptr ds:[_tssCmos.mCr3],PDE_ENTRY_VALUE
mov dword ptr ds:[_tssCmos.mLdt],0
mov word ptr ds:[_tssCmos.mTrap],0
mov word ptr ds:[_tssCmos.mIomap],104
mov byte ptr ds:[_tssCmos.mIomapEnd],0ffh

mov eax,kernelData
shl eax,4
add eax,offset _tssCmos
mov word ptr ds:[kTssCmosDescriptor + 2],ax
shr eax,16
mov byte ptr ds:[kTssCmosDescriptor + 4],al
mov byte ptr ds:[kTssCmosDescriptor + 7],ah
mov word ptr ds:[kTssCmosDescriptor],sizeof TASKSTATESEG -1

;rpl = 0
mov ax,ktssCmosSelector
;or ax,3
mov word ptr ds:[iCMOSEntry + 2],ax
*



mov eax,ebx
add eax,offset __kNetworkProc
mov word ptr ds:[iNetworkEntry],ax
shr eax,16
mov word ptr ds:[iNetworkEntry + 6],ax
mov word ptr ds:[iNetworkEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kUSBProc
mov word ptr ds:[iUSBEntry],ax
shr eax,16
mov word ptr ds:[iUSBEntry + 6],ax
mov word ptr ds:[ iUSBEntry+ 2],reCode32Seg

mov eax,ebx
add eax,offset __kScsiProc
mov word ptr ds:[iScsiEntry],ax
shr eax,16
mov word ptr ds:[iScsiEntry + 6],ax
mov word ptr ds:[iScsiEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kMouseProc
mov word ptr ds:[iMouseEntry],ax
shr eax,16
mov word ptr ds:[iMouseEntry + 6],ax
mov word ptr ds:[iMouseEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kCoProcessorProc
mov word ptr ds:[iCoprocessorEntry],ax
shr eax,16
mov word ptr ds:[iCoprocessorEntry + 6],ax
mov word ptr ds:[iCoprocessorEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kDriverProc
mov word ptr ds:[iDriverEntry],ax
shr eax,16
mov word ptr ds:[iDriverEntry + 6],ax
mov word ptr ds:[iDriverEntry + 2],reCode32Seg

mov eax,ebx
add eax,offset __kCDROMProc
mov word ptr ds:[iCDROMEntry],ax
shr eax,16
mov word ptr ds:[iCDROMEntry + 6],ax
mov word ptr ds:[iCDROMEntry + 2],reCode32Seg


mov eax,kernel
shl eax,4
add eax,offset __kServicesProc
mov word ptr ds:[tSysSvcEntry],ax
shr eax,16
mov word ptr ds:[tSysSvcEntry + 6],ax
mov word ptr ds:[tSysSvcEntry + 2],reCode32Seg


mov eax,kernel
shl eax,4
add eax,offset __int13hProc
mov word ptr ds:[int13CodeDescriptor+2],ax
shr eax,16
mov byte ptr ds:[int13CodeDescriptor + 4],al
mov byte ptr ds:[int13CodeDescriptor + 7],ah
;mov word ptr ds:[tInt13Entry + 2],int13CodeSeg

;task gate dpl = 3,cpl = 3,rpl = 0(rpl is defined by kernel,now it is 0)
mov dword ptr ds:[_tssInt13h.mEip],0
mov dword ptr ds:[_tssInt13h.mCs],int13CodeSeg	
;rpl = 0
MOV dword ptr DS:[_tssInt13h.mEsp0],TSSINT13H_STACK0_TOP
mov dword ptr ds:[_tssInt13h.mSs0],rwData32Seg
mov dword ptr ds:[_tssInt13h.mSs],rwData32Seg
MOV dword ptr DS:[_tssInt13h.mEsp],TSSINT13H_STACK_TOP
MOV dword ptr DS:[_tssInt13h.mEbp],TSSINT13H_STACK_TOP

mov dword ptr ds:[_tssInt13h.mDs],rwData32Seg
mov dword ptr ds:[_tssInt13h.mEs],rwData32Seg
mov dword ptr ds:[_tssInt13h.mFs],rwData32Seg
mov dword ptr ds:[_tssInt13h.mGs],rwData32Seg
mov dword ptr ds:[_tssInt13h.mEax],0
mov dword ptr ds:[_tssInt13h.mEcx],0
mov dword ptr ds:[_tssInt13h.mEdx],0
mov dword ptr ds:[_tssInt13h.mEbx],0
mov dword ptr ds:[_tssInt13h.mEsi],0
mov dword ptr ds:[_tssInt13h.mEdi],0
mov dword ptr ds:[_tssInt13h.mPrev],0
mov dword ptr ds:[_tssInt13h.mEflags],0
mov dword ptr ds:[_tssInt13h.mCr3],PDE_ENTRY_VALUE
mov dword ptr ds:[_tssInt13h.mLdt],0
mov word ptr ds:[_tssInt13h.mTrap],0
mov word ptr ds:[_tssInt13h.mIomap],104
mov byte ptr ds:[_tssInt13h.mIomapEnd],0ffh

mov eax,kernelData
shl eax,4
add eax,offset _tssInt13h
mov word ptr ds:[kTssInt13hDescriptor + 2],ax
shr eax,16
mov byte ptr ds:[kTssInt13hDescriptor + 4],al
mov byte ptr ds:[kTssInt13hDescriptor + 7],ah
mov word ptr ds:[kTssInt13hDescriptor],sizeof TASKSTATESEG -1

mov ax,kTssInt13hSelector
mov word ptr ds:[tInt13Entry + 2],ax



add esp,40h
pop es
pop ds
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__initVector endp




__initIDT proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
push ds
push es
sub esp,40h

mov ax,kernelData
mov ds,ax
mov es,ax
cli

sidt fword ptr ds:[_rmModeIdtReg]

call __initVector

mov eax,KernelData
shl eax,4
add eax,offset tDivEntry
;idtr low 2 bytes is limit,hight 4 bytes is base address
mov dword ptr ds:[idtReg + 2],eax

mov word ptr ds:[idtReg ],idtLimit

lidt fword ptr ds:[idtReg]

add esp,40h
pop es
pop ds
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__initIDT endp



__loadRmIdt proc
lidt fword ptr ds:[_rmModeIdtReg]
ret
__loadRmIdt endp





kernel16 ends