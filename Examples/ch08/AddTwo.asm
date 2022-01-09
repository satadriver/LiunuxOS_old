TITLE Demonstrate the AddTwo Procedure     (AddTwo.asm)

; Last update: 8/30/01

INCLUDE Irvine32.inc

.data
sum DWORD ?

.code
main PROC

	call MySub

; Restore the stack after the call.
; This is what C/C++ programs do:
	call DumpRegs
	push 5
	push 6
	call AddTwo2
	add  esp,8
	call DumpRegs

	INVOKE ExitProcess,0
main ENDP

MySub PROC
	call DumpRegs	; check ESP

; Let the procedure clean up the stack.
; This is what Pascal/stdcall procedures do:
	push 5
	push 6
	call AddTwo
	mov  sum,eax

	call DumpRegs	; check ESP again
	ret
MySub ENDP

AddTwo PROC
; Adds two integers, returns sum in EAX.
; The RET instruction cleans up the stack.
    push ebp
    mov  ebp,esp
    mov  eax,[ebp + 12]   		; first parameter
    add  eax,[ebp + 8]		; second parameter
    pop  ebp
    ret  8		; clean up the stack
AddTwo ENDP

AddTwo2 PROC
; Adds two integers, return sum in EAX.
; RET does not clean up the stack.
    push ebp
    mov  ebp,esp
    mov  eax,[ebp + 12]   		; first parameter
    add  eax,[ebp + 8]		; second parameter
    pop  ebp
    ret
AddTwo2 ENDP

END main