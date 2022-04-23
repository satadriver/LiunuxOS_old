TITLE Read From the Console         (ReadConsole.asm)

; Read a line of input from standard input.
; Last update: 1/20/02

INCLUDE Irvine32.inc

BufSize = 80

.data
buffer BYTE BufSize DUP(?),0,0
stdInHandle DWORD ?
bytesRead   DWORD ?

.code
main PROC
	; Get handle to standard input
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdInHandle,eax

	; Wait for user input
	INVOKE ReadConsole, stdInHandle, ADDR buffer,
	  BufSize - 2, ADDR bytesRead, 0

	; Display the buffer
	mov  esi,OFFSET buffer
	mov  ecx,16	; 16 bytes
	mov  ebx,TYPE buffer
	call DumpMem

	exit
main ENDP
END main