TITLE  Link Library Functions		(Irvine16.asm)

Comment @

This library was created exlusively for use with the book,
"Assembly Language for Intel-Based Computers, 4th Edition",
by Kip R. Irvine, 2002.

Copyright 2002, Prentice-Hall Incorporated. No part of this file may be
reproduced, in any form or by any other means, without permission in writing
from the publisher.

Updates to this file will be posted at the book's site:
www.nuvisionmiami.com/books/asm

Acknowledgements:
------------------------------
Most of the code in this library was written by Kip Irvine.
Special thanks to Gerald Cahill for his many insights, suggestions, and bug fixes!
Also to Courtney Amor, a student at UCLA.

Alphabetical Listing of Procedures
----------------------------------
(Unless otherwise marked, all procedures are documented in Chapter 5.)

ClrScr
Crlf
Delay
DumpMem
DumpRegs
GetCommandTail
GetDateTime	Chapter 11
GetMseconds
Gotoxy
IsDigit
Random32
Randomize
RandomRange
ReadChar
ReadHex
ReadInt
ReadString
SetTextColor
Str_compare	Chapter 9
Str_copy	Chapter 9
Str_length	Chapter 9
Str_trim	Chapter 9
Str_ucase	Chapter 9
WaitMsg
WriteBin
WriteChar
WriteDec
WriteHex
WriteInt
WriteString
=================================@

INCLUDE Irvine16.inc

; Write <count< spaces to standard output

WriteSpace MACRO count
Local spaces
.data
spaces BYTE count dup(' '),0
.code
	mov  dx,OFFSET spaces
	call WriteString
ENDM

; Send a newline sequence to standard output

NewLine MACRO
Local temp
.data
temp BYTE 13,10,0
.code
	push dx
	mov  dx,OFFSET temp
	call WriteString
	pop  dx
ENDM

;-------------------------------------
ShowRegister MACRO regName, regVal
	        Local str
;
; Show a single register value
;-------------------------------------
.data
str  BYTE  "  &regName=",0
.code
	push eax

	push edx	; save EDX
	mov  dx,OFFSET str
	call WriteString
	pop  edx	; must restore EDX now
IF (TYPE regVal) EQ 4
	mov  eax,regVal	; register value
ELSE
	mov  eax,0
	mov  ax,regVal
ENDIF
	call WriteHex

	pop  eax
ENDM

;-------------------------------------
ShowFlag MACRO flagName,shiftCount
	    LOCAL flagStr, flagVal, L1
;
; Display a single flag value
;-------------------------------------

.data
flagStr BYTE "  &flagName="
flagVal BYTE ?,0

.code
	push ax
	push dx

	mov  ax,flags	; retrieve the flags
	mov  flagVal,'1'
	shr  ax,shiftCount	; shift into carry flag
	jc   L1
	mov  flagVal,'0'
L1:
	mov  dx,OFFSET flagStr	; display flag name and value
	call WriteString

	pop  dx
	pop  ax
ENDM

;--------- END OF MACRO DEFINITIONS ---------------------------


;********************* SHARED DATA AREA **********************
.data?
buffer BYTE 512 dup(?)

;*************************************************************

.code
;------------------------------------------------------
Clrscr PROC
;
; Clears the screen (video page 0) and locates the cursor
; at row 0, column 0.
; Receives: nothing
; Returns:  nothing
;-------------------------------------------------------
	pusha
	mov     ax,0600h    	; scroll window up
	mov     cx,0        	; upper left corner (0,0)
	mov     dx,184Fh    	; lower right corner (24,79)
	mov     bh,7        	; normal attribute
	int     10h         	; call BIOS
	mov     ah,2        	; locate cursor at 0,0
	mov     bh,0        	; video page 0
	mov     dx,0	; row 0, column 0
	int     10h
	popa
	ret
Clrscr ENDP

;-----------------------------------------------------
Crlf PROC
;
; Writes a carriage return / linefeed
; sequence (0Dh,0Ah) to standard output.
;-----------------------------------------------------
	NewLine	; invoke a macro
	ret
Crlf ENDP


;-----------------------------------------------------------
Delay PROC
;
; Create an n-millisecond delay.
; Receives: EAX = milliseconds
; Returns: nothing
; Remarks: May only used under Windows 95, 98, or ME. Does
; not work under Windows NT, 2000, or XP, because it
; directly accesses hardware ports.
; Source: "The 80x86 IBM PC & Compatible Computers" by
; Mazidi and Mazidi, page 343. Prentice-Hall, 1995.
;-----------------------------------------------------------

MsToMicro = 1000000	; convert ms to microseconds
ClockFrequency = 15085	; microseconds per tick
.code
	pushad
; Convert milliseconds to microseconds.
	mov  ebx,MsToMicro
	mul  ebx

; Divide by clock frequency of 15.085 microseconds,
; producing the counter for port 61h.
	mov  ebx,ClockFrequency
	div  ebx	; eax = counter
	mov  ecx,eax

; Begin checking port 61h, watching bit 4 toggle
; between 1 and 0 every 15.085 microseconds.
L1:
	in  al,61h	; read port 61h
	and al,10h	; clear all bits except bit 4
	cmp al,ah	; has it changed?
	je  L1	; no: try again
	mov ah,al	; yes: save status
	dec ecx
	cmp ecx,0	; loop finished yet?
	ja  L1

quit:
	popad
	ret
Delay ENDP


;---------------------------------------------------
DumpMem PROC
	   LOCAL unitsize:word, byteCount:word
;
; Writes a range of memory to standard output
; in hexadecimal.
; Receives: SI = starting OFFSET, CX = number of units,
;           BX = unit size (1=byte, 2=word, or 4=doubleword)
; Returns:  nothing
;---------------------------------------------------
.data
oneSpace   BYTE ' ',0
dumpPrompt BYTE 13,10,"Dump of offset ",0
.code
	pushad

	mov  dx,OFFSET dumpPrompt
	call WriteString
	movzx eax,si
	call  WriteHex
	NewLine

	mov  byteCount,0
	mov  unitsize,bx
	cmp  bx,4	; select output size
	je   L1
	cmp  bx,2
	je   L2
	jmp  L3

L1:	; doubleword output
	mov  eax,[si]
	call WriteHex
	WriteSpace 2
	add  si,bx
	Loop L1
	jmp  L4

L2:	; word output
	mov  ax,[si]	; get a word from memory
	ror  ax,8	; display high byte
	call HexByte
	ror  ax,8	; display low byte
	call HexByte
	WriteSpace 1	; display 1 space
	add  si,unitsize	; point to next word
	Loop L2
	jmp  L4

; Byte output: 16 bytes per line

L3:
	mov  al,[si]
	call HexByte
	inc  byteCount
	WriteSpace 1
	inc  si

	; if( byteCount mod 16 == 0 ) call Crlf

	mov  dx,0
	mov  ax,byteCount
	mov  bx,16
	div  bx
	cmp  dx,0
	jne  L3B
	NewLine
L3B:
	Loop L3
	jmp  L4

L4:
	NewLine
	popad
	ret
DumpMem ENDP

;--------------------------------------------------
Get_Commandtail PROC
;
; Gets a copy of the DOS command tail at PSP:80h.
; Receives: DX contains the offset of the buffer
; that receives a copy of the command tail.
; Returns: CF=1 if the buffer is empty; otherwise,
; CF=0.
; Last update: 11/11/01
;--------------------------------------------------
    push es
	pusha	; save general registers

	mov  ah,62h	; get PSP segment address
	int  21h	; returned in BX
	mov  es,bx	; copied to ES

	mov  si,dx	; point to buffer
	mov  di,81h	; PSP offset of command tail
	mov  cx,0	; byte count
	mov  cl,es:[di-1]	; get length byte
	cmp  cx,0	; is the tail empty?
	je   L2	; yes: exit
	cld	; no: scan forward
	mov  al,20h	; space character
	repz scasb	; scan for non space
	jz   L2	; all spaces found
	dec  di	; non space found
	inc  cx

L1: mov  al,es:[di]	; copy tail to buffer
	mov  [si],al	; pointed to by DS:SI
	inc  si
	inc  di
	loop L1
	clc	; CF=0 means tail found
	jmp  L3

L2:	stc	; set carry: no command tail
L3:	mov byte ptr [si],0	; store null byte
	popa	; restore registers
	pop es
	ret
Get_Commandtail ENDP

;---------------------------------------------------
Gotoxy PROC
;
; Sets the cursor position on video page 0.
; display page.
; Receives: DH,DL = row, column
; Returns: nothing
;---------------------------------------------------
	pusha
	mov ah,2
	mov bh,0
	int 10h
	popa
	ret
Gotoxy ENDP


HexByte PROC
	LOCAL theByte:BYTE
; Display the byte in AL in hexadecimal
; Called only by DumpMem. Updated 9/21/01

	pusha
	mov  theByte,al	; save the byte
	mov  cx,2

HB1:
	rol  theByte,4
	mov  al,theByte
	and  al,0Fh
	mov  bx,OFFSET xtable
	xlat

	; insert hex char in the buffer
	; and display using WriteString
	mov  buffer,al
	mov  [buffer+1],0
	mov  dx,OFFSET buffer
	call WriteString

	Loop HB1

	popa
	ret
HexByte ENDP

;---------------------------------------------------
DumpRegs PROC
;
; Displays EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP in
; hexadecimal. Also displays the Zero, Sign, Carry, and
; Overflow flags.
; Receives: nothing.
; Returns: nothing.
;
; Warning: do not create any local variables or stack
; parameters, because they will alter the EBP register.
;---------------------------------------------------
.data
flags  WORD  ?
saveIP WORD ?
saveSP WORD ?
.code
	pop saveIP	; get current IP
	mov saveSP,sp	; save SP's value at entry
	push saveIP	; replace it on stack
	push eax
	pushfd	; push flags

	pushf	; copy flags to a variable
	pop  flags

	NewLine
	ShowRegister EAX,EAX
	ShowRegister EBX,EBX
	ShowRegister ECX,ECX
	ShowRegister EDX,EDX
	NewLine
	ShowRegister ESI,ESI
	ShowRegister EDI,EDI

	ShowRegister EBP,EBP

	movzx eax,saveSP
	ShowRegister ESP,EAX
	NewLine

	movzx eax,saveIP
	ShowRegister EIP,EAX

	movzx eax,flags
	ShowRegister EFL,EAX

; Show the flags
	ShowFlag CF,1
	ShowFlag SF,8
	ShowFlag ZF,7
	ShowFlag OF,12

	NewLine
	NewLine

	popfd	; restore flags
	pop eax	; restore EAX
	ret
DumpRegs ENDP

;---------------------------------------------------
Get_time PROC
;
; Get the current system time.Input parameter:
; DS:SI points to a TimeRecord structure.
; PRIVATE FUNCTION
;---------------------------------------------------
	 pushad
	 mov ah,2Ch
	 int 21h
	 mov (TimeRecord ptr [si]).hours,ch
	 mov (TimeRecord ptr [si]).minutes,cl
	 mov (TimeRecord ptr [si]).seconds,dh
	 mov (TimeRecord ptr [si]).hhss,dl
	 popad
	 ret
Get_time ENDP

;-----------------------------------------------
Isdigit PROC
;
; Determines whether the character in AL is a
; valid decimal digit.
; Receives: AL = character
; Returns: ZF=1 if AL contains a valid decimal
;   digit; otherwise, ZF=0.
;-----------------------------------------------
	 cmp   al,'0'
	 jb    ID1
	 cmp   al,'9'
	 ja    ID1
	 test  ax,0     		; set ZF = 1
ID1: ret
Isdigit ENDP

;--------------------------------------------------------------
RandomRange PROC
;
; Returns an unsigned pseudo-random 32-bit integer
; in EAX, between 0 and n-1. Input parameter:
; EAX = n.
;--------------------------------------------------------------
	push  bp
	mov   bp,sp
	push  ebx
	push  edx

	mov   ebx,eax  ; maximum value
	call  Random32 ; eax = random number
	mov   edx,0
	div   ebx      ; divide by max value
	mov   eax,edx  ; return the remainder

	pop   edx
	pop   ebx
	pop   bp
	ret
RandomRange ENDP

;--------------------------------------------------------------
Random32  PROC
;
; Returns an unsigned pseudo-random 32-bit integer
; in EAX,in the range 0 - FFFFFFFFh.
;--------------------------------------------------------------
.data
seed  dd 1
.code
	push  edx
	mov   eax, 343FDh
	imul  seed
	add   eax, 269EC3h
	mov   seed, eax    ; save the seed for the next call
	ror   eax,8        ; rotate out the lowest digit (10/22/00)
	pop   edx
	ret
Random32  ENDP

;--------------------------------------------------------
Randomize PROC
;
; Re-seeds the random number generator with the current time
; in seconds.
;
;--------------------------------------------------------
	push eax
	call Seconds_today
	mov  seed,eax
	pop  eax
	ret
Randomize ENDP

;---------------------------------------------------------
ReadChar PROC
;
; Reads one character from standard input and echoes
; on the screen. Waits for the character if none is
; currently in the input buffer.
; Receives: nothing
; Returns:  AL = ASCII code
;----------------------------------------------------------
	mov  ah,1
	int  21h
	ret
ReadChar ENDP

;--------------------------------------------------------
ReadHex PROC
;
; Reads a 32-bit hexadecimal integer from standard input,
; stopping when the Enter key is pressed.
; Receives: nothing
; Returns: EAX = binary integer value
; Remarks: No error checking performed for bad digits
; or excess digits.
; Last update: 11/7/01
;--------------------------------------------------------
.data
HMAX_DIGITS = 128
Hinputarea  BYTE  HMAX_DIGITS dup(0),0
xbtable     BYTE 0,1,2,3,4,5,6,7,8,9,7 DUP(0FFh),10,11,12,13,14,15
numVal      DWORD ?
charVal     BYTE ?

.code
	push ebx
	push ecx
	push edx
	push esi

	mov   edx,OFFSET Hinputarea
	mov   esi,edx		; save in ESI also
	mov   ecx,HMAX_DIGITS
	call  ReadString		; input the string
	mov   ecx,eax           		; save length in ECX

	; Start to convert the number.

B4: mov   numVal,0		; clear accumulator
	mov   ebx,OFFSET xbtable		; translate table

	; Repeat loop for each digit.

B5: mov   al,[esi]	; get character from buffer
	cmp al,'F'	; lowercase letter?
	jbe B6	; no
	and al,11011111b	; yes: convert to uppercase

B6:
	sub   al,30h	; adjust for table
	xlat  	; translate to binary
	mov   charVal,al

	mov   eax,16	; numVal *= 16
	mul   numVal
	mov   numVal,eax
	movzx eax,charVal	; numVal += charVal
	add   numVal,eax
	inc   esi	; point to next digit
	loop  B5	; repeat, decrement counter

	mov  eax,numVal	; return binary result
	pop  esi
	pop  edx
	pop  ecx
	pop  ebx
	ret
ReadHex ENDP


;--------------------------------------------------------
ReadInt PROC uses ebx ecx edx esi
  LOCAL Lsign:DWORD, saveDigit:DWORD
;
; Reads a 32-bit signed decimal integer from standard
; input, stopping when the Enter key is pressed.
; All valid digits occurring before a non-numeric character
; are converted to the integer value. Leading spaces are
; ignored, and an optional leading + or - sign is permitted.

; Receives: nothing
; Returns:  If CF=0, the integer is valid, and EAX = binary value.
;   If CF=1, the integer is invalid and EAX = 0.
;
; Credits: Thanks to Courtney Amor, a student at the UCLA Mathematics
; department, for pointing out improvements that have been
; implemented in this version.
; Last update: 1/27/02
;--------------------------------------------------------
.data
LMAX_DIGITS = 80
Linputarea    BYTE  LMAX_DIGITS dup(0),0
overflow_msgL BYTE  " <32-bit integer overflow>",0
invalid_msgL  BYTE  " <invalid integer>",0
.code

; Input a string of digits using ReadString.

	mov   edx,offset Linputarea
	mov   esi,edx           		; save offset in ESI
	mov   ecx,LMAX_DIGITS
	call  ReadString
	mov   ecx,eax           		; save length in CX
	mov   Lsign,1         		; assume number is positive
	cmp   ecx,0            		; greater than zero?
	jne   L1              		; yes: continue
	mov   eax,0            		; no: set return value
	jmp   L10              		; and exit

; Skip over any leading spaces.

L1:	mov   al,[esi]         		; get a character from buffer
	cmp   al,' '          		; space character found?
	jne   L2              		; no: check for a sign
	inc   esi              		; yes: point to next char
	loop  L1
	jcxz  L8              		; quit if all spaces

; Check for a leading sign.

L2:	cmp   al,'-'          		; minus sign found?
	jne   L3              		; no: look for plus sign

	mov   Lsign,-1        		; yes: sign is negative
	dec   ecx              		; subtract from counter
	inc   esi              		; point to next char
	jmp   L4

L3:	cmp   al,'+'          		; plus sign found?
	jne   L4              		; no: must be a digit
	inc   esi              		; yes: skip over the sign
	dec   ecx              		; subtract from counter

; Test the first digit, and exit if it is nonnumeric.

L3A:mov  al,[esi]		; get first character
	call IsDigit		; is it a digit?
	jnz  L7A		; no: show error message

; Start to convert the number.

L4:	mov   eax,0           		; clear accumulator
	mov   ebx,10          		; EBX is the divisor

; Repeat loop for each digit.

L5:	mov  dl,[esi]		; get character from buffer
	cmp  dl,'0'		; character < '0'?
	jb   L9
	cmp  dl,'9'		; character > '9'?
	ja   L9
	and  edx,0Fh		; no: convert to binary

	mov  saveDigit,edx
	imul ebx		; EDX:EAX = EAX * EBX
	mov  edx,saveDigit

	jo   L6		; quit if overflow
	add  eax,edx         		; add new digit to AX
	jo   L6		; quit if overflow
	inc  esi              		; point to next digit
	jmp  L5		; get next digit

; Overflow has occured, unlesss EAX = 80000000h
; and the sign is negative:

L6: cmp  eax,80000000h
	jne  L7
	cmp  Lsign,-1
	jne  L7		; overflow occurred
	jmp  L9		; the integer is valid

; Choose "integer overflow" messsage.

L7:	mov  edx,OFFSET overflow_msgL
	jmp  L8

; Choose "invalid integer" message.

L7A:
	mov  edx,OFFSET invalid_msgL

; Display the error message pointed to by EDX.

L8:	call WriteString
	call Crlf
	stc		; set Carry flag
	mov  eax,0            		; set return value to zero
	jmp  L10		; and exit

L9: imul Lsign           		; EAX = EAX * sign

L10:ret
ReadInt ENDP


;--------------------------------------------------------
ReadString PROC
; Reads a string from standard input and places the
; characters in a buffer. Reads past end of line,
; and removes the CF/LF from the string.
; Receives: DS:DX points to the input buffer,
;           CX = maximum characters that may be typed.
; Returns:  AX = size of the input string.
; Comments: Stops when the Enter key (0Dh) is pressed.
;--------------------------------------------------------
	push cx		; save registers
	push si
	push cx		; save digit count again
	mov  si,dx		; point to input buffer

L1:	mov  ah,1		; function: keyboard input
	int  21h		; DOS returns char in AL
	cmp  al,0Dh		; end of line?
	je   L2		; yes: exit
	mov  [si],al		; no: store the character
	inc  si		; increment buffer pointer
	loop L1		; loop until CX=0

L2:	mov  byte ptr [si],0		; end with a null byte
	pop  ax		; original digit count
	sub  ax,cx		; AX = size of input string
	pop  si		; restore registers
	pop  cx
	ret
ReadString ENDP


;-------------------------------------------------------
Seconds_today PROC
;
; Returns a count of the number of seconds that
; have elapsed today. Output: EAX contains the
; return value. Range: 0 - 86,399
;--------------------------------------------------------
.data
timerec TimeRecord <>
saveSec  DWORD  ?

.code
	push ebx
	push si

	mov  si,OFFSET timerec
	call Get_time

 ; calculate # seconds based on hours.
	xor  eax,eax
	mov  al,(TimeRecord ptr [si]).hours
	mov  ebx,3600
	mul  ebx
	mov  saveSec,eax

 ; multiply minutes by 60

	xor  eax,eax
	mov  al,(TimeRecord ptr [si]).minutes
	mov  ebx,60
	mul  ebx
	add  saveSec,eax

	xor  eax,eax
	mov  al,(TimeRecord ptr [si]).seconds
	add  eax,saveSec

	pop  si
	pop  ebx
	ret
Seconds_today ENDP


;----------------------------------------------------------
Str_compare PROC USES ax dx si di,
	string1:PTR BYTE,
	string2:PTR BYTE
;
; Compare two strings.
; Returns nothing, but the Zero and Carry flags are affected
; exactly as they would be by the CMP instruction.
; Last update: 1/18/02
;-----------------------------------------------------
    mov  si,string1
    mov  di,string2

L1: mov  al,[si]
    mov  dl,[di]
    cmp  al,0    			; end of string1?
    jne  L2      			; no
    cmp  dl,0    			; yes: end of string2?
    jne  L2      			; no
    jmp  L3      			; yes, exit with ZF = 1

L2: inc  si      			; point to next
    inc  di
    cmp  al,dl   			; chars equal?
    je   L1      			; yes: continue loop
                 			; no: exit with flags set
L3: ret
Str_compare ENDP

;---------------------------------------------------------
Str_copy PROC USES ax cx si di,
 	source:PTR BYTE, 		; source string
 	target:PTR BYTE		; target string
;
; Copy a string from source to target.
; Requires: the target string must contain enough
;           space to hold a copy of the source string.
; Last update: 1/18/02
;----------------------------------------------------------
	INVOKE Str_length,source 		; AX = length source
	mov cx,ax		; REP count
	inc cx         		; add 1 for null byte
	mov si,source
	mov di,target
	cld               		; direction = up
	rep movsb      		; copy the string
	ret
Str_copy ENDP

;---------------------------------------------------------
Str_length PROC USES di,
	pString:PTR BYTE	; pointer to string
;
; Return the length of a null-terminated string.
; Receives: pString - pointer to a string
; Returns: AX = string length
; Last update: 1/18/02
;---------------------------------------------------------
	mov di,pString
	mov ax,0     	; character count
L1:
	cmp byte ptr [di],0	; end of string?
	je  L2	; yes: quit
	inc di	; no: point to next
	inc ax	; add 1 to count
	jmp L1
L2: ret
Str_length ENDP


;-----------------------------------------------------------
Str_trim PROC USES ax cx di,
	pString:PTR BYTE,		; points to string
	char:BYTE		; char to remove
;
; Remove all occurences of a given character from
; the end of a string.
; Returns: nothing
; Last update: 1/18/02
;-----------------------------------------------------------
	mov  di,pString
	INVOKE Str_length,di		; returns length in AX
	cmp  ax,0		; zero-length string?
	je   L2		; yes: exit
	mov  cx,ax		; no: counter = string length
	dec  ax
	add  di,ax		; DI points to last char
	mov  al,char		; char to trim
	std		; direction = reverse
	repe scasb		; skip past trim character
	jne  L1		; removed first character?
	dec  di		; adjust DI: ZF=1 && ECX=0
L1:	mov  BYTE PTR [di+2],0		; insert null byte
L2:	ret
Str_trim ENDP

;---------------------------------------------------
Str_ucase PROC USES ax si,
	pString:PTR BYTE
; Convert a null-terminated string to upper case.
; Receives: pString - a pointer to the string
; Returns: nothing
; Last update: 1/18/02
;---------------------------------------------------
	mov si,pString
L1:
	mov al,[si]		; get char
	cmp al,0		; end of string?
	je  L3		; yes: quit
	cmp al,'a'		; below "a"?
	jb  L2
	cmp al,'z'		; above "z"?
	ja  L2
	and BYTE PTR [si],11011111b		; convert the char

L2:	inc si		; next char
	jmp L1

L3: ret
Str_ucase ENDP

;------------------------------------------------------
WaitMsg PROC
;
; Displays "Press any key to continue"
; Receives: nothing
; Returns: nothing
;------------------------------------------------------
.data
waitmsgstr BYTE "Press any key to continue...",0
.code
	push dx
	mov  dx,OFFSET waitmsgstr
	call WriteString
	call ReadChar
	NewLine
	pop  dx
	ret
WaitMsg ENDP

;------------------------------------------------------
WriteBin PROC
;
; Writes a 32-bit integer to standard output in
; binary format.
; Receives: EAX = the integer to write
;------------------------------------------------------
.code
	push  eax
	push  ecx
	push  edx
	mov   cx,32	; number of bits in AX
	mov   si,OFFSET buffer

WB1:
	shl   eax,1	; shift EAX left into Carry flag
	mov   byte ptr [si],'0'	; choose '0' as default digit
	jnc   WB2	; if no carry, then jump to L2
	mov   byte ptr [si],'1'	; else move '1' to DL

WB2:
	inc   si
	loop  WB1	; shift another bit to left

	mov  byte ptr [si],0	; insert null byte at end
	mov  dx,OFFSET buffer	; display the buffer
	call WriteString

	pop  edx
	pop  ecx
	pop  eax
	ret
WriteBin ENDP


;------------------------------------------------------
WriteChar PROC
;
; Write a character to standard output
; Recevies: AL = character
;------------------------------------------------------
	push ax
	push dx
	mov  ah,2
	mov  dl,al
	int  21h
	pop  dx
	pop  ax
	ret
WriteChar ENDP


;-----------------------------------------------------
WriteDec PROC
;
; Writes an unsigned 32-bit decimal number to
; standard output. Input parameters: EAX = the
; number to write.
;
;------------------------------------------------------
.data
; There will be as many as 10 digits.
BUFFER_SIZE = 12

bufferL BYTE BUFFER_SIZE dup(?),0
xtable BYTE "0123456789ABCDEF"

.code
	pushad               ; save all 32-bit data registers
	mov   cx,0           ; digit counter
	mov   di,OFFSET bufferL
	add   di,(BUFFER_SIZE - 1)
	mov   ebx,10	; decimal number base

WI1:
	mov   edx,0          ; clear dividend to zero
	div   ebx            ; divide EAX by the radix

	xchg  eax,edx        ; swap quotient, remainder
	call  AsciiDigit     ; convert AL to ASCII
	mov   [di],al        ; save the digit
	dec   di             ; back up in buffer
	xchg  eax,edx        ; swap quotient, remainder

	inc   cx             ; increment digit count
	or    eax,eax        ; quotient = 0?
	jnz   WI1            ; no, divide again

	; Display the digits (CX = count)
WI3:
	inc   di
	mov   dx,di
	call  WriteString

WI4:
	popad	; restore 32-bit registers
	ret
WriteDec ENDP

; Convert AL to an ASCII digit.

AsciiDigit PROC private
	push  bx
	mov   bx,OFFSET xtable
	xlat
	pop   bx
	ret
AsciiDigit ENDP

;------------------------------------------------------
WriteHex PROC
;
; Writes an unsigned 32-bit hexadecimal number to
; standard output.
; Input parameters: EAX = the number to write.
;
;------------------------------------------------------

DISPLAY_SIZE = 8          ; total number of digits to display

.data
bufferLH BYTE DISPLAY_SIZE dup(?),0

.code
	pushad               ; save all 32-bit data registers
	mov   cx,0           ; digit counter
	mov   di,OFFSET bufferLH
	add   di,(DISPLAY_SIZE - 1)
	mov   ebx,16	     ; hexadecimal base

WLH1:
	mov   edx,0          ; clear dividend to zero
	div   ebx            ; divide EAX by the radix

	xchg  eax,edx        ; swap quotient, remainder
	call  AsciiDigit     ; convert AL to ASCII
	mov   [di],al        ; save the digit
	dec   di             ; back up in buffer
	xchg  eax,edx        ; swap quotient, remainder

	inc   cx             ; increment digit count
	or    eax,eax        ; quotient = 0?
	jnz   WLH1           ; no, divide again

	; Insert leading zeros

	mov   ax,DISPLAY_SIZE
	sub   ax,cx
	jz    WLH3           ; display now if no leading zeros required
	mov   cx,ax          ; CX = number of leading zeros to insert

WLH2:
	mov   byte ptr [di],'0'   ; insert a zero
	dec   di                  ; back up
	loop  WLH2                ; continue the loop

	; Display the digits

WLH3:
	mov   cx,DISPLAY_SIZE
	inc   di
	mov   dx,di
	call  WriteString

	popad     ; restore 32-bit registers
	ret
WriteHex ENDP


;-----------------------------------------------------
WriteInt PROC
;
; Writes a 32-bit signed binary integer to standard output
; in ASCII decimal.
; Receives: EAX = the integer
; Returns:  nothing
; Comments: Displays a leading sign, no leading zeros.
;-----------------------------------------------------
WI_Bufsize = 12
true  =   1
false =   0
.data
buffer_B  BYTE  WI_Bufsize dup(0),0  ; buffer to hold digits
neg_flag  BYTE  ?

.code
	 pushad

	 mov   neg_flag,false    ; assume neg_flag is false
	 or    eax,eax             ; is AX positive?
	 jns   WIS1              ; yes: jump to B1
	 neg   eax                ; no: make it positive
	 mov   neg_flag,true     ; set neg_flag to true

WIS1:
	 mov   cx,0              ; digit count = 0
	 mov   di,OFFSET buffer_B
	 add   di,(WI_Bufsize-1)
	 mov   ebx,10             ; will divide by 10

WIS2:
	 mov   edx,0              ; set dividend to 0
	 div   ebx                ; divide AX by 10
	 or    dl,30h            ; convert remainder to ASCII
	 dec   di                ; reverse through the buffer
	 mov   [di],dl           ; store ASCII digit
	 inc   cx                ; increment digit count
	 or    eax,eax             ; quotient > 0?
	 jnz   WIS2              ; yes: divide again

	 ; Insert the sign.

	 dec   di	; back up in the buffer
	 inc   cx               	; increment counter
	 mov   byte ptr [di],'+' 	; insert plus sign
	 cmp   neg_flag,false    	; was the number positive?
	 jz    WIS3              	; yes
	 mov   byte ptr [di],'-' 	; no: insert negative sign

WIS3:	; Display the number
	mov  dx,di
	call WriteString

	popad
	ret
WriteInt ENDP


;--------------------------------------------------------
WriteString PROC
; Writes a null-terminated string to standard output
; Receives: DS:DX points to the string
; Returns: nothing
;--------------------------------------------------------
	pusha
	push ds           		; set ES to DS
	pop  es
	mov  di,dx        		; ES:DI = string ptr
	INVOKE Str_length, DX   		; AX = string length
	mov  cx,ax        		; CX = number of bytes
	mov  ah,40h       		; write to file or device
	mov  bx,1         		; standard output handle
	int  21h          		; call MS-DOS
	popa
	ret
WriteString ENDP

END