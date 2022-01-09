

DATALOADERSECTOR STRUC
_flags			dd 0
_loaderSecCnt	dw 0	;4
_loaderSecOff	dd 0	;6
_kernelSecCnt	dw 0	;10
_kernelSecOff	dd 0	;12
_bakMbrSecOff	dd 0	;16
_bakMbr2SecOff	dd 0	;20
_fontSecCnt		dw 0	;24
_fontSecOff		dd 0	;26
_kdllSecCnt		dw 0	;30
_kdllSecOff		dd 0	;32
_maindllSecCnt	dw 0	;36
_maindllSecOff	dd 0	;38
_reserved		db 22 dup (0)	;42
DATALOADERSECTOR ENDS



PATCOMMAND STRUC
patlen 		db 0
reserved 	db 0
seccnt 		dw 0
segoff		dd 0
secofflow 	dd 0
secoffhigh 	dd 0
PATCOMMAND ENDS

INSTALL_FLAG			EQU 00474a4ch

SHIFTLEFT_SET_FLAG 		EQU 1
SHIFTRIGHT_SET_FLAG 	EQU 2
CTRLLEFT_SET_FLAG 		EQU 4
CTRLRIGHT_SET_FLAG 		EQU 8
ALTLEFT_SET_FLAG		EQU 10H
ALTRIGHT_SET_FLAG		EQU 20H
SCROLLLOCK_SET_FLAG 	EQU 40H
NUMSLOCK_SET_FLAG		EQU 80H
CAPSLOCK_SET_FLAG 		EQU 100H
INSERT_SET_FLAT			EQU 200H

PS2_CMD_STATUS_PORT 	EQU 64H
PS2_DATA_PORT			EQU 60H

KEYBORAD_BUF_SIZE 		EQU 1024
KEYBORAD_BUF_LIMIT 		EQU 4*KEYBORAD_BUF_SIZE
MOUSE_POS_TOTAL 		EQU 256


ICW2_MASTER_DOSINT_NO 	EQU 8
ICW2_SLAVE_DOSINT_NO 	EQU 70H
ICW2_MASTER_INT_NO 		EQU 40H
ICW2_SLAVE_INT_NO 		EQU 48H

KEYBOARDDATA struc
_KbdBuf          	dd KEYBORAD_BUF_SIZE dup (0)
_KbdStatusBuf       dd KEYBORAD_BUF_SIZE dup (0)
_KbdBufHdr   		dd 0
_KbdBufTail 		dd 0
_KbdStatus			dd 0
_KbdLedStatus   	dd 0
KEYBOARDDATA ends


V86VMIPARAMS STRUC
_work 		db 0

_intNumber	db 0

_eax		dd 0
_ecx		dd 0
_edx		dd 0
_ebx		dd 0
_esi		dd 0
_edi		dd 0
_es 		dw 0
_ds			dw 0
_result		dd 0
V86VMIPARAMS ENDS

CONTEXT STRUC
m_eax			dd 0
m_Ecx			dd 0
m_edx			dd 0
m_ebx			dd 0
m_esp			dd 0
m_ebp			dd 0
m_esi			dd 0
m_edi			dd 0	
m_eflags		dd 0
m_cs			dd 0
m_ss			dd 0
m_es			dd 0
m_ds			dd 0
m_fs			dd 0
m_gs			dd 0
CONTEXT ENDS



MOUSEINTRDATA STRUC
;bit 6-7 两个比特位必须为0
;bit 5: if deltaY is negtive,then set to 1,else set to 0
;bit 4: if deltaX is negtive,then set to 1,else set to 0
;bit 3  always set to 1,means than this mouse packet data is valid
;bit 2	middle click
;bit 1  right click
;bit 0  left click
_mouseStatus		dd 0
_mouseDeltaX		dd 0
_mouseDeltaY		dd 0
_mouseDeltaZ		dd 0
MOUSEINTRDATA ENDS


MOUSEPOSDATA STRUC
_mouseStatus		dd 0
_mouseX				dd 0
_mouseY				dd 0
_mouseZ				dd 0
MOUSEPOSDATA ENDS


MOUSEDATA STRUC
_mintrData			MOUSEINTRDATA <?>
_mouseWidth			dd 0
_mouseHeight		dd 0
_mouseX				dd 0
_mouseY				dd 0
_mouseZ				dd 0
_mouseBuf			MOUSEPOSDATA MOUSE_POS_TOTAL dup (<?>)
_mouseBufHdr		dd 0
_mouseBufTail		dd 0

_bInvalid			dd 0

_mouseCoverData		dd 4096 dup (0)
MOUSEDATA ends


DOS_THREAD_TERMINATE_CONTROL_CODE EQU 20000000h

DOS_PE_CONTROL STRUC
	address DD 0
	status  DD 0
	pid		DD 0
DOS_PE_CONTROL ENDS




TASKDOSPARAMS struc
	;terminate 		dd 0		;0
	pid 			dd 0		;4
	lpfilename 		dd 0		;8
	lpfuncname 		dd 0		;12
	address			dd 0		;16
	param 			dd 0		;20
	szFileName 		db 64 dup (0)	;24
	szFuncName 		db 64 dup (0)	;88
TASKDOSPARAMS ends




BC_BACK		equ		8
VK_BACK		equ		08h 
BC_TAB		equ		8
VK_TAB		equ		09h 
BC_ESCAPE	equ		1
VK_ESCAPE	equ		1Bh  

BC_F1 equ 3Bh
VK_F1 equ 112

BC_F2 equ 3Ch
VK_F2 equ 113

BC_F3 equ 3Dh
VK_F3 equ 114

BC_F4 equ 3Eh
VK_F4 equ 115

BC_F5 equ 3Fh
VK_F5 equ 116

BC_F6 equ 40h
VK_F6 equ 117

BC_F7 equ 41h
VK_F7 equ 118

BC_F8 equ 42h
VK_F8 equ 119

BC_F9 equ 43h
VK_F9 equ 120

BC_F10 equ 44h
VK_F10 equ 121

BC_F11 equ 57h
VK_F11 equ 122

BC_F12 equ 58h
VK_F12 equ 123



BC_INSERT equ 52h
VK_INSERT equ 45

BC_HOME equ 47h
VK_HOME equ 36

BC_PRIOR equ 49h
VK_PRIOR equ 33

BC_NEXT equ 51h
VK_NEXT equ 34

BC_END equ 4Fh
VK_END equ 35

BC_DELETE equ 53h
VK_DELETE equ 46

BC_LEFT equ 4Bh
VK_LEFT equ 37

BC_UP equ 48h
VK_UP equ 38

BC_RIGHT equ 4Dh
VK_RIGHT equ 39

BC_DOWN equ 50h
VK_DOWN equ 40



BC_CAPSLOCK equ 3Ah
VK_CAPSLOCK equ 20

BC_NUMSLOCK equ 45h
VK_NUMSLOCK equ 144

BC_PAUSE_BREAK equ 37h
VK_PAUSE_BREAK equ 19

BC_SCROLLLOCK equ 46h
VK_SCROLLLOCK equ 145

BC_LSHIFT			equ 2Ah
VK_LSHIFT			equ 0A0h
BC_RSHIFT			equ 36h
VK_RSHIFT			equ 0A1h

BC_CONTROL			equ 1Dh
VK_CONTROL			equ 17

VK_LCONTROL			equ 0A2h
VK_RCONTROL			equ 0A3h
VK_LMENU			equ 0A4h
VK_RMENU			equ 0A5h

VK_PRINT			equ 2Ah


BC_MENU equ 38h
VK_MENU equ 18

BC_APPS equ 46h
VK_APPS equ 93

BC_RWIN equ 46h
VK_RWIN equ 92

BC_LWIN equ 46h
VK_LWIN equ 91