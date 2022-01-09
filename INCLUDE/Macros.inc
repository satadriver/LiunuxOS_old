.NOLIST
; (Macros.inc) - Include file containing Macros for Irvine32.lib.
; Last update: 3/16/02

IsDefined MACRO symbol
    IFDEF symbol
        EXITM <-1>              ;; True
    ELSE
        EXITM <0>               ;; False
    ENDIF
ENDM

Startup MACRO
	IF IsDefined( RealMode )
  	  mov ax,@data
	  mov ds,ax
	ENDIF
ENDM


; Send a newline sequence to standard output

NewLine MACRO
LOCAL temp
.data
temp BYTE 13,10,0
.code
	pushfd
	push edx
	mov  edx,OFFSET temp
	call WriteString
	pop  edx
	popfd
ENDM


; Write <count< spaces to standard output

WriteSpace macro count
Local spaces
.data
spaces DB count dup(' '),0
.code
	mov  edx,offset spaces
	call WriteString
endm

mNewLine MACRO
	call Gotoxy
ENDM

;-------------------------------------
ShowFlag macro flagName,shiftCount
	     LOCAL flagStr, flagVal, L1
;
; Display a single CPU flag value
; Directly accesses the eflags variable
;-------------------------------------

.data
flagStr DB "  &flagName="
flagVal DB ?,0

.code
	push eax
	push edx

	mov  eax,eflags	; retrieve the flags
	mov  flagVal,'1'
	shr  eax,shiftCount	; shift into carry flag
	jc   L1
	mov  flagVal,'0'
L1:
	mov  edx,offset flagStr	; display flag name and value
	call WriteString

	pop  edx
	pop  eax
endm


;---------------------------------------------------
ShowRegister MACRO regName, regValue
	         LOCAL tempStr
;
; Display a register's name and contents.
;---------------------------------------------------
.data
tempStr BYTE "  &regName=",0
.code
	push eax

; Display the register name
	push edx
	mov  edx,OFFSET tempStr
	call WriteString
	pop  edx

; Display the register contents
	mov  eax,regValue
	call WriteHex
	pop  eax
ENDM

;------------------------------------------------------
mGotoxy MACRO X:REQ, Y:REQ
;
; Set the cursor position
;------------------------------------------------------
	push edx
    mov  dh,Y
    mov  dl,X
	call Gotoxy
	pop  edx
ENDM

;------------------------------------------------------
mWrite MACRO text
;
; Write a literal string to standard output
;------------------------------------------------------
	LOCAL string
	.data				;; local data
	string BYTE text,0		;; define the string
	.code
	push edx
	mov  edx,OFFSET string
	call Writestring
	pop  edx
ENDM

;------------------------------------------------------
mWriteLn MACRO text
;
; Write a literal string to standard output, with
; an end of line appended.
;------------------------------------------------------
	mWrite text
	call Crlf
ENDM

;------------------------------------------------------
mWriteStr MACRO buffer
;
; Write a string variable to standard output.
;------------------------------------------------------
	push edx
	mov  edx,OFFSET buffer
	call WriteString
	pop  edx
ENDM

;------------------------------------------------------
mReadStr MACRO varName
;
; Read from standard input into a buffer.
; Input argument must be the name of a variable.
;------------------------------------------------------
	push ecx
	push edx
	mov  edx,OFFSET varName
	mov  ecx,(SIZEOF varName) - 1
	call ReadString
	pop  edx
	pop  ecx
ENDM

;------------------------------------------------------
mDumpMem MACRO address,		;; address of variable
	itemCount,		;; number of items
	componentSize		;; size of each item
;
; Display a dump of memory, using the DumpMem procedure.
;------------------------------------------------------
	push ebx
	push ecx
	push esi
	mov esi,address
	mov ecx,itemCount
	mov ebx,componentSize
	call DumpMem
	pop esi
	pop ecx
	pop ebx
ENDM

.LIST