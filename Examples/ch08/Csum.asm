TITLE CalcSum Program                   (Csum.asm)

; This program demonstrates recursion as it sums
; the integers 1-n.
; Last update: 8/2/01

INCLUDE Irvine32.inc

.code
main PROC
	mov  ecx,10	; count = 10
	mov  eax,0	; holds the sum
	call CalcSum	; calculate sum
L1:	call WriteDec	; display eax
	call Crlf
	exit
main ENDP

CalcSum PROC
	cmp  ecx,0	; check counter value
	jz   L2	; quit if zero
	add  eax,ecx	; otherwise, add to sum
	dec  ecx	; decrement counter
	call CalcSum	; recursive call
L2:	ret
CalcSum ENDP

end Main