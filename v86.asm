.386p

Kernel Segment public para use32
assume cs:Kernel

;useless function
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

;pushad or popfd will cause GP protection exp
align 10h
__v86VMIntrProc proc

mov eax,0
mov ds,ax
mov es,ax

;set int21h
mov eax,Kernel16
shl eax,16
mov ax,offset __v86Int21hProc
mov ecx,21h
shl ecx,2
mov dword ptr ds:[ecx],eax

;set int20h
mov eax,Kernel16
shl eax,16
mov ax,offset __v86Int20hProc
mov ecx,20h
shl ecx,2
mov dword ptr ds:[ecx],eax

mov ax,V86VMIPARAMS_SEG
mov fs,ax
mov ax,Kernel16
mov gs,ax
mov ax,kernelData
mov ds,ax
mov es,ax
mov ax,KERNEL_BASE_SEGMENT
mov ss,ax
mov esp,BIT16_STACK_TOP

mov byte ptr fs:[V86VMIPARAMS_OFFSET + V86VMIPARAMS._work],0

_v86VmIntCheckRequest:
mov ax,V86VMIPARAMS_SEG
mov fs,ax
mov ax,Kernel16
mov gs,ax
mov ax,kernelData
mov ds,ax
mov es,ax
mov ax,KERNEL_BASE_SEGMENT
mov ss,ax
mov esp,BIT16_STACK_TOP

mov ecx,8
_v86Wait:
nop
;fwait 指令会触发异常？
;fwait
;pause 指令会触发异常？
;db 0f3h,90h
;db 0f3h,90h
;db 0f3h,90h
loop _v86Wait

cmp byte ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._work],0
jz _v86VmIntCheckRequest

mov al,byte ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._intNumber]
cmp al,3
jz _v86VMInt3
mov byte ptr gs:[_v86VMIntNumber],al
mov byte ptr gs:[_v86VMIntOpcode],0cdh
jmp _v86VMIntSetRegs

_v86VMInt3:
mov byte ptr gs:[_v86VMIntOpcode],0cch
mov byte ptr gs:[_v86VMIntNumber],90h

_v86VMIntSetRegs:
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

;stc
_v86VMIntOpcode:
db 0cdh
_v86VMIntNumber:
db 13h

jc _V86VMIWorkError

;cmp ah,0
;jnz _V86VMIWorkError

mov ax,V86VMIPARAMS_SEG
mov fs,ax
mov dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._result],1
jmp _V86VMIWorkOK

_V86VMIWorkError:
mov ax,V86VMIPARAMS_SEG
mov fs,ax
mov dword ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._result],0

_V86VMIWorkOK:
mov byte ptr fs:[V86VMIPARAMS_OFFSET +V86VMIPARAMS._work],0

jmp _v86VmIntCheckRequest

__v86VMIntIretdAddr:
;iretd will cause GP exception
iretd
__v86VMIntrProc endp

align 10h
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

__v86TssProc proc

;mov ax,3
;int 10h
iret
jmp __v86TssProc
__v86TssProc endp


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


Kernel16 ends