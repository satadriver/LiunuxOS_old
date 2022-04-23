Title Irvine32 Link Library Source Code         (Irvine32.asm)

Comment @

This library was created exlusively for use with the book,
"Assembly Language for Intel-Based Computers",
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

	          Implementation Notes:
	          --------------------
1. The Windows Sleep function changes ECX. Remember to save and restore all
   registers before calling other windows functions.
2. The WriteConsole API function will not work if the Direction flag is set.
@

INCLUDE Irvine32.inc	; function prototypes for this library
INCLUDE Macros.inc	; macro defintions

;-------------------------------------
ShowFlag macro flagName,shiftCount
	     LOCAL flagStr, flagVal, L1
;
; Display a single CPU flag value
; Directly accesses the eflags variable in Irvine16.asm/Irvine32.asm
; (This macro cannot be placed in Macros.inc)
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

;********************* SHARED DATA AREA **********************
.data		; initialized data
InitFlag DB 0	; initialization flag

.data?		; uninitialized data
consoleInHandle  dd ?     	; handle to standard input device
consoleOutHandle dd ?     	; handle to standard output device
bytesWritten     dd ?     	; number of bytes written
eflags  DWORD ?

buffer DB 512 dup(?)
bufferMax = ($ - buffer)
bytesRead DD ?
sysTime SYSTEMTIME <>	; system time structure

.code

;---------------------------------------------------
; Check to see if the console handles have been initialized

CheckInit macro
Local exit
	cmp InitFlag,0
	jne exit
	call Initialize
exit:
endm

;--------------------------------------------------
ClrScr proc
;
; Clear the screen by writing blanks to all positions
; Receives: nothing
; Returns: nothing
; Last update: 7/11/01
;--------------------------------------------------------

.data
blanks DB (80 * 25) DUP(' ')
blankSize = ($ - blanks)
upperLeft COORD <0,0>

.code
	pushad
	CheckInit

	INVOKE SetConsoleCursorPosition, consoleOutHandle, upperLeft

	INVOKE WriteConsole,
	    consoleOutHandle,        	; console output handle
	    offset blanks,        		; string pointer
	    blankSize,          	 	; string length
	    offset bytesWritten,  		; returns number of bytes written
	    0

	INVOKE SetConsoleCursorPosition, consoleOutHandle, upperLeft

	popad
	ret
ClrScr endp


;-----------------------------------------------------
Crlf proc
;
; Writes a carriage return / linefeed
; sequence (0Dh,0Ah) to standard output.
;-----------------------------------------------------
	CheckInit
	NewLine	; invoke a macro
	ret
Crlf endp


;------------------------------------------------------
Delay proc
;
; THIS FUNCTION IS NOT IN THE IRVINE16 LIBRARY
; Delay (pause) the current process for a given number
; of milliseconds.
; Receives: EAX = number of milliseconds
; Returns: nothing
; Last update: 7/11/01
;------------------------------------------------------

	pushad
	INVOKE Sleep,eax
	popad
	ret

Delay endp


;---------------------------------------------------
DumpMem proc
	     LOCAL unitsize:dword, byteCount:word
;
; Writes a range of memory to standard output
; in hexadecimal.
; Receives: ESI = starting offset, ECX = number of units,
;           EBX = unit size (1=byte, 2=word, or 4=doubleword)
; Returns:  nothing
; Last update: 7/11/01
;---------------------------------------------------
.data
oneSpace   DB ' ',0

dumpPrompt DB 13,10,"Dump of offset ",0
dashLine   DB "-------------------------------",13,10,0

.code
	pushad

	mov  edx,offset dumpPrompt
	call WriteString
	mov  eax,esi	; get memory offset to dump
	call  WriteHex
	NewLine
	mov  edx,offset dashLine
	call WriteString

	mov  byteCount,0
	mov  unitsize,ebx
	cmp  ebx,4	; select output size
	je   L1
	cmp  ebx,2
	je   L2
	jmp  L3

	; 32-bit doubleword output
L1:
	mov  eax,[esi]
	call WriteHex
	WriteSpace 2
	add  esi,ebx
	Loop L1
	jmp  L4

	; 16-bit word output
L2:
	mov  ax,[esi]	; get a word from memory
	ror  ax,8	; display high byte
	call HexByte
	ror  ax,8	; display low byte
	call HexByte
	WriteSpace 1	; display 1 space
	add  esi,unitsize	; point to next word
	Loop L2
	jmp  L4

	; 8-bit byte output, 16 bytes per line
L3:
	mov  al,[esi]
	call HexByte
	inc  byteCount
	WriteSpace 1
	inc  esi

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
DumpMem endp


;---------------------------------------------------
DumpRegs PROC
;
; Displays EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP in
; hexadecimal. Also displays the Zero, Sign, Carry, and
; Overflow flags.
; Receives: nothing.
; Returns: nothing.
; Last update: 8/23/01
;
; Warning: do not create any local variables or stack
; parameters, because they will alter the EBP register.
;---------------------------------------------------
.data
saveIP  DWORD ?
saveESP DWORD ?
.code
	pop saveIP	; get current EIP
	mov saveESP,esp	; save ESP's value at entry
	push saveIP	; replace it on stack
	push eax	; save EAX (restore on exit)

	pushfd	; push extended flags

	pushfd	; push flags again, and
	pop  eflags	; save them in a variable

	NewLine
	ShowRegister EAX,EAX
	ShowRegister EBX,EBX
	ShowRegister ECX,ECX
	ShowRegister EDX,EDX
	NewLine
	ShowRegister ESI,ESI
	ShowRegister EDI,EDI

	ShowRegister EBP,EBP

	mov eax,saveESP
	ShowRegister ESP,EAX
	NewLine

	mov eax,saveIP
	ShowRegister EIP,EAX
	mov eax,eflags
	ShowRegister EFL,EAX

; Show the flags (using the eflags variable)
	ShowFlag CF,1
	ShowFlag SF,8
	ShowFlag ZF,7
	ShowFlag OF,12

	NewLine
	NewLine

	popfd
	pop eax
	ret
DumpRegs endp

;------------------------------------------------------------
GetCommandTail PROC
;
; Copies the program command line into a buffer.
; Receives: EDX points to a buffer that will receive the data.
; Returns: nothing
;-------------------------------------------------------------
	pushad
	INVOKE GetCommandLine	; Win32 API function
		; returns pointer in EAX
; Copy the command-line string to the array
; pointed to by EDX.
	mov esi,eax

L1:	mov al,[esi]
	mov [edx],al
	cmp al,0	; null byte found?
	je  L2	; exit loop
	inc esi
	inc edx
	jmp L1

L2:	popad
	ret
GetCommandTail ENDP


;--------------------------------------------------
GetDateTime PROC,
	pStartTime:PTR QWORD
	LOCAL flTime:FILETIME
;
; Gets and saves the current local date/time as a
; 64-bit integer (in the Win32 FILETIME format).
;--------------------------------------------------
; Get the system local time
	INVOKE GetLocalTime,
	  ADDR sysTime

; Convert the SYSTEMTIME to FILETIME
	INVOKE SystemTimeToFileTime,
	  ADDR sysTime,
	  ADDR flTime

; Copy the FILETIME to a Quadword
	mov esi,pStartTime
	mov eax,flTime.loDateTime
	mov DWORD PTR [esi],eax
	mov eax,flTime.hiDateTime
	mov DWORD PTR [esi+4],eax
	ret
GetDateTime ENDP

;---------------------------------------------------
GetMseconds PROC USES ebx
	LOCAL hours:DWORD, min:DWORD, sec:DWORD
;
; Calculate milliseconds past midnight.
; Receives: nothing
; Returns: EAX = ((hours * 3600) + (minutes * 60) + seconds) * 1000 + milliseconds
;---------------------------------------------------

	INVOKE GetLocalTime,offset sysTime
	; convert hours to seconds
	movzx eax,sysTime.wHour
	mov   ebx,3600
	mul   ebx
	mov   hours,eax

	; convert minutes to seconds
	movzx eax,sysTime.wMinute
	mov   ebx,60
	mul   ebx
	mov   min,eax

	; add seconds to total seconds
	movzx eax,sysTime.wSecond
	mov  sec,eax

	; multiply seconds by 1000
	mov  eax,hours
	add  eax,min
	add  eax,sec
	mov  ebx,1000
	mul  ebx

	; add milliseconds to total
	movzx ebx,sysTime.wMilliseconds
	add  eax,ebx

	ret
GetMseconds ENDP


;--------------------------------------------------
Gotoxy proc
;
; Locate the cursor
; Receives: DH = screen row, DL = screen column
; Last update: 7/11/01
;--------------------------------------------------------
.data
_cursorPosition COORD <>
.code
	pushad

	CheckInit

  movzx ax,dl
  mov _cursorPosition.X, ax
  movzx ax,dh
	mov _cursorPosition.Y, ax
	INVOKE SetConsoleCursorPosition, consoleOutHandle, _cursorPosition

	popad
	ret
Gotoxy endp

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
RandomRange proc
;
; Returns an unsigned pseudo-random 32-bit integer
; in EAX, between 0 and n-1. Input parameter:
; EAX = n.
; Last update: 7/11/01
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
RandomRange endp


;--------------------------------------------------------------
Random32  proc
;
; Returns an unsigned pseudo-random 32-bit integer
; in EAX,in the range 0 - FFFFFFFFh.
; Last update: 7/11/01
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
Random32  endp


;--------------------------------------------------------
Randomize proc
;
; Re-seeds the random number generator with the current time
; in seconds.
; Receives: nothing
; Returns: nothing
; Last update: 7/11/01
;--------------------------------------------------------
	  push eax

	  INVOKE GetSystemTime,offset sysTime

	  movzx eax,sysTime.wMilliseconds
	  mov   seed,eax
	  pop   eax
	  ret
Randomize endp


;---------------------------------------------------------
ReadChar proc
;
; Reads one character from standard input and echoes
; on the screen. Waits for the character if none is
; currently in the input buffer.
; Receives: nothing
; Returns:  AL = ASCII code
; Last update: 9/24/01
;----------------------------------------------------------
.data
saveFlags DWORD ?
.code
	pushad
	CheckInit

	; Get & save the current console input mode flags:
	invoke GetConsoleMode,consoleInHandle,offset saveFlags

	; Clear all flags
	invoke SetConsoleMode,consoleInHandle,0

	; Read a single character from input buffer:
	INVOKE ReadConsole,
	  consoleInHandle,	; console input handle
	  ADDR buffer,	; pointer to buffer
	  1,	; max characters to read
	  ADDR bytesRead,0

	; Restore the previous flags state:
	invoke SetConsoleMode,consoleInHandle,saveFlags

	popad
	mov al,buffer	; return the input character
	ret
ReadChar endp


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
	mov   esi,edx           		; save offset in SI
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
ReadString proc
;
; Reads a string of up to 128 characters from the console
; past the end of line, and places the characters in a buffer.
; Strips off CR/LF from the input buffer.
; Receives: EDX points to the input buffer,
;           ECX contains the maximum string length
; Returns:  EAX = size of the input string.
; Comments: Stops when Enter key (0Dh) is pressed. Because ReadConsole
; places 0Dh,0Ah in the buffer, we have to use a local variable
; to overwriting the caller's memory. After calling ReadConsole,
; we copy the characters back to the caller's buffer.
; Last update: 8/14/01
;--------------------------------------------------------
.data
READSTRING_BUFSIZE = 128
InputTooLong BYTE "ReadString error: Cannot input string longer than 128 bytes.",0Dh,0Ah,0
localBuf BYTE (READSTRING_BUFSIZE + 2) DUP(?)
.code
	pushad
	CheckInit
	cmp ecx,READSTRING_BUFSIZE
	ja L3Err		; InputTooLong

	add ecx,2		; include CR/LF in the input

	push edx
	INVOKE ReadConsole,
	  consoleInHandle,		; console input handle
	  OFFSET localBuf,		; pointer to local buffer
	  ecx,		; max count
	  OFFSET bytesRead,
	  0
	pop edx
	sub bytesRead,2		; adjust character count

	jz  L5 		; skip move if zero chars input

L1:
	; Copy from the local buffer to the caller's buffer.
	mov ecx,bytesRead
	mov esi,OFFSET localBuf
L2:
	mov al,[esi]
	mov [edx],al
	inc esi
	inc edx
	Loop L2

L5:	mov BYTE PTR [edx],0		; add NULL byte
	jmp L4

L3Err:
	mov edx,OFFSET InputTooLong
	call WriteString

L4:
	popad
	mov eax,bytesRead
	ret
ReadString endp


;------------------------------------------------------------
SetTextColor PROC
;
; Change the color of all subsequent text output.
; Receives: EAX = attribute. Bits 0-3 are the foreground
; 	color, and bits 4-7 are the background color.
; Returns: nothing
; Last update: 1/18/02
;------------------------------------------------------------
.data
scrAttrib DWORD ?
.code
	pushad
	mov scrAttrib,eax	; lowest byte contains the attribute

  ; Get the console standard output handle:
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov [consoleOutHandle],eax

 ; Set the text color (both background and foreground)
 ; to white on blue

	INVOKE SetConsoleTextAttribute, consoleOutHandle, scrAttrib
	popad
	ret
SetTextColor endp

;----------------------------------------------------------
Str_compare PROC USES eax edx esi edi,
	string1:PTR BYTE,
	string2:PTR BYTE
;
; Compare two strings.
; Returns nothing, but the Zero and Carry flags are affected
; exactly as they would be by the CMP instruction.
; Last update: 1/18/02
;-----------------------------------------------------
    mov esi,string1
    mov edi,string2

L1: mov  al,[esi]
    mov  dl,[edi]
    cmp  al,0    		; end of string1?
    jne  L2      		; no
    cmp  dl,0    		; yes: end of string2?
    jne  L2      		; no
    jmp  L3      		; yes, exit with ZF = 1

L2: inc  esi      		; point to next
    inc  edi
    cmp  al,dl   		; chars equal?
    je   L1      		; yes: continue loop
                 		; no: exit with flags set
L3: ret
Str_compare ENDP

;---------------------------------------------------------
Str_copy PROC USES eax ecx esi edi,
 	source:PTR BYTE, 		; source string
 	target:PTR BYTE		; target string
;
; Copy a string from source to target.
; Requires: the target string must contain enough
;           space to hold a copy of the source string.
; Last update: 1/18/02
;----------------------------------------------------------
	INVOKE Str_length,source 		; EAX = length source
	mov ecx,eax		; REP count
	inc ecx         		; add 1 for null byte
	mov esi,source
	mov edi,target
	cld               		; direction = up
	rep movsb      		; copy the string
	ret
Str_copy ENDP

;---------------------------------------------------------
Str_length PROC USES edi,
	pString:PTR BYTE	; pointer to string
;
; Return the length of a null-terminated string.
; Receives: pString - pointer to a string
; Returns: EAX = string length
; Last update: 1/18/02
;---------------------------------------------------------
	mov edi,pString
	mov eax,0     	; character count
L1:
	cmp byte ptr [edi],0	; end of string?
	je  L2	; yes: quit
	inc edi	; no: point to next
	inc eax	; add 1 to count
	jmp L1
L2: ret
Str_length ENDP


;-----------------------------------------------------------
Str_trim PROC USES eax ecx edi,
	pString:PTR BYTE,		; points to string
	char:BYTE		; char to remove
;
; Remove all occurences of a given character from
; the end of a string.
; Returns: nothing
; Last update: 1/18/02
;-----------------------------------------------------------
	mov  edi,pString
	INVOKE Str_length,edi		; returns length in EAX
	cmp  eax,0		; zero-length string?
	je   L2		; yes: exit
	mov  ecx,eax		; no: counter = string length
	dec  eax
	add  edi,eax		; EDI points to last char
	mov  al,char		; char to trim
	std		; direction = reverse
	repe scasb		; skip past trim character
	jne  L1		; removed first character?
	dec  edi		; adjust EDI: ZF=1 && ECX=0
L1:	mov  BYTE PTR [edi+2],0		; insert null byte
L2:	ret
Str_trim ENDP

;---------------------------------------------------
Str_ucase PROC USES eax esi,
	pString:PTR BYTE
; Convert a null-terminated string to upper case.
; Receives: pString - a pointer to the string
; Returns: nothing
; Last update: 1/18/02
;---------------------------------------------------
	mov esi,pString
L1:
	mov al,[esi]		; get char
	cmp al,0		; end of string?
	je  L3		; yes: quit
	cmp al,'a'		; below "a"?
	jb  L2
	cmp al,'z'		; above "z"?
	ja  L2
	and BYTE PTR [esi],11011111b	; convert the char

L2:	inc esi		; next char
	jmp L1

L3: ret
Str_ucase ENDP


;------------------------------------------------------
WaitMsg proc
;
; Displays a prompt and waits for the user to press Enter.
; Receives: nothing
; Returns: nothing
;------------------------------------------------------
.data
waitmsgstr DB "Press [Enter] to continue...",0
.code
	pushad
	CheckInit
	mov  edx,offset waitmsgstr
	call WriteString
	NewLine

w1:INVOKE FlushConsoleInputBuffer,consoleInHandle
	INVOKE ReadConsole,
	  consoleInHandle,		; console input handle
	  OFFSET localBuf,		; pointer to local buffer
	  READSTRING_BUFSIZE,		; max count
	  OFFSET bytesRead,
	  0
	cmp bytesRead,2
	jnz w1            ;loop until ReadConsole returns 2 bytes read

	popad
	ret
WaitMsg endp


;------------------------------------------------------
WriteBin proc
;
; Writes a 32-bit integer to standard output in
; binary format.
; Receives: EAX = the integer to write
; Returns: nothing
; Last update: 7/11/01
;------------------------------------------------------
	pushad

	mov   ecx,8	; number of 4-bit groups in EAX
	mov   esi,offset buffer

WB1:
	push  ecx	; save loop count

	mov   ecx,4	; 4 bits in each group
WB1A:
	shl   eax,1	; shift EAX left into Carry flag
	mov   byte ptr [esi],'0'	; choose '0' as default digit
	jnc   WB2	; if no carry, then jump to L2
	mov   byte ptr [esi],'1'	; else move '1' to DL
WB2:
	inc   esi
	Loop  WB1A	; go to next bit within group

	mov   byte ptr [esi],' '  ; insert a blank space
	inc   esi	; between groups
	pop   ecx	; restore outer loop count
	loop  WB1	; begin next 4-bit group

	mov  byte ptr [esi],0	; insert null byte at end
	mov  edx,offset buffer	; display the buffer
	call WriteString

	popad
	ret
WriteBin endp

;------------------------------------------------------
WriteChar proc
;
; Write a character to standard output
; Recevies: AL = character
; Last update: 7/11/01
;------------------------------------------------------
	pushad
	CheckInit

	mov  buffer,al

	INVOKE WriteConsole,
	    consoleOutHandle,        ; console output handle
	    offset buffer,	; points to string
	    1,		; string length
	    offset bytesWritten,  ; returns number of bytes written
	    0

	popad
	ret
WriteChar endp

;-----------------------------------------------------
WriteDec proc
;
; Writes an unsigned 32-bit decimal number to
; standard output. Input parameters: EAX = the
; number to write.
; Last update: 7/11/01
;------------------------------------------------------
.data
; There will be as many as 10 digits.
BUFFER_SIZE = 12

bufferL db BUFFER_SIZE dup(?),0
xtable db "0123456789ABCDEF"

.code
	pushad
	CheckInit

	 mov   ecx,0           ; digit counter
	 mov   edi,offset bufferL
	 add   edi,(BUFFER_SIZE - 1)
	 mov   ebx,10	; decimal number base

WI1: mov   edx,0          ; clear dividend to zero
	 div   ebx            ; divide EAX by the radix

	 xchg  eax,edx        ; swap quotient, remainder
	 call  AsciiDigit     ; convert AL to ASCII
	 mov   [edi],al        ; save the digit
	 dec   edi             ; back up in buffer
	 xchg  eax,edx        ; swap quotient, remainder

	 inc   ecx             ; increment digit count
	 or    eax,eax        ; quotient = 0?
	 jnz   WI1            ; no, divide again

	 ; Display the digits (CX = count)
WI3:
	 inc   edi
	 mov   edx,edi
	 call  WriteString

WI4:
	 popad	; restore 32-bit registers
	 ret
WriteDec endp

;------------------------------------------------------
WriteHex proc
;
; Writes an unsigned 32-bit hexadecimal number to
; standard output.
; Input parameters: EAX = the number to write.
; Last update: 7/11/01
;------------------------------------------------------

DISPLAY_SIZE = 8          ; total number of digits to display

.data
bufferLH db DISPLAY_SIZE dup(?),0

.code
	 pushad               ; save all 32-bit data registers

	CheckInit

	 mov   ecx,0           ; digit counter
	 mov   edi,offset bufferLH
	 add   edi,(DISPLAY_SIZE - 1)
	 mov   ebx,16	       ; hexadecimal base

WLH1:
	 mov   edx,0          ; clear dividend to zero
	 div   ebx            ; divide EAX by the radix

	 xchg  eax,edx        ; swap quotient, remainder
	 call  AsciiDigit     ; convert AL to ASCII
	 mov   [edi],al        ; save the digit
	 dec   edi             ; back up in buffer
	 xchg  eax,edx        ; swap quotient, remainder

	 inc   ecx             ; increment digit count
	 or    eax,eax        ; quotient = 0?
	 jnz   WLH1           ; no, divide again

	 ; Insert leading zeros

	 mov   ax,DISPLAY_SIZE
	 sub   ax,cx
	 jz    WLH3           ; display now if no leading zeros required
	 movzx ecx,ax          ; CX = number of leading zeros to insert

WLH2:
	 mov   byte ptr [edi],'0'   ; insert a zero
	 dec   edi                  ; back up
	 loop  WLH2                ; continue the loop

	 ; Display the digits

WLH3:
	 mov   cx,DISPLAY_SIZE
	 inc   edi
	 mov   edx,edi
	 call  WriteString

	 popad     ; restore 32-bit registers
	 ret
WriteHex endp


;-----------------------------------------------------
WriteInt proc
;
; Writes a 32-bit signed binary integer to standard output
; in ASCII decimal.
; Receives: EAX = the integer
; Returns:  nothing
; Comments: Displays a leading sign, no leading zeros.
; Last update: 7/11/01
;-----------------------------------------------------
WI_Bufsize = 12
true  =   1
false =   0
.data
buffer_B  db  WI_Bufsize dup(0),0  ; buffer to hold digits
neg_flag  db  ?

.code
	pushad
	CheckInit

	mov   neg_flag,false    ; assume neg_flag is false
	or    eax,eax             ; is AX positive?
	jns   WIS1              ; yes: jump to B1
	neg   eax                ; no: make it positive
	mov   neg_flag,true     ; set neg_flag to true

WIS1:
	mov   ecx,0              ; digit count = 0
	mov   edi,offset buffer_B
	add   edi,(WI_Bufsize-1)
	mov   ebx,10             ; will divide by 10

WIS2:
	mov   edx,0              ; set dividend to 0
	div   ebx                ; divide AX by 10
	or    dl,30h            ; convert remainder to ASCII
	dec   edi                ; reverse through the buffer
	mov   [edi],dl           ; store ASCII digit
	inc   ecx                ; increment digit count
	or    eax,eax             ; quotient > 0?
	jnz   WIS2              ; yes: divide again

	; Insert the sign.

	dec   edi	; back up in the buffer
	inc   ecx               	; increment counter
	mov   byte ptr [edi],'+' 	; insert plus sign
	cmp   neg_flag,false    	; was the number positive?
	jz    WIS3              	; yes
	mov   byte ptr [edi],'-' 	; no: insert negative sign

WIS3:	; Display the number
	mov  edx,edi
	call WriteString

	popad
	ret
WriteInt endp


;--------------------------------------------------------
WriteString proc
;
; Writes a null-terminated string to standard
; output. Input parameter: EDX points to the
; string.
; Last update: 9/7/01
;--------------------------------------------------------
	pushad

	CheckInit

	INVOKE Str_length,edx   	; return length of string in EAX
	cld	; must do this before WriteConsole

	INVOKE WriteConsole,
	    consoleOutHandle,     	; console output handle
	    edx,	; points to string
	    eax,	; string length
	    offset bytesWritten,  	; returns number of bytes written
	    0

	popad
	ret
WriteString endp


;----------- PRIVATE PROCEDURES --------------------------

;----------------------------------------------------
Initialize proc private
;
; Get the standard console handles for input and output,
; and set a flag indicating that it has been done.
;----------------------------------------------------

  pushad

	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov [consoleInHandle],eax

	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov [consoleOutHandle],eax

	mov InitFlag,1

  popad
	ret
Initialize endp


; Convert AL to an ASCII digit. Used by WriteHex & WriteDec

AsciiDigit proc private
	 push  ebx
	 mov   ebx,offset xtable
	 xlat
	 pop   ebx
	 ret
AsciiDigit endp

HexByte proc private
; Display the byte in AL in hexadecimal

	pushad
	mov  dl,al

	rol  dl,4
	mov  al,dl
	and  al,0Fh
	mov  ebx,offset xtable
	xlat
	mov  buffer,al	; save first char
	rol  dl,4
	mov  al,dl
	and  al,0Fh
	xlat
	mov  [buffer+1],al	; save second char
	mov  [buffer+2],0	; null byte

	mov  edx,offset buffer	; display the buffer
	call WriteString

	popad
	ret
HexByte endp

end
