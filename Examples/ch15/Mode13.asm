; Memory Mapped Graphics, Mode 13        	(Mode13.asm)

Comment !

This program demonstrates direct memory mapping in video
graphics Mode 13 (320 x 200, 256 colors). The video memory
is a two-dimensional array of memory bytes which can be addressed
and modified individually. Each byte represents a pixel on
the screen, and each byte contains an index into the color
palette.
!

INCLUDE Irvine16.inc
.data
saveMode BYTE ?	; saved video mode
xVal WORD ?	; x-coordinate
yVal WORD ?	; y-coordinate

.code
main PROC
	mov ax,@data
	mov ds,ax

	call SetVideoMode
	call SetScreenBackground
	call Draw_Some_Pixels
	call RestoreVideoMode
	exit
main ENDP

;----------------------------------------------------------
SetScreenBackground PROC
;
; This procedure sets the screen's background color.
; Video palette index 0 is the background color.
;----------------------------------------------------------
	mov dx,3c8h	; video palette port (3C8h)
	mov al,0	; set palette index
	out dx,al

; Set screen background color to dark blue.
	mov dx,3c9h	; colors go to port 3C9h
	mov al,0	; red
	out dx,al
	mov al,0	; green
	out dx,al
	mov al,35	; blue (intensity 35/63)
	out dx,al

	ret
SetScreenBackground endp

;----------------------------------------------------------
SetVideoMode PROC
;
; This procedure saves the current video mode, switches to
; a new mode, and points ES to the video segment.
;----------------------------------------------------------
	mov  ah,0Fh	; get current video mode
	int  10h
	mov  saveMode,al	; save it

	mov ah,0	; set new video mode
	mov al,13h	; to mode 13h
	int 10h

	push 0A000h	; video segment address
	pop es              	; ES = A000h (video segment).

	ret
SetVideoMode ENDP

;----------------------------------------------------------
RestoreVideoMode PROC
;
; This procedure waits for a key to be pressed and
; restores the video mode to its original value.
;----------------------------------------------------------
	mov ah,10h	; wait for keystroke
	int 16h
	mov ah,0   	; reset video mode
	mov al,saveMode   	; to saved mode
	int 10h
	ret
RestoreVideoMode ENDP

;----------------------------------------------------------
Draw_Some_Pixels PROC
;
; This procedure sets individual palette colors and
; draws several pixels.
;----------------------------------------------------------

	; Change color at index 1 to white (63,63,63)
	mov dx,3c8h	; video palette port (3C8h)
	mov al,1	; set palette index 1
	out dx,al

	mov dx,3c9h	; colors go to port 3C9h
	mov al,63	; red
	out dx,al
	mov al,63	; green
	out dx,al
	mov al,63	; blue
	out dx,al

	; Calculate the video buffer offset of the first pixel.
	; Specific to mode 13h, which is 320 X 200.
	mov xVal,160	; middle of screen
	mov yVal,100
	mov ax,320	; 320 for video mode 13h
	mul yVal	; y-coordinate
	add ax,xVAl	; x-coordinate

	; Place the color index into the video buffer.
	mov cx,10	; draw 10 pixels
	mov di,ax	; AX contains buffer offset

	; Draw the 10 pixels now.
DP1:
	mov BYTE PTR es:[di],1	; store color index
	add di,5	; move 5 pixels to the right
	Loop DP1

	ret
Draw_Some_Pixels ENDP

END main