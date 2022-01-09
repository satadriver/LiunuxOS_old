.386p

Kernel Segment public para use32
assume cs:Kernel


__shutdownSystem proc
push edx

mov dx,0cf8h
mov eax,8000f840h
out dx,eax

mov dx,0cfch
in eax,dx
cmp eax,0ffffffffh
jz _notSupportICH

and ax,0fffeh
add ax,4
mov dx,ax
in ax,dx
or ax,03c00h
out dx,ax

_notSupportICH:
pop edx
ret

push dx
mov dx,0cf8h
mov eax,8000f840h
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh    
mov dx,ax
push dx
add dx,30h 
in ax,dx
and ax,0ffefh
;and ax,0fffeh?
out dx,ax
pop dx
add dx,5 
in al,dx
or al,3ch
out dx,al
pop dx
ret
__shutdownSystem endp


;可以打开a20访问ffff:0 - ffff:ffff的地址空间(100000h --1ffefh)
;1 jmp 0ffffh:0
;2 92h的bit 0是给机器发复位信号的
__resetSystem proc
mov al,1
out 92h,al
ret

;mov al,4
;mov dx,0cf9h
;out dx,al
ret
__resetSystem endp




Kernel ends

