.686p


KBD_SERVICE_PRINT		EQU 1
KBD_SERVICE_PUT			EQU 2
MOUSE_SERVICE_INFO		EQU 3
GRAPHCHAR_SERVICE		EQU 4
RANDROM_NUMBER			EQU 5
SLEEPTIME				EQU 6

TURNONSCREEN				EQU 7
TURNOFFSCREEN				EQU 8

CPUMANUFACTORY				EQU 9
TIMESTAMP					EQU 10
SWITCHSCREEN				EQU 11
CPUINFO						EQU 12

DRAW_MOUSE					EQU 13
RESTORE_MOUSE				Equ 14
SETVIDEOMODE				EQU 15


Kernel Segment public para use32
assume cs:Kernel

;eax:cmd
__kServicesProc proc
push ebp
mov ebp,esp
sub esp,100h

;PUSH eax
push ecx
push edx
push ebx
push esi
push edi
push ds
push es
push fs
push gs
push ss

;do not user eax,because eax is used to switch params
mov cx,rwData32Seg
mov ds,cx
mov es,cx

mov ebx,kernelData
shl ebx,4

cmp dword ptr ds:[ebx + _kServicesProc],0
jz __kservicesAsm
cmp eax,6
jnz __kservicesAsm
push edi
push eax
call dword ptr ds:[ebx + _kServicesProc]
add esp,8
jmp _kSysSvcReturn

__kservicesAsm:

cmp eax,KBD_SERVICE_PRINT
jz _kbdPrintable
cmp eax,MOUSE_SERVICE_INFO
jz _mousePosService
cmp eax,KBD_SERVICE_PUT
jz _kbdOutput
cmp eax,GRAPHCHAR_SERVICE
jz _graphCharShow
cmp eax,RANDROM_NUMBER
jz _randromNumber
cmp eax,SLEEPTIME
jz _sleepTime
cmp eax,TURNONSCREEN
jz _turnonscreen
cmp eax,TURNOFFSCREEN
jz _turnoffscreen
CMP eax,CPUMANUFACTORY
jz _cpumanu
cmp eax,TIMESTAMP
jz _cputimestamp
CMP EAX,SWITCHSCREEN
jz _switchScreen
CMP EAX,CPUINFO
jz _cpuInfo

CMP EAX,DRAW_MOUSE
JZ _drawMouse

CMP EAX,RESTORE_MOUSE
jz _restoreMouse

CMP EAX,SETVIDEOMODE
JZ _setVideoMode

jmp _kSysSvcReturn

_kbdPrintable:
call __scancode2Ascii
jmp _kSysSvcReturn

_mousePosService:
call __mouseService
jmp _kSysSvcReturn

_kbdOutput:
push edi
call __showErrInfo
add esp,4
jmp _kSysSvcReturn

_graphCharShow:
;string,color,pos,backcolor
push dword ptr [edi+12]
push dword ptr [edi+8]
push dword ptr [edi+4]
push dword ptr [edi]
call __graphPositonString
add esp,16
jmp _kSysSvcReturn

_sleepTime:
call __sleep
jmp _kSysSvcReturn

_randromNumber:
call __getRandom
jmp _kSysSvcReturn

_turnoffscreen:
call __turnoffScreen
jmp _kSysSvcReturn

_turnonscreen:
call __turnonScreen
jmp _kSysSvcReturn

_switchScreen:
call __switchScreen
jmp _kSysSvcReturn

_cpuInfo:
call __cpuinfo
jmp _kSysSvcReturn

_drawMouse:
call __drawArray
jmp _kSysSvcReturn

_restoreMouse:
call __restoreArray
jmp _kSysSvcReturn

_setVideoMode:
call __setVideoMode
jmp _kSysSvcReturn


_kSysSvcReturn:
pop ss
pop gs
pop fs
pop es
pop ds
pop edi
pop esi
pop ebx
pop edx
pop ecx
;pop eax
mov esp,ebp
pop ebp
iretd
__kServicesProc endp



__sleep proc
mov edx,0
mov eax,ds:[edi]
mov ecx,15	;time0 most least frequency is 55ms,cmos most least frequency is 15ms
div ecx
cmp eax,0
jnz _waitForIntr
inc eax
_waitForIntr:
hlt
dec eax
cmp eax,0
jnz _waitForIntr
ret
__sleep endp


__getRandom proc
mov eax,0
mov al,0
out 43h,al
in al,40h
shl eax,8
in al,40h
shl eax,8

mov al,0
out 43h,al
in al,40h
shl eax,8
in al,40h
ret
__getRandom endp


__turnoffScreen proc
push edx
mov dx,3c4h
mov al,1
out dx,al
mov dx,3c5h
in al,dx
test al,20h
jnz __turnoffScreenEnd
or al,20h
out dx,al
__turnoffScreenEnd:
pop edx
ret
__turnoffScreen endp


__turnonScreen proc
push edx
mov dx,3c4h
mov al,1
out dx,al
mov dx,3c5h
in al,dx
test al,20h
jz __turnonScreenEnd
and al,0
out dx,al
__turnonScreenEnd:
pop edx
ret
__turnonScreen endp

__switchScreen proc
push edx
mov dx,3c4h
mov al,1
out dx,al
mov dx,3c5h
in al,dx
test al,20h
jz _shutdownscreen
mov al,0
out dx,al
pop edx
ret

_shutdownscreen:
mov al,20h
out dx,al
pop edx
ret
__switchScreen endp



_cpumanu proc
mov eax,0
;must use .586 or above
;dw 0a20fh
cpuid
;ebx:edx:ecx = intel or else
mov ds:[edi],ebx
mov ds:[edi+4],edx
mov ds:[edi + 8],ecx
mov dword ptr ds:[edi + 12],0
ret
_cpumanu endp



__cpuinfo proc
mov     eax, 80000000h
;dw 0a20fh
cpuid
cmp     eax, 80000004h
jb      __cpuinfoEnd

mov     eax, 80000002h
;dw 0a20fh
cpuid
mov     dword ptr [edi], eax
mov     dword ptr [edi + 4], ebx
mov     dword ptr [edi + 8], ecx
mov     dword ptr [edi + 12], edx

mov     eax, 80000003h
;dw 0a20fh
cpuid
mov     dword ptr [edi + 16], eax
mov     dword ptr [edi + 20], ebx
mov     dword ptr [edi + 24], ecx
mov     dword ptr [edi + 28], edx

mov     eax, 80000004h
;dw 0a20fh
cpuid
mov     dword ptr [edi + 32], eax
mov     dword ptr [edi + 36], ebx
mov     dword ptr [edi + 40], ecx
mov     dword ptr [edi + 44], edx

mov     dword ptr [edi + 48], 0

__cpuinfoEnd:
ret
__cpuinfo endp


_cputimestamp proc
;must use .586 or above
rdtsc
;edx:eax = time stamp
mov ds:[edi],eax
mov ds:[edi+4],edx
mov dword ptr ds:[edi + 8],0
ret
_cputimestamp endp



__setVideoMode proc
cmp byte ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._work],0
jz __setVideoModeParams

mov eax,6
push dword ptr 0
mov edi,esp
int 80h
add esp,4

jmp __setVideoMode

__setVideoModeParams:

mov word ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._ds],0
mov word ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._es],0
mov eax,ds:[edi]
mov dword ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._eax],eax
mov dword ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._ecx],0
mov dword ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._edx],0
mov eax,ds:[edi+4]
mov dword ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._ebx],eax
mov dword ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._esi],0
mov dword ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._edi],0
mov byte ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._intNumber],10h

mov byte ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._work],1
mov dword ptr ds:[V86VMIPARAMS_ADDRESS +V86VMIPARAMS._result],1
ret
__setVideoMode endp

Kernel ends
