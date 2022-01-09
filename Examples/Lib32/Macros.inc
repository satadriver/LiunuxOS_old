.NOLIST

Comment !
; (Macros.inc) - Include file containing Macros for Irvine32.lib.
; Last update: 1/19/02

; List of macros in this file:

IsDefined MACRO symbol
	-- Return -1 if a symbol has been defined, or else return 0

mDumpMem MACRO address, itemCount, componentSize
	-- Display a dump of a range of memory

mGotoxy MACRO X:REQ, Y:REQ
	-- Set the cursor position

mReadStr MACRO bufferPtr, maxChars
	-- Read from standard input into a buffer

mWrite MACRO text
	-- Write a string literal to standard output

mWriteLn MACRO text
	-- Write a literal string to standard output,
	-- and append an end of line

mWriteStr MACRO buffer
	-- Write a string variable to standard output

NewLine MACRO
	--  Send a newline sequence to standard output

Startup MACRO
	-- Initialize DS & ES for 16-bit Real-mode program

WriteSpace MACRO count
	-- Write <count< spaces to standard output

*********** end of comments ! ******************************

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
	  mov es,ax
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

WriteSpace MACRO count
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
; Write a string literal to standard output
;------------------------------------------------------
	LOCAL string
	.data		;; local data
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
mReadStr MACRO bufferPtr, maxChars
;
; Read from standard input into a buffer.
;------------------------------------------------------
	IFIDNI <maxChars>,<EDX>
	   ECHO Warning: Second argument to mReadStr cannot be EDX
	   ECHO **************************************************
	   EXITM
	ENDIF
	push ecx
	push edx
	mov  edx,bufferPtr
	mov  ecx,maxChars
	call ReadString
	pop  edx
	pop  ecx
ENDM

;------------------------------------------------------
mDumpMem MACRO address, itemCount, componentSize
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