TITLE Hello World Program         (Hello.asm)

; This program displays "Hello, world!"

.model small
.stack 100h
.386

.data
message BYTE "Hello, world!",0dh,0ah

.code
main PROC
    mov  ax,@data
    mov  ds,ax

    mov  ah,40h	; write to file/device
    mov  bx,1	; output handle
    mov  cx,SIZEOF message	; number of bytes
    mov  dx,OFFSET message	; addr of buffer
    int  21h

    .exit
main ENDP
END main