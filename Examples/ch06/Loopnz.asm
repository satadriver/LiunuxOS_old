TITLE Scanning for a Positive Value        (Loopnz.asm)

; Scan an array for the first positive value.
; If no value is found, ESI will point to a sentinel
; value (0) stored immediately after the array.
; Last update: 11/4/01

INCLUDE Irvine32.inc
.data
array  SWORD  -3,-6,-1,-10,10,30,40,4
;array    SWORD  -3,-6,-1,-10		; alternate test data
sentinel SWORD  0

.code
main PROC
	mov esi,OFFSET array
	mov ecx,LENGTHOF array

next:
	test WORD PTR [esi],10000000b	; test highest bit
	pushfd		; push flags on stack
	add esi,TYPE array
	popfd		; pop flags from stack
	loopnz next 		; continue loop
	jnz quit		; none found

	sub esi,TYPE array		; SI points to value

quit:
	call  crlf
	exit
main ENDP

END main