TITLE Segment Example           (main module, Seg2.asm)

EXTRN var2:WORD, subroutine_1:PROC

cseg SEGMENT BYTE PUBLIC 'CODE'
ASSUME cs:cseg,ds:dseg, ss:sseg

main PROC
	mov  ax,dseg        	; initialize DS
	mov  ds,ax

	mov  ax,var1        	; local variable
	mov  bx,var2        	; external variable
	call subroutine_1   	; external procedure

	mov  ax,4C00h	; exit to OS
	int  21h
main ENDP
cseg ENDS

dseg SEGMENT WORD PUBLIC 'DATA'   ; local data segment
	var1 WORD 1000h
dseg ends

sseg SEGMENT STACK 'STACK'	; stack segment
	BYTE 100h dup('S')
sseg ENDS
END main