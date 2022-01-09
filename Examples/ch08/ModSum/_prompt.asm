TITLE Prompt For Integers	      (_prompt.asm)

; Last update: 8/29/01

INCLUDE sum.inc

.code
;-----------------------------------------------------
PromptForIntegers PROC,
  ptrPrompt:PTR BYTE,		; prompt string
  ptrArray:PTR DWORD,		; pointer to array
  arraySize:DWORD		; size of the array
;
; Prompts the user for an array of integers and fills
; the array with the user's input.
; Returns:  nothing
;-----------------------------------------------------
	pushad		; save all registers

	mov  ecx,arraySize
	cmp  ecx,0		; array size <= 0?
	jle  L2		; yes: quit
	mov  edx,ptrPrompt		; address of the prompt
	mov  esi,ptrArray

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

END