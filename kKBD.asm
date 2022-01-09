.386p

;对于驱动来说，和键盘相关的最重要的硬件是两个芯片。
;一个是 intel 8042 芯片，位于主板上，CPU 通过 IO 端口直接和这个芯片通信，获得按键的扫描码或者发送各种键盘命令。
;另一个是 intel 8048 芯片或者其兼容芯片，位于键盘中，这个芯片主要作用是从键盘的硬件中得到被按的键所产生的扫描码 与 i8042 通信控制键盘本身


;最简单是用xlat指令
;将ds:[BX]为首地址的,偏移地址为AL的内容送给AL

Kernel Segment public para use32
assume cs:Kernel

align 10h
__kKeyBoardProc proc
pushad
push ds
push es
push fs
push gs
push ss

mov ax,rwData32Seg
mov ds,ax
mov es,ax

mov ebx,KernelData
shl ebx,4
cmp dword ptr ds:[ebx + offset _kKbdProc],0
jz _kkbdProcEnd
call dword ptr ds:[ebx + offset _kKbdProc]
jmp _kkbdProcEnd

in al,60h
movzx eax,al
call near ptr _analyseScanCode

_kkbdProcEnd:
mov dword ptr ds:[CMOS_SECONDS_TOTAL],0
mov eax,TURNONSCREEN
int 80h

;mov ebp,esp
;add ebp,32
;push dword ptr ICW2_MASTER_INT_NO + 1
;push dword ptr eax
;push dword ptr [ebp]
;push dword ptr [ebp + 4]
;push dword ptr [ebp + 8]
;call  __exceptionInfo
;add esp,20
;add ebp,32

mov al,20h
out 20h,al

pop ss
pop gs
pop fs
pop es
pop ds
popad
iretd
__kKeyBoardProc endp



_analyseScanCode proc near
mov ebx,KEYBOARD_BUFFER

cmp al,1dh		;1dh=Ctrl down
jz _ctrlLeftKey
cmp al,9dh		;9dh=Ctrl up
jz _ctrlLeftKey

cmp al,2ah		;2ah=Shift Left down
jz _shiftLeftKey
cmp al,0aah		;0aah=Shift Left up
jz _shiftLeftKey

cmp al,36h		;36h=Shift Right down
jz _shiftRightKey
cmp al,0b6h		;0b6h=Shift Right up
jz _shiftRightKey

cmp al,38h		;38h=left Alt down
jz _altLeftKey
cmp al,0b8h		;0b8h=left Alt up
jz _altLeftKey

;capsLock scrollLock numsLock could only use once,not both
cmp al,3ah		;3ah=CapsLock down
jz _CapsLock                       
;cmp al,0bah		;bah=CapsLock up
;jz _CapsLock

cmp al,46h		;46h=ScrollLock down
jz _ScrollLock
;cmp al,0c6h		;c6h=ScrollLock up
;jz _ScrollLock

cmp al,53h
jz _deleteKey

cmp al,45h		;45h=NumsLock down
jz _NumsLock 
;cmp al,0c5h		;c5h=NumsLock up
;jz _NumsLock 

cmp al,0e0h
jz _multiKeye0

cmp al,0e1h
jz _multiKeye1

cmp al,0e2h
jz _multiKeye2

cmp al,37h		;small kbd *
jz _codeSmallKbd
cmp al,47h
jb _filterUpKey
cmp al,53h
ja _filterUpKey
jmp _codeSmallKbd	;from 47h to 53h is small kbd vlaue

_filterUpKey:
test al,080h
jnz _parseKeyEnd

_saveKbdKey:
mov esi,ds:[ebx + KEYBOARDDATA._KbdBufHdr]
shl esi,2
mov dword ptr ds:[ebx + KEYBOARDDATA._kbdBuf + esi],eax
mov edx,dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus]
mov dword ptr ds:[ebx + KEYBOARDDATA._kbdStatusBuf + esi],edx

add dword ptr ds:[ebx + KEYBOARDDATA._kbdBufHdr],1

cmp dword ptr ds:[ebx + KEYBOARDDATA._kbdBufHdr],KEYBORAD_BUF_LIMIT
jb _parseKeyEnd
mov dword ptr ds:[ebx + KEYBOARDDATA._kbdBufHdr],0

_parseKeyEnd:
ret



_deleteKey:
test dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],CTRLLEFT_SET_FLAG
jz _saveKbdKey
test dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],ALTLEFT_SET_FLAG 
jz _saveKbdKey
call __resetSystem
jmp _parseKeyEnd


_shiftLeftKey:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],SHIFTLEFT_SET_FLAG
jmp _parseKeyEnd

_shiftRightKey:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],SHIFTRIGHT_SET_FLAG
jmp _parseKeyEnd

_ctrlLeftKey:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],CTRLLEFT_SET_FLAG
jmp _parseKeyEnd

_ctrlRightKey:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],CTRLRIGHT_SET_FLAG
jmp _parseKeyEnd

_altLeftKey:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],ALTLEFT_SET_FLAG
jmp _parseKeyEnd

_altRightKey:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],ALTRIGHT_SET_FLAG
jmp _parseKeyEnd

_ScrollLock:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],SCROLLLOCK_SET_FLAG

xor byte ptr ds:[ebx + KEYBOARDDATA._KbdLedStatus],1
mov al,byte ptr ds:[ebx + KEYBOARDDATA._KbdLedStatus]
call __setKbdLed
jmp _parseKeyEnd

_NumsLock:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],NUMSLOCK_SET_FLAG

xor byte ptr ds:[ebx + KEYBOARDDATA._KbdLedStatus],2
mov al,byte ptr ds:[ebx + KEYBOARDDATA._KbdLedStatus]
call __setKbdLed
jmp _parseKeyEnd

_CapsLock:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],CAPSLOCK_SET_FLAG

xor byte ptr ds:[ebx + KEYBOARDDATA._KbdLedStatus],4
mov al,byte ptr ds:[ebx + KEYBOARDDATA._KbdLedStatus]
call __setKbdLed
jmp _parseKeyEnd

_insertKey:
xor dword ptr ds:[ebx + KEYBOARDDATA._KbdStatus],INSERT_SET_FLAT
jmp _parseKeyEnd

_codeSmallKbd:
test dword ptr ds:[ebx + KEYBOARDDATA._kbdStatus],NUMSLOCK_SET_FLAG
jz _parseKeyEnd
;53h=small kbd Delete key down
;d3h=small kbd Delete key up
;cmp al,0d2h
;jz _insertKey	;;d2h=small kbd insert key up	
cmp al,52h		;52h=small kbd insert key down	
jz _insertKey
test al,080h
jnz _parseKeyEnd
jmp _saveKbdKey


_multiKeye0:
shl eax,8
in al,60h

cmp ax,0e053h
jz _deleteKey

CMP AX,0e01dh
jz _ctrlRightKey
CMP AX,0e09dh
jz _ctrlRightKey

cmp ax,0e038h
jz _altRightKey
cmp ax,0e0b8h
jz _altRightKey

CMP AX,0e05bh		;windows down
cmp ax,0e0dbh		;windows up

cmp ax,0e02ah
jnz _checkPrintScreen
shl eax,8
in al,60h
shl eax,8
in al,60h
cmp eax,0e02ae037h
jz _printScreen
jmp _parseKeyEnd

_checkPrintScreen:
cmp ax,0e0b7h
jnz _checkOtherMultiKeye0
shl eax,8
in al,60h
shl eax,8
in al,60h
cmp eax,0e0b7e0aah
;jz _printScreen		;printscreen break key,ignore it
jmp _parseKeyEnd

_checkOtherMultiKeye0:
cmp ax,0e052h		;insert down
jz _insertKey
;cmp ax,0e0d2h		;insert up
;jz _insertKey

cmp ax,0e01ch		;small kbd enter
jz _codeSmallKbd
;cmp ax,0e09ch		;small kbd enter
;jz _codeSmallKbd
cmp ax,0e035h		;small kbd /
jz _codeSmallKbd	
;cmp ax,0e0b5h		;small kbd /
;jz _codeSmallKbd	
test al,080h
jnz _parseKeyEnd
jmp _saveKbdKey


_multiKeye1:
shl eax,8
in al,60h
shl eax,8
in al,60h
;split pause/break e11d45e19dc5 into 2 keys
cmp eax,0e11d45h
jz _pauseBreak
cmp eax,0e19dc5h
jz _pauseBreak
test al,080h
jnz _parseKeyEnd
jmp _saveKbdKey


_multiKeye2:
shl eax,8
in al,60h
shl eax,8
in al,60h
shl eax,8
in al,60h
test al,080h
jnz _parseKeyEnd
jmp _saveKbdKey


_printScreen:
mov edi,KERNELData
shl edi,4
call dword ptr ds:[edi + _kPrintScreen]
jmp _parseKeyEnd


_pauseBreak:
call __shutdownSystem
jmp _parseKeyEnd

_analyseScanCode endp










__scancode2Ascii proc
mov ebx,KEYBOARD_BUFFER
mov esi,ds:[ebx + KEYBOARDDATA._KbdBufTail]
cmp esi,ds:[ebx + KEYBOARDDATA._kbdBufHdr]
jnz _kbdBufferFull
mov eax,0
ret

_kbdBufferFull:
shl esi,2
mov eax,ds:[ebx + KEYBOARDDATA._kbdBuf + esi]
mov edx,ds:[ebx + KEYBOARDDATA._kbdStatusBuf + esi]

;1 small keyboard
cmp eax,0e035h		;small kbd /
jz _smallKbdKey
cmp eax,0e01ch		;small kbd enter
jz _smallKbdKey
cmp eax,37h			;small kbd *
jz _smallKbdKey
cmp eax,47h
jb _checkPageKey
cmp eax,53h
ja _checkPageKey
jmp _smallKbdKey

;2 up down left right insert delete 
_checkPageKey:
cmp eax,0e047h
jb _checkFunctionKey
cmp eax,0e053h
ja _checkFunctionKey
jmp _pageKey

;3 f0-f12
_checkFunctionKey:
cmp eax,57h
jz _functionKey
cmp eax,58h
jz _functionKey
cmp eax,3bh
jb _notFunctionKey
cmp eax,44h
ja _notFunctionKey
jmp _functionKey

_notFunctionKey:

_tranlateKeyCode:
movzx ecx,al
mov edi,KERNELData
shl edi,4

test edx,SHIFTLEFT_SET_FLAG
jnz _shiftTranlate
test edx,SHIFTRIGHT_SET_FLAG
jnz _shiftTranlate


movzx eax,byte ptr ds:[edi + ScanCodesBuf + ecx]
jmp _checkCapsLock
_shiftTranlate:
movzx eax,byte ptr ds:[edi + ScanCodesTransBuf + ecx]

_checkCapsLock:
test edx,CAPSLOCK_SET_FLAG
jz _resetKbdTail

cmp al,'A'
jb _resetKbdTail
cmp al,'Z'
ja _checkLowercase
add al,20h
jmp _resetKbdTail

_checkLowercase:
cmp al,'a'
jb _resetKbdTail
cmp al,'z'
ja _resetKbdTail
sub al,20h

_resetKbdTail:
add dword ptr ds:[ebx + KEYBOARDDATA._kbdBufTail],1
cmp dword ptr ds:[ebx + KEYBOARDDATA._kbdBufTail],KEYBORAD_BUF_LIMIT
jb _transferEnd
mov dword ptr ds:[ebx + KEYBOARDDATA._kbdBufTail],0
_transferEnd:
ret


_smallKbdKey:
or al,80h
test edx,NUMSLOCK_SET_FLAG
jnz _tranlateKeyCode
jmp _resetKbdTail


_functionKey:
or al,80h
jmp _resetKbdTail

_pageKey:
;mov eax,0
or al,80h
jmp _resetKbdTail

__scancode2Ascii endp






Kernel ends




