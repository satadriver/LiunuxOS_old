TITLE Extended Open/Create            (Fileio.asm)

; Demonstration of 16-bit FileIO under Windows 95/98/ME.
; The complete program does not appear in the text, but
; excerpts do appear.
; Last update: 11/12/01

INCLUDE Irvine16.inc

.data
Date WORD ?
handle WORD ?
actionTaken WORD ?
FileName BYTE "long_filename.txt",0
NewFile  BYTE "newfile.txt",0

.code
main PROC
	mov  ax,@data
	mov  ds,ax

;Create new file, fail if it already exists:
	mov  ax,716Ch             	; Extended Open/Create
	mov  bx,2	; read-write
	mov  cx,0      	; normal attribute
	mov  dx,10h	; action: create
	mov  si,OFFSET NewFile
	int  21h
	jc   failed
	mov  handle,ax        	; file handle
	mov  actionTaken,cx   	; action taken to open file

;Open existing file
	mov  ax,716Ch             	; Extended Open/Create
	mov  bx,0	; read-only
	mov  cx,0      	; normal attribute
	mov  dx,1	; open existing file
	mov  si,OFFSET Filename
	int  21h
	jc   failed
	mov  handle,ax        	; file handle
	mov  actionTaken,cx   	; action taken to open file

;Create new file or truncate existing file:
	mov  ax,716Ch             	; Extended Open/Create
	mov  bx,2	; read-write
	mov  cx,0      	; normal attribute
	mov  dx,10h + 02h	; action: create + truncate
	mov  si,OFFSET NewFile
	int  21h
	jc   failed
	mov  handle,ax        	; file handle
	mov  actionTaken,cx   	; action taken to open file


failed:

	exit
main ENDP
END main