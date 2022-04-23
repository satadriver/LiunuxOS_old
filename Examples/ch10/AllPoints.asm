TITLE Loop Through Array       (AllPoints.asm)

; Loop through the array of points and set their
; X and Y values.
; Last update: 11/26/01

INCLUDE Irvine32.inc
.data
NumPoints = 3
AllPoints COORD NumPoints DUP(<0,0>)

.code
main PROC
	mov edi,0	; array index
	mov ecx,NumPoints	; loop counter
	mov ax,1	; starting X, Y values
L1:
	mov (COORD PTR AllPoints[edi]).X,ax
	mov (COORD PTR AllPoints[edi]).Y,ax
	add edi,TYPE COORD
	inc ax
	Loop L1

	exit
main ENDP
END main