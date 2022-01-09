.386p

Kernel Segment public para use32
assume cs:Kernel





;param:ss_esp_eflag_cs_ip_errcode_errtype
__exceptionInfo proc
push ebp
mov ebp,esp
push ecx
push edx
push ebx
push esi
push edi
push ds
push es

sub esp,40h

mov ax,rwData32Seg
mov ds,ax
mov ebx,KernelData
shl ebx,4

mov eax,ebx
add eax,offset _exceptionType
push eax
push dword ptr 0
push dword ptr ss:[ebp + 32]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _exceptionErrCode
push eax
push dword ptr 0
push dword ptr ss:[ebp + 28]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _exceptionEIP
push eax
push dword ptr 0
push dword ptr ss:[ebp + 24]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _exceptionCS
push eax
push dword ptr 0
push dword ptr ss:[ebp + 20]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _exceptionEflags
push eax
push dword ptr 0
push dword ptr ss:[ebp + 16]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _exceptionESP
push eax
push dword ptr 0
push dword ptr ss:[ebp + 12]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _exceptionSS
push eax
push dword ptr 0
push dword ptr ss:[ebp + 8]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _exceptionInfo
push eax
call __showErrInfo
add esp,4

add esp,40h
pop es
pop ds
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__exceptionInfo endp



__testMouseInfo proc
push ebp
mov ebp,esp

push ebx
sub esp,40h

mov ebx,KernelData
shl ebx,4

MOV ESI,MOUSE_BUFFER

mov eax,ebx
add eax,offset _screenX
push eax
push dword ptr 0
push dword ptr ds:[ebx + _videoWidth]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _screenY
push eax
push dword ptr 0
push dword ptr ds:[ebx + _videoHeight]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _screenColor
push eax
push dword ptr 0
push dword ptr ds:[ebx + _bytesPerPixel ]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _mousePosX
push eax
push dword ptr 0
push dword ptr ds:[ esi + MOUSEDATA._mouseX]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _mousePosY
push eax
push dword ptr 0
push dword ptr ds:[esi + MOUSEDATA._mouseY]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _mouseW
push eax
push dword ptr 0
push dword ptr ds:[ esi + MOUSEDATA._mouseWidth]
call __int2hexstr
add esp,12

mov eax,ebx
add eax,offset _mouseH
push eax
push dword ptr 0
push dword ptr ds:[esi + MOUSEDATA._mouseHeight]
call __int2hexstr
add esp,12

cmp word ptr ds:[ebx + _videoMode],VIDEO_MODE_3
jz __graphInfoShowText

push dword ptr ds:[ebx + _taskBarColor]
push dword ptr ds:[ebx + _screenInfoPos]
push dword ptr VIDEOMODE_FONTCOLOR_ERR
mov eax,ebx
add eax,offset _graphShowInfo
push eax
call __graphPositonString
add esp,16
jmp __graphInfoShowTextEnd

__graphInfoShowText:
mov eax,VIDEOMODE_TEXT_MAX_OFFSET
add eax,VIDEOMODE_TEXT_DATABASE
sub eax,VIDEOMODE_TEXT_BYTESPERLINE
sub eax,VIDEOMODE_TEXT_BYTESPERLINE
push eax
push dword ptr TEXTMODE_FONTCOLOR_ERR
mov eax,ebx
add eax,offset _graphShowInfo
push eax
call __textModePositionShow32
add esp,12

__graphInfoShowTextEnd:
add esp,40h
pop ebx

mov esp,ebp
pop ebp
ret
__testMouseInfo endp



Kernel ends


