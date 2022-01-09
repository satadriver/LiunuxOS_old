TITLE Using ReadFile                       (ReadFile.asm)

; Open the file created by WriteFile.asm and display its data.
; Last update: 1/20/02

INCLUDE Irvine32.inc

.data
buffer BYTE 500 DUP(?)
bufSize = ($-buffer)

errMsg BYTE "Cannot open file",0dh,0ah,0
filename     BYTE "output.txt",0
fileHandle   DWORD ?	; handle to output file
byteCount    DWORD ?    	; number of bytes written

.code
main PROC
	INVOKE CreateFile,
	  ADDR filename, GENERIC_READ, DO_NOT_SHARE, NULL,
	  OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0

	mov fileHandle,eax		; save file handle
	.IF eax == INVALID_HANDLE_VALUE
	  mov  edx,OFFSET errMsg		; Display error message
	  call WriteString
	  jmp  QuitNow
	.ENDIF

	INVOKE ReadFile,		; write text to file
	    fileHandle,		; file handle
	    ADDR buffer,		; buffer pointer
	    bufSize,		; number of bytes to write
	    ADDR byteCount,		; number of bytes written
	    0		; overlapped execution flag

	INVOKE CloseHandle, fileHandle

	mov esi,byteCount		; insert null terminator
	mov buffer[esi],0		; into buffer
	mov edx,OFFSET buffer		; display the buffer
	call WriteString

QuitNow:
	exit
main ENDP
END main