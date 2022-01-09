TITLE Comparing Strings             (Cmpsb.asm)

; This program uses CMPSB to compare two strings
; of equal length.

INCLUDE Irvine.inc
.data
source BYTE "MARTIN  "
dest   BYTE "MARTINEZ"
str1   BYTE "Source is smaller",0dh,0ah,0

.code
main PROC
	startup

	cld	; direction = up
	mov  esi,OFFSET source
	mov  edi,OFFSET dest
	mov  cx,LENGTHOF source
	repe cmpsb
	jb   source_smaller
	jmp  quit

source_smaller:
	mov  edx,OFFSET str1
	call WriteString

quit:
	exit
main ENDP
END main