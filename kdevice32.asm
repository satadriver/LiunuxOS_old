.386p

Kernel Segment public para use32
assume cs:Kernel


;parm:dststr
__strCmosTimer proc
push ebp
mov ebp,esp

push edi
push edx
sub esp,40h

mov edi,ss:[ebp+8]

cld

mov al,32h
call __getCmosTimerAsc
stosw

mov al,9
call __getCmosTimerAsc
stosw

mov al,'/'
stosb

mov al,8
call __getCmosTimerAsc
stosw

mov al,'/'
stosb

mov al,7
call __getCmosTimerAsc
stosw

mov al,' '
stosb

mov al,4
call __getCmosTimerAsc
stosw

mov al,':'
stosb

mov al,2
call __getCmosTimerAsc
stosw

mov al,':'
stosb

mov al,0
call __getCmosTimerAsc
stosw

mov al,' '
stosb

mov al,6
call __getCmosTimerBCD
push edi
push eax
call __int2Week
add esp,8

add edi,eax
mov eax,0
stosd

add esp,40h
pop edx
pop edi
mov esp,ebp
pop ebp
ret
__strCmosTimer endp



;port = al
;need to check bit7 in port 70h,if 1 then wait to 0
__getCmosTimerAsc proc
push edx

;cli
;shutdown nmi
;or al,80h

;mov dl,al
;in al,70h
;and al,80h
;or al,dl
out 70h,al

in al,71h

;bcd to ascii
mov ah,al

shr ah,4
and ah,0fh
and al,0fh
add ah,30h
add al,30h
xchg al,ah
movzx eax,ax

pop edx

;sti

ret
__getCmosTimerAsc endp



;port = al
;param:port
__getCmosTimerBCD proc
push edx

;cli
;shutdown nmi
;or al,80h

;mov dl,al
;in al,70h
;and al,80h
;or al,dl
out 70h,al

in al,71h
movzx eax,al

pop edx

;sti

ret
__getCmosTimerBCD endp



__waitPs2Out proc
in al,64h
test al,1
jz __waitPs2Out
ret
__waitPs2Out endp



__waitPs2In proc
in al,64h
test al,2
jnz __waitPs2In
ret
__waitPs2In endp



__setKbdLed proc
push edx
mov edx,eax

;disable keyboard
call __waitPs2In
mov al,0adh
out 64h,al

;send ED command to 8048,not 8042 in cpu bridge
call __waitPs2In
mov al,0edh
out 60h,al

;任何时候收到一个来自于60h端口的合法命令或合法数据之后，都回复一个FAh
call __waitPs2Out
in al,60h
cmp al,0fah

call __waitPs2In
;send command data to 8048
mov eax,edx
out 60h,al
call __waitPs2Out        ;here u get return byte 0fah,but why can't read it out ?
in al,60h
cmp al,0fah

;break the waiting
;call __waitPs2In
;mov al,80h
;out 60h,al
;call __waitPs2Out
;in al,60h
;cmp al,0fah

;enable keyboard
call __waitPs2In
mov al,0aeh
out 64h,al

pop edx
ret
__setKbdLed endp






Kernel ends