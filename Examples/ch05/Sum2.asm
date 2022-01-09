TITLE Integer Summation Program		      (Sum2.asm)

; This program inputs multiple integers from the user,
; stores them in an array, calculates the sum of the
; array, and displays the sum.

INCLUDE Irvine32.inc

IntegerCount = 3			; array size

.data
prompt1 BYTE  "Enter a signed integer: ",0
prompt2 BYTE  "The sum of the integers is: ",0
array   DWORD  IntegerCount DUP(?)

.code
main PROC
	call Clrscr
	mov  esi,OFFSET array
	mov  ecx,IntegerCount
	call PromptForIntegers
	call ArraySum
	call DisplaySum
	exit
main ENDP

;-----------------------------------------------------
PromptForIntegers PROC
;
; Prompts the user for an array of integers, and fills
; the array with the user's input.
; Receives: ESI points to the array, ECX = array size
; Returns:  nothing
;-----------------------------------------------------
	pushad		; save all registers

	mov  edx,OFFSET prompt1		; address of the prompt
	cmp  ecx,0		; array size <= 0?
	jle  L2		; yes: quit

L1:
	call WriteString		; display string
	call ReadInt		; read integer into EAX
	call Crlf		; go to next output line
	mov  [esi],eax		; store in array
	add  esi,4		; next integer
	loop L1

L2:
	popad		; restore all registers
	ret
PromptForIntegers ENDP

;-----------------------------------------------------
ArraySum PROC
;
; Calculates the sum of an array of 32-bit integers.
; Receives: ESI points to the array, ECX = array size
; Returns:  EAX = sum of the array elements
;-----------------------------------------------------
	push  esi		; save ESI, ECX
	push  ecx
	mov   eax,0		; set the sum to zero

L1:
	add   eax,[esi]		; add each integer to sum
	add   esi,4		; point to next integer
	loop  L1		; repeat for array size

L2:
	pop   ecx		; restore ECX, ESI
	pop   esi
	ret		; sum is in EAX
ArraySum ENDP

;-----------------------------------------------------
DisplaySum PROC
;
; Displays the sum on the screen
; Recevies: EAX = the sum
; Returns:  nothing
;-----------------------------------------------------
	push edx
	mov  edx,OFFSET prompt2		; display message
	call WriteString
	call WriteInt		; display EAX
	call Crlf
	pop  edx
	ret
DisplaySum ENDP
END main