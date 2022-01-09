TITLE Testing the Link Library 	        (TestLib.asm)

; Use this program to test individual Irvine16
; library procedures.

INCLUDE Irvine16.inc

.data


.code
main PROC
	mov ax,@data
	mov ds,ax


	exit
main ENDP
END main