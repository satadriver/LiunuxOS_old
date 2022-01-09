TITLE Procedure Wrapper Macros        (Wraps.ASM)

; This program demonstrates macros as wrappers
; for library procedures. Contents: mGotoxy, mWrite,
; mWriteLn, mWriteStr, mReadStr, and mDumpMem.
; Last update: 8/15/01.

INCLUDE Irvine32.inc
INCLUDE Macros.inc	; macro definitions

.data
array DWORD 1,2,3,4,5,6,7,8
firstName BYTE 31 DUP(?)
lastName  BYTE 31 DUP(?)

.code
main PROC
	mGotoxy 20,0
	mWriteLn "Sample Macro Program"

	mGotoxy 0,5
	mWrite "Please enter your first name: "
	mReadStr OFFSET firstName, 30
	call Crlf

	mWrite "Please enter your last name: "
	mReadStr OFFSET lastName, 30
	call Crlf

; Display the person's complete name:
	mWrite "Your name is "
	mWriteStr firstName
	mWrite " "
	mWriteStr lastName

	call Crlf
	mDumpMem OFFSET array,8,4

	exit
main ENDP
END main