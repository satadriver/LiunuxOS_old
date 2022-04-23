TITLE Macro Examples - 1            (Macro1.ASM)

; This program demonstrates the MACRO directive.
; Last update: 8/15/01.

INCLUDE Irvine32.inc

mPutchar MACRO char
	push eax
	mov  al,char
	call WriteChar
	pop  eax
ENDM

.code
main PROC

	mPutchar 'A'

; Invoke the macro in a loop.
    mov   al,'A'
    mov   ecx,20
L1:
	mPutchar al
    inc   al
    Loop  L1

quit:
	exit
main ENDP
END main