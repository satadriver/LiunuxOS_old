TITLE Repeat Block Examples         (Repeat.asm)

; This program demonstrates the REPEAT, FOR,
; FORC, and WHILE directives.
; Last update: 2/30/02

INCLUDE Irvine32.inc
INCLUDE Macros.inc

COURSE STRUCT
  Number  BYTE 9 DUP(?)
  Credits BYTE ?
COURSE ENDS

; A semester contains an array of courses.
SEMESTER STRUC
	Courses COURSE 6 DUP(<>)
	NumCourses WORD ?
SEMESTER ENDS

.data

; Create a character lookup table:
Delimiters LABEL BYTE
FORC code,<@#$%^&*!<!>>
  BYTE "&code"
ENDM
BYTE 0  	; marks the end

; Generate Fibonacci numbers up to 0FFFFh
f1  = 1
f2  = 1
f3 = f1 + f2
DWORD f1,f2

WHILE f3 LT 0FFFFh
	DWORD f3
	f1 = f2
	f2 = f3
	f3 = f1 + f2
ENDM

ECHO ---------------------------------------------------------

iVal = 10
REPEAT 100                 	; begin REPT loop
	DWORD iVal	; status
	iVal = iVal + 10
ENDM

; Define a set of semester variables.
FOR semName,<Fall1999,Spring2000,Summer2000,Fall2000,Spring2001,Summer2001>
	semName SEMESTER <>
ENDM

.code
main PROC
	mov esi,OFFSET Fall1999
	mov ecx,2
L1:
	mov edx,esi
	add edx,OFFSET COURSE.Number
	mWrite "Enter a course name: "
	mReadStr edx,8
	mWrite "Enter the credits: "
	call ReadInt
	mov  (COURSE PTR [esi]).Credits,al
	add esi,SIZEOF COURSE
	Loop L1

    exit
main ENDP
END main