TITLE Extended Addition Example           (ExtAdd.asm)

; This program calculates the sum of two 64-bit integers.
; Chapter 7 example.
; Last update: 07/18/01

INCLUDE Irvine16.inc

.data
op1 QWORD 0A2B2A40674981234h
op2 QWORD 08010870000234502h
sum DWORD 3 dup(?) ; = 0000000122C32B0674BB5736

.code
main PROC
	mov ax,@data
	mov ds,ax

	mov  esi,OFFSET op1		; first operand
	mov  edi,OFFSET op2		; second operand
	mov  ebx,OFFSET sum		; sum operand
	mov  ecx,2           		; number of doublewords
	call Extended_Add
	mov  esi,OFFSET sum		; dump memory
	mov  ebx,4
	mov  ecx,3
	call DumpMem

	exit
main ENDP

;--------------------------------------------------------
Extended_Add PROC
;
; Calculates the sum of two extended integers that are
;   stored as an array of doublewords.
; Receives: ESI and EDI point to the two integers,
; EBX points to a variable that will hold the sum, and
; ECX indicates the number of doublewords to be added.
;--------------------------------------------------------
	pushad
	clc                		; clear the Carry flag

L1:	mov eax,[esi]      		; get the first integer
	adc eax,[edi]      		; add the second integer
	pushfd              		; save the Carry flag
	mov [ebx],eax      		; store partial sum
	add esi,4         		; advance all 3 pointers
	add edi,4
	add ebx,4
	popfd               		; restore the Carry flag
	loop L1           		; repeat the loop

	adc word ptr [ebx],0		; add any leftover carry
	popad
	ret
Extended_Add ENDP
END main