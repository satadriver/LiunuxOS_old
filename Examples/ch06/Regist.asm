TITLE  Compound IF Statements         (Regist.asm)

; Simple college registration example that uses
; the .IF, .ENDIF, and .ELSEIF directives.
; Last update: 1/28/02

INCLUDE Irvine32.inc

.data
TRUE = 1
FALSE = 0
gradeAverage  WORD ?
credits       WORD ?
OkToRegister  BYTE ?

.code
main PROC

	mov gradeAverage,300
	mov credits,14
	call CheckRegistration

	exit
main ENDP

CheckRegistration PROC

	mov OkToRegister,FALSE

	.IF gradeAverage > 350
	   mov OkToRegister,TRUE
	.ELSEIF (gradeAverage > 250) && (credits <= 16)
	   mov OkToRegister,TRUE
	.ELSEIF (credits <= 12)
	   mov OkToRegister,TRUE
	.ENDIF

	ret
CheckRegistration ENDP

END main