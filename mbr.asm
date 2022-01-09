.386p
.model small

FIRST_SEGMENT		EQU 0
LOADER_BASE_SEGMENT EQU 800H
KERNEL_BASE_SEGMENT EQU 1000H

BAKMBR_BASE			EQU 7A00H
INFO_BASE			EQU 7800H
LOADER_FLAG_OFFST	EQU INFO_BASE
LOADER_SEC_OFFSET	EQU (INFO_BASE + 6)
LOADER_SEC_CNT		EQU (INFO_BASE + 4)
KERNEL_SEC_OFFSET	EQU (INFO_BASE + 12)
KERNEL_SEC_CNT		EQU (INFO_BASE + 10)
BAKMBR_SEC_OFFSET	EQU (INFO_BASE + 16)
BAKMBR2_SEC_OFFSET	EQU (INFO_BASE + 20)
FONT_SEC_CNT		EQU (INFO_BASE + 24)
FONT_SEC_OFFSET		EQU (INFO_BASE + 26)
KERDLL_SEC_CNT		EQU (INFO_BASE + 30)
KERDLL_SEC_OFFSET	EQU (INFO_BASE + 32)

RM_SEG_LIMIT		EQU 10000H
RM_STACK_TOP		EQU (RM_SEG_LIMIT - 10H)

INSTALL_FLAG		EQU 00474a4ch

	;retn =c3 
	;ret =c3 
	;retf =cb  
	;retd =66cb 
	;ret 4 = c2 04 00
	;ret 8 = c2 08 00
	
	;cs = 0,ip = 7c00
MBR SEGMENT para use16
	assume cs:MBR

	start:
	cli
	cld

	xor eax,eax
	xor ecx,ecx
	xor edx,edx
	xor ebx,ebx
	xor esi,esi
	xor edi,edi
	xor esp,RM_STACK_TOP
	xor ebp,esp

	mov ax,FIRST_SEGMENT
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov gs,ax

	push dword ptr 0
	push dword ptr ds:[7c00h + 1bah]
	push word ptr 1
	push word ptr INFO_BASE
	push word ptr FIRST_SEGMENT
	call near ptr __getLoaderSectors
	add sp,14
	cmp ax,-1
	jz _loadErr
	
	mov eax,dword ptr ds:[INFO_BASE]
	cmp eax,dword ptr INSTALL_FLAG
	jnz _loadErr

	push dword ptr 0
	push dword ptr ds:[LOADER_SEC_OFFSET]
	push word ptr ds:[LOADER_SEC_CNT]
	push word ptr 0
	push word ptr LOADER_BASE_SEGMENT
	call near ptr __getLoaderSectors
	add sp,14
	cmp eax,-1
	jz _loadErr
	
	call near ptr _loadOK

	;low = offset,high = segment
	;考虑这样调用跟com文件的加载方式有什么异同？
	push word ptr LOADER_BASE_SEGMENT
	push word ptr 0
	
	retf
	
	;mov ax,LOADER_BASE_SEGMENT
	;mov _LoaderSeg,ax
	;db eah
	;dw 0
	;_LoaderSeg dw 0
	
	;mov bp,sp
	;jmp dword ptr ss:[bp]
	
	;call dword ptr ss:[bp]

	
_loadOK:
	push word ptr 0ah
	lea ax, loaderOK
	add ax,7c00h
	push ax
	push word ptr FIRST_SEGMENT
	call __showMsg
	add sp,6
	retn
	loaderOK 	db 'mbr read loader ok',0

_loadErr:
	push word ptr 8ch
	lea ax, loaderErr
	add ax,7c00h
	push ax
	push word ptr FIRST_SEGMENT
	call __showMsg
	add sp,6
	hlt
	loaderErr 	db 'mbr read loader error',0
	

;bp old bp
;bp + 2 ret address
;bp + 4 segment
;bp + 6 offset
;bp + 8 sector count
;bp + 10 sector no low
;bp + 14 sector no high
__getLoaderSectors proc near
	push bp
	mov bp,sp

	push ds
	push si
	push dx
	sub sp,100h

	mov byte ptr ss:[esp],10h

	mov byte ptr ss:[esp + 1],0

	mov ax,word ptr ss:[bp + 8]
	mov word ptr ss:[esp + 2],ax

	movzx eax,word ptr ss:[bp + 4]
	shl eax,16
	mov ax,word ptr ss:[bp + 6]
	mov dword ptr ss:[esp + 4],eax

	mov eax,dword ptr ss:[bp + 10]
	mov dword ptr ss:[esp + 8],eax
	mov eax,dword ptr ss:[bp + 14]
	mov dword ptr ss:[esp + 12],eax

	mov ax,ss
	mov ds,ax
	mov si,sp
	mov eax,4200h
	mov edx,80h
	int 13h
	cmp ah,0
	jnz _readerror

	mov eax,dword ptr ss:[bp + 10]
	jmp _readEnd
	
	_readerror:
	mov eax,-1
	
	_readEnd:
	add sp,100h
	pop dx
	pop si
	pop ds
	mov sp,bp
	pop bp
	retn
__getLoaderSectors endp

;bit 7 high ground
;bit 6 red ground
;bit 5 yellow ground
;bit 4 blue ground
;bit 3 high character
;bit 2 red character
;bit 1 yellow character
;bit 0 blue character
__showMsg proc near
	push bp
	mov bp,sp

	push ds
	push es
	push si
	push di
	sub sp,100h
	
	mov ax,word ptr ss:[bp + 4]
	mov ds,ax
	mov ax,0b800h
	mov es,ax
	mov si,word ptr ss:[bp+6]
	
	mov di, word ptr ds:[_showPos]
	add word ptr ds:[_showPos],160
	cld
	_showmbrok:
	lodsb
	cmp al,0
	jz _okmbrend
	mov ah,byte ptr ss:[bp + 8]
	stosw
	jmp _showmbrok
	
	_okmbrend:
	mov ax,si
	sub ax,word ptr ss:[bp + 6]
	
	add sp,100h
	pop di
	pop si
	pop es
	pop ds

	mov sp,bp
	pop bp
	retn
_showPos dw 0
__showMsg endp


version		db 1

MBR ends
end start