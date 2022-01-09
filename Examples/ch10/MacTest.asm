TITLE Macro Library Test               (MacTest.asm)

; This program demonstrates various macros from
; the Macros.inc file.
; Last update: 1/19/02

INCLUDE Irvine32.inc
INCLUDE Macros.inc

NAME_SIZE = 30

.data
str1 BYTE NAME_SIZE DUP(?)
array DWORD 5 DUP(12345678h)

.code
main PROC
	mGotoxy 10,0
	mDumpMem OFFSET array, LENGTHOF array, TYPE array

	mGotoxy 10,8
	mWrite "Please enter your first name: "
	mReadStr OFFSET str1, 10

	mGotoxy 10,10
	mWrite "Your name is "
	mWriteStr str1
	NewLine

	exit
main ENDP
END main