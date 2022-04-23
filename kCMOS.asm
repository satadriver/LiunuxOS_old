.386p

CMOS_ALARM_MINUTE_INTERVAL EQU 3

Kernel Segment public para use32
assume cs:Kernel


;0ch
;bit7  Interrupt Request Flag (IRQF): IRQF = (PF * PIE) + (AF * AIE) + (UF *UFE). 
;This bit also causes the RTC Interrupt to be asserted. This bit is cleared upon RSMRST# or a read of Register C

;bit6 Periodic Interrupt Flag (PF): This bit is cleared upon RSMRST# or a read of Register C.
;0 = If no taps are specified through the RS bits in Register A, this flag will not be set.
;1 = Periodic interrupt Flag will be 1 when the tap specified by the RS bits of register A is 1.

;bit5 Alarm Flag (AF):
;0 = This bit is cleared upon RTCRST# or a read of Register C.
;1 = Alarm Flag will be set after all Alarm values match the current time.

;bit4 Update-Ended Flag (UF): 
;0 = The bit is cleared upon RSMRST# or a read of Register C.
;1 = Set immediately following an update cycle for each second.
align 10h
__iCmosTimerProc proc
pushad
push ds
push es
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebx,kernelData
shl ebx,4

;0a寄存器的 RS必须置位才能引发中断
;u must read 0ch to clear the interruption
mov al,0ch
out 70h,al
in al,71h
; IRQF = (PF * PIE) + (AF * AIE) + (UF *UFE),if double interruptions,will not be 1
test al,040h
jnz _cmosExactlyTimer
test al,020h
jnz _cmosAlarmer
test al,010h
jnz _cmosPeriodSecond
jmp _cmosIntEnd

_cmosExactlyTimer:
cmp dword ptr ds:[ebx + _kCmosExactTimerProc],0
jz _cmosIntEnd
call dword ptr ds:[ebx + _kCmosExactTimerProc]

;cmp dword ptr ds:[ebx + _kTaskSchedule],0
;jz _cmosIntEnd

;push esp
;mov eax,dword ptr ds:[ebx + _kTaskSchedule]
;call eax
;add esp,4

;cmp dword ptr ds:[ebx + _kScreenProtect],0
;jz _timer0CheckTaskCounter
;call dword ptr ds:[ebx + _kScreenProtect]
;_timer0CheckTaskCounter:

mov al,20h
out 20h,al
out 0a0h,al

pop ss
pop gs
pop fs
pop es
pop ds
popad
;[esp -32] edi
;[esp -28] esi
;[esp -24] ebp
;[esp -20] esp
;[esp -16] ebx
;[esp -12] edx
;[esp -8] ecx
;[esp -4] eax
;[esp ] ip
;[esp + 4] cs
;[esp + 8] eflags
;[esp + 12] esp3
;[esp + 16] ss3
;test dword ptr ss:[esp + 4],3

;mov esp,ss:[esp - 20]

iretd
jmp __iCmosTimerProc
;响应 interrupt gate 时，processor 将 Rflags.IF 清为 0，将中断标志清为 0，
;表示在 interrupt 例程执行完毕之前是不能响应其它的中断（可屏敝中断）
;在 long mode 下已经不支持使用 TSS 来切换 task ，包括 TSS selector 和 task gate。
;使用 call / jmp TSS_selector 将产生 #GP 异常



_cmosAlarmer:
;call __makeCmosAlarm
cmp dword ptr ds:[ebx + _kCmosAlarmProc],0
jz _cmosIntEnd
call dword ptr ds:[ebx + _kCmosAlarmProc]
;call __showCmosInterruption
jmp _cmosIntEnd

_cmosPeriodSecond:
;call __cmosShowTime
cmp dword ptr ds:[ebx+_kCmosTimer],0
jz _cmosIntEnd
call dword ptr ds:[ebx+_kCmosTimer]
jmp _cmosIntEnd

_cmosIntEnd:
mov al,20h
out 20h,al
out 0a0h,al

pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
jmp __iCmosTimerProc
__iCmosTimerProc endp



__showCmosInterruption proc
mov ebp,esp
add ebp,52
push dword ptr ICW2_SLAVE_INT_NO + 0
push dword ptr 0
push dword ptr [ebp]
push dword ptr [ebp + 4]
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kCmosKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kCmosShowExpInfo
_kCmosKernelModeInt:
push dword ptr 0
push dword ptr 0
_kCmosShowExpInfo:
call  __exceptionInfo
add esp,28
mov ebp,esp
ret
__showCmosInterruption endp








__cmosShowTime proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

mov ebx,kernelData
shl ebx,4

;mov esi,ebx
;add esi,offset _timerZoneBuf
mov esi,esp

push esi
call __strCmosTimer
add esp,4
push esi
push CMOS_DATETIME_STRING
CALL __strcpy

inc dword ptr ds:[CMOS_SECONDS_TOTAL]
cmp dword ptr ds:[CMOS_SECONDS_TOTAL],180
jb _toShowCmosTimerStr
mov eax,TURNOFFSCREEN
int 80h

_toShowCmosTimerStr:
cmp word ptr ds:[ebx + _videoMode],VIDEO_MODE_3
jz __cmosShowText

;WHY HERE CAUSE EXCEPTION?
;call __setTimerBackground

push dword ptr ds:[ebx + _timerZoneColor]
mov eax,ds:[ebx + _videoFrameTotal]
sub eax,ds:[ebx + _graphFontLSize]
push eax
push dword ptr VIDEOMODE_FONTCOLOR_NORMAL
push esi
call __graphPositonString
add esp,16
jmp __cmosShowTimeEnd

__cmosShowText:
mov eax,VIDEOMODE_TEXT_MAX_OFFSET
add eax,VIDEOMODE_TEXT_DATABASE
sub eax,VIDEOMODE_TEXT_BYTESPERLINE
push eax
push dword ptr TEXTMODE_FONTCOLOR_NORMAL
push esi
call __textModePositionShow32
add esp,12

__cmosShowTimeEnd:
add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__cmosShowTime endp






__makeCmosAlarm proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

;day,hour,minute,second,year,month
push esp
call __getCmosAlarmParams
add esp,4

mov eax,dword ptr ss:[esp + 8]
add eax,CMOS_ALARM_MINUTE_INTERVAL
;bcd 57h
cmp eax,60
jb _cmosAlarmMinuteOk
sub eax,60
das
mov dword ptr ss:[esp + 8],eax

mov eax,dword ptr ss:[esp + 4]
add eax,1
cmp eax,24
jb _cmosAlarmHourOk
sub eax,24
das
mov dword ptr ss:[esp + 4],eax

push dword ptr ss:[esp + 20]
push dword ptr ss:[esp + 16]
call __getDaysOfMonth
add esp,8

mov ecx,dword ptr ss:[esp]
add ecx,1

cmp ecx,eax
jbe _cmosAlarmDayOk
mov dword ptr ss:[esp],1

_cmosAlarmOk:
call __setCmosAlarmTimer

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret

_cmosAlarmMinuteOk:
daa
mov dword ptr ss:[esp + 8],eax
jmp _cmosAlarmOk

_cmosAlarmHourOk:
daa
mov dword ptr ss:[esp + 4],eax
jmp _cmosAlarmOk

_cmosAlarmDayOk:
daa
mov dword ptr ss:[esp],eax
jmp _cmosAlarmOk
__makeCmosAlarm endp



;day,hour,minute,seconds
__setCmosAlarmTimer proc
push ebp
mov ebp,esp

;These bits store the date of month alarm value. If set to 000000b, then a don’t care state is assumed
mov al,0dh
out 70h,al
mov al,byte ptr ss:[ebp + 8]
out 71h,al

mov al,5
out 70h,al
mov al,byte ptr ss:[ebp + 12]
out 71h,al

mov al,3
out 70h,al
mov al,byte ptr ss:[ebp + 16]
out 71h,al

mov al,1
out 70h,al
mov al,byte ptr ss:[ebp + 20]
out 71h,al

mov esp,ebp
pop ebp
ret
__setCmosAlarmTimer endp


;buffer
__getCmosAlarmParams proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

mov edi,ss:[ebp + 8]

mov eax,0

cld

mov al,7
out 70h,al
in al,71h
movzx eax,al
push eax
call __bcdb2b
add esp,4
stosd

mov al,4
out 70h,al
in al,71h
movzx eax,al
push eax
call __bcdb2b
add esp,4
stosd

mov al,2
out 70h,al
in al,71h
movzx eax,al
push eax
call __bcdb2b
add esp,4
stosd

mov al,0
out 70h,al
in al,71h
movzx eax,al
push eax
call __bcdb2b
add esp,4
stosd

mov al,32h
out 70h,al
in al,71h
movzx eax,al
mov ah,al

mov al,9
out 70h,al
in al,71h
push eax
call __bcdw2b
add esp,4
stosd

mov al,8
out 70h,al
in al,71h
movzx eax,al
push eax
call __bcdb2b
add esp,4
stosd

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__getCmosAlarmParams endp







Kernel ends