TITLE Keyboard Toggle Keys             (Keybd.asm)

; This program shows how to detect the states of various
; keyboard toggle keys. Before you run the program, hold
; down a selected key.
; Last update: 12/7/01

INCLUDE Irvine32.inc

VK_NUMLOCK  =   90h
VK_SCROLL   =   91h
VK_LSHIFT   =   0A0h
VK_RSHIFT   =   0A1h
VK_LCONTROL =   0A2h
VK_RCONTROL =   0A3h
VK_LMENU    =   0A4h
VK_RMENU    =   0A5h

GetKeyState PROTO, nVirtKey:DWORD
; Sets bit 0 in EAX if a toggle key is currently on.
; (CapsLock, NumLock, ScrollLock)
; Sets bit 15 in EAX if an other specified key is
;   currently held down

.data

.code
main PROC

	INVOKE GetKeyState, VK_NUMLOCK
	call DumpRegs		; sets bit 0

	INVOKE GetKeyState, VK_LSHIFT
	call DumpRegs		; sets bit 15

	exit
main ENDP
END main