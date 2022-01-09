TITLE Calculate Elapsed Time               (Timer.asm)

; Demonstrate a simple stopwatch timer, using
; the Win32 GetTickCount function.
; Last update: 1/21/02

INCLUDE Irvine32.inc

TimerStart PROTO,
	pSavedTime: PTR DWORD

TimerStop PROTO,
	pSavedTime: PTR DWORD

.data
msg BYTE " milliseconds have elapsed",0dh,0ah,0
timer1 DWORD ?

.code
main PROC
	INVOKE TimerStart,	; start the timer
	  ADDR timer1

	INVOKE Sleep, 5000	; sleep for a while

	INVOKE TimerStop, 	; EAX = elapsed milliseconds
	  ADDR timer1

	call WriteDec	; display elapsed time
	mov  edx,OFFSET msg
	call WriteString

	exit
main ENDP

;--------------------------------------------------
TimerStart PROC uses eax esi,
	pSavedTime: PTR DWORD
; Starts a stopwatch timer.
; Receives: pointer to a variable that will hold
;    the current time.
; Returns: nothing
;--------------------------------------------------
	INVOKE GetTickCount
	mov    esi,pSavedTime
	mov    [esi],eax
	ret
TimerStart ENDP

;--------------------------------------------------
TimerStop PROC uses esi,
	pSavedTime: PTR DWORD
;
; Stops the current stopwatch timer.
; Receives: pointer to a variable holding the
;           saved time
; Returns: EAX = number of elapsed milliseconds
; Remarks: Accurate to about 10ms
;--------------------------------------------------
	INVOKE GetTickCount
	mov esi,pSavedTime
	sub  eax,[esi]

	ret
TimerStop ENDP

END main