
RECODE			EQU 9AH
ROCODE			EQU 98H
RWDATA			EQU 92H
RODATA			EQU 90H

TASKGATE286		EQU 81h
LDTGATE			EQU 82h
TASKGATE286B	EQU 83h
CALLGATE286 	EQU 84h
TASKGATE 		EQU 85h
INTRGATE286 	EQU 86h
TRAPGATE286		EQU 87h
TSSSEG			EQU 89h
TSSSEGB			EQU 8bh
CALLGATE 		EQU 8ch
INTRGATE 		EQU 8eh
TRAPGATE 		EQU 8fh

GDL_4G_32B 		equ 0cfh
GDL_1M_32B 		equ 04fh
GDL_64K_32B 	equ 040h
GDL_64K_16B 	equ 0

DPL0			EQU 0
DPL1			EQU 20H
DPL2			EQU 40H
DPL3			EQU 60H

RPL0			EQU 0
RPL1			EQU 1
RPL2			EQU 2
RPL3			EQU 3

DESCRIPTOR struc
_segLimit 		dw 0
_baseLow		dw 0
_baseMid		db 0
_attr			db 0
_GDL			db 0
_baseHigh		db 0
DESCRIPTOR ends

GATEDESCRIPTOR struc
_offsetLow		dw 0
_selector		dw 0
_paramCnt		db 0
_attr			db 0
_offsetHigh		dw 0
GATEDESCRIPTOR ends

JUMP16 macro seg,off
DB 0eah
dw off
dw seg
endm


CALL16 macro seg,off
DB 09ah
dw off
dw seg
endm

JUMP32 macro seg,off
DB 0eah
dd off
dw seg
endm

CALL32 macro seg,off
DB 09ah
dd off
dw seg
endm

SETDESCBASE MACRO desc, seg
    mov eax, seg
    shl eax, 4
    mov desc._baseLow, ax
	shr	eax,16
    mov desc._baseMid, al
    mov desc._baseHigh, ah
ENDM

SETDESCADDR MACRO desc, seg,off
    mov eax, seg
    shl eax, 4
	add eax,off
    mov desc._baseLow, ax
	shr	eax,16
    mov desc._baseMid, al
    mov desc._baseHigh, ah
ENDM

SETGATEADDR MACRO gate,seg,off,selector
    mov eax, seg
    shl eax, 4
	add eax,off
	mov gate + GATEDESCRIPTOR._offsetLow,ax
	shr eax,16
	mov gate + GATEDESCRIPTOR._offsetHigh,ax
	mov gate + GATEDESCRIPTOR._selector,selector
ENDM

comment *
JUMP32  MACRO   selector,offsetv
    DB  0eaH
    DW  offsetv ;32位偏移
    DW  0
    DW  selector
ENDM
CALL32  MACRO   selector,offsetv
    db  09ah
    dw  offsetv
    dw  0
    dw  selector
endm
JUMP16  MACRO   selector,offsetv
    db  0eah
    dw  offsetv
    dw  selector
endm
call16  MACRO   selector,offsetv
    db  9ah
    dw  offsetv
    dw  selector
endm
*