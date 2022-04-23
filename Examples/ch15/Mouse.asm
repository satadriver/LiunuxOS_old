TITLE Tracking the Mouse                      (mouse.asm)

; This simple mouse demo program is designed to show off some
; of the basic mouse functions available through INT 33h.
; Last update: 8/21/01
;
; In Standard DOS mode, each character position in the DOS window
; is equal to 8 mouse units (called "mickeys").

INCLUDE Irvine16.inc

.data
ESCkey = 1Bh
GreetingMsg BYTE "Press Esc to quit",0dh,0ah,0
StatusLine  BYTE "Left button:                              "
	        BYTE "Mouse position: ",0
blanks      BYTE "                ",0
Xcoordinate WORD 0	; current X-position
Ycoordinate WORD 0	; current Y-position
Xclick      WORD 0	; X-pos of last button click
Yclick      WORD 0	; Y-pos of last button click

.code
main PROC
	mov  ax,@data
	mov  ds,ax

; Hide the text cursor and display the mouse.
	call HideCursor
	mov  dx,OFFSET GreetingMsg
	call WriteString
	call ShowMousePointer

; Display a status line on line 24.
	mov  dh,24
	mov  dl,0
	call Gotoxy
	mov  dx,OFFSET StatusLine
	call Writestring

; Loop: show mouse coordinates, check for left mouse
; button click, or for a keypress (Esc key).
L1: call ShowMousePosition
	call LeftButtonClick	; check for button click
	mov  ah,11h	; key pressed already?
	int  16h
	jz   L2          	; no, continue the loop
	mov  ah,10h	; remove key from buffer
	int  16h
	cmp  al,ESCkey   	; yes. Is it the ESC key?
	je   quit        	; yes, quit the program
L2: jmp  L1          	; no, continue the loop


; Hide the mouse, restore the text cursor, clear
; the screen, and display "Press any key to continue."
quit:
	call HideMousePointer
	call ShowCursor
	call Clrscr
	call WaitMsg
	exit
main ENDP

;---------------------------------------------------------
GetMousePosition PROC
;
; Return the current mouse position and button status.
; Receives: nothing
; Returns:  BX = button status (0 = left button down,
;           (1 = right button down, 2 = center button down)
;           CX = X-coordinate
;           DX = Y-coordinate
;---------------------------------------------------------
	push ax
	mov  ax,3
	int  33h
	pop  ax
	ret
GetMousePosition ENDP

;---------------------------------------------------------
HideCursor proc
;
; Hide the text cursor by setting its top line
; value to an illegal value.
;---------------------------------------------------------
	mov  ah,3	; get cursor size
	int  10h
	or   ch,30h	; set upper row to illegal value
	mov  ah,1	; set cursor size
	int  10h
	ret
HideCursor ENDP

ShowCursor PROC
	mov  ah,3	; get cursor size
	int  10h
	mov  ah,1	; set cursor size
	mov  cx,0607h	; default size
	int  10h
	ret
ShowCursor ENDP

;---------------------------------------------------------
HideMousePointer PROC
;---------------------------------------------------------
	push ax
	mov  ax,2	; hide mouse cursor
	int  33h
	pop  ax
	ret
HideMousePointer ENDP

;---------------------------------------------------------
ShowMousePointer PROC
;---------------------------------------------------------
	push ax
	mov  ax,1	; make mouse cursor visible
	int  33h
	pop  ax
	ret
ShowMousePointer ENDP

;---------------------------------------------------------
LeftButtonClick PROC
;
; Check for the most recent click of the left mouse
; button, and display its location.
; Receives: BX = button number (0=left, 1=right, 2=middle)
; Returns:  BX = button press counter
;           CX = X-coordinate
;           DX = Y-coordinate
;---------------------------------------------------------
	pusha
	mov  ah,0	; get mouse status
	mov  al,5	; (button press information)
	mov  bx,0	; specify the left button
	int  33h

; Exit proc if the coordinates have not changed.
	cmp  cx,Xclick
	jne  LBC1
	cmp  dx,Yclick
	je   LBC_exit

LBC1:
; Save the mouse coordinates.
	mov  Xclick,cx
	mov  Yclick,dx

; Position the cursor, clear the old numbers.
	mov  dh,24	; screen row
	mov  dl,15         	; screen column
	call Gotoxy
	push dx
	mov  dx,OFFSET blanks
	call WriteString
	pop  dx

; Show the mouse click coordinates.
	call Gotoxy
	mov  ax,Xcoordinate
	call WriteDec
	mov  dl,20        	; screen column
	call Gotoxy
	mov  ax,Ycoordinate
	call WriteDec

LBC_exit:
	popa
	ret
LeftButtonClick ENDP

;---------------------------------------------------------
SetMousePosition PROC
;
; Set the mouse's position on the screen.
; Receives: CX = X-coordinate
;           DX = Y-coordinate
; Returns:  nothing
;---------------------------------------------------------
	mov  ax,4
	int  33h
	ret
SetMousePosition ENDP

;---------------------------------------------------------
ShowMousePosition PROC
;
; Get and show the mouse corrdinates at the
; bottom of the screen.
; Receives: nothing
; Returns:  nothing
;---------------------------------------------------------
	pusha
	call GetMousePosition

; Exit proc if the coordinates have not changed.
	cmp  cx,Xcoordinate
	jne  SMP1
	cmp  dx,Ycoordinate
	je   SMP_exit

SMP1:
	mov  Xcoordinate,cx
	mov  Ycoordinate,dx

; Position the cursor, clear the old numbers.
	mov  dh,24               	; screen row
	mov  dl,60        	; screen column
	call Gotoxy
	push dx
	mov  dx,OFFSET blanks
	call WriteString
	pop  dx

; Show the mouse coordinates.
	call Gotoxy	; (24,60)
	mov  ax,Xcoordinate
	call WriteDec
	mov  dl,65        	; screen column
	call Gotoxy
	mov  ax,Ycoordinate
	call WriteDec

SMP_exit:
	popa
	ret
ShowMousePosition ENDP
END main