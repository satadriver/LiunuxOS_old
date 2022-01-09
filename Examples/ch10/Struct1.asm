TITLE Intro to STRUCT               (Struct1.asm)

; This program demonstrates the STRUC directive.
; 32-bit version.
; Last update: 8/13/01.

INCLUDE Irvine32.inc

COORD STRUCT
  X WORD ?
  Y WORD ?
COORD ENDS

typEmployee STRUCT
	Idnum    BYTE 9 DUP(0)
	Lastname BYTE 30 DUP(0)
	Years    WORD 0
	SalaryHistory DWORD 10 DUP(0)
typEmployee ENDS

.data

; Create instances of the COORD structure,
; assigning values to both X and Y:
point1 COORD <5,10>
point2 COORD <10,20>

worker typEmployee <>

; override all fields. Either angle brackets
; or curly braces can be used:
person1 typEmployee {"555223333"}
person2 typEmployee <"555223333">

; override only the second field:
person3 typEmployee <,"Jones">

; skip the first three fields, and
; use DUP to initialize the last field:
person4 typEmployee <,,,3 DUP(20000)>

; Create an array of COORD objects:
NumPoints = 3
AllPoints COORD NumPoints DUP(<0,0>)

.code
main PROC


; Get the offset of a field within a structure:
	mov edx,OFFSET typEmployee.SalaryHistory

; The following generates an "undefined identifier" error:
	;mov edx,OFFSET Salary

; The TYPE, LENGTH, and SIZE operators can be applied
; to the structure and its fields:
	mov eax,TYPE typEmployee			; 82
	mov eax,SIZE typEmployee
	mov eax,SIZE worker
	mov eax,SIZEOF worker

	mov eax,TYPE typEmployee.SalaryHistory	; 4
	mov eax,LENGTH typEmployee.SalaryHistory	; 10
	mov eax,SIZE typEmployee.SalaryHistory	; 40

; The TYPE, LENGTH and SIZE operators can be applied
; to instances of the structure:
	mov eax,TYPE worker		; 82
	mov eax,TYPE worker.Years		; 2

; Indirect operands require the PTR operator:
	mov esi,offset worker
	mov ax,(typEmployee PTR [esi]).Years

; Loop through the array of points and set their
; X and Y values:
	mov edi,0
	mov ecx,NumPoints
	mov ax,1
L1:
	mov (COORD PTR AllPoints[edi]).X,ax
	mov (COORD PTR AllPoints[edi]).X,ax
	add edi,TYPE COORD
	inc ax
	Loop L1

quit:
     exit
main ENDP
END main