TITLE Integer Summation Program		  (Sum1.asm)

; This program inputs multiple integers from the user,
; stores them in an array, calculates the sum of the
; array, and displays the sum. Chapter 5 example.

INCLUDE Irvine32.inc

.data
first DWORD 2323423424
second BYTE "adjaslfdjsl"

.code
main PROC
; Main program control procedure.
; Calls: Clrscr, PromptForIntegers,
;        ArraySum, DisplaySum

	exit
main ENDP

;-----------------------------------------------------
PromptForIntegers PROC
;
; Prompts the user for an array of integers, and
; fills the array with the user's input.
; Receives: ESI points to an array of
;   doubleword integers, ECX = array size.
; Returns: the array contains the values
;   entered by the user
; Calls: ReadInt, WriteString
;-----------------------------------------------------
	ret
PromptForIntegers ENDP

;-----------------------------------------------------
ArraySum PROC
;
; Calculates the sum of an array of 32-bit integers.
; Receives: ESI points to the array, ECX = array size
; Returns:  EAX = sum of the array elements
;-----------------------------------------------------
	ret
ArraySum ENDP

;-----------------------------------------------------
DisplaySum PROC
;
; Displays the sum on the screen
; Recevies: EAX = the sum
; Calls: WriteString, WriteInt
;-----------------------------------------------------
	ret
DisplaySum ENDP

END main