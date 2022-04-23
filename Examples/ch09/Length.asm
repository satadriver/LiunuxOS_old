TITLE String Length                           (Length.asm)

; Testing the Str_length procedure.
; Last update: 9/7/01

INCLUDE Irvine32.inc

Str_length PROTO,
	pString:PTR BYTE		; pointer to string

.data
string_1 BYTE "Hello",0
string_2 BYTE "#",0
string_3 BYTE 0

.code
main PROC
	call Clrscr

	INVOKE Str_length,ADDR string_1
	call DumpRegs
	INVOKE Str_length,ADDR string_2
	call DumpRegs
	INVOKE Str_length,ADDR string_3
	call DumpRegs

	exit
main ENDP

END main
