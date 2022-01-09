.386p

;comment @
;public __showTextRM16
;comment

Kernel Segment public para use32
assume cs:Kernel


;112 640*480*16m
;115 800*600*16m
;118 1024*768*16m
;11b 1280 1024 24
;你会发现这里送入bx的是0x4111而不是0x111，这是为什么呢？这主要是因为，
;我们要使用线性地址模式，也就是说通过直接访问物理内存空存来访问所有的显存空间，
;因此，这时的送入bx的就应当是0x4000|模式号，
;对于此处就是：0x4000 | 0x111 = 0x4111（将模式号与0x4000进行与操作，这也是VBE标所规定的）
;must first set video mode,than get the video info



;param:x,y
__getPosition proc
push ebp
mov ebp,esp

push ecx
push edx
push ebx
sub esp,40h

mov ebx,KernelData
shl ebx,4

mov ecx,ds:[ebx + _bytesPerLine]
mov eax,ss:[ebp + 12]
mul ecx

push eax

mov ecx,ds:[ebx + _bytesPerPixel]
mov eax,ss:[ebp+8]
mul ecx

pop ecx
add eax,ecx

add esp,40h
pop ebx
pop edx
pop ecx

mov esp,ebp
pop ebp
ret
__getPosition endp



;param:string,color,pos,backcolor
__graphPositonString  proc
push ebp
mov ebp,esp

push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

mov ebx,KernelData
shl ebx,4

mov edi,ss:[ebp + 16]
add edi,ds:[ebx + _videoBase]

mov esi,ss:[ebp + 8]
cld
_pgShowStr:
lodsb
cmp al,0
jz _pgraphStrEnd
cmp al,0ah
jz _pgraphShowNewLine
cmp al,0dh
jz _pgraphShowEnter 
jmp _pgraphShowChar

_pgraphShowNewLine:
mov eax,edi
sub eax,ds:[ebx + _videoBase]
mov edx,0
mov ecx,ds:[ebx + _graphFontLSize]
div ecx
;cmp edx,0
;jz _pnoIncrementLine
inc eax
;_pnoIncrementLine:
mul ecx
mov edi,eax
add edi,ds:[ebx + _videoBase]
jmp _pgShowStr

_pgraphShowEnter:
mov eax,edi
sub eax,ds:[ebx + _videoBase]
mov edx,0
mov ecx,ds:[ebx + _graphFontLSize]
div ecx
mul ecx
mov edi,eax
add edi,ds:[ebx + _videoBase]
jmp _pgShowStr

_pgraphShowChar:
push edi
push esi
movzx esi,al
shl esi,3
add esi,ds:[ebx + _graphCharBase]

mov ecx,BIOS_GRAPHCHAR_WIDTH
_pgShowCharLines:
push edi
push ecx
lodsb
mov dl,al
mov dh,128
_pbyte2Line:
test dl,dh
jz _ppixelEmpty
mov eax,ss:[ebp + 12]
mov ecx,ds:[ebx + _bytesPerPixel]
_pgcopyColorBytes:
stosb
shr eax,8
loop _pgcopyColorBytes
jmp _pgraphNextPixel
_ppixelEmpty:
mov eax,ss:[ebp + 20]
mov ecx,ds:[ebx + _bytesPerPixel]
_pgcopyBackColorBytes:
stosb
shr eax,8
loop _pgcopyBackColorBytes
_pgraphNextPixel:
shr dh,1
jnz _pbyte2Line
pop ecx
pop edi
add edi,dword ptr ds:[ebx + _bytesPerLine]
loop _pgShowCharLines		;loop first judge ecx==0,if ecx != 0,goto label,else drop condition

pop esi
pop edi
add edi,ds:[ebx + _bytesXPerChar]
mov eax,edi
sub eax,ds:[ebx + _videoBase]
mov edx,0
mov ecx,ds:[ebx + _bytesPerLine]
div ecx
cmp edx,0
jnz _pgShowStr
sub edi,ds:[ebx + _bytesPerLine]
add edi,ds:[ebx + _graphFontLSize]
mov eax,edi
sub eax,ds:[ebx + _videoBase]
cmp eax,ds:[ebx + _graphwindowLimit]
jb _pgShowStr
mov edi,ds:[ebx + _videoBase]
jmp _pgShowStr

_pgraphStrEnd:
mov eax,esi
sub eax,ss:[ebp + 8]

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__graphPositonString endp



;caution the usage of loop instruction
;because you run once before loop,than if ecx ==8,
;although run 7 times then ecx == 1 will break the circle
;but you run once at first times
;so the total run times is 8
;loop will run ecx -1 times,not ecx times(8 7 6 5 4 3 2 1)


;ebp + 12 color
;ebp + 8 string position
;ebp + 4 ret address
;ebp old ebp
;ebp - 4 ecx
;ebp - 8 edx
;ebp - 12 ebx
;ebp - 16 esi
;ebp - 20 edi
;ebp - 24  _bytesPerLine
;ebp - 28  _bytesPerPixel
;ebp - 32  _graphShowX
;ebp - 36  _graphShowY
;ebp - 40  _graphwindowLimit
;ebp - 44  _graphFontLSize
;ebp - 48  _videoBase

;param:string,color
__vesaGraphStr  proc
push ebp
mov ebp,esp

push ecx
push edx
push ebx
push esi
push edi
sub esp,40h

mov ebx,KernelData
shl ebx,4

push ds:[ebx + _graphShowY]
push ds:[ebx + _graphShowX]
call __getPosition
add esp,8
mov edi,eax
add edi,ds:[ebx + _videoBase]

mov esi,ss:[ebp + 8]
cld
_gShowStr:
lodsb
cmp al,0
jz _graphShowStrEnd
cmp al,0ah
jz _graphShowNewLine
cmp al,0dh
jz _graphShowEnter 
jmp _graphShowChar

_graphShowNewLine:
mov eax,edi
sub eax,ds:[ebx + _videoBase]
mov edx,0
mov ecx,ds:[ebx + _graphFontLSize]
div ecx
;cmp edx,0
;jz _noIncrementLine
inc eax
;_noIncrementLine:
mul ecx
mov edi,eax
add edi,ds:[ebx + _videoBase]
jmp _gShowStr

_graphShowEnter:
mov eax,edi
sub eax,ds:[ebx + _videoBase]
mov edx,0
mov ecx,ds:[ebx + _graphFontLSize]
div ecx
mul ecx
mov edi,eax
add edi,ds:[ebx + _videoBase]
jmp _gShowStr

_graphShowChar:
push edi
push esi
movzx esi,al
shl esi,3
add esi,ds:[ebx + _graphCharBase]

mov ecx,BIOS_GRAPHCHAR_WIDTH
_gShowCharLines:
push edi
push ecx
lodsb
mov dl,al
mov dh,128
_gbyte2Line:
test dl,dh
jz _gpixelEmpty
mov eax,ss:[ebp + 12]
mov ecx,ds:[ebx + _bytesPerPixel]
_gcopyColorBytes:
stosb
shr eax,8
loop _gcopyColorBytes
jmp _graphNextPixel
_gpixelEmpty:
mov eax,ds:[ebx + _backGroundColor]
mov ecx,ds:[ebx + _bytesPerPixel]
_gcopyBackColorBytes:
stosb
shr eax,8
loop _gcopyBackColorBytes
_graphNextPixel:
shr dh,1
jnz _gbyte2Line
pop ecx
pop edi
add edi,dword ptr ds:[ebx + _bytesPerLine]
loop _gShowCharLines		;loop first judge ecx==0,if ecx != 0,goto label,else drop condition

pop esi
pop edi
add edi,ds:[ebx + _bytesXPerChar]
mov eax,edi
sub eax,ds:[ebx + _videoBase]
mov edx,0
mov ecx,ds:[ebx + _bytesPerLine]
div ecx
cmp edx,0
jnz _gShowStr
sub edi,ds:[ebx + _bytesPerLine]
add edi,ds:[ebx + _graphFontLSize]
mov eax,edi
sub eax,ds:[ebx + _videoBase]
cmp eax,ds:[ebx + _videoFrameTotal]
jb _gShowStr
mov edi,ds:[ebx + _videoBase]
jmp _gShowStr

_graphShowStrEnd:
sub edi,ds:[ebx + _videoBase]
mov eax,edi
mov edx,0
mov ecx,ds:[ebx + _bytesPerLine]
div ecx
mov ds:[ebx + _graphShowY],eax

mov eax,edx
mov edx,0
mov ecx,ds:[ebx + _bytesPerPixel]
div ecx
mov ds:[ebx + _graphShowX],eax

mov eax,esi
sub eax,ss:[ebp + 8]

add esp,40h
pop edi
pop esi
pop ebx
pop edx
pop ecx
mov esp,ebp
pop ebp
ret
__vesaGraphStr endp



;param:string,color,pos
__textModePositionShow32 proc
	push ebp
	mov ebp,esp

	PUSH ECX
	push edx
	push ebx
	push esi
	push edi
	sub esp,40h
	
	mov ebx,KernelData
	shl ebx,4
	
	mov esi,dword ptr ss:[ebp+8]
	mov edi,dword ptr ss:[ebp + 16]

	cld
	_ppmTextShowChar:
	lodsb
	cmp al,0
	jz _ppmTextShowOver
	
	cmp al,0ah
	jz ppmTextShowNewLine
	cmp al,0dh
	jz _ppmTextShowEnter
	jmp _ppmToShowChar
	
	ppmTextShowNewLine:
	mov eax,edi
	sub eax,VIDEOMODE_TEXT_DATABASE
	mov edx,0
	mov ecx,VIDEOMODE_TEXT_BYTESPERLINE
	div ecx
	cmp edx,0
	jz _ppmTextShowNewLine
	inc eax
	_ppmTextShowNewLine:
	mul ecx
	mov edi,eax
	add edi,VIDEOMODE_TEXT_DATABASE
	jmp _ppmTextShowChar
	
	_ppmTextShowEnter:
	mov eax,edi
	sub eax,VIDEOMODE_TEXT_DATABASE
	mov edx,0
	mov ecx,VIDEOMODE_TEXT_BYTESPERLINE
	div ecx
	mul ecx
	mov edi,eax
	add edi,VIDEOMODE_TEXT_DATABASE
	jmp _ppmTextShowChar
	
	_ppmToShowChar:
	mov edx,edi
	sub edx,VIDEOMODE_TEXT_DATABASE
	cmp edx,VIDEOMODE_TEXT_MAX_OFFSET
	jb _ppmOutputChar
	
	mov edi,VIDEOMODE_TEXT_DATABASE
	
	_ppmOutputChar:
	mov ah,byte ptr ss:[ebp + 12]
	stosw
	jmp _ppmTextShowChar
	
	_ppmTextShowOver:
	mov eax,esi
	sub eax,dword ptr ss:[ebp + 8]
	
	add esp,40h
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx

	mov esp,ebp
	pop ebp
	ret
__textModePositionShow32 endp




;param:string,color
__textModeShow32 proc
	push ebp
	mov ebp,esp

	PUSH ECX
	push edx
	push ebx
	push esi
	push edi
	sub esp,40h
	
	mov ebx,KernelData
	shl ebx,4
	add ebx,offset _textShowPos
	
	mov esi,dword ptr ss:[ebp+8]
	mov edi, VIDEOMODE_TEXT_DATABASE
	MOVZX EAX,word ptr ds:[ebx]
	add edi,EAX

	cld
	_pmTextShowChar:
	lodsb
	cmp al,0
	jz _pmTextShowOver
	
	cmp al,0ah
	jz pmTextShowNewLine
	cmp al,0dh
	jz _pmTextShowEnter
	jmp _pmToShowChar
	
	pmTextShowNewLine:
	mov eax,edi
	sub eax,VIDEOMODE_TEXT_DATABASE
	mov edx,0
	mov ecx,VIDEOMODE_TEXT_BYTESPERLINE
	div ecx
	cmp edx,0
	jz _pmTextShowNewLine
	inc eax
	_pmTextShowNewLine:
	mul ecx
	mov edi,eax
	add edi,VIDEOMODE_TEXT_DATABASE
	jmp _pmTextShowChar
	
	_pmTextShowEnter:
	mov eax,edi
	sub eax,VIDEOMODE_TEXT_DATABASE
	mov edx,0
	mov ecx,VIDEOMODE_TEXT_BYTESPERLINE
	div ecx
	mul ecx
	mov edi,eax
	add edi,VIDEOMODE_TEXT_DATABASE
	jmp _pmTextShowChar
	
	_pmToShowChar:
	mov edx,edi
	sub edx,VIDEOMODE_TEXT_DATABASE
	cmp edx,VIDEOMODE_TEXT_MAX_OFFSET
	jb _pmOutputChar
	
	mov edi,VIDEOMODE_TEXT_DATABASE
	
	_pmOutputChar:
	mov ah,byte ptr ss:[ebp + 12]
	stosw
	jmp _pmTextShowChar
	
	_pmTextShowOver:
	sub edi,VIDEOMODE_TEXT_DATABASE
	mov word ptr ds:[ebx],di
	
	mov eax,esi
	sub eax,dword ptr ss:[ebp + 8]
	
	add esp,40h
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx

	mov esp,ebp
	pop ebp
	ret
__textModeShow32 endp



;point postion,width,height,color
__setRegionColor proc
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
	
	mov edi,ss:[ebp + 8]
	add edi,ds:[ebx + _videoBase]
	
	mov ecx,ss:[ebp + 16]
	_setRegionbkGround:
	push ecx
	push edi

	mov ecx,ss:[ebp + 12]
	_setRegionbkGroundLine:
	push ecx
	mov ecx,ds:[ebx + _bytesPerPixel]
	mov eax,ss:[ebp + 20]
	_setRegionbkGroundPixel:
	stosb
	shr eax,8
	loop _setRegionbkGroundPixel
	pop ecx
	loop _setRegionbkGroundLine
	
	pop edi
	add edi,dword ptr ds:[ebx + _bytesPerLine]
	pop ecx
	loop _setRegionbkGround
	
	add esp,40h
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	
	mov esp,ebp
	pop ebx
	ret
__setRegionColor endp



__setDesktopBackground proc
	push ebx
	
	mov ebx,kernelData
	shl ebx,4
	
	push dword ptr ds:[ebx + _backGroundColor]
	push dword ptr ds:[ebx + _videoHeight]
	push dword ptr ds:[ebx + _videoWidth]
	push dword ptr 0
	
	call __setRegionColor
	add esp,16

	pop ebx
	ret
__setDesktopBackground endp




__setTaskbarColor proc
	push ecx
	push edx
	push ebx
	
	mov ebx,kernelData
	shl ebx,4
	
	push dword ptr ds:[ebx + _taskBarColor]
	
	push dword ptr GRAPH_TASK_HEIGHT
	
	push dword ptr ds:[ebx + _videoWidth]
	
	push dword ptr ds:[ebx + _graphWindowLimit]
	
	call __setRegionColor
	add esp,16

	pop ebx
	pop edx
	pop ecx
	ret
__setTaskbarColor endp


comment *
__setTimerBackground proc
	push ecx
	push edx
	push ebx
	
	mov ebx,kernelData
	shl ebx,4
	
	push dword ptr ds:[ebx + _timerZoneColor]
	
	push dword ptr BIOS_GRAPHCHAR_HEIGHT
	
	mov eax,BIOS_GRAPHCHAR_WIDTH
	mov ecx,CMOS_TIMER_ZONE_CHARS
	mul ecx
	push eax
	
	mov eax,ds:[ebx + _videoFrameTotal]
	sub eax,ds:[ebx + _graphFontLSize]
	push eax
	
	call __setRegionColor
	add esp,16

	pop ebx
	pop edx
	pop ecx
	ret
__setTimerBackground endp
*


;param x,y,radius,COLOR,EDGE COLOR
__drawCircle0 proc
	push ecx
	push edx
	push ebx
	push esi
	push edi
	
	mov ebx,kernelData
	shl ebx,4

	push ss:[ebp + 8]		;x
	push ss:[ebp + 12]		;y
	call __getPosition
	add esp,8
	mov edi,eax
	add edi,ds:[ebx + _videoBase]
	
	mov eax,ss:[ebp + 16]	;radius
	shl eax,1
	mov ss:[ebp - 24],eax	;diameter
	
	mov eax,ss:[ebp + 16]	;radius
	mov ecx,ss:[ebp + 16]	;radius
	mul ecx
	mov dword ptr ss:[ebp - 28],eax 	;radius * radius
	
	mov dword ptr ss:[ebp - 32],0	;delta x
	mov dword ptr ss:[ebp - 36],0	;delta y
	
	
	mov eax,ss:[ebp + 8]
	add eax,ss:[ebp + 16]
	mov ss:[ebp + 40],eax
	
	mov eax,ss:[ebp + 12]
	add eax,ss:[ebp + 16]
	mov ss:[ebp + 44],eax
	
	
	mov ecx,ss:[ebp - 24]		;diameter
	_drawCircle:
	push ecx
	push edi
	mov ecx,ss:[ebp -24]		;diameter
	mov dword ptr ss:[ebp - 32],0	;delta x
	
	_drawCircleLine:
	push ecx
	
	mov eax,ss:[ebp + 16]
	sub eax,ss:[ebp - 32]
	mov ecx,eax
	mul ecx
	push eax
	
	mov eax,ss:[ebp + 16]
	sub eax,ss:[ebp - 36]
	mov ecx,eax
	mul ecx 
	pop ecx
	add eax,ecx
	cmp eax,ss:[ebp - 28]
	jb _incircleDot
	jz _circleEdgeDot
	jmp _notCircleDot
	
	_incircleDot:
	mov eax,SS:[EBP + 20]
	;mov eax,ds:[ebx + _mouseColor]
	mov ecx,ds:[ebx + _bytesPerPixel]
	jmp _drawCircleDot
	_circleEdgeDot:
	mov eax,SS:[EBP + 24]
	;mov eax,ds:[ebx + _mouseBorderColor]
	mov ecx,ds:[ebx + _bytesPerPixel]
	_drawCircleDot:
	stosb
	shr eax,8
	loop _drawCircleDot
	sub edi,ds:[ebx + _bytesPerPixel]
	
	_notCircleDot:
	add edi,ds:[ebx + _bytesPerPixel]
	inc dword ptr ss:[ebp - 32]		;delta x
	pop ecx
	loop _drawCircleLine
	
	inc dword ptr ss:[ebp - 36]		;delta y
	pop edi
	add edi,ds:[ebx + _bytesPerLine]
	pop ecx
	loop _drawCircle
	
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	ret
__drawCircle0 endp



;param:string
__showErrInfo proc
push ebp
mov ebp,esp

push ebx

mov ebx,KernelData
shl ebx,4

cmp word ptr ds:[ebx + _videoMode],VIDEO_MODE_3
jz __showErrInfoText
push dword ptr VIDEOMODE_FONTCOLOR_ERR
push dword ptr ss:[ebp + 8]
call __vesaGraphStr
add esp,8
jmp __showErrInfoEnd

__showErrInfoText:
push dword ptr TEXTMODE_FONTCOLOR_ERR
push dword ptr ss:[ebp + 8]
call __textModeShow32
add esp,8

__showErrInfoEnd:
pop ebx

mov esp,ebp
pop ebp
ret
__showErrInfo endp


Kernel ends
