.386p

Kernel Segment public para use32
assume cs:Kernel

;useless function
comment *
__initV86Tss proc 
push ecx
push edx
push ebx
push esi
push edi

mov ebx,KernelData
shl ebx,4

mov ecx,SYSTEM_TSS_SIZE
mov edi,V86_TSS_BASE
mov al,0
cld
rep stosb

pushfd
pop eax
or eax,23200h
mov dword ptr ds:[V86_TSS_BASE + TASKSTATESEG.mEflags],eax
mov word ptr ds:[V86_TSS_BASE + TASKSTATESEG.mIomap],136
mov byte ptr ds:[V86_TSS_BASE + TASKSTATESEG.mIomapEnd + 8192+32],0ffh
MOV dword ptr ds:[V86_TSS_BASE + TASKSTATESEG.mEsp0],TSSV86_STACK0_TOP
MOV dword ptr ds:[V86_TSS_BASE + TASKSTATESEG.mSS0],rwData32Seg	;stackV86Seg
mov dword ptr ds:[V86_TSS_BASE + TASKSTATESEG.mCr3],PDE_ENTRY_VALUE

mov eax,Kernel16
mov ds:[V86_TSS_BASE + TASKSTATESEG.mCs],eax
mov eax,kernelData
mov ds:[V86_TSS_BASE + TASKSTATESEG.mDs],eax
mov ds:[V86_TSS_BASE + TASKSTATESEG.mEs],eax
mov ds:[V86_TSS_BASE + TASKSTATESEG.mFs],eax
mov ds:[V86_TSS_BASE + TASKSTATESEG.mGs],eax
mov ds:[V86_TSS_BASE + TASKSTATESEG.mSs],eax
mov ds:[V86_TSS_BASE + TASKSTATESEG.mEsp],BIT16_STACK_TOP - STACK_TOP_DUMMY
mov ds:[V86_TSS_BASE + TASKSTATESEG.mEbp],BIT16_STACK_TOP - STACK_TOP_DUMMY
lea eax,__v86TssProc
mov ds:[V86_TSS_BASE + TASKSTATESEG.mEip],eax

;you can modify tss in protect mode
;but you can not modify tss descriptor in gdt in protect mode ?????
mov eax,V86_TSS_BASE
mov word ptr ds:[ebx + kTssV86Descriptor + 2],ax
shr eax,16
mov byte ptr ds:[ebx + kTssV86Descriptor + 4],al
mov byte ptr ds:[ebx + kTssV86Descriptor + 7],ah
mov word ptr ds:[ebx + kTssV86Descriptor ],SYSTEM_TSS_SIZE - 1

mov ax,kTssV86Selector
mov word ptr ds:[tV86Entry + 2],ax

pop edi
pop esi
pop ebx
pop edx
pop ecx
ret
__initV86Tss endp

*




;useless function
__v86Entry proc
pushad
push es
push ds
push fs
push gs

;gs,fs,ds,es
mov eax,Kernel16
push eax
mov ecx,kernelData
push ecx
push eax
push eax

;ss
push eax
;esp
push dword ptr BIT16SEGMENT_SIZE - STACK_TOP_DUMMY

;eflags
pushfd
pop eax
or eax,23200h
push eax

;cs
mov eax,Kernel16
push eax

;eip
lea eax,__v86VMIntrProc
push eax

iretd

_v86EntryReturn:
pop gs
pop fs
pop ds
pop es
popad
ret
__v86Entry endp

Kernel ends





Kernel16 Segment public para use16

assume cs:Kernel16

__v86VMIntrProc proc

mov ax,V86VMIPARAMS_SEG
mov fs,ax

mov byte ptr fs:[V86VMIPARAMS_OFFSET + V86VMIPARAMS._work],0

_v86VmIntCheckRequest:
mov ax,V86VMIPARAMS_SEG
mov fs,ax
mov ax,Kernel16
mov gs,ax
mov ax,KERNEL_BASE_SEGMENT
mov ss,ax
mov esp,BIT16_STACK_TOP
;sti
mov ecx,256
_v86Wait:

;hlt
nop
;fwait 指令会触发异常？
;fwait
;pause 指令会触发异常？
;db 0f3h,90h
loop _v86Wait

cmp byte ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._work],0
jz _v86VmIntCheckRequest

mov al,byte ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._intNumber]
mov byte ptr gs:[_v86VMIntNumber],al
mov byte ptr gs:[_v86VMIntOpcode],0cdh

push word ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._ds]
pop ds
push word ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._es]
pop es

mov eax,dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._eax]
mov ecx,dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._ecx]
mov edx,dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._edx]
mov ebx,dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._ebx]
mov esi,dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._esi]
mov edi,dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._edi]

_v86VMIntOpcode:
db 0cdh
_v86VMIntNumber:
db 13h

push word ptr V86VMIPARAMS_SEG
pop fs
push word ptr Kernel16
pop gs

jc _checkV86CarryError
;cmp ah,0					;ax=41h, bx=55aah not support,whenever succucess or failure, ah is not 0
;jnz _checkV86CarryError

jmp _V86VMIWorkOk

_checkV86CarryError:
cmp byte ptr gs:[_v86VMIntNumber],13h
jz _V86VMIWorkError

jmp _V86VMIWorkOk

_V86VMIWorkError:
mov dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._result],0
jmp _V86VMIComplete

_V86VMIWorkOk:
mov dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._result],1

_V86VMIComplete:
mov byte ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._work],0

;int 3

jmp _v86VmIntCheckRequest

iretd

jmp _v86VmIntCheckRequest

db 16 dup (0)
__v86VMIntrProcEnd equ $
__v86VMIntrProc endp




__v86VMLeave proc
MOV AX,KernelData
MOV DS,AX
MOV BX,DS:[_videoMode]
OR BX,4000H
MOV AX,4F02H
INT 10H
CMP AX,4FH

mov eax,dword ptr ss:[esp + TASKDOSPARAMS.address]

mov edx,eax
shr eax,4
mov ds,ax
and edx,0fh
mov dword ptr ds:[edx + DOS_PE_CONTROL.status],DOS_THREAD_TERMINATE_CONTROL_CODE
_v86LeaveWait:
nop
jmp _v86LeaveWait
__v86VMLeave endp


comment *
__v86Int20hProc proc
pushad
push ds
push es

mov ax,V86_TASKCONTROL_SEG
mov es,ax

;bp + 36 == ip
;bp + 38 == cs
;bp + 40 == eflags
mov bp,sp
add bp,36
movzx edx,word ptr ss:[bp+2]
shl edx,4
movzx eax,word ptr ss:[bp]
add edx,eax
shr edx,4

mov si,V86_TASKCONTROL_OFFSET
mov cx,LIMIT_V86_PROC_COUNT
_v86Int20DosTaskInfo:
push cx
push edx
push si

;mov eax,dword ptr es:[si+DOS_PE_CONTROL.address]
;cmp edx,eax
;jb ___v86Int21ProcNotFoundCs
;add eax,1000h
;cmp edx,eax
;ja ___v86Int21ProcNotFoundCs

pop si
pop edx
pop cx

;call __restoreScreen

MOV AX,KernelData
MOV DS,AX
MOV BX,DS:[_videoMode]
OR BX,4000H
MOV AX,4F02H
INT 10H
CMP AX,4FH
JNZ _int20RestoreVideoModeError

_int20RestoreVideoModeError:

mov dword ptr es:[si + DOS_PE_CONTROL.status],DOS_THREAD_TERMINATE_CONTROL_CODE

_v86Int20WaitEnd:
wait
nop
jmp _v86Int20WaitEnd

jmp __v86Int20ProcEnd

___v86Int20ProcNotFoundCs:
pop si
add si,sizeof DOS_PE_CONTROL
pop edx
pop cx
loop _v86Int20DosTaskInfo

__v86Int20ProcEnd:
pop es
pop ds
popad
iret
__v86Int20hProc endp
*




comment *
__v86Int21hProc proc
pushad
push ds
push es

cmp ah,4ch
jnz __v86Int21ProcEnd

mov ax,V86_TASKCONTROL_SEG
mov es,ax

;bp + 36 == ip
;bp + 38 == cs
;bp + 40 == eflags
mov bp,sp
add bp,36
movzx edx,word ptr ss:[bp+2]
shl edx,4
movzx eax,word ptr ss:[bp]
add edx,eax
shr edx,4

mov si,V86_TASKCONTROL_OFFSET
mov ecx,LIMIT_V86_PROC_COUNT
_v86Int21DosTaskInfo:
push cx
push edx
push si

mov eax,dword ptr es:[si+DOS_PE_CONTROL.address]
cmp edx,eax
jb ___v86Int21ProcNotFoundCs
add eax,1000h
cmp edx,eax
ja ___v86Int21ProcNotFoundCs

pop si
pop edx
pop cx

;call __restoreScreen

MOV AX,KernelData
MOV DS,AX
MOV BX,DS:[_videoMode]
OR BX,4000H
MOV AX,4F02H
INT 10H
CMP AX,4FH
JNZ _int21RestoreVideoModeError

_int21RestoreVideoModeError:

mov dword ptr es:[si + DOS_PE_CONTROL.status],DOS_THREAD_TERMINATE_CONTROL_CODE

_v86Int21WaitEnd:
wait
nop
jmp _v86Int21WaitEnd

jmp __v86Int21ProcEnd

___v86Int21ProcNotFoundCs:
pop si
add si,sizeof DOS_PE_CONTROL
pop edx
pop cx
loop _v86Int21DosTaskInfo

__v86Int21ProcEnd:
pop es
pop ds
popad
iret
__v86Int21hProc endp

*

__v86TssProc proc

;mov ax,3
;int 10h
iret
jmp __v86TssProc
__v86TssProc endp


comment *
__restoreScreen proc
	push ax
	push cx
	push dx
	push bx
	push es
	
	mov ax,kernelData
	mov es,ax
	mov ax,4f02h
	mov bx,4000h
	or bx,word ptr es:[_videoMode]
	int 10h
	
    mov AX, 4F04h
    mov DX, 2       ;子功能--恢复
    mov CX, 1       ;恢复硬件控制器状态
	push word ptr VESA_STATE_SEG
	pop es
    mov BX, VESA_STATE_OFFSET
    int 10h
	
	pop es
	pop bx
	pop dx
	pop cx
	pop ax
	ret
__restoreScreen endp
*


__v86Process proc
;cli
mov eax,V86_INT_SEG
mov fs,ax

mov ax,kernel16
mov gs,ax

mov eax,KERNEL_BASE_SEGMENT
mov ss,ax

mov esp,BIT16_STACK_TOP
mov ebp,esp

mov eax,kernel
mov eax,KernelData

mov eax,fs:[V86_INT_OFFSET + 32]
mov gs:[int_cmd],al

mov eax,fs:[V86_INT_OFFSET + 24]
mov ds,ax

mov eax,fs:[V86_INT_OFFSET + 28]
mov es,ax

mov eax,fs:[V86_INT_OFFSET]
mov ecx,fs:[V86_INT_OFFSET + 4]
mov edx,fs:[V86_INT_OFFSET + 8]
mov ebx,fs:[V86_INT_OFFSET + 12]
mov esi,fs:[V86_INT_OFFSET + 16]
mov edi,fs:[V86_INT_OFFSET + 20]

		db 0cdh
int_cmd db 13h

push word ptr V86_INT_SEG
pop fs
push word ptr Kernel16
pop gs

JC _CHECK_INT255_ERROR
;cmp ah,0
;jnz _CHECK_INT255_ERROR

JMP _INT255_RESULT_OK

_CHECK_INT255_ERROR:
CMP BYTE PTR gs:[int_cmd],13H
JNZ _INT255_RESULT_OK
mov dword ptr fs:[V86_INT_OFFSET + 36],0
jmp _int255_complete

_INT255_RESULT_OK:
mov dword ptr fs:[V86_INT_OFFSET + 36],1

_int255_complete:
nop
int 3
;int 254
jmp __v86Process

iretd
jmp __v86Process
__v86Process endp



Kernel16 ends