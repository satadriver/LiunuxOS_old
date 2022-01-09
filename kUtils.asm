.386p

;comment @
;include mymacro.asm
;comment


Kernel Segment public para use32
assume cs:Kernel

;param:string
__hexstr2int  proc

push ebp
mov ebp,esp

push edx
push esi
sub esp,40h

push ss:[ebp + 8]
call __strlen
add esp,4

mov edx,0

cmp eax,8
ja _hexstr2intover
cmp eax,0
jbe _hexstr2intover

mov esi,ss:[ebp + 8]
cld

_hexstr2inextc:
lodsb
cmp al,0
jz _hexstr2intover

cmp al,'a' 
jb _checkupper
cmp al ,'f'
ja _hexstr2intover
sub al,87
jmp _h2iKeepResult

_checkupper:
cmp al,'A' 
jb _checknumber
cmp al,'F'
ja _hexstr2intover
sub al,55
jmp _h2iKeepResult

_checknumber:
cmp al , '0' 
jb _hexstr2intover
cmp al , '9'
ja _hexstr2intover
sub al,30h
jmp _h2iKeepResult

_h2iKeepResult:
shl edx,4
or dl,al
jmp _hexstr2inextc

_hexstr2intover:
mov eax,edx
add esp,40h
pop esi
pop edx

mov esp,ebp
pop ebp
ret
__hexstr2int endp


;param:intvalue,uppercase,dstbuf
__int2hexstr proc
push ebp
mov ebp,esp

push ecx
push edx
push ebx
push edi
sub esp,40h

mov eax,ss:[ebp + 12]
cmp eax,0
jnz _uppercase
mov ebx,87
jmp _i2hStartMain
_uppercase:
mov ebx,55

_i2hStartMain:
mov edi,ss:[ebp + 16]
cld
mov eax,ss:[ebp + 8]
mov edx,eax
mov ecx,28
_i2hHex16:
shr eax,cl
and al,0fh
cmp al,9
jbe _i2hNumber
add al,bl
jmp _i2hKeepResult
_i2hNumber:
add al,30h

_i2hKeepResult:
stosb
mov eax,edx
sub ecx,4
;JNC也可以看成是加法没有进位，减法没有借位的时候转移
jnc _i2hHex16

add esp,40h
pop edi
pop ebx
pop edx
pop ecx

mov esp,ebp
pop ebp
ret
__int2hexstr endp


;param string
__strlen proc
push ebp
mov ebp,esp

push esi
sub esp,40h

mov esi,ss:[ebp + 8]
cld
_strlenNextByte:
lodsb
cmp al,0
jnz _strlenNextByte

mov eax,esi
dec eax
sub eax,dword ptr ss:[ebp + 8]

add esp,40h
pop esi

mov esp,ebp
pop ebp
ret
__strlen endp


;param:dst,src
__strcpy proc
push ebp
mov ebp,esp

push esi
push edi
sub esp,40h

mov esi,ss:[ebp + 12]
mov edi,ss:[ebp +8]
cld
_strcopybytes:
;movsb 不改变al的值
lodsb
stosb
cmp al,0
jnz _strcopybytes
mov eax,esi
dec eax
sub eax,dword ptr ss:[ebp +12]

add esp,40h
pop edi
pop esi
mov esp,ebp
pop ebp
ret
__strcpy endp


;param:dststr,srcstr
__strstr proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi

sub esp,40h

push dword ptr ss:[ebp + 8]
call __strlen
add esp,4
mov ss:[ebp - 24],eax

push dword ptr ss:[ebp + 12]
call __strlen
add esp,4
mov ss:[ebp - 28],eax

cmp eax,ss:[ebp - 24]
ja _strstrFound

mov esi,ss:[ebp + 8]
mov edi,ss:[ebp + 12]
mov ecx,ss:[ebp - 24]
sub ecx,ss:[ebp - 28]
inc ecx
_getsubstr:
push esi
mov edx,ecx
mov ecx,ss:[ebp - 28]
mov edi,ss:[ebp + 12]
repe cmpsb
pop esi
jz _strstrFound
inc esi
mov ecx,edx
loop _getsubstr

mov eax,0
jmp _strstrOver

_strstrFound:
mov eax,esi

_strstrOver:
add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__strstr endp



;param:dststr,srcstr
__strcat proc
push ebp
mov ebp,esp

push edi

push dword ptr ss:[ebp + 8]
call __strlen
add esp,4
mov edi,dword ptr ss:[ebp + 8]
add edi,eax
push dword ptr ss:[ebp +12]
push edi
call __strcpy
add esp,8

pop edi

mov esp,ebp
pop ebp
ret
__strcat endp



;param:string,string
__strcmp proc
push ebp
mov ebp,esp
push ecx
push edx
push esi
push edi
sub esp,40h

push dword ptr ss:[ebp + 8]
call __strlen
add esp,4
mov ecx,eax
push dword ptr ss:[ebp + 12]
call __strlen
add esp,4
cmp eax,ecx
jz _strlenSame
mov eax,-1
jmp __strcmpEnd
_strlenSame:
mov esi,ss:[ebp + 8]
mov edi,ss:[ebp + 12]
repe cmpsb
jz _strCmpSame
mov eax,-1
jmp __strcmpEnd
_strCmpSame:
mov eax,0
__strcmpEnd:
add esp,40h
pop edi
pop esi
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__strcmp endp



;param: dst,src,len
__memcpy proc
push ebp
mov ebp,esp

push ecx
push esi
push edi
sub esp,40h

mov esi,ss:[ebp + 12]
mov edi,ss:[ebp +8]
mov ecx,ss:[ebp + 16]
cld
rep movsb

mov eax,ss:[ebp + 16]

add esp,40h
pop edi
pop esi
pop ecx
mov esp,ebp
pop ebp
ret
__memcpy endp




;param:dayOfWeek,dstdata
__int2Week proc
push ebp
mov ebp,esp

push ebx
sub esp,40h

mov ebx,KERNELData
shl ebx,4

mov eax,dword ptr ss:[ebp + 8]
cmp eax,1
jz _monday
cmp eax,2
jz _tuesday
cmp eax,3
jz _wednesday
cmp eax,4
jz _thursday
cmp eax,5
jz _friday
cmp eax,6
jz _saturday
cmp eax,7
jz _sunday
mov eax,0
jmp _int2WeekOver

_monday:
add ebx,offset _mondayStr
push ebx
push dword ptr ss:[ebp + 12]
call __strcpy 
add esp,8
jmp _int2WeekOver
_tuesday:
add ebx,offset _tuesdayStr
push ebx
push dword ptr ss:[ebp + 12]
call __strcpy 
add esp,8
jmp _int2WeekOver
_wednesday:
add ebx,offset _wednesdayStr
push ebx
push dword ptr ss:[ebp + 12]
call __strcpy 
add esp,8
jmp _int2WeekOver
_thursday:
add ebx,offset _thursdayStr
push ebx
push dword ptr ss:[ebp + 12]
call __strcpy 
add esp,8
jmp _int2WeekOver
_friday:
add ebx,offset _fridaystr
push ebx
push dword ptr ss:[ebp + 12]
call __strcpy 
add esp,8
jmp _int2WeekOver
_saturday:
add ebx,offset _saturdayStr
push ebx
push dword ptr ss:[ebp + 12]
call __strcpy 
add esp,8
jmp _int2WeekOver
_sunday:
add ebx,offset _sundayStr
push ebx
push dword ptr ss:[ebp + 12]
call __strcpy 
add esp,8

_int2WeekOver:
add esp,40h
pop ebx

mov esp,ebp
pop ebp
ret
__int2Week endp




;year
__isLeapYear proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

mov eax,ss:[ebp + 8]
mov edx,0
mov ecx,100
div ecx
cmp edx,0
jz _notLeapYear

mov eax,ss:[ebp + 8]
mov edx,0
mov ecx,4
div ecx
cmp edx,0
jnz _notLeapYear

mov eax,1
jmp __isLeapYearEnd

_notLeapYear:
mov eax,0

__isLeapYearEnd:
add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__isLeapYear endp



__bcdb2b proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

mov eax,ss:[ebp + 8]
movzx eax,al
shr al,4
mov ecx,10
mul ecx

mov ecx,ss:[ebp + 8]
movzx ecx,cl
and ecx,0fh
add eax,ecx

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__bcdb2b endp



__bcdw2b proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

mov eax,ss:[ebp + 8]
movzx eax,al
shr al,4
mov ecx,10
mul ecx

mov ecx,ss:[ebp + 8]
movzx ecx,cl
and ecx,0fh
add eax,ecx

push eax

mov eax,ss:[ebp + 8]
shr eax,8
movzx eax,al
shr al,4
mov ecx,10
mul ecx

mov ecx,ss:[ebp + 8]
shr ecx,8
movzx ecx,cl
and ecx,0fh
add eax,ecx

mov ecx,100
mul ecx

pop edx
mov al,dl

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__bcdw2b endp



;year,month
__getDaysOfMonth proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

cmp dword ptr ss:[ebp + 12],2
jz _checkDaysOfFeb

mov al,byte ptr ss:[ebp + 12]
dec al
movzx esi,al

mov ebx,kerneldata
shl ebx,4

mov al,ds:[_gDateOfMonth + ebx + esi]
movzx eax,al
jmp __getDaysOfMonthEnd

_checkDaysOfFeb:
push dword ptr ss:[ebp + 8]
call __isLeapYear
add esp,4
cmp eax,0
jnz _leapYearFeb
mov eax,28
jmp __getDaysOfMonthEnd

_leapYearFeb:
mov eax,29
jmp __getDaysOfMonthEnd

__getDaysOfMonthEnd:
add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__getDaysOfMonth endp


Kernel Ends
