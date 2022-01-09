;重定位地址的基地址是以EXE文件头长度加上装载地址之和，而不是以CS:IP为基地址

.386
include pe.h

stack segment stack
db 400h dup (0)
stack ends

;__mytest proto far
;extrn __mytest:far


PSPsegment segment para use16
dw 20cdh
db 0feh dup (0)
PSPsegment ends




exesegment segment para use16
exedata db 0ffffh dup (0)           ;段最大为65535字节大小
exesegment ends

extra segment para
db 0ffffh dup (0)
db 0
extra ends



data segment para use16
exesize                 dw 0
exesize_high            dw 0
handle                  dw 0
exename_limit_lenth     db 40h
exename_fact_lenth      db 0
exe_name                db 40h dup (0)
exe_entrance_offset     dw 0
exe_entrance_seg        dw 0
stack_pointer           dw 0
stack_seg               dw 0
reallocation_seg        dw 0
reallocation_offset     dw 0
msg_input               db 'Input file name(xxxx.EXE or xxxx.COM) to execute',0ah,0dh
                        db 'CTRL+C/CTRL+BREAK to quit',0ah,0dh,24h
msg_notfoundfile        db 'Not found file,Press any key to continue...',0ah,0dh,24h
msg_largemode           db 'File too BIG to be executed,Press any key to continue...',0ah,0dh,24h
msg_notEXEorCOM         db 'NOT CORRECT file format,Press any key to continue...',0ah,0dh,24h
data ends



code segment public para use16
assume cs:code
start:

;retd
;retn
;retf
;ret  8

;call near ptr __mytest



call readfile

call __runExe16

call __CheckPE
cmp ax,1
jz __runExe16
;cmp word ptr ds:[exedata],5a4dh  ;'MZ' is flag of exe file，COM FILE is all binary data
;jz __runExe16
;jz __runExe32

;jz reallocation_exe
jmp reallocation_com


KERNEL_BASE_SEGMENT EQU 2000H
KERNEL_RUN_SEGMENT 	EQU 3000H

__runExe32 proc near
mov ax,exesegment
mov ds,ax

mov ax,4000h
mov es,ax

mov bp,sp
sub sp,100h

mov esi,ds:[3ch]
add esi,sizeof IMAGE_NT_HEADERS32.Signature
mov edi,esi
add edi,sizeof IMAGE_FILE_HEADER
mov ebx,edi
add ebx,sizeof IMAGE_OPTIONAL_HEADER32

mov eax, ds:[edi + IMAGE_OPTIONAL_HEADER32.SizeOfImage]
mov cs:[sizeOfImage],eax

mov eax, ds:[edi + IMAGE_OPTIONAL_HEADER32.ImageBase]
mov cs:[imageBase],eax

mov eax, ds:[edi + IMAGE_OPTIONAL_HEADER32.SizeOfHeaders]
mov cs:[sizeOfHeaders],eax

push esi
push edi
mov esi,0
mov edi,0
mov ecx,cs:[sizeOfHeaders]
cld
rep movsb
pop edi
pop esi

movzx ecx, word ptr ds:[esi + IMAGE_FILE_HEADER.NumberOfSections]
mov cs:[numOfSections],ecx
push esi
push edi
_checkSec:
push ecx
mov edi,ds:[ebx + IMAGE_SECTION_HEADER.VirtualAddress]
;mov edi,ds:[ebx + 12]
mov esi,ds:[ebx + IMAGE_SECTION_HEADER.PointerToRawData]
;mov esi,ds:[ebx + 20]
mov ecx,ds:[ebx + IMAGE_SECTION_HEADER.SizeOfRawData]
;mov ecx,ds:[ebx + 16]
mov eax,esi
and eax,edi
and eax,ecx
cmp eax,0
jz _nextSection
cld
rep movsb
_nextSection:
add ebx,sizeof IMAGE_SECTION_HEADER
pop ecx
loop _checkSec
pop edi
pop esi

mov eax,0
mov es:[edi + IMAGE_OPTIONAL_HEADER32.ImageBase],eax

mov eax, ds:[esi + IMAGE_OPTIONAL_HEADER32.Characteristics]
and eax,2000h
jnz _runDll32

mov ax,1000h
;mov eax,ds:[edi + IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint]
push es
push ax
mov bp,sp
push dword ptr 0
push dword ptr 0
push dword ptr 0
push dword ptr 0
call dword ptr ss:[bp]
_runDll32:
mov ax,1000h
;mov eax,ds:[edi + IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint]
push es
push ax
mov bp,sp
push dword ptr 0
push dword ptr 0
push dword ptr 0
call dword ptr ss:[bp]

hlt
__runExe32 endp

readfile proc near
mov ax,data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
cld
mov ax,3
int 10h
mov ah,9
mov dx,offset msg_input
int 21h
mov ah,0ah
mov dx,offset exename_limit_lenth
int 21h

xor bx,bx
mov di,offset exe_name
MOV BL,byte ptr ds:[exename_fact_lenth]
add di,bx
mov si,di
sub si,3
lodsd

cmp eax,0d6d6f63h      ; 'com'
jnz check_is_exe_caps
jmp exe_or_com
check_is_exe_caps:
cmp eax,0d4d4f43h      ; 'COM'
jnz check_is_com
jmp exe_or_com
check_is_com:
cmp eax,0d657865h      ; 'exe'
jnz check_is_com_caps
jmp exe_or_com
check_is_com_caps:
cmp eax,0d455845h      ; 'EXE'
jz exe_or_com
CALL notEXEorCOM
exe_or_com:
mov al,0
stosb

mov ax,3d00h
mov dx,offset exe_name
int 21h
jnc open_success
jmp notfoundfile
open_success:
mov ds:[handle],ax
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
cmp dx,1
jb mode_small
jmp mode_large
mode_small:
mov ds:[exesize_high],dx
mov ds:[exesize],ax
mov ax,4200h
mov bx,ds:[handle]
mov cx,0
mov dx,0
int 21h
mov ax,exesegment 
mov ds,ax

mov cx,fs:[exesize_high]
cmp cx,0
jz readdetail
dec cx
readblock:
push cx
mov ax,3f00h
mov bx,fs:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov bx,fs:[handle]
mov cx,1
mov dx,0ffffh
int 21h
mov ax,ds
add ax,1000h
mov ds,ax
pop cx
loop readblock


readdetail:
mov ax,3f00h
mov bx,fs:[handle]
mov cx,fs:[exesize]
mov dx,offset exedata
int 21h
ret
readfile endp


__CheckPE proc near
	push ds
	mov ax,ExeSegment
	mov ds,ax

	cmp word ptr ds:[0],5a4dh
	jnz _notPE

	mov eax,dword ptr ds:[3ch]
	;mov eax,dword ptr ds:[eax]
	cmp dword ptr ds:[eax],4550h
	jz _pe32

	pop ds
	mov ax,1
	ret

	_pe32:
	mov ax,2
	pop ds
	ret

	_notPE:
	pop ds
	mov ax,-1
	ret
__CheckPE endp



__runExe16 proc near
	mov ax,ExeSegment
	mov ds,ax
	mov es,ax
	mov bp,sp
	sub sp,100h

	;定位的基地址
	mov ax,ds
	add ax,word ptr ds:[8]
	mov ss:[esp + 8],ax

	;开始的ip指针
	mov ax,word ptr ds:[14h]
	mov ss:[esp],ax

	;cs段地址
	mov ax,word ptr ds:[16h]
	add ax,word ptr ss:[esp + 8]
	mov ss:[esp+2],ax

	;sp原始地址
	mov ax,word ptr ds:[10h]
	mov ss:[esp + 4],bx

	;ss段地址
	mov ax,ss:[esp + 8]
	add ax,word ptr ds:[0eh]
	mov ss:[esp + 6],ax

	mov cx,word ptr ds:[6]
	cmp cx,0
	jz _setregcall

	mov bx,word ptr ds:[18h]
	cld
	_reallocate:
	movzx edi,word ptr ds:[bx]
	mov ax,word ptr ds:[bx + 2]
	add ax,word ptr ss:[esp+8]

	mov es,ax
	mov dx,es:[edi]
	add dx,word ptr ss:[esp+8]
	mov es:[edi],dx
	add bx,4
	loop _reallocate

	_setregcall:
	mov ax,ss:[esp]
	mov cs:[exe16_ip],ax
	mov ax,ss:[esp +2]
	mov cs:[exe16_cs],ax

	mov ax,ss:[esp+8]
	sub ax,10h
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax

	mov ax,ss:[esp + 4]
	mov dx,ss:[esp + 6]
	mov ss,dx
	mov sp,ax

	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0
	mov si,0
	mov di,0
	mov sp,0
	mov bp,sp

	db 0Eah            
	exe16_ip  dw 0
	exe16_cs  dw 0
__runExe16 endp


reallocation_exe proc near


mov bx,word ptr ds:[exedata+14h]
mov fs:[exe_entrance_offset],bx
mov bx,exesegment
add bx,word ptr ds:[exedata+8]
mov fs:[reallocation_seg],bx
add bx,word ptr ds:[exedata+16h]
mov fs:[exe_entrance_seg],bx
;call createpsp_exe                  ;how could to set PSP correctly???

xor eax,eax
mov ax,word ptr ds:[exedata+16h]
shl eax,4
xor ebx,ebx
mov bx,word ptr ds:[exedata+14h]
add eax,ebx
cmp ax,0
jnz notmax_allocation
mov ax,fs:[reallocation_seg]
mov word ptr fs:[exe_entrance_seg],ax
mov word ptr fs:[exe_entrance_offset],0

notmax_allocation:
mov bx,fs:[reallocation_seg]
add bx,word ptr ds:[exedata+0eh]
mov fs:[stack_seg],bx
mov bx,word ptr ds:[exedata+10h]
mov fs:[stack_pointer],bx

mov cx,word ptr ds:[exedata+6]
cmp cx,0
jz set_register
mov ax,word ptr fs:[reallocation_seg]
mov es,ax
mov si,word ptr ds:[exedata+18h]
reallocat:
push cx
push es
add si,2
lodsw
mov bx,es
add ax,bx
mov es,ax
sub si,4
lodsw
;add ax,fs:[exe_entrance_offset]
mov di,ax
mov ax,word ptr es:[di]
add ax,fs:[reallocation_seg]
mov es:[di],ax
add si,2
pop es
pop cx
loop reallocat

set_register:
MOV AX,3
INT 10H
MOV AX,0
push ax
popf
push word ptr fs:[exe_entrance_offset]
pop word ptr cs:[exe_ip]
push word ptr fs:[exe_entrance_seg]
pop word ptr cs:[exe_cs]
lss sp,dword ptr fs:[stack_pointer]
mov cx,fs:[exesize]
mov ax,fs:[reallocation_seg]
sub ax,10h                     ;PSP
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ax,0    ;command line parameters,but is 0 here as no command line parameters
mov bx,0    ;pagehigh of file,but here is 0 as only less 64kbs lenth file can be executed
mov dx,0
mov si,0
mov di,0
mov bp,0
STI
db 0Eah            
exe_ip  dw 0
exe_cs  dw 0
reallocation_exe endp



reallocation_com proc near
;call createPSP_COM              ;how could to set PSP correctly???

MOV AX,3
INT 10H
MOV AX,2
push ax
popf
mov cx,fs:[exesize]
push word ptr 100h
pop word ptr cs:[com_ip]
mov ax,pspsegment               ;be equalvalent to ds-10h also            
mov cs:[com_CS],ax
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov sp,0fffeh
;sub sp,100h
mov ax,0        ;command line parameters,but is 0 here as no command line parameters
mov bx,0        ;pagehigh of file,but here is 0 as only less 64kbs lenth file can be executed
mov dx,0
mov si,0
mov di,0
mov bp,0
STI
db 0EAh        ;长跳转 JMP FAR PTR XXXX 或JMP DWORD PTR XXXX:[XXXX]
com_ip  dw 0
com_cs  dw 0
reallocation_com endp



createPSP_com proc near
mov ah,55h
mov dx,PSPsegment
int 21h
ret
createPSP_com endp



createPSP_exe proc near
mov ah,55h
mov dx,fs:[reallocation_seg]
sub dx,10h
int 21h
ret
createPSP_exe endp



notfoundfile proc near
mov ax,data
mov ds,ax
mov ah,9
mov dx,offset msg_notfoundfile
int 21h
mov ah,0
int 16h
JMP start
notfoundfile endp



mode_large proc near
mov ah,9
mov dx,offset msg_largemode
int 21h
mov ah,0
int 16h
JMP start
mode_large endp



NOTEXEorCOM PROC NEAR
mov ah,9
mov dx,offset msg_notEXEorCOM
int 21h
mov ah,0
int 16h
JMP start
NOTEXEorCOM ENDP



quit proc near
mov ah,0
int 16h
mov ah,4ch
int 21h
quit endp


numOfSections	dd 0
imageBase		dd 0
sizeOfImage		dd 0
sizeOfHeaders	dd 0

code ends
end start