TITLE DrawLine Program              (Pixel1.asm)

; This program draws a straight line, using INT 10h
; function calls.
; Last update: 12/14/01

INCLUDE Irvine16.inc

;------------ Video Mode Constants -------------------
Mode_06 = 6		; 640 X 200,  2 colors
Mode_0D = 0Dh		; 320 X 200, 16 colors
Mode_0E = 0Eh		; 640 X 200, 16 colors
Mode_0F = 0Fh		; 640 X 350,  2 colors
Mode_10 = 10h		; 640 X 350, 16 colors
Mode_11 = 11h		; 640 X 480,  2 colors
Mode_12 = 12h		; 640 X 480, 16 colors
Mode_13 = 13h		; 320 X 200, 256 colors
Mode_6A = 6Ah		; 800 X 600, 16 colors

.data
saveMode  BYTE  ?		; save the current video mode
currentX  WORD 100		; column number (X-coordinate)
currentY  WORD 100		; row number (Y-coordinate)
color     BYTE 1		; default color

; In 2-color modes, white = 1
; In 16-color modes, blue = 1

.code
main PROC
	mov ax,@data
	mov ds,ax

; Save the current video mode
	mov  ah,0Fh
	int  10h
	mov  saveMode,al

; Switch to a graphics mode
	mov  ah,0   	; set video mode
	mov  al,Mode_11
	int  10h

; Draw a straight line
	LineLength = 100

	mov  dx,currentY
	mov  cx,LineLength	; loop counter

L1:
	push cx
	mov  ah,0Ch  	; write pixel
	mov  al,color    	; pixel color
	mov  bh,0	; video page 0
	mov  cx,currentX
	int  10h
	inc  currentX
	;inc  color         ; try this for multi-color modes
	pop  cx
	Loop L1

; Wait for a keystroke
	mov  ah,0
	int  16h

; Restore the starting video mode
	mov  ah,0   	; set video mode
	mov  al,saveMode   	; saved video mode
	int  10h
	exit
main ENDP
END main
