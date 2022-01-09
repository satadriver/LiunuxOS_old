.386p


Kernel Segment public para use32
assume cs:Kernel

;页目录表必须位于一个自然页内(4KB对齐), 故其物理地址的低12位是全0
__initPageTable proc

push ecx
push edi

;mov eax,kernelData
;shl eax,2
;add eax,offset pageTableIndex
mov eax,PDE_ENTRY_VALUE
mov cr3,eax

;mov edi,eax
mov edi,PDE_ENTRY_VALUE
mov ecx,PAGE_INDEX_COUNT
MOV EAX,PTE_ENTRY_VALUE
OR eax,7
cld
_setPdeTable:
stosd
add eax,PAGE_SIZE
loop _setPdeTable

mov edi,PTE_ENTRY_VALUE
mov eax,7
mov ecx,100000h
_setPte:
stosd
add eax,PAGE_SIZE
loop _setPte

pop edi
pop ecx
ret
__initPageTable endp



__startPage proc
call __initPageTable

mov eax,cr0
or eax,80000000h
mov cr0,eax
jmp _flushPage

_flushPage:
ret
__startPage endp



Kernel ends



kernel16 segment public para use16

;[ebp + 4] es
;[ebp + 6] di
__getMemoryMap proc
push bp
mov bp,sp
push cx
push dx
push bx
push si
push di
push es
sub esp,10h

	mov ax,word ptr ss:[ebp + 4]
	mov es,ax
	mov di,word ptr ss:[ebp + 6]
	add di,4
    mov ebx, 0
	MOV DWORD PTR SS:[esp],0
    
__getMemoryInt15hSeg:
    mov    eax, 0e820h
	mov    ecx,20
    mov    edx, 0534D4150h
    int    15h
    jc     _INT15_MEM_CHK_FAIL
    add    di, 20
    inc    dword ptr ss:[esp]
    cmp    ebx, 0
    jne    __getMemoryInt15hSeg
    jmp    _INT15_MEM_CHK_OK
_INT15_MEM_CHK_FAIL:
    mov    dword ptr ss:[esp], 0
_INT15_MEM_CHK_OK:

mov eax,ss:[esp]
mov di,word ptr ss:[ebp + 6]
mov es:[di],eax

add esp,10h
pop es
pop di
pop si
pop bx
pop dx
pop cx
mov sp,bp
pop bp
ret
__getMemoryMap endp

kernel16 ends