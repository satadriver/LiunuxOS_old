.686p
;多个函数汇编的方法
;1 导出far方法
;(1 子程序文件sub.asm中，将需要导出的函数用public声明：public mytestfun
;(2 主程序文件main.asm开头声明 mytestfun proto:far，或者 EXTRN mytestfun:far,并且只能用far，不可以用near
;如果坚持想要near调用,sub.asm 中的代码段和sub.asm中的代码段名字必须一致，如都定义为:code segment public para use32，注意用public修饰
;(3 link 选项添加连接选项，如link main.obj sub.obj

;编译后的exe的排列顺序由include顺寻决定
include kdata.asm
;include tsstest.asm

include kernel32.asm
include kvideo16.asm
include kdevice16.asm
include kintr16.asm
;include mymacro.asm
include int13h.asm
include v86.asm
include kcall.asm

KERNEL_BASE_SEGMENT EQU 1000H

;cpu进入32位后必须执行32位代码,16位实模式或者保护模式必须执行16位代码?
KERNEL16 SEGMENT para public use16
assume cs:KERNEL16,ss:KERNELdata
start:

_kernel16Entry proc
cli

mov eax,0
mov ecx,0
mov edx,0
mov ebx,0
mov esi,0
mov edi,0
mov esp,BIT16_STACK_TOP
mov ebp,esp

mov ax,KERNELData
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax

;ss如果被设置为KERNELData,esp设置为0xfff0可能导致溢出
mov ax,KERNEL_BASE_SEGMENT
mov ss,ax

mov eax,ss
shl eax,16
mov ax,sp
mov dword ptr ds:[_realModeStack],eax

push word ptr 0ch
push offset _kernel16Start
push cs
call __textModeShow16
add esp,6

push word ptr MEMORYINFO_LOAD_OFFSET
push word ptr MEMORYINFO_LOAD_SEG
call __getMemoryMap
add esp,4

call __loadAllFiles

call __initVideo

call __initDevices

call __initGDT

call __initIDT

push ds
mov eax,kernel
mov ds,ax
shl eax,4
add eax,offset __kernel32Entry
mov dword ptr ds:[__kernel32EntryOffset],eax
;mov eax,Kernel
;shl eax,4
;add eax,offset _int13RetPm32
;mov dword ptr ds:[__int13RetPm32EIP],eax
pop ds

;开机后cr0默认为10h et=1 浮点处理器存在,且bit4不可写
;进入保护模式之前必须使cr4为0
mov eax,0
;mov cr4,eax
db 0fh,22h,0e0h

;enable a20 line
;in al,0eeh

mov eax,cr0
or al,1
mov cr0,eax

;跳过16位保护模式,直接进入32位保护模式
;32位标识的段内偏移值：((kernel<<4) + __kernel32Entry)必然大于0x10000,因为kernel16本身加载地址在0x10000,
;16位跳转32位的时候段间跳转偏移用2个字节表示而不是4字节，这时2字节的长度会溢出无法正确表示32偏移，因此添加了32位段内跳转
_pmTmp32Entry 			db 0eah
_pmTmp32EntryOffset		dw __tmp32Entry
_pmTmp32EntrySelector	dw reCode32TempSeg

;从32位保护模式返回到16位实模式的过程中,必须进入16位保护模式,使得影子寄存器的段寄存长度界限等字段符合16位的要求
_pmCode16Entry:
cli
mov ax,rwData16Seg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov esp,BIT16_STACK_TOP
mov ebp,esp

mov eax,0
;mov cr4,eax
db 0fh,22h,0e0h

mov eax,cr0
and eax,0fffffffeh
mov cr0,eax

db 0eah
dw offset _realModeEntry
dw Kernel16

_realModeEntry:
mov ax,kerneldata
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ax,KERNEL_BASE_SEGMENT
mov ss,ax

mov esp,BIT16_STACK_TOP
mov ebp,esp

lss sp, DWORD PTR ds:[_realModeStack]

call __disableA20

call __loadRmIdt

CALL __restoreDos8259

mov ax,4f02h
mov bx,3
int 10h

sti

mov ah,4ch
int 21h
_kernel16Entry endp



__initGdt proc
push bp
mov bp,sp
push cx
push dx
push bx
push si
push di
push ds
push es

sub sp,40h

mov ax,kerneldata
mov ds,ax
mov es,ax

mov eax,LDT_BASE
mov word ptr ds:[ldtDescriptor+2],ax
shr eax,16
mov byte ptr ds:[ldtDescriptor +4],al
mov byte ptr ds:[ldtDescriptor +7],ah
mov word ptr ds:[ldtDescriptor],0ffffh

mov eax,Kernel
shl eax,4
add eax,offset __callGateEntry
mov word ptr ds:[callGateDescriptor],ax
shr eax,16
mov word ptr ds:[callGateDescriptor +6],ax
mov ax,reCode32Seg
mov word ptr ds:[callGateDescriptor + 2],ax


mov eax,Kernel16
shl eax,4
mov word ptr ds:[reCode16Descriptor+2],ax
shr eax,16
mov byte ptr ds:[reCode16Descriptor +4],al

mov eax,KernelData
shl eax,4
mov word ptr ds:[rwData16Descriptor+2],ax
shr eax,16
mov byte ptr ds:[rwData16Descriptor +4],al

mov eax,Kernel
shl eax,4
mov word ptr ds:[reCode32TempDescriptor+2],ax
shr eax,16
mov byte ptr ds:[reCode32TempDescriptor +4],al

mov eax,KernelData
shl eax,4
add eax,offset gdtNullDescriptor
;gdtr low 2 bytes is limit,hight 4 bytes is base address
mov dword ptr ds:[gdtReg + 2],eax
mov word ptr ds:[gdtReg ],gdtLimit

sgdt fword ptr ds:[_rmGdtReg]

lgdt fword ptr ds:[gdtReg]

add sp,40h
pop es
pop ds
pop di
pop si
pop bx
pop dx
pop cx
mov sp,bp
pop bp
ret
__initGdt endp



;param:secno,seccnt,seg,off
;ebp + 14 off
;ebp + 12 seg
;ebp + 10 seccnt
;ebp + 6 secno
;ebp + 4 ret
;ebp old ebp
__sectorReader proc
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
	
	mov byte ptr ss:[esp],10h
	
	mov byte ptr ss:[esp + 1],0
	
	mov ax, word ptr ss:[ebp + 10]
	mov word ptr ss:[esp + 2],ax
	
	movzx eax,word ptr ss:[ebp + 12]
	shl eax,16
	mov ax,word ptr ss:[ebp + 14]
	mov ss:[esp + 4],eax
	
	mov eax, dword ptr ss:[ebp + 6]
	mov dword ptr ss:[esp + 8],eax
	
	mov dword ptr ss:[esp + 12] ,0
	
	mov ax,ss
	mov ds,ax
	mov esi,esp
	mov ax,4200h
	mov dx,80h
	int 13h
	cmp ah,0
	jnz _readSectorErr
	mov ax,ss:[ebp + 10]
	jmp _readSectorEnd

	_readSectorErr:
	mov ax,0
	_readSectorEnd:
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
__sectorReader endp



__loadAllFiles proc
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
	
mov ax,kerneldata
mov ds,ax
;dll和字体扇区信息在data头部，直接读取就行了，mbr恢复后找不到写入扇区信息
mov esi,offset _kernelSectorInfo

mov ebx,VSKDLL_LOAD_SEG
mov edi,ds:[esi + DATALOADERSECTOR._kdllSecOff]
movzx ecx,ds:[esi + DATALOADERSECTOR._kdllSecCnt]
shr ecx,7
cmp ecx,0
jz _readVsDllModSectors

_readVsDllBlockSectors:
push ecx
push word ptr VSKDLL_LOAD_OFFSET
push bx
push word ptr 80h
push edi
call __sectorReader
add esp,10
add ebx,1000h
add edi,80h
pop ecx
loop _readVsDllBlockSectors

_readVsDllModSectors:
movzx ecx,ds:[esi + DATALOADERSECTOR._kdllSecCnt]
and ecx,7fh
CMP ECX,0
JZ _readVsDllMain
push word ptr VSKDLL_LOAD_OFFSET
push bx
push cx
push edi
call __sectorReader
add esp,10



_readVsDllMain:
mov ebx,VSMAINDLL_LOAD_SEG
mov edi,ds:[esi + DATALOADERSECTOR._maindllSecOff]
movzx ecx,ds:[esi + DATALOADERSECTOR._maindllSecCnt]
shr ecx,7
cmp ecx,0
jz _readVsDllMainModSectors

_readVsMainDllBlockSectors:
push ecx
push word ptr VSMAINDLL_LOAD_OFFSET
push bx
push word ptr 80h
push edi
call __sectorReader
add esp,10
add bx,1000h
add edi,80h
pop ecx
loop _readVsMainDllBlockSectors

_readVsDllMainModSectors:
movzx ecx,ds:[esi + DATALOADERSECTOR._maindllSecCnt]
and ecx,7fh
CMP ECX,0
JZ _readVsDllFont
push word ptr VSMAINDLL_LOAD_OFFSET
push bx
push cx
push edi
call __sectorReader
add esp,10




_readVsDllFont:
push word ptr GRAPHFONT_LOAD_OFFSET
push word ptr GRAPHFONT_LOAD_SEG
push word ptr ds:[esi + DATALOADERSECTOR._fontSecCnt]
push dword ptr ds:[esi + DATALOADERSECTOR._fontSecOff]
call __sectorReader
add esp,10

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
__loadAllFiles endp




_kernel16Start db 'kernel start',0



KERNEL16 ends

end start