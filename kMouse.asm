.386p

;include 8042_8048_info.asm
Kernel Segment public para use32
assume cs:Kernel

;mouse direction is from left,top to right down,so the x delta is right,but y delta is negtive
align 10h
__kMouseProc proc 
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

cmp word ptr ds:[ebx + _videoMode],VIDEO_MODE_3
jz _mouseReturn
cmp word ptr ds:[ebx + _kMouseProc],0
jz _mouseReturn
call dword ptr ds:[ebx + _kMouseProc]
jmp _mouseReturn


mov esi,MOUSE_BUFFER
mov ecx,0
mov edx,0

in al,60h
mov dl,al
movsx eax,al
mov ds:[esi + MOUSEDATA._mintrData._mouseStatus + ecx ],eax
add ecx,4

_checkMouseStatus:
in al,64h
test al,1
jz _MouseProcMain
in al,60h
shl edx,8
mov dl,al
movsx eax,al
mov ds:[esi + MOUSEDATA._mintrData._mouseStatus + ecx ],eax
add ecx,4
cmp ecx,12
jz _MouseProcMain
jmp _checkMouseStatus

_MouseProcMain:
cmp ecx,12
jb _mousetestErr

mov eax,ds:[esi + MOUSEDATA._mintrData._mouseDeltaY]
not eax
mov ds:[esi + MOUSEDATA._mintrData._mouseDeltaY],eax


cmp dword ptr ds:[esi + MOUSEDATA._bInvalid],0
jnz _mouseIntCalcPos
cmp dword ptr ds:[esi + MOUSEDATA._mintrData._mouseDeltaY],0
jnz _mouseIntBackup
cmp dword ptr ds:[esi + MOUSEDATA._mintrData._mouseDeltaX],0
jnz _mouseIntBackup
jmp _mouseIntCalcPos
_mouseIntBackup:
call __restoreArray

_mouseIntCalcPos:
mov dword ptr ds:[esi + MOUSEDATA._bInvalid],0

mov eax,dword ptr ds:[esi + MOUSEDATA._mintrData._mouseDeltaX]
add dword ptr ds:[esi + MOUSEDATA._mouseX],eax
mov eax,dword ptr ds:[esi + MOUSEDATA._mouseX]
cmp eax,dword ptr ds:[ebx + _videoWidth]
jg _mouseXMax
cmp eax,0
jl _mouseXMin
jmp _checkMouseY
_mouseXMax:
mov eax,dword ptr ds:[ebx + _videoWidth]
mov dword ptr ds:[esi + MOUSEDATA._mouseX],eax
jmp _checkMouseY
_mouseXMin:
mov dword ptr ds:[esi + MOUSEDATA._mouseX],0
jmp _checkMouseY

_checkMouseY:
mov eax,dword ptr ds:[esi + MOUSEDATA._mintrData._mouseDeltaY]
add dword ptr ds:[esi + MOUSEDATA._mouseY],eax
mov eax,dword ptr ds:[esi + MOUSEDATA._mouseY]
cmp eax,dword ptr ds:[ebx + _videoHeight]
jg _mouseYMax
cmp eax,0
jl _mouseYMin
jmp _maekeArray
_mouseYMax:
mov eax,dword ptr ds:[ebx + _videoHeight]
mov dword ptr ds:[esi + MOUSEDATA._mouseY],eax
jmp _maekeArray
_mouseYMin:
mov dword ptr ds:[esi + MOUSEDATA._mouseY],0
jmp _maekeArray

_maekeArray:
cmp dword ptr ds:[esi + MOUSEDATA._mintrData._mouseDeltaY],0
jnz _mouseIntDraw
cmp dword ptr ds:[esi + MOUSEDATA._mintrData._mouseDeltaX],0
jnz _mouseIntDraw
jmp _mouseIntCheckClick
_mouseIntDraw:
call __drawArray

_mouseIntCheckClick:
test dword ptr ds:[esi + MOUSEDATA._mintrData._mouseStatus],7
jz _toShowMouse

mov edi,ds:[esi+ MOUSEDATA._mouseBufHdr]
shl edi,4
mov eax,ds:[esi+ MOUSEDATA._mintrData._mouseStatus]
mov ds:[esi+ MOUSEDATA._mouseBuf._mouseStatus + edi],eax
mov eax,ds:[esi+ MOUSEDATA._mouseX]
mov ds:[esi+ MOUSEDATA._mouseBuf._mouseX + edi],eax
mov eax,ds:[esi+ MOUSEDATA._mouseY]
mov ds:[esi+ MOUSEDATA._mouseBuf._mouseY + edi],eax
mov eax,ds:[esi+ MOUSEDATA._mouseZ]
mov ds:[esi+ MOUSEDATA._mouseBuf._mouseZ + edi],eax
;add dword ptr ds:[esi+ MOUSEDATA._mouseBufHdr],sizeof MOUSEPOSDATA
inc dword ptr ds:[esi+ MOUSEDATA._mouseBufHdr]
;cmp dword ptr ds:[esi+ MOUSEDATA._mouseBufHdr],MOUSE_BUF_LIMIT
cmp dword ptr ds:[esi+ MOUSEDATA._mouseBufHdr],MOUSE_POS_TOTAL
jb _toShowMouse
mov dword ptr ds:[esi+ MOUSEDATA._mouseBufHdr],0

_toShowMouse:
;call __showGraphInfo

_mouseReturn:
mov dword ptr ds:[CMOS_SECONDS_TOTAL],0
mov eax,TURNONSCREEN
int 80h

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

_mousetestErr:
mov ebp,esp
add ebp,52

push dword ptr ICW2_SLAVE_INT_NO + 4
push dword ptr edx
push dword ptr [ebp]
push dword ptr ecx
push dword ptr [ebp + 8]

test dword ptr [ebp + 4],3
jz _kMouseKernelModeInt
push dword ptr [ebp + 12]
push dword ptr [ebp + 16]
jmp _kMouseShowExpInfo
_kMouseKernelModeInt:
push dword ptr 0
push dword ptr 0
_kMouseShowExpInfo:
call  __exceptionInfo
add esp,28
mov ebp,esp
jmp _mouseReturn 

__kMouseProc endp



;ebp + 4  ret address
;ebp 	  old ebp
;ebp - 4  ecx
;ebp - 8  edx
;ebp - 12 ebx
;ebp - 16 esi
;ebp - 20 edi
;ebp - 24 x
;ebp - 28 y
;ebp - 32 4x
;ebp - 36 6y
;ebp - 40 9x

;param:null
__drawArray proc
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
mov eax,dword ptr ds:[ebx + _bytesPerPixel]
mov ss:[ebp - 44],eax
mov eax,dword ptr ds:[ebx + _bytesPerLine]
mov ss:[ebp - 48],eax
mov eax,dword ptr ds:[ebx + _videoBase]
mov ss:[ebp - 52],eax
mov eax,dword ptr ds:[ebx + _mouseColor]
;MOV EAX,MOUSE_INIT_COLOR
mov ss:[ebp - 56],eax
;mov eax,dword ptr ds:[ebx + _mouseBorderColor]
MOV EAX,MOUSE_BORDER_COLOR
mov ss:[ebp - 60],eax
mov eax,dword ptr ds:[ebx + _mouseBorderSize]
mov ss:[ebp - 64],eax

mov ebx,MOUSE_BUFFER
push dword ptr ds:[ebx + MOUSEDATA._mouseY]
push dword ptr ds:[ebx + MOUSEDATA._mouseX]
call __getPosition
add esp,8
mov edi,eax
add edi,ss:[ebp - 52]

mov esi,MOUSE_BUFFER
add esi,MOUSEDATA._mouseCoverData

cld

mov dword ptr ss:[ebp - 28],0

mov ecx,dword ptr ds:[ebx + MOUSEDATA._mouseHeight]

_drawMousePixel:

mov dword ptr ss:[ebp - 24],0

push ecx
push edi
mov ecx,dword ptr ds:[ebx + MOUSEDATA._mouseWidth]

_drawMouseLine:
push ecx

mov eax,dword ptr ss:[ebp - 28]
shl eax,2
mov dword ptr ss:[ebp - 32],eax

mov eax,dword ptr ss:[ebp - 24]
mov ecx,6
mul ecx
mov dword ptr ss:[ebp - 36],eax

mov eax,dword ptr ss:[ebp - 28]
mov ecx,9
mul ecx
mov dword ptr ss:[ebp - 40],eax

mov eax,dword ptr ss:[ebp - 36]
cmp eax,dword ptr ss:[ebp - 32]
jb _mouseOverDraw
cmp eax,dword ptr ss:[ebp - 40]
ja _mouseOverDraw
mov ecx,ss:[ebp - 44]
_mouseBakColorPixel:
mov dl,byte ptr ds:[edi]
mov ds:[esi],dl
inc edi
inc esi
loop _mouseBakColorPixel
sub edi,ss:[ebp - 44]
mov ecx,ss:[ebp - 44]

mov eax,dword ptr ss:[ebp - 36]
sub eax,dword ptr ss:[ebp - 32]
cmp eax,ss:[ebp - 64]
jbe _mouseBorderDraw
mov eax,dword ptr ss:[ebp - 36]
mov edx,dword ptr ss:[ebp - 40]
sub edx,eax
cmp edx,ss:[ebp - 64]
jbe _mouseBorderDraw
add dword ptr ss:[ebp - 56],00000fh
mov eax,dword ptr ss:[ebp - 56]
mov dword ptr ds:[ebx + _mouseColor],eax
jmp _mouseDrawPoint
_mouseBorderDraw:
mov eax,dword ptr ss:[ebp - 60]
_mouseDrawPoint:
stosb
shr eax,8
loop _mouseDrawPoint
sub edi,dword ptr ss:[ebp - 44]

_mouseOverDraw:
add edi,dword ptr ss:[ebp - 44]
inc dword ptr ss:[ebp - 24]
pop ecx
dec ecx
jnz _drawMouseLine

pop edi
add edi,dword ptr ss:[ebp - 48]
inc dword ptr ss:[ebp - 28]
pop ecx
dec ecx
cmp ecx,0
;loop,jne等条件跳转的距离不能超过127字节,jnz,ja,jg,jb,jl等可以
jnz _drawMousePixel

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__drawArray endp




;ebp + 4  ret address
;ebp 	  old ebp
;ebp - 4  ecx
;ebp - 8  edx
;ebp - 12 ebx
;ebp - 16 esi
;ebp - 20 edi
;ebp - 24 x
;ebp - 28 y
;ebp - 32 4x
;ebp - 36 6y
;ebp - 40 9x

;param:null
__restoreArray proc
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
mov eax,dword ptr ds:[ebx + _bytesPerPixel]
mov ss:[ebp - 44],eax
mov eax,dword ptr ds:[ebx + _bytesPerLine]
mov ss:[ebp - 48],eax
mov eax,dword ptr ds:[ebx + _videoBase]
mov ss:[ebp - 52],eax

mov ebx,MOUSE_BUFFER

push ds:[ebx + MOUSEDATA._mouseY]
push ds:[ebx + MOUSEDATA._mouseX]
call __getPosition
add esp,8
mov edi,eax
add edi,ss:[ebp - 52]

mov esi,MOUSE_BUFFER
add esi,MOUSEDATA._mouseCoverData

cld

mov dword ptr ss:[ebp - 28],0

mov ecx,dword ptr ds:[ebx + MOUSEDATA._mouseHeight]

_bdrawMousePixel:

mov dword ptr ss:[ebp - 24],0

push ecx
push edi
mov ecx,dword ptr ds:[ebx + MOUSEDATA._mouseWidth]

_bdrawMouseLine:
push ecx

mov eax,dword ptr ss:[ebp - 28]
shl eax,2
mov dword ptr ss:[ebp - 32],eax

mov eax,dword ptr ss:[ebp - 24]
mov ecx,6
mul ecx
mov dword ptr ss:[ebp - 36],eax

mov eax,dword ptr ss:[ebp - 28]
mov ecx,9
mul ecx
mov dword ptr ss:[ebp - 40],eax

mov eax,dword ptr ss:[ebp - 36]
cmp eax,dword ptr ss:[ebp - 32]
jb _bmouseOverDraw
cmp eax,dword ptr ss:[ebp - 40]
ja _bmouseOverDraw
mov ecx,dword ptr ss:[ebp - 44]
rep movsb
sub edi,dword ptr ss:[ebp - 44]

_bmouseOverDraw:
add edi,dword ptr ss:[ebp - 44]
inc dword ptr ss:[ebp - 24]
pop ecx
dec ecx
cmp ecx,0
jnz _bdrawMouseLine

pop edi
add edi,dword ptr ss:[ebp - 48]
inc dword ptr ss:[ebp - 28]
pop ecx
dec ecx
cmp ecx,0
jnz _bdrawMousePixel

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__restoreArray endp




__mouseInit proc
push ebp
mov ebp,esp
push ebx
sub esp,40h

mov ebx,kernelData
shl ebx,4

push dword ptr ds:[ebx + _videoHeight]
push dword ptr ds:[ebx + _videoWidth]
call __initMouseParams
add esp,8

call __drawArray

add esp,40h
pop ebx
mov esp,ebp
pop ebp
ret
__mouseInit endp








;parm: x,y
__initMouseParams proc
push ebp
mov ebp,esp

push ecx
push edx
push ebx
push esi
sub esp,40h

mov ebx,kernelData
shl ebx,4

mov esi,MOUSE_BUFFER

mov eax,dword ptr ss:[ebp + 8]
shr eax,1
mov ds:[esi + MOUSEDATA._MouseX],eax

;mov dword ptr ds:[esi + MOUSEDATA._MouseX],0


mov edx,dword ptr ss:[ebp + 12]
shr edx,1
mov ds:[esi + MOUSEDATA._MouseY],edx

;mov dword ptr ds:[esi + MOUSEDATA._MouseY],0

mov eax,dword ptr ss:[ebp + 8]
cmp eax,dword ptr ss:[ebp + 12]
jae _makeMouseSquare
mov eax,dword ptr ss:[ebp + 12]
_makeMouseSquare:
mov edx,0
mov ecx,ds:[ebx + _mouseRatioSize]
div ecx
mov ds:[esi + MOUSEDATA._mouseWidth],eax
mov ds:[esi + MOUSEDATA._mouseHeight],eax

;mov eax,dword ptr ss:[ebp + 8]
;mov edx,0
;mov ecx,ds:[ebx + _mouseRatioSize]
;div ecx
;mov ds:[ebx + _mouseHeight],eax

add esp,40h
pop esi
pop ebx
pop edx
pop ecx

mov esp,ebp
pop ebp
ret
__initMouseParams endp





__mouseService proc
push ebp
mov ebp,esp

push ebx
push esi
push edi

mov ebx,MOUSE_BUFFER

mov eax,0

mov esi,ds:[ebx + MOUSEDATA._mouseBufTail]
cmp esi,dword ptr [ebx + MOUSEDATA._mouseBufHdr]
jz _mouseServiceEnd

shl esi,4
mov eax,ds:[ebx + MOUSEDATA._mouseBuf._mouseStatus + esi]
mov dword ptr ds:[edi],eax

mov eax,ds:[ebx + MOUSEDATA._mouseBuf._mouseX + esi]
mov dword ptr ds:[edi + 4],eax

mov eax,ds:[ebx + MOUSEDATA._mouseBuf._mouseY + esi]
mov dword ptr ds:[edi + 8],eax

mov eax,ds:[ebx + MOUSEDATA._mouseBuf._mouseZ + esi]
mov dword ptr ds:[edi + 12],eax

mov eax,4

;add dword ptr ds:[ebx+ MOUSEDATA._mouseBufTail],sizeof MOUSEPOSDATA
inc dword ptr ds:[ebx+ MOUSEDATA._mouseBufTail]
;cmp dword ptr ds:[ebx+ MOUSEDATA._mouseBufTail],MOUSE_BUF_LIMIT
cmp dword ptr ds:[ebx+ MOUSEDATA._mouseBufTail],MOUSE_POS_TOTAL
jb _mouseServiceEnd
mov dword ptr ds:[ebx+ MOUSEDATA._mouseBufTail],0

_mouseServiceEnd:
pop edi
pop esi
pop ebx
mov esp,ebp
pop ebp
ret
__mouseService endp




Kernel ends
