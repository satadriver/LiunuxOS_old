TITLE Binary Multiplication         (BMult.asm)

; Demonstration of binary multiplication using SHL.
; Multiply intval by 36, using SHL instructions:

INCLUDE Irvine16.inc

.code
main PROC
	mov ax,@data
	mov ds,ax

.data
intval  DWORD  123
.code
	mov eax,intval
	mov ebx,eax
	shl eax,5
	shl ebx,2
	add eax,ebx
	call DumpRegs

	exit
main ENDP
END main