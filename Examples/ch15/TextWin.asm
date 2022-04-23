TITLE Color Text Window             (TextWin.asm)

; Display a color window and write text inside.
; Last update: 8/20/01

INCLUDE Irvine16.inc
.data
message BYTE "Message in Window"

.code
main PROC
	mov ax,@data
	mov ds,ax

; Scroll a window.
	mov ax,0600h	; scroll window
	mov bh,00011110b	; yellow on blue
	mov cx,050Ah	; upper-left corner
	mov dx,0A30h	; lower-right corner
	int 10h

; Position the cursor inside the window.
	mov ah,2	; set cursor position
	mov dx,0714h	; row 7, col 20
	mov bh,0	; video page 0
	int 10h

; Write some text in the window.
	mov ah,40h	; write to file or device
	mov bx,1	; console handle
	mov cx,SIZEOF message
	mov dx,OFFSET message
	int 21h

; Wait for a keypress.
	mov ah,10h
	int 16h
	exit
main ENDP
END main