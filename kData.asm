.386p
include vesadata.asm
include tss.ASM
include descriptor.asm
include deviceData.asm


SIZE_OF_CHAR			EQU 1
SIZE_OF_SHORT			EQU 2
SIZE_OF_INT				EQU 4
SIZE_OF_FWORD			EQU 6
SIZE_OF_QWORD			EQU 8

PAGE_SIZE				EQU 1000h

PAGE_INDEX_COUNT		EQU PAGE_SIZE/SIZE_OF_INT

SYSTEM_TSS_SIZE			EQU (104+ 32 + 8192+1)

MAX_TASK_LIMIT			EQU 256
KERNEL_TASK_LIMIT		EQU 64

KTASK_STACK_SIZE		EQU 10000H
USER_TASK_STACK_SIZE	EQU 100000h
TASK_STACK0_SIZE 		EQU 1024
STACK_TOP_DUMMY			EQU 20H

BIT16SEGMENT_SIZE		EQU 10000H
BIT16_STACK_TOP			equ (BIT16SEGMENT_SIZE - STACK_TOP_DUMMY)

RM_EMS_BASE		 		EQU 100000H

;页目录表物理地址低12位必须全是0
PTE_ENTRY_VALUE			EQU 110000H
PDE_ENTRY_VALUE 		EQU 510000H

CMOS_DATETIME_STRING 	EQU 512000H
TIMER0_FREQUENCY_ADDR	EQU CMOS_DATETIME_STRING + 100H
CMOS_SECONDS_TOTAL		EQU TIMER0_FREQUENCY_ADDR + 4
CMOS_TICK_COUNT 		EQU CMOS_SECONDS_TOTAL + 4
TIMER0_TICK_COUNT		EQU CMOS_TICK_COUNT + 4

VESA_INFO_BASE			EQU 513000H

KEYBOARD_BUFFER			EQU 518000H

MOUSE_BUFFER			EQU 520000H

LDT_BASE				EQU 5c0000H

CURRENT_TASK_TSS_BASE	EQU 540000H

AP_KSTACK_BASE			equ 780000h

;V86_TSS_BASE			EQU 544000H
;TIMER_TSS_BASE			EQU 548000h
;INVALID_TSS_BASE		EQU 54c0000h

KERNEL_TASK_STACK_BASE 	EQU 600000h
KERNEL_TASK_STACK_TOP 	EQU KERNEL_TASK_STACK_BASE + KTASK_STACK_SIZE - STACK_TOP_DUMMY

TSSEXP_STACK_ADDRESS 	EQU KERNEL_TASK_STACK_TOP + STACK_TOP_DUMMY
TSSEXP_STACK_TOP 		EQU TSSEXP_STACK_ADDRESS + KTASK_STACK_SIZE - STACK_TOP_DUMMY

TSSTIMER_STACK_ADDRESS 	EQU TSSEXP_STACK_TOP + STACK_TOP_DUMMY
TSSTIMER_STACK_TOP 		EQU	TSSTIMER_STACK_ADDRESS + KTASK_STACK_SIZE - STACK_TOP_DUMMY

TSSV86_STACK_ADDRESS 	EQU TSSTIMER_STACK_TOP + STACK_TOP_DUMMY)
TSSV86_STACK_TOP 		EQU TSSV86_STACK_ADDRESS + KTASK_STACK_SIZE - STACK_TOP_DUMMY

TSSEXP_STACK0_ADDRESS 	EQU 680000h
TSSEXP_STACK0_TOP 		EQU TSSEXP_STACK0_ADDRESS + TASK_STACK0_SIZE - STACK_TOP_DUMMY

TSSTIMER_STACK0_ADDRESS EQU TSSEXP_STACK0_TOP + STACK_TOP_DUMMY
TSSTIMER_STACK0_TOP 	EQU TSSTIMER_STACK0_ADDRESS + TASK_STACK0_SIZE - STACK_TOP_DUMMY

TSSV86_STACK0_ADDRESS 	EQU TSSTIMER_STACK0_TOP + STACK_TOP_DUMMY
TSSV86_STACK0_TOP 		EQU TSSV86_STACK0_ADDRESS + TASK_STACK0_SIZE - STACK_TOP_DUMMY

SYSCALL_STACK0			EQU TSSV86_STACK0_TOP + STACK_TOP_DUMMY
SYSCALL_STACK0_TOP		EQU SYSCALL_STACK0 + TASK_STACK0_SIZE - STACK_TOP_DUMMY

KERNEL_DLL_BASE			EQU 1000000h

KERNEL_DLL_SOURCE_BASE	EQU 1100000h

TASKS_STACK0_BASE		EQU 1800000h
;TSS_STACK0BASE_TOP		EQU (TSS_STACK0BASE + MAX_TASK_LIMIT*TASK_STACK0_SIZE)

LOADER_BASE_SEGMENT 	equ 800h
KERNEL_BASE_SEGMENT 	equ 1000h

LIMIT_V86_PROC_COUNT	equ 6

V86TASK_FIRST_SEG		EQU 2000H

;从90000h到a0000h的内存地址属性，有可能是不连续的
GRAPHFONT_LOAD_SEG 		EQU 9000H
GRAPHFONT_LOAD_OFFSET 	EQU 0
GRAPHFONT_LOAD_ADDRESS 	equ (GRAPHFONT_LOAD_SEG*16 + GRAPHFONT_LOAD_OFFSET)

MEMORYINFO_LOAD_SEG 	EQU 9000H
MEMORYINFO_LOAD_OFFSET 	EQU 1000H
MEMORYINFO_LOAD_ADDRESS equ (MEMORYINFO_LOAD_SEG*16 + MEMORYINFO_LOAD_OFFSET)

V86VMIPARAMS_SEG		EQU 9000H
V86VMIPARAMS_OFFSET		EQU 1400H
V86VMIPARAMS_ADDRESS	EQU (V86VMIPARAMS_SEG*16 + V86VMIPARAMS_OFFSET)

V86VMIDATA_SEG			EQU 9000h
V86VMIDATA_OFFSET		EQU 1500H
V86VMIDATA_ADDRESS		EQU (V86VMIDATA_SEG*16 + V86VMIDATA_OFFSET)

V86_INT_SEG				EQU	9000h
V86_INT_OFFSET 			EQU	1600h
V86_INT_ADDRESS 		EQU	(V86_INT_SEG * 16 + V86_INT_OFFSET)

;V86_TASKCONTROL_SEG	EQU 9000h
;V86_TASKCONTROL_OFFSET	EQU 2200H
;V86_TASKCONTROL_ADDRESS	EQU (V86_TASKCONTROL_SEG*16 + V86_TASKCONTROL_OFFSET)

VESA_STATE_SEG			EQU	9000h
VESA_STATE_OFFSET 		EQU	1800h
VESA_STATE_ADDRESS 		EQU	(VESA_STATE_SEG * 16 + VESA_STATE_OFFSET)

AP_INIT_SEG				EQU 9000h
AP_INIT_OFFSET			EQU 2000h
AP_INIT_ADDRESS			EQU (AP_INIT_SEG * 16 + AP_INIT_OFFSET)

VSKDLL_LOAD_SEG 		EQU 2000H
VSKDLL_LOAD_OFFSET 		EQU 0
VSKDLL_LOAD_ADDRESS 	equ (VSKDLL_LOAD_SEG*16 + VSKDLL_LOAD_OFFSET)

VSMAINDLL_LOAD_SEG 		EQU 6000H
VSMAINDLL_LOAD_OFFSET 	EQU 0
VSMAINDLL_LOAD_ADDRESS 	equ (VSMAINDLL_LOAD_SEG*16 + VSMAINDLL_LOAD_OFFSET)

INT13_RM_FILEBUF_SEG	EQU 8000H
INT13_RM_FILEBUF_OFFSET EQU 0
INT13_RM_FILEBUF_ADDR	EQU (INT13_RM_FILEBUF_SEG*16 + INT13_RM_FILEBUF_OFFSET)

BIOS_GRAPHCHARS_SEG		EQU 0f000h
BIOS_GRAPHCHARS_OFFSET	EQU 0fa6eH
BIOS_GRAPHCHARS_BASE	EQU (BIOS_GRAPHCHARS_SEG*16 + BIOS_GRAPHCHARS_OFFSET)

BIOS_GRAPHCHAR_HEIGHT	EQU 8
BIOS_GRAPHCHAR_WIDTH	EQU 8
GRAPH_TASK_HEIGHT		equ (BIOS_GRAPHCHAR_HEIGHT*4)

VIDEO_MODE_3			equ 3
VIDEO_MODE_112 			equ 112h
VIDEO_MODE_115 			equ 115h
VIDEO_MODE_118 			equ 118h
VIDEO_MODE_11B 			equ 11bh
VIDEO_MODE_11F			equ 11fh
VIDEO_MODE_319			equ 319
VIDEO_MODE_320 			equ 320
VIDEO_MODE_321 			equ 321
VIDEO_MODE_324			equ 324
VIDEO_MODE_326 			equ 326

VIDEOMODE_TEXT_DATASEG 		EQU 0b800h
VIDEOMODE_TEXT_DATABASE 	EQU (VIDEOMODE_TEXT_DATASEG * 16)
VIDEOMODE_TEXT_BYTESPERLINE EQU 160
VIDEOMODE_TEXT_MAX_LINE 	EQU 25
VIDEOMODE_TEXT_MAX_OFFSET 	equ (VIDEOMODE_TEXT_MAX_LINE * VIDEOMODE_TEXT_BYTESPERLINE )

TEXTMODE_FONTCOLOR_ERR 		equ 0ch
TEXTMODE_FONTCOLOR_NORMAL 	equ 0ah
VIDEOMODE_FONTCOLOR_ERR 	equ 00ff0000h
VIDEOMODE_FONTCOLOR_NORMAL 	equ 0
BACKGROUND_COLOR			equ 00B0E0E6h

;1.1931816MHZ 1193181.6/11932 = 100hz = 10ms
SYSTEM_TIMER0_FACTOR		EQU 11932



kernelData segment para use32
_kernelSectorInfo			DATALOADERSECTOR <0>

align 10h
gdtNullSelector				equ 0
gdtNullDescriptor			dq 0000000000000000h			;0

;内核代码段
reCode32Seg           		=$ - gdtNullDescriptor			;8
reCode32Descriptor         	dq 00cf9a000000ffffh

;00cf96000000ffffh means data segment increment from high to low,the offset in segment must above the segment limit
;do not use this to make a stack segment
;内核堆栈段和数据段
rwData32Seg           		=$ - gdtNullDescriptor			;16
rwDataDescriptor         	dq 00cf92000000ffffh

;用户代码段
reUsrCode32Seg           	=$ - gdtNullDescriptor			;24
reUsrCode32Descriptor       dq 00cffa000000ffffh

;用户堆栈段数据段
rwUsrData32Seg           	=$ - gdtNullDescriptor			;32
rwUsrStackDescriptor        dq 00cff2000000ffffh

;必要的跳转段
reCode32TempSeg           	=$ - gdtNullDescriptor			;40
reCode32TempDescriptor      dq 00cf9a000000ffffh

kTssSelector               	=$-gdtNullDescriptor			;48
kTssDescriptor           	dq 0000e90000000000h

kTssExpSelector             =$-gdtNullDescriptor			;56
kTssExpDescriptor           dq 0000e90000000000h

kTssTimerSelector			=$-gdtNullDescriptor			;64
kTssTimerDescriptor			dq 0000e90000000000h

kTssV86Selector				=$-gdtNullDescriptor			;72
kTssV86Descriptor			dq 0000e90000000000h

ldtSelector             	=$-gdtNullDescriptor			;80
ldtDescriptor           	dq 0000e20000000000h

callGateSelector            =$-gdtNullDescriptor			;88
callGateDescriptor      	dq 0000ec0000000000h

reCode16Seg					= $-gdtNullDescriptor			;96
reCode16Descriptor			dq 00009a000000ffffh

;16位测试段
rwData16Seg					= $ - gdtNullDescriptor			;104
rwData16Descriptor			dq 000092000000ffffh

;32位测试段
eoCode32Seg           		=$ - gdtNullDescriptor			;112
eoCode32Descriptor         	dq 00cf98000000ffffh	

roData32Seg           		=$ - gdtNullDescriptor			;120
roDataDescriptor         	dq 00cf90000000ffffh

gdtLimit					= $-gdtNullDescriptor -1

align 10h
gdtReg					df 0

align 10h
;exceptions AND traps
idtOffset				equ $
tDivEntry				GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tDebugEntry				GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tNmiEntry				GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tBreakPointEntry		GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tOverFlowEntry			GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tBoundErrEntry			GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tUnlawfulOpcodeEntry	GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tNoneCoprocessorEntry	GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tDoubleFaultEntry		GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tCoprocessorBoundEntry	GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tInvalidTssEntry		GATEDESCRIPTOR<0,0,0, TASKGATE + DPL3,0>
tSegNonePresentEntry	GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tStackSegErrEntry		GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
;GP fault:
;bit0:external
;bit1:interrupt
;bit2:ldt
tGPEntry				GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tPageFaultEntry			GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tUnused15               GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>		;15 dummy exception
tFpuFaultEntry			GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tAlignmentCheckErrEntry	GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tMachineCheckErrEntry	GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tSimdFaultEntry			GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tVirtualErrorEntry		GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>
tUnknowns0				dq 11 dup (0000ef0000000000h)	;20-31
tUnknowns1				dq 20h dup (0000ef0000000000h)					;20h - 3fh
;first 8259 interruptions
;在任务切换过程中，任务门描述符中DPL字段控制访问TSS描述符。当程序通过任务门调用和跳转到一个任务时，CPL和门选择符的RPL字段必须小于等于任务门描述符中的DPL
IFDEF SINGLE_TASK_TSS
iSysTimerEntry			GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
ELSE
iSysTimerEntry			GATEDESCRIPTOR<0,0,0, TASKGATE + DPL3,0>
ENDIF
iKbdEntry      			GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iNmiEntry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iCom2Entry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iCom1Entry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iAudioEntry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iFloppyEntry			GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iParallelEntry			GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
;second 8259 interruptions	
iCMOSEntry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iNetworkEntry			GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iUSBEntry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iScsiEntry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iMouseEntry   			GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iCoprocessorEntry		GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iDriverEntry			GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
iCDROMEntry				GATEDESCRIPTOR<0,0,0, INTRGATE + DPL3,0>
tUnknowns2				dq 30h dup (0000ef0000000000h)					;50h - 7fh
tSysSvcEntry			GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0>		;80h
;tSysSvcEntry			GATEDESCRIPTOR<0,0,0, CALLGATE + DPL3,0>		;80h
tUnknowns3				dq 07ah dup (0000ef0000000000h)					;81h - 0fah
tintFBEntry				GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0> 
tintFCEntry				GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0> 
tintFDEntry				GATEDESCRIPTOR<0,0,0, TRAPGATE + DPL3,0> 
tInt13Entry				GATEDESCRIPTOR<0,0,0, TASKGATE + DPL3,0>		;0feh
tV86Entry				GATEDESCRIPTOR<0,0,0, TASKGATE + DPL3,0>		;0ffh

idtLimit				= $ - idtOffset - 1

align 10h
idtReg					df 0

;tss do not need to align,can be any where,ignore alignment
;tss must be in one page!!!
;align 10h

_tssExp 			TASKSTATESEG <0>
_tssTimer 			TASKSTATESEG <0>

_textShowPos 		dd 640
_graphShowX			dd 0
_graphShowY			dd 0

_videoBufTotal		dd 0

_videoMode			dw 0
_videoInfo			VESAInformation <?>

_videoBlockInfo		VESAInfoBlock <>

_videoTypes			dw 64 dup (0)		;mode width height bits base

text_mode_tag		dd 0
_videoBase			dd 0
_bytesPerLine		dd 0
_bytesPerPixel		dd 0
_videoHeight		dd 0
_videoWidth			dd 0
_windowHeight		dd 0
_graphWindowLimit	dd 0
_videoFrameTotal	dd 0
_graphFontLines		dd 0
_graphFontRows		dd 0
_bytesXPerChar		dd 0
_graphFontLSize		dd 0
_graphCharBase		dd 0

_backGroundColor	EQU 00B0E0E6h
_taskBarColor		EQU 00CFCFCFh
_timerZoneColor		EQU 00E8E8E8h
_mouseColor			EQU 005C9C00H
MOUSE_BORDER_COLOR	EQU 0
_mouseBorderSize	EQU 4
_mouseRatioSize		EQU 40

_kTaskSchedule		dd 0
_kernelDllEntry		dd 0
_kDebugger			dd 0
_kBreakPoint		dd 0
_kSoundCardInt		dd 0
_kPrintScreen		dd 0
_kScreenProtect		dd 0
_kCmosAlarmProc		dd 0
_kCom1Proc			dd 0
_kCom2Proc			dd 0
_kMouseProc			dd 0
_kException			dd 0
_kCmosTimer			dd 0
_kKbdProc			dd 0
_kServicesProc		dd 0
_kFloppyIntrProc	dd 0
_kCoprocessor		dd 0
_kCallGateProc		dd 0
_kCmosExactTimerProc dd 0
_kTextModeEntry		dd 0
__kApInitProc		dd 0

__APCounter				dd 0
				
_kernelDllEntryFz		db '__kernelEntry',0
_kTaskScheduleFz		db '__kTaskSchedule',0
_kDebuggerFz			db '__kDebugger',0
_kBreakPointFz			db '__kBreakPoint',0
_kSoundCardIntFz		db '__kSoundInterruptionProc',0
_kPrintScreenFz			db '__kPrintScreen',0
_kScreenProtectFz		db '__kScreenProtect',0
_kCmosAlarmProcFz		db '__kCmosAlarmProc',0
_kCom1ProcFz			db '__kCom1Proc',0
_kCom2ProcFz			db '__kCom2Proc',0
_kMouseProcFz			db '__kMouseProc',0
_kExceptionFz			db '__kException',0
_kCmosTimerFz			db '__kCmosTimer',0
_kKbdProcFz				db '__kKeyboardProc',0
_kServicesProcFz		db '__kServicesProc',0
_kFloppyIntrProcFz		db '__kFloppyIntrProc',0
_kCoprocessorFz			db '__kCoprocessor',0
_kCallGateProcFz		db '__kCallGateProc',0
_kCmosExactTimerProcFz	db '__kCmosExactTimerProc',0
_kTextModeEntryFz		db '__kTextModeEntry',0
__kApInitProcFz			db '__kApInitProc',0

;page index entry must be aligned 1000h,else will cause GP error,so here is not suitable
;align 10h
;pageTableIndex dd 1024 dup (0)

_mondayStr 		db 'Monday',0
_tuesdayStr 	db 'Tuesday',0
_wednesdayStr 	db 'Wednesday',0
_ThursdayStr 	db 'Thursday',0
_FridayStr 		db 'Friday',0
_saturdayStr 	db 'Saturday',0
_sundayStr 		db 'Sunday',0

_exceptionInfo 			db 'System Kernel Exception'
						db ',Type:0x'
_exceptionType			db 8 dup (0)
						db ',ErrorCode:0x'
_exceptionErrCode		db 8 dup (0)
						db ',EIP:0x'
_exceptionEIP			db 8 dup (0)	
						db ',CS:0x'
_exceptionCS			db 8 dup (0)
						db ',Eflags:0x'
_exceptionEflags		db 8 dup (0)	
						db ',ESP:0x'
_exceptionESP			db 8 dup (0)	
						db ',SS:0x'
_exceptionSS			db 8 dup (0)	
						db 0ah
						db 0	

_graphShowInfo			db '('
_screenX				db 8 dup (0)
						db ','
_screenY				db 8 dup (0)
						db ','
_screenColor			db 8 dup (0)
						db '),'
						db '('
_mousePosX				db 8 dup (0)
						db ','
_mousePosY				db 8 dup (0)
						db ','
_mouseW					db 8 dup (0)
						db ','
_mouseH					db 8 dup (0)
						db ')',0
_screenInfoPos			dd 0


comment *
_memInfo				db 'Memory Address low:'
_memSegLow				db 8 dup (0)
						db ',Memory Address high:'
_memSegHigh				db 8 dup (0)
						db ',Memory Length low:'
_memLenLow				db 8 dup (0)
						db ',Memory Length high:'
_memLenHigh				db 8 dup (0)
						db ',Memory Type:'
_memType				db 8 dup (0)
						db 0ah
						db 0	
*

_gDateOfMonth			db 31,28,31,30,31,30,31,31,30,31,30,31

;f1 - f10 = 3b - 44 f11=85 f12=86
;e0 2a/e0 37 PrintScreen/SysRq
;Pause/Break e1 1d 45/e1 9d c5
;fill with 0 if without scancode

;0, left ctrl
;leftshift,rightshift,printscreen,alt,capslock,f1,f2,f3,f4,f5
;f6,f7,f8,f9,f10,numbslock,scrolllock
ScanCodesBuf 		db  0 ,1bh,'1','2','3','4','5','6','7','8','9','0','-','=', 8,  9, 		'q','w','e','r','t','y','u','i','o','p','[',']',0ah, 0, 'a','s'
					db 'd','f','g','h','j','k','l',';',"'",'`', 0, '\','z','x','c','v',		'b','n','m',',','.','/', 0,  0 , 0, ' ', 0,  0 , 0,  0,  0,  0
					db  0,	0,  0,  0,  0,  0,  0, '7','8','9','-','4','5','6','+','1',  	'2','3','0','.', 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
					
ScanCodesTransBuf  	db  0, 1bh,'!','@','#','$','%','^','&','*','(',')','_','+', 8,  9, 		'Q','W','E','R','T','Y','U','I','O','P','{','}',0ah, 0, 'A','S'
					db 'D','F','G','H','J','K','L',':','"','~', 0, '|','Z','X','C','V',		'B','N','M','<','>','?', 0, '*', 0, ' ', 0,  0,  0,  0,  0,  0
					db  0,  0,  0,  0,  0,  0,  0, '7','8','9','-','4','5','6','+','1',		'2','3','0','.', 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
kernelData ends