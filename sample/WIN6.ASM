.386p


Param Segment para use16       
PspSeg			dw 0
DosIntMask		dw 0
DosIdtPtr		df 0
DosStackPtr		dd 0
PicElcr             	dw 0

MsgBoxStrPtr    	dd 0

MsgBoxButtonTxtYes	db 'Y E S',0
MsgBoxButtonTxtNo	db ' N O ',0
MsgPeFile       	db 'PE FILE IS NOT SUPPORTED!',0
MsgAdjustMouse		DB 'ADJUST YOUR MOUSE:',0AH,0DH
			DB 'NOW MOVE YOUR MOUSE......'
			DB 'IF IT DOES NOT WORK WELL,PRESS "ENTER" OR CLICK "YES"'
                        DB 'ELSE,PRESS ESC OR CLICK "NO"',0
MsgIdeBusy		db 'ERROR! READ DISK FAILURE.',0
MsgReadFileFailure	db 'ERROR! FAILED TO READ FILE:',0AH,0dh
			db '1. FILE NOT EXIST.',0AH,0DH
			DB '2. ENCOUNTER BAD SECTOR.',0AH,0DH
			DB '3. FILE DESTROYED.',0
MsgNotFat32		db 'ERROR! NOT FAT32 PARTITION.',0
MsgFileNameInvalid 	db 'ERROR! INVALID FILE NAME.',0

MsgCoprocessorError	db 'COPROCESSOR ERROR!',0

MsgDiskPartInfo         db 'DISK FDT LOCATION:',0ah,0dh
Disk0FdtAddr            db 24 dup (0,0,0,0,0,0,0,0,0ah,0dh)
		
MsgExceptionPrompt	db 'EXCEPTION ADDRESS:'
ExpSegment		dd 0
			db 3ah
ExpAddress		dq 0
			db 0ah,0dh,'EXCEPTION TYPE:'
ExpType			dd 0		
			db 0ah,0dh,'ERROR CODE:'
ExpErrCode		dd 0
			dd 0
AscMyComputer   	db 'MyComputer',0

MsgHdPortBase  		db 'ATAPI DEVICE DRIVER:'
AscHdPortBase		dd 0
                        db 0ah,0dh,'MASTER/SLAVE:'
AscHdSlaveFlag		dd 0

FileNamePtr		dd offset FileName		
BmpName			db 'win9.bmp',20 dup (0)		
FileName		db 260 dup (0)
FileSubDirBuf		db 10h dup (0)
FileSubDirLen		dd 0
FileSize		dd 0
FileCluSize		dd 0
FileCluPtr		dd 0
FileSecPtr		dd 0
FileCluStatus		dd 0
PartNumPtr		dd 0
DiskNumPtr	 	dd 0
ExtPartPtr		dd 0


MultiModeSecNum     	dd 0

SysTimerCount		dd 0

KbdBuf          	db 100h dup (0)
KbdBufHeadPtr   	dw offset KbdBuf
                	dw 0
KbdBufDetailPtr 	dw offset KbdBuf
                	dw 0
KbdStatus       	dd 0
ScanCode    		dd 0
KbdLedStatus   		dd 0
TransScanCodeNormal  	db 0,1bh,31h,32h,33h,34h,35h,36h,37h,38h,39h,30h,'-','=',8,9,'q'
                	db 'w','e','r','t','y','u','i','o','p','[',']',0dh,0,'a','s','d'
                	db 'f','g','h','j','k','l',';',"'",'`',0,'\','z','x','c','v','b'
                	db 'n','m', ',' , '.', '/', 0, 0, 0,' ',0,0,0,0,0,0,0
                	db 0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0
                	db 0,0,0
TransScanCodeShift   	db 0,1bh,'!@#$%^&*()_+',8,9,'Q'
                	db 'WERTYUIOP{}',0dh,0,'ASD'
                	db 'FGHJKL:"~',0,'|ZXCVB'
                	db 'NM<>?',0,0,0,' ',0,0,0,0,0,0,0
                	db 0,0,0,0,0,0,'789-456+1230.'

KbdPromptAlterFlag	dd 0
KbdMsgFlag      	dd 0

MouseStatus		dd 0
MouseDeltaX		dd 0
MouseDeltaY		dd 0
MouseDeltaZ		dd 0
MouseDeltaU		dd 0
MouseX			dd 320
MouseY			dd 240
MouseZ			dd 0
MouseU			dd 0
MousePos		dd 2560*240+1280
MousePacketSequence  	dd 0
MousePacketSize		dd 12
MouseColor		dd 2020c0h
MouseMsgFlag		dd 0


DeskTopAlterFlag	dd 0
FontColor		dd 0ff00h
VesaCharColor		dd 0ff0000h
RltClockColor		dd 00ffh
FontColorBackup 	dd 0
RltClockPos    		dd 2560*464+2240   ;caution here why is 464+2240?????
PromptPos       	dd 2560*456

HdPortBase	dw 0
BmHdPortBase	dw 0
HdSlaveFlag	db 0
SataFlag	db 0
HdPciPortBuf	dw 20h dup (0)
HdIntLinePin    dw 0

Disk0SecPerClu 	db 0
Disk0Reserved 	dw 0
Disk0FatNum	db 0
Disk0Hidden	dd 0
Disk0SecSum  	dd 0
Disk0FatSize	dd 0
Disk0FirstClu	dd 0
Disk0FsInfo	dw 0
Disk0Stock	dw 0
Disk0FatPtr	dd 0
Disk0FdtPtr	dd 0
	
NextDiskInfo	db 736 dup (0)

ParentDirPtr		dd 0
IconPagePtr     	dd 4096
FileDirInfoPtr		dd 8192
IconPageEndFlag 	dd 0
ParamBuf		db 400h dup (0)
ParamLenth		equ $-1
Param ends


Rom segment para use16
NullSelector		dq 0
NormalSeg		= $-NullSelector
NormalSelector		dq 000092000000ffffh
ParamSeg		= $-NullSelector
ParamSelector		dq 0040920000000000h
RomSeg			= $-NullSelector
RomSelector		dq 0040900000000000h
VgaSeg			= $-NullSelector
VgaSelector		dq 0040920a0000ffffh
TxtSeg			= $-NullSelector
TxtSelector		dq 0040920b80007fffh
VesaSeg			= $-NullSelector
VesaSelector		dq 00cf92000000ffffh
GraphCharSeg		= $-NullSelector
GraphCharSelector	dq 0040900ffa6e07ffh

HdDataSeg		=$-NullSelector
HdDataSelector		dq 00c092400000ffffh
DeskTopBackupSeg 	=$-NullSelector
DeskTopBackupSelector  	dq 10c0924000000bffh
Stack0Seg               =$-NullSelector
Stack0Selector   	dq 114f92000000ffffh
Stack1Seg               =$-NullSelector
Stack1Selector        	dq 114fb2100000ffffh
Stack2Seg               =$-NullSelector
Stack2Selector        	dq 114fd2200000ffffh
Stack3Seg               =$-NullSelector
Stack3Selector		dq 114ff2300000ffffh
BackingBufSeg		=$-NullSelector
BackingBufSelector	dq 114f92400000ffffh
HdBufSeg           	=$-NullSelector
HdBufSelector      	dq 114f92500000ffffh
PdeSeg                  =$-NullSelector
PdeSelector             dq 1140926000000fffh
PteSeg                  =$-NullSelector
PteSelector             dq 11c09270000003ffh

DeskTopFileSeg		=$-NullSelector
DeskTopFileSelector	dq 11c092a0000000ffh
PmCode16Seg		=$-NullSelector
PmCode16Selector	dq 00009a000000ffffh
PmCode32Seg		= $-NullSelector
PmCode32Selector	dq 0040980000000000h
PmIntSeg		= $-NullSelector
PmIntSelector	  	dq 0040980000000000h	
Tss0Seg                 =$-NullSelector
Tss0Selector            dq 0040890000000068h
Tss1Seg                 =$-NullSelector
Tss1Selector            dq 0040890000000068h
Tss2Seg                 =$-NullSelector
Tss2Selector            dq 0040890000000068h
Tss3Seg                 =$-NullSelector
Tss3Selector            dq 0040890000000068h
		
GdtLimit		dw $-1
GdtBase			dd 0
align 10h			
IdtLimit		dw 7ffh
IdtBase			dd 0
	
align 10h
ExpDivisionErrDesc		dq 00008f0000000000h
ExpDebugDesc			dq 00008f0000000000h
ExpNmiDesc			dq 00008f0000000000h
ExpBreakPointDesc		dq 00008f0000000000h
ExpOverFlowDesc			dq 00008f0000000000h
ExpBoundErrDesc			dq 00008f0000000000h
ExpUnlawfulOpcodeDesc		dq 00008f0000000000h
ExpNoneCoprocDesc		dq 00008f0000000000h
ExpDoubleFaultDesc		dq 00008f0000000000h
ExpCoprocBoundErrDesc		dq 00008f0000000000h
ExpInvalidTssDesc		dq 00008f0000000000h
ExpSegNonePresentDesc		dq 00008f0000000000h
ExpStackSegErrDesc		dq 00008f0000000000h
ExpGeneralProtectDesc		dq 00008f0000000000h
ExpPageFaultDesc		dq 00008f0000000000h
                                dq 00008f0000000000h
ExpFpuFaultDesc			dq 00008f0000000000h
ExpAlignmentCheckErrDesc	dq 00008f0000000000h
ExpMachineCheckErrDesc		dq 00008f0000000000h
ExpSimdFaultDesc		dq 00008f0000000000h
				dq 12 dup (00008f0000000000h)

SysTimerIntDesc		dq 00008e0000000000h
KbdIntDesc      	dq 00008e0000000000h
			dq 6 dup (00008e0000000000h)			
RltIntDesc		dq 00008e0000000000h
			dq 3 dup (00008e0000000000h)
MouseIntDesc   		dq 00008e0000000000h 
CoprocessorIntDesc	dq 00008e0000000000h              
HdPrimaryIntDesc	dq 00008e0000000000h
HdSecondaryIntDesc	dq 00008e0000000000h

			dq 50h dup (00008f0000000000h)

SysTimerIntCallDesc     dq 00008f0000000000h
KbdServiceDesc      	dq 00008f0000000000h
GraphServiceDesc        dq 00008f0000000000h
SunDryServiceDesc       dq 00008f0000000000h
			dq 00008f0000000000h			
			dq 3 dup (00008f0000000000h)
RltIntCallDesc          dq 00008f0000000000h
                        dq 3 dup (00008f0000000000h)
MouseServiceDesc    	dq 00008f0000000000h
CoprocServiceDesc    	dq 00008f0000000000h
HdServiceDesc           dq 00008f0000000000h
FileServiceDesc         dq 00008f0000000000h        
                     
			dq 112 dup (00008f0000000000h)

Tss0                    db 102 dup (0)
                        dw $+2
                        db 0ffh
Tss1                    db 102 dup (0)
                        dw $+2
                        db 0ffh                                   
Tss2                    db 102 dup (0)
                        dw $+2
                        db 0ffh
Tss3                    db 102 dup (0)
                        dw $+2
                        db 0ffh
RomLenth		equ $-1
Rom  Ends






MainProc Segment para use16
assume cs:MainProc
start:
call GetPspSegment
call SetDescriptor
call SetVesaMode
call GetDeskTopBmpPath

mov ax,Param
mov es,ax
mov ax,Rom
mov ds,ax
mov ax,ss
shl eax,16
mov ax,sp
mov es:[DosStackPtr],eax
in al,21h
mov ah,al
in al,0a1h
xchg ah,al
mov es:[DosIntMask],ax
cli
sidt fword ptr es:[DosIdtPtr]
lgdt fword ptr ds:[GdtLimit]
lidt fword ptr ds:[IdtLimit]
mov al,2
out 92h,al
mov eax,0
db 0fh,22h,0e0h
mov eax,cr0
or al,1
mov cr0,eax
                db 0eah
                dw 0
                dw PmCode16Seg
DosMode:
cli
mov ax,Param
mov ds,ax
mov es,ax
lidt fword ptr ds:[DosIdtPtr]
lss sp,dword ptr ds:[DosStackPtr]
mov ax,ds:[DosIntMask]
out 21h,al
mov al,ah
or al,11h
out 0a1h,al
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h


GetPspSegment proc near
mov ax,Param
mov ds,ax
push es
pop word ptr ds:[PspSeg]
ret
GetPspSegment endp



GetDeskTopBmpPath proc near
mov ax,Param
mov ds,ax
mov es,ax
cld
mov ah,19h
int 21h
inc al
push ax
mov dl,al
mov ah,47h
mov si,offset FileName
add si,3
int 21h
mov di,offset FileName
add di,3
mov cx,0ffh
CheckDeskTopBmpPathTerminal:
mov al,es:[di]
inc di
cmp al,0
jnz CheckDeskTopBmpPathTerminal
dec di
mov byte ptr es:[di],5ch
inc di
mov si,offset BmpName
mov cx,9
rep movsb
pop ax
add al,40h
mov di,offset FileName
stosb
mov ax,5c3ah
stosw
ret
GetDeskTopBmpPath endp





SetVesaMode proc near
mov ax,4f02h
mov bx,112h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
ret
SetVesaMode endp






SetDescriptor proc near
cld
xor eax,eax
mov ax,Rom
mov ds,ax
mov es,ax
shl eax,4
push eax
push eax
push eax
mov word ptr ds:[RomSelector+2],ax
shr eax,16
mov byte ptr ds:[RomSelector+4],al
mov byte ptr ds:[RomSelector+7],ah
mov word ptr ds:[RomSelector],RomLenth
pop eax
add eax,offset NullSelector
mov ds:[GdtBase],eax
pop eax
add eax,offset ExpDivisionErrDesc
mov dword ptr ds:[IdtBase],eax

pop eax
add eax,offset Tss0
mov bx,offset Tss0Selector
mov cx,4
SetTssDesc:
push eax
mov word ptr ds:[bx+2],ax
shr eax,16
mov byte ptr ds:[bx+4],al
mov byte ptr ds:[bx+7],ah
pop eax
add eax,105
add bx,8
loop SetTssDesc


mov di,offset ExpDivisionErrDesc
mov ax,PmIntSeg
shl eax,16
mov ax,offset PmExpDivisionErrProc
mov cx,32
SetDefaultDesc:
stosd
add di,4
loop SetDefaultDesc


mov di,offset SysTimerIntDesc
mov ax,PmIntSeg
shl eax,16
mov ax,offset PmIntRet
mov cx,224
SetTrapDesc:
stosd
add di,4
loop SetTrapDesc


mov ax,offset PmExpDivisionErrProc
mov word ptr ds:[ExpDivisionErrDesc],ax
mov ax,offset PmExpDebugProc
mov word ptr ds:[ExpDebugDesc],ax
mov ax,offset PmExpNmiProc
mov word ptr ds:[ExpNmiDesc],ax
mov ax,offset PmExpBreakPointProc
mov word ptr ds:[ExpBreakPointDesc],ax

mov ax,offset PmExpOverFlowProc
mov word ptr ds:[ExpOverFlowDesc],ax
mov ax,offset PmExpBoundErrProc
mov word ptr ds:[ExpBoundErrDesc],ax
mov ax,offset PmExpUnlawfulOpcodeProc
mov word ptr ds:[ExpUnlawfulOpcodeDesc],ax
mov ax,offset PmExpNoneCoprocProc
mov word ptr ds:[ExpNoneCoprocDesc],ax

mov ax,offset PmExpDoubleFaultProc
mov word ptr ds:[ExpDoubleFaultDesc],ax
mov ax,offset PmExpCoprocBoundErrProc
mov word ptr ds:[ExpCoprocBoundErrDesc],ax
mov ax,offset PmExpInvalidTssProc
mov word ptr ds:[ExpInvalidTssDesc],ax
mov ax,offset PmExpSegNonePresentProc
mov word ptr ds:[ExpSegNonePresentDesc],ax

mov ax,offset PmExpStackSegErrProc
mov word ptr ds:[ExpStackSegErrDesc],ax
mov ax,offset PmExpGeneralProctectProc
mov word ptr ds:[ExpGeneralProtectDesc],ax
mov ax,offset PmExpPageFaultProc
mov word ptr ds:[ExpPageFaultDesc],ax
mov ax,offset PmExpFpuFaultProc
mov word ptr ds:[ExpFpuFaultDesc],ax

mov ax,offset PmExpAlignmentCheckErrProc
mov word ptr ds:[ExpAlignmentCheckErrDesc],ax
mov ax,offset PmExpMachineCheckErrProc
mov word ptr ds:[ExpMachineCheckErrDesc],ax
mov ax,offset PmExpSimdFaultProc
mov word ptr ds:[ExpSimdFaultDesc],ax



mov ax,offset PmSysTimerIntProc
mov word ptr ds:[SysTimerIntDesc],ax
mov ax,offset PmKbdIntProc
mov word ptr ds:[KbdIntDesc],ax
mov ax,offset PmRltIntProc
mov word ptr ds:[RltIntDesc],ax
mov ax,offset PmMouseIntProc
mov word ptr ds:[MouseIntDesc],ax
mov ax,offset PmCoprocessorIntProc
mov word ptr ds:[CoprocessorIntDesc],ax
mov ax,offset PmKbdServiceProc
mov word ptr ds:[KbdServiceDesc],ax
mov ax,offset PmGraphServiceProc
mov word ptr ds:[GraphServiceDesc],ax
mov ax,offset PmSundryServiceProc
mov word ptr ds:[SundryServiceDesc],ax
mov ax,offset PmMouseServiceProc
mov word ptr ds:[MouseServiceDesc],ax
mov ax,offset PmHdServiceProc
mov word ptr ds:[HdServiceDesc],ax
mov ax,offset PmFileServiceProc
mov word ptr ds:[FileServiceDesc],ax


xor eax,eax
mov ax,Param
mov es,ax
shl eax,4
push eax
mov ax,4f01h
mov di,offset ParamBuf
mov cx,112h
int 10h
mov di,offset ParamBuf
mov eax,es:[di+28h]
mov word ptr ds:[VesaSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaSelector+4],al
mov byte ptr ds:[VesaSelector+7],ah
pop eax
mov word ptr ds:[ParamSelector+2],ax
shr eax,16
mov byte ptr ds:[ParamSelector+4],al
mov byte ptr ds:[ParamSelector+7],ah
mov word ptr ds:[ParamSelector],ParamLenth

xor eax,eax
mov ax,PmCode16Proc
shl eax,4
mov word ptr ds:[PmCode16Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode16Selector+4],al
mov byte ptr ds:[PmCode16Selector+7],ah
mov word ptr ds:[PmCode16Selector],PmCode16ProcLenth	
;What's  normal format of Rm Code segment??? 

xor eax,eax
mov ax,PmCode32Proc
shl eax,4
mov word ptr ds:[PmCode32Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode32Selector+4],al
mov byte ptr ds:[PmCode32Selector+7],ah
mov word ptr ds:[PmCode32Selector],PmCode32ProcLenth

xor eax,eax
mov ax,PmIntProc
shl eax,4
mov word ptr ds:[PmIntSelector+2],ax
shr eax,16
mov byte ptr ds:[PmIntSelector+4],al
mov byte ptr ds:[PmIntSelector+7],ah
mov word ptr ds:[PmIntSelector],PmIntProcLenth
ret
SetDescriptor endp


MainProc ends






PmIntProc segment para use32
assume cs:PmIntProc
PmExpDivisionErrProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3030h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd





PmExpDebugProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3130h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd


PmExpNmiProc:
cli
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3230h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
sti
iretd

PmExpBreakPointProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3330h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpOverFlowProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3430h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpBoundErrProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3530h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpUnlawfulOpcodeProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3630h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpNoneCoprocProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3730h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpDoubleFaultProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+52]
mov esi,ss:[esp+56]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],20203830h
mov ax,ParamSeg
mov ds,ax
mov esi,ss:[esp+48]
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpErrCode],ecx
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd


PmExpCoprocBoundErrProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3930h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpInvalidTssProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+52]
mov esi,ss:[esp+56]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],20203031h
mov ax,ParamSeg
mov ds,ax
mov esi,ss:[esp+48]
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpErrCode],ecx
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd


PmExpSegNonePresentProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+52]
mov esi,ss:[esp+56]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],20203131h
mov ax,ParamSeg
mov ds,ax
mov esi,ss:[esp+48]
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpErrCode],ecx
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd

PmExpStackSegErrProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+52]
mov esi,ss:[esp+56]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],20203231h
mov ax,ParamSeg
mov ds,ax
mov esi,ss:[esp+48]
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpErrCode],ecx
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd

PmExpGeneralProctectProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+52]
mov esi,ss:[esp+56]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],20203331h
mov ax,ParamSeg
mov ds,ax
mov esi,ss:[esp+48]
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpErrCode],ecx
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd

PmExpPageFaultProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+52]
mov esi,ss:[esp+56]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],20203431h
mov ax,ParamSeg
mov ds,ax
mov esi,ss:[esp+48]
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpErrCode],ecx
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd

PmExpFpuFaultProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3631h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpAlignmentCheckErrProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+52]
mov esi,ss:[esp+56]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],20203731h
mov ax,ParamSeg
mov ds,ax
mov esi,ss:[esp+48]
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpErrCode],ecx
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd

PmExpMachineCheckErrProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3831h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd

PmExpSimdFaultProc:
pushad
push ds
push es
push fs
push gs
mov edi,ss:[esp+48]
mov esi,ss:[esp+52]
call near ptr GetExpAddress
mov dword ptr ds:[ExpType],3931h
mov esi,offset MsgExceptionPrompt
mov bh,1
int 82h
pop gs
pop fs
pop es
pop ds
popad
iretd



GetExpAddress:
mov ax,ParamSeg
mov ds,ax
mov eax,esi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,esi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov dword ptr ds:[ExpSegment],ecx
mov eax,edi
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov eax,edi
shr eax,8
mov bh,1
int 83h
mov cx,ax
mov eax,edi
shr eax,16
mov bh,1
int 83h
mov dx,ax
shl edx,16

mov eax,edi
shr eax,24
mov bh,1
int 83h
mov dx,ax
mov dword ptr ds:[ExpAddress+4],ecx
mov dword ptr ds:[ExpAddress],edx
ret








PmSysTimerIntProc:
push eax
push ds
mov ax,ParamSeg
mov ds,ax
mov eax,ds:[SysTimerCount]
inc eax
cmp eax,1800b0h
jbe AlternateKbdPromptFlag
mov eax,0
AlternateKbdPromptFlag:
mov ds:[SysTimerCount],eax
and eax,8
cmp eax,0
jz PmSysTimerRet
xor dword ptr ds:[KbdPromptAlterFlag],0ffffffffh
PmSysTimerRet:
mov al,20h
out 20h,al
out 0a0h,al
pop ds
pop eax
PmIntRet:
iretd







PmKbdIntProc:
pushad
push ds
push es
push fs
push gs
cld
mov ax,ParamSeg
mov ds,ax   
in al,60h
mov byte ptr ds:[ScanCode],al
call AnalysisScanCode  
PmKbdIntRet:
mov al,20h
out 20h,al
pop gs
pop fs
pop es
pop ds
popad
iretd

AnalysisScanCode proc near
CheckMakeCtrl:
cmp byte ptr ds:[ScanCode],1dh		;1dh=Ctrl
jnz CheckMakeShiftLeft
or byte ptr ds:[KbdStatus],4
ret
CheckMakeShiftLeft:
cmp byte ptr ds:[ScanCode],2ah		;2ah=Shift Left
jnz CheckMakeShiftRight
or byte ptr ds:[KbdStatus],2
ret
CheckMakeShiftRight:
cmp byte ptr ds:[ScanCode],36h		;36h=Shift Right
jnz CheckMakeAlt
or byte ptr ds:[KbdStatus],1
ret
CheckMakeAlt:
cmp byte ptr ds:[ScanCode],38h		;38h=Alt
jnz CheckMakeCapsLock
or byte ptr ds:[KbdStatus],8
ret
CheckMakeCapsLock:
cmp byte ptr ds:[ScanCode],3ah		;3ah=CapsLock
jnz CheckMakeScrollLock
call MakeCapsLock                       
ret
CheckMakeScrollLock:
cmp byte ptr ds:[ScanCode],46h		;46h=ScrollLock
jnz CheckMakeNumsLock
call MakeScrollLock                            
ret
CheckMakeNumsLock:
cmp byte ptr ds:[ScanCode],45h		;45h=NumsLock
jnz CheckBreakShiftRight
call MakeNumsLock 
ret
CheckBreakShiftRight:
cmp byte ptr ds:[ScanCode],0b6h		;0b6h=Shift Left
jnz CheckBreakShiftLeft
and byte ptr ds:[KbdStatus],0feh
ret
CheckBreakShiftLeft:
cmp byte ptr ds:[ScanCode],0aah		;0aah=Shift Right
jnz CheckBreakCtrl
and byte ptr ds:[KbdStatus],0fdh
ret
CheckBreakCtrl:
cmp byte ptr ds:[ScanCode],9dh		;9dh=Ctrl
jnz CheckBreakAlt
and byte ptr ds:[KbdStatus],0fbH
ret
CheckBreakAlt:
cmp byte ptr ds:[ScanCode],0b8h		;0b8h=Alt
jnz CheckMakeInsert
and byte ptr ds:[KbdStatus],0f7h
ret
CheckMakeInsert:
cmp byte ptr ds:[ScanCode],52h		;52h=Insert
jnz CheckMakeDelete
xor byte ptr ds:[KbdStatus],80h
jmp ToScanCodeToAscii
CheckMakeDelete:
cmp byte ptr ds:[ScanCode],53h		;53h=Delete
jnz CheckInvalidBreakScanCode
test byte ptr ds:[KbdStatus],4
jz ToScanCodeToAscii
test byte ptr ds:[KbdStatus],8
jz ToScanCodeToAscii
call ShutSystem
CheckInvalidBreakScanCode:
cmp byte ptr ds:[ScanCode],80h
jae AnalysisScanCodeReturn
ToScanCodeToAscii:
call ScanCodeToAscii
AnalysisScanCodeReturn:
retn
AnalysisScanCode endp


ScanCodeToAscii proc near
mov al,byte ptr ds:[KbdStatus]
and al,40h
jnz ScanCodeCapsLock
test byte ptr ds:[KbdStatus],3
jnz ScanCodeShift
jmp ScanCodeNormal
ScanCodeCapsLock:
shr al,5
test al,byte ptr ds:[KbdStatus]
jz CheckShiftRightCapsLock	;ScanCodeNormal
jmp ShiftAndCapsLock
CheckShiftRightCapsLock:
shr al,1
test al,byte ptr ds:[KbdStatus]
jz OnlyCapsLock
ShiftAndCapsLock:
cmp byte ptr ds:[ScanCode],10h
jb ScanCodeShift
cmp byte ptr ds:[ScanCode],19h
jbe ScanCodeNormal
cmp byte ptr ds:[ScanCode],1eh
jb ScanCodeShift
cmp byte ptr ds:[ScanCode],26h
jbe ScanCodeNormal
cmp byte ptr ds:[ScanCode],2ch
jb ScanCodeShift
cmp byte ptr ds:[ScanCode],32h
jbe ScanCodeNormal
jmp ScanCodeShift
OnlyCapsLock:
cmp BYTE PTR ds:[scancode],10h
jb  ScanCodeNormal
cmp BYTE PTR ds:[scancode],19h
jbe ScanCodeShift
cmp BYTE PTR ds:[scancode],1eh
jb  ScanCodeNormal
cmp BYTE PTR ds:[scancode],26h
jbe ScanCodeShift
CMP byte ptr ds:[scancode],2ch
jb  ScanCodeNormal
cmp byte ptr ds:[scancode],32h
jbe ScanCodeShift
ScanCodeNormal:
mov ebx,offset TransScanCodeNormal
jmp TranslateScanCode
ScanCodeShift:
mov ebx,offset TransScanCodeShift
TranslateScanCode:
mov al,byte ptr ds:[ScanCode]
xlat 
mov ah,byte ptr ds:[ScanCode]
cmp ah,39h
jb  StoreKeyValue
mov al,0
StoreKeyValue:
mov edi,dword ptr ds:[KbdBufDetailPtr]
add edi,2		
cmp edi,offset KbdBufHeadPtr
jnz KbdBufNotDetail
mov edi,offset KbdBuf
KbdBufNotDetail:
mov dword ptr ds:[KbdBufDetailPtr],edi	
mov word ptr ds:[edi],ax
mov dword ptr ds:[KbdMsgFlag],1
ret
ScanCodeToAscii endp


SetKbdLed proc near
call waitIn
mov al,0adh
out 64h,al
call WaitIn
mov al,0edh
out 60h,al
call waitOut
in al,60h
cmp al,0fah
jnz SetKbdLed
ResendKbdLedCom:
call waitIn
mov al,byte ptr ds:[KbdLedStatus]
out 60h,al
call waitOut        ;here u get return byte 0fah,but why can't read it out ?
in al,60h
cmp al,0fah
jnz ResendKbdLedCom
call WaitIn
mov al,0aeh
out 64h,al
ret
SetKbdLed endp

MakeScrollLock proc near
xor byte ptr ds:[KbdStatus],10h
xor byte ptr ds:[KbdLedStatus],1
call SetKbdLed
ret
MakeScrollLock endp

MakeNumsLock proc near
xor byte ptr ds:[KbdStatus],20h
xor byte ptr ds:[KbdLedStatus],2
call SetKbdLed
ret
MakeNumsLock endp

MakeCapsLock proc near
Xor byte ptr ds:[KbdStatus],40h
xor byte ptr ds:[KbdLedStatus],4
call SetKbdLed
ret
MakeCapsLock endp

WaitOut proc near
in al,64h
test al,1
jz waitout
ret
WaitOut endp

WaitIn proc near
in al,64h
test al,2
jnz WaitIn
ret
WaitIn endp

ShutSystem proc near
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
out dx,ax
pop dx
add dx,5 
in al,dx
or al,3ch
out dx,al
ShutSystem endp







PmRltIntProc:
pushad
push ds
push es
push fs
push gs
mov al,0ch
out 70h,al
in al,71h
cmp al,90h
jz RltTimingInt
cmp al,0a0h
jz RltAlarmInt
cmp al,0c0h
jz RltPeriodInt
PmRltIntRet:
mov al,20h
out 20h,al
out 0a0h,al
pop gs
pop fs
pop es
pop ds
popad
iretd

RltPeriodInt:
jmp PmRltIntRet
mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov eax,ds:[MouseColor]
mov edi,ds:[MousePos]
mov ecx,16
cld
ColorMouse:
push ecx
push edi
mov ecx,16
ColorMouseLine:
stosd
add eax,10h
loop ColorMouseLine
pop edi
add edi,2560
pop ecx
loop ColorMouse
mov ds:[MouseColor],eax
jmp PmRltIntRet



RltAlarmInt:
jmp PmRltIntRet



RltTimingInt:
mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov edi,ds:[RltClockPos]
mov ecx,16
mov eax,8080e0h
cld
ResetRtlBkgrd:
push ecx
push edi
mov ecx,80
rep stosd
pop edi
add edi,2560
pop ecx
loop ResetRtlBkgrd

push dword ptr ds:[FontColor]
pop dword ptr ds:[FontColorBackup]
push dword ptr ds:[RltClockColor]
pop dword ptr ds:[FontColor]
mov edi,ds:[RltClockPos]
mov al,4
call ShowRltDateTime

mov al,3ah
mov bh,0
int 82h
add edi,32

mov al,2
call ShowRltDateTime

mov al,3ah
mov bh,0
int 82h
add edi,32

mov al,0
call ShowRltDateTime

add edi,32
push edi
mov ecx,8
mov eax,0
SetRltWeekBkgrd:
push ecx
push edi
mov ecx,8
rep stosd
pop edi
add edi,2560
pop ecx
loop SetRltWeekBkgrd

pop edi
mov al,6
out 70h,al
in al,71h
mov bh,1
int 83h
mov al,ah
mov bh,0
int 82h

mov edi,ds:[RltClockPos]
add edi,2560*8
mov al,32h
call ShowRltDateTime
mov al,9
call ShowRltDateTime

mov al,5ch
mov bh,0
int 82h
add edi,32

mov al,8
call ShowRltDateTime

mov al,5ch
mov bh,0
int 82h
add edi,32

mov al,7
call ShowRltDateTime

push dword ptr ds:[FontColorBackup]
pop dword ptr ds:[FontColor]
add dword ptr ds:[RltClockColor],8020c0h
jmp PmRltIntRet

ShowRltDateTime:
out 70h,al
in al,71h
mov bh,1
int 83h
mov bh,0
int 82h
add edi,32
xchg ah,al
mov bh,0
int 82h
add edi,32
ret








PmMouseIntProc:
pushad
push ds
push es
push fs
push gs
mov ax,ParamSeg
mov ds,ax
mov ebx,ds:[MousePacketSequence]
in al,60h
movsx eax,al
mov ds:[MouseStatus+ebx],eax
add dword ptr ds:[MousePacketSequence],4
mov eax,dword ptr ds:[MousePacketSequence]
cmp eax,ds:[MousePacketSize]
jz  MouseIntMain

PmMouseIntReturn:
mov al,20h
out 20h,al
out 0a0h,al
pop gs
pop fs
pop es
pop ds
popad
iretd
MouseIntMain:
mov dword ptr ds:[MouseMsgFlag],1
mov dword ptr ds:[MousePacketSequence],0
mov edi,ds:[MousePos]
mov ax,VesaSeg
mov es,ax
mov ax,BackingBufSeg
mov ds,ax
mov esi,0
mov ecx,16
cld
RestoreMouseBkgrd:
push ecx
push edi
mov ecx,16
rep movsd
pop edi
add edi,2560
pop ecx
loop RestoreMouseBkgrd

GetMousePos:
mov ax,ParamSeg
mov ds,ax
mov eax,ds:[MouseDeltaX]
add ds:[MouseX],eax
cmp dword ptr ds:[MouseX],0
jge CheckMouseXMaxRange
mov dword ptr ds:[MouseX],0
CheckMouseXMaxRange:
cmp dword ptr ds:[MouseX],639
jle MouseXRangeNormal
mov dword ptr ds:[MouseX],639
MouseXRangeNormal:
mov eax,ds:[MouseY]
sub eax,ds:[MouseDeltaY]
mov ds:[MouseY],eax

cmp dword ptr ds:[MouseY],0
jge CheckMouseYMaxRange
mov dword ptr ds:[MouseY],0
CheckMouseYMaxRange:
cmp dword ptr ds:[MouseY],480
jle MouseYRangeNormal
mov dword ptr ds:[MouseY],480
MouseYRangeNormal:
mov edx,0
mov ebx,2560
mul ebx
mov ebx,ds:[MouseX]
shl ebx,2
add eax,ebx
mov ds:[MousePos],eax

mov esi,eax
mov ax,VesaSeg
mov ds,ax
mov ax,BackingBufSeg
mov es,ax
mov edi,0
mov ecx,16
SaveMouseBkgrd:
push ecx
push esi
mov ecx,16
rep movsd
pop esi
add esi,2560
pop ecx
loop SaveMouseBkgrd

mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov edi,ds:[MousePos]
mov eax,ds:[MouseColor]
mov ecx,16
ShowMouseGraph:
push ecx
push edi
mov ecx,16
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowMouseGraph
sti
jmp PmMouseIntReturn	;jmp is illegal when offset above 128b in masm5.0,why?????







PmCoprocessorIntProc:
pushad
push ds
clts
mov al,0
out 0f0h,al
in al,0f0h
mov al,20h
out 0a0h,al
out 20h,al
mov ax,ParamSeg
mov ds,ax
mov esi,offset MsgCoprocessorError
mov bh,1
int 82h
pop ds
popad
iretd






PmKbdServiceProc proc near
cmp bh,0
jz WaitForInputAKey
cmp bh,1
jz GetPreviousKey
iretd

WaitForInputAKey:
push ds
mov ax,ParamSeg
mov ds,ax
WaitKeyPress:
sti
mov eax,dword ptr ds:[KbdBufHeadPtr]
cmp eax,dword ptr ds:[KbdBufDetailPtr]
jz WaitKeyPress
add eax,2
cmp eax,offset KbdBufHeadPtr
jnz KbdBufHeadNotEnd
mov eax,offset KbdBuf
KbdBufHeadNotEnd:
mov dword ptr ds:[KbdBufHeadPtr],eax
mov ax,word ptr ds:[eax]
pop ds
iretd
PmKbdServiceProc endp



GetPreViousKey:
cli
push ds
mov ax,ParamSeg
mov ds,ax
cmp dword ptr ds:[KbdMsgFlag],0
jz PreviousNoKey
mov dword ptr ds:[KbdMSgFlag],0
mov eax,dword ptr ds:[KbdBufHeadPtr]
add eax,2
cmp eax,offset KbdBufHeadPtr
jnz KbdBufNotEnd
mov eax,offset KbdBuf
KbdBufNotEnd:
mov dword ptr ds:[KbdBufHeadPtr],eax
mov ax,word ptr ds:[eax]
jmp GetPreviousKeyEnd
PreviousNoKey:
mov eax,-1
GetPreviousKeyEnd:
pop ds
sti
iretd







PmGraphServiceproc:            ;input:eax=ascii char ,edi=position
cmp bh,0
jz VesaShowGraphChar
cmp bh,1
jz MessageBox
iretd

VesaShowGraphChar:
pushad
push ds
push es

mov bx,VesaSeg
mov es,bx
mov bx,GraphCharSeg
mov ds,bx
movzx eax,al
shl eax,3
mov esi,eax
cld
mov ecx,8
ShowCharGraph:
push ecx
push esi
push edi
xor eax,eax
mov al,ds:[esi]
call ShowCharGraphLine
pop edi
add edi,2560
pop esi
inc esi
pop ecx
loop ShowCharGraph
ShowGraphCharRet:
pop es
pop ds
popad
iretd

ShowCharGraphLine:
push eax
push ebx
push ecx
push ds
mov bl,al
mov bh,128
mov ax,ParamSeg
mov ds,ax
mov ecx,8
cld
DrawCharPixLine:
push ecx
mov al,bl
and al,bh
cmp al,0
jnz DrawCharPixDot
add edi,4
jmp InspectNextPix
DrawCharPixDot:
mov eax,ds:[FontColor]
stosd
InspectNextPix:
shr bh,1
pop ecx
loop DrawCharPixLine
pop ds
pop ecx
pop ebx
pop eax
ret






MessageBox:                     ;ds:[esi]--->string
cli
push ecx
push edx
push ebx
push ebp
push esp
push esi
push edi
push ds
push es
push fs
push gs

mov ax,ParamSeg
mov ds,ax
mov edi,ds:[MousePos]
mov ax,VesaSeg
mov es,ax
mov ax,BackingBufSeg
mov ds,ax
mov esi,0
mov ecx,16
cld
MsgBoxRestoreMouse:
push ecx
push edi
mov ecx,16
rep movsd
pop edi
add edi,2560
pop ecx
loop MsgBoxRestoreMouse


mov ax,VesaSeg
mov ds,ax
mov ax,BackingBufSeg
mov es,ax
mov esi,2560*200+200*4
mov edi,3072
mov ecx,80
BackingMsgBoxBkgrd:
push ecx
push esi
mov ecx,240
rep movsd
pop esi
add esi,2560
pop ecx
loop BackingMsgBoxBkgrd

mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov edi,2560*200+200*4
mov ecx,80
mov eax,0e08080h
MsgBoxShowFrame:
push ecx
push edi
mov ecx,240
rep stosd
pop edi
add edi,2560
pop ecx
loop MsgBoxShowFrame

mov eax,ss:[esp+12]
mov ds,ax
mov esi,ss:[esp+20]
mov edi,2560*208+208*4
MsgBoxShowTxt:
cmp edi,2560*256+208*4
jae MsgBoxShowButtonFrame
lodsb
cmp al,0
jz MsgBoxShowButtonFrame
cmp al,0dh
jnz MsgBoxNotEnter
mov eax,edi
mov edx,0
mov ecx,2560
div ecx
sub edi,edx
add edi,208*4
jmp MsgBoxShowTxt
MsgBoxNotEnter:
cmp al,0ah
jnz MsgBoxNotNextLine
add edi,2560*8
jmp MsgBoxShowTxt
MsgBoxNotNextLine:
mov bh,0
int 82h
add edi,32
mov eax,edi
mov edx,0
mov ecx,2560
div ecx
cmp edx,432*4
jb MsgBoxShowTxt
add edi,2560*8-224*4
jmp MsgBoxShowTxt

MsgBoxShowButtonFrame:
mov edi,2560*256+340*4
mov ecx,16
mov eax,0ffffffffh
MsgBoxShowButtonNo:
push ecx
push edi
mov ecx,40
rep stosd
pop edi
add edi,2560
pop ecx
loop MsgBoxShowButtonNo

mov edi,2560*256+260*4
mov ecx,16
mov eax,0ffffffffh
MsgBoxShowButtonYes:
push ecx
push edi
mov ecx,40
rep stosd
pop edi
add edi,2560
pop ecx
loop MsgBoxShowButtonYes

mov ax,ParamSeg
mov ds,ax
mov edi,2560*260+260*4
mov esi,offset MsgBoxButtonTxtYes
MsgBoxShowButtonTxtYes:
lodsb
cmp al,0
jz MsgBoxShowButtonTxtYesEnd
mov bh,0
int 82h
add edi,32
jmp MsgBoxShowButtonTxtYes

MsgBoxShowButtonTxtYesEnd:
mov esi,offset MsgBoxButtonTxtNo
mov edi,2560*260+340*4
MsgBoxShowButtonTxtNo:
lodsb
cmp al,0
jz MsgBoxShowButtonTxtEnd
mov bh,0
int 82h
add edi,32
jmp MsgBoxShowButtonTxtNo

MsgBoxShowButtonTxtEnd:
mov bh,1
int 8ch

MsgBoxButtonWaitClick:
sti
mov bh,1
int 81h
cmp al,0dh
jz MsgBoxClickYes
cmp al,1bh
jz MsgBoxClickNo

mov bh,0
int 8ch
cmp eax,-1
jz MsgBoxButtonWaitClick
test eax,1
jz MsgBoxButtonWaitClick
cmp ecx,256
jb MsgBoxButtonWaitClick
cmp ecx,272
jae MsgBoxButtonWaitClick

cmp ebx,260
jb MsgBoxButtonWaitClick
cmp ebx,300
jb MsgBoxClickYes
cmp ebx,340
jb MsgBoxButtonWaitClick
cmp ebx,380
jae MsgBoxButtonWaitClick
MsgBoxClickNo:
mov eax,1
push eax
jmp MsgBoxRestoreBkgrd
MsgBoxClickYes:
mov eax,0
push eax
MsgBoxRestoreBkgrd:
mov ax,VesaSeg
mov es,ax
mov ax,BackingBufSeg
mov ds,ax
mov edi,2560*200+200*4
mov esi,3072
mov ecx,80
RestoreMsgBoxBkgrd:
push ecx
push edi
mov ecx,240
rep movsd
pop edi
add edi,2560
pop ecx
loop RestoreMsgBoxBkgrd
mov bh,1
int 8ch
pop eax
pop gs
pop fs
pop es
pop ds
pop edi
pop esi
pop esp
pop ebp
pop ebx
pop edx
pop ecx
sti
iretd









PmSundryServiceProc:
cmp bh,0
jz InitMouseRltTiming
cmp bh,1
jz DigitToAsc
iretd

InitMouseRltTiming proc near
iretd
InitMouseRltTiming  Endp


DigitToAsc:                
push ebx
mov bh,al
shr al,4
cmp al,9
jbe TranslateDigitalHigh
add al,7
TranslateDigitalHigh:
add al,30h
mov bl,al
mov al,bh
and al,0fh
cmp al,9
jbe TranslateDigitalLow
add al,7
TranslateDigitalLow:
add al,30h
mov bh,al
mov ax,bx
pop ebx
iretd








PmMouseServiceProc:
cmp bh,0
jz GetMousePacketMsg
cmp bh,1
jz InitMouseGraph
iretd

GetMousePacketMsg:
cli
push ds
mov ax,ParamSeg
mov ds,ax
cmp dword ptr ds:[MouseMsgFlag],0
jz NoMousePacketMsg
mov dword ptr ds:[MouseMsgFlag],0
mov eax,ds:[MouseStatus]
mov ebx,ds:[MouseX]
mov ecx,ds:[MouseY]
mov edx,ds:[MouseZ]
jmp GetMousePacketMsgEnd 
NoMousePacketMsg:
mov eax,-1
GetMousePacketMsgEnd:
pop ds
sti
iretd



InitMouseGraph:
cli
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov esi,ds:[MousePos]
mov ax,VesaSeg
mov ds,ax
mov ax,BackingBufSeg
mov es,ax
mov edi,0
mov ecx,16
cld
SaveMouseBkgrdFirst:
push ecx
push esi
mov ecx,16
rep movsd
pop esi
add esi,2560
pop ecx
loop SaveMouseBkgrdFirst

mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov eax,ds:[MouseColor]
mov edi,ds:[MousePos]
mov ecx,16
ShowMouseFirst:
push ecx
push edi
mov ecx,16
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowMouseFirst
mov dword ptr ds:[MouseMsgFlag],0
pop es
pop ds
popad
sti
iretd







;how to reference the function?which reg is much better as a function index?
;eax looks no good,cx is also,dx is not appropriate,so bx is perceived to be better,but DOS used to 
;use ah as a function index,cause ebx will be assigned again as a pointer,but eax and ecx and edx will be good to be parameters,
PmHdServiceProc:
cmp bh,0
jz ReadSector
cmp bh,1
jz WriteSector
iretd




ReadSector proc near            ;input ecx,eax,es:[edi]
pushad
push ds
push es
push fs
push gs

mov ax,ParamSeg
mov ds,ax
call WaitIdeFree
mov ebx,ds:[MultiModeSecNum]
mov eax,ecx
mov edx,0
div ebx
cmp eax,0
jz NotReadMaxMutiSec
mov ecx,eax
mov eax,ss:[esp+44]
ReadMaxMultiSec:
push ecx
push edi
push eax
mov dx,ds:[HdPortBase]
add dx,2
mov eax,ds:[MultiModeSecNum]
xchg ah,al
out dx,al
xchg ah,al
out dx,al
mov ecx,eax
pop eax
call ReadSec
add eax,ecx
pop edi
shl ecx,9
add edi,ecx
pop ecx
dec ecx
cmp ecx,0
jnz ReadMaxMultiSec
ReadSectorEnd:
pop gs
pop fs
pop es
pop ds
popad
iretd


NotReadMaxMutiSec:
mov ecx,edx
mov dx,ds:[HdPortBase]
add dx,2
mov ax,cx
xchg ah,al
out dx,al
xchg ah,al
out dx,al
mov eax,ss:[esp+44]
call ReadSec
jmp ReadSectorEnd


ReadSec:        ;esi=sec num eax=sec index
push eax
push ecx
push edx
push edi
push eax
mov dx,ds:[HdPortBase]
add dx,5
mov al,0
out dx,al
dec dx 	
out dx,al
dec dx	
pop eax
rol eax,8
out dx,al
add dx,2	
rol eax,8
out dx,al
dec dx 		
rol eax,8
out dx,al
dec dx		
rol eax,8
out dx,al
add dx,3
mov al,ds:[HdSlaveFlag]
out dx,al
sub dx,5
mov al,0
out dx,al
add dx,6

cli
mov al,29h
out dx,al
WaitHdReady:
in al,dx
and al,0fdh
cmp al,58h
jnz WaitHdReady
sub dx,7
shl ecx,8
cld
rep insw
ReadSecEnd:
pop edi
pop edx
pop ecx
pop eax
ret

ReadSector endp



WriteSector:
iretd






WaitIdeFree:
push eax
push edx
mov dx,ds:[HdPortBase]
add dx,7
WaitIdeIdle:
in al,dx
cmp al,50h
jnz WaitIdeIdle
pop edx
pop eax
ret





















PmFileServiceProc:
cmp bh,0
jz OpenFile
cmp bh,1
jz ReadFile
cmp bh,2
jz GetDiskInfo
iretd



;ds:[esi]->filename
OpenFile Proc near
pushad
push ds
push es
push fs
push gs
mov ax,ParamSeg
mov es,ax
mov dword ptr es:[FileCluStatus],0
cld        
lodsb
cmp al,43h		;'C'
jl FileNameInvalid
cmp al,5ah		;'Z'
jle FileNameCapitals
cmp al,63h		;'c'
jl FileNameInvalid
cmp al,7ah		;'z'
jg FileNameInvalid
sub al,20h
FileNameCapitals:
sub al,43h		;'C'
movzx eax,al
cmp eax,es:[DiskNumPtr]	
jge FileNameInvalid
shl eax,5
mov es:[PartNumPtr],eax
lodsw
cmp ax,5c3ah		
jnz FileNameInvalid
mov ebx,es:[PartNumPtr]
mov eax,es:[ebx+Disk0FDTptr]
mov es:[FileSecPtr],eax
push dword ptr es:[ebx+Disk0FirstClu]
pop dword ptr es:[FileCluPtr]

HandleFileName:
mov edi,offset FileSubDirBuf
mov dword ptr es:[FileSubDirLen],0
CheckFileSubDir:
lodsb
cmp al,5ch		
jz GetFileSubDir
cmp al,2eh		
jz GetFileSoleName
stosb
inc dword ptr es:[FileSubDirLen]
jmp CheckFileSubDir

FileNameInvalid:
mov ax,ParamSeg
mov ds,ax
mov esi,offset MsgFileNameInvalid
mov bh,1
int 82h
jmp OpenFileRet

GetFileSubDir:
mov ecx,11
sub ecx,dword ptr es:[FileSubDirLen]
mov al,20h
rep stosb
call LowerLetterToCapitals
call ReadFileSubDir
jmp HandleFileName

GetFileSoleName:
mov ecx,8
sub ecx,es:[FileSubDirLen]
mov al,20h
rep stosb
mov ecx,3
rep movsb
call LowerLetterToCapitals
call ReadFileSubDir
OpenFileRet:
pop gs
pop fs
pop es
pop ds
popad
iretd



LowerLetterToCapitals:
push eax
push ecx
push esi
push edi
push ds
mov ax,ParamSeg
mov ds,ax
mov esi,offset FileSubDirBuf
mov edi,offset FileSubDirBuf
mov ecx,11
LowerCaseToUpperCase:
lodsb
cmp al,7ah
ja NeglectLetter
cmp al,61h
jb NeglectLetter
sub al,20h
NeglectLetter:
stosb
loop LowerCaseToUpperCase
pop ds
pop edi
pop esi
pop ecx
pop eax
ret


ReadFileSubDir:
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov ax,HdBufSeg
mov es,ax

ReadFileSubDirClu:
mov ebx,ds:[PartNumPtr]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
mov eax,ds:[FileSecPtr]
mov edi,0
mov bh,0
int 8eh

mov ebx,ds:[PartNumPtr]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
shl ecx,4		
mov esi,offset FileSubDirBuf
mov edi,0
SearchFileNameInFdt:
push ecx
push esi
push edi
mov ecx,11
repz cmpsb
cmp ecx,0
jz FindShortNameInFdt
pop edi
add edi,20h
pop esi
pop ecx
loop SearchFileNameInFdt
call GetNextCluNum
test dword ptr ds:[FileCluStatus],7
jz ReadFileSubDirClu

mov eax,offset MsgReadFileFailure
mov ds:[MsgBoxStrPtr],eax
mov bh,1
int 82h
jmp ReadFileSubDirEnd
FindShortNameInFdt:
pop edi
pop esi
pop ecx
mov ax,word ptr es:[edi+14h]
shl eax,16
mov ax,word ptr es:[edi+1ah]		
mov dword ptr ds:[FileCluPtr],eax
mov eax,es:[edi+1ch]
mov ds:[FileSize],eax
mov eax,ds:[FileCluPtr]
mov ebx,ds:[PartNumPtr]
sub eax,ds:[ebx+Disk0FirstClu]
mov dl,ds:[ebx+Disk0SecPerClu]
movzx edx,dl
mul edx
add eax,ds:[ebx+Disk0FDTptr]
mov ds:[FileSecPtr],eax
ReadFileSubDirEnd:
pop es
pop ds
popad
ret
OpenFile endp








ReadFile Proc near
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax

test dword ptr ds:[FileCluStatus],7
jnz ReadFileEnd
mov ebx,ds:[PartNumPtr]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
shl ecx,9
mov ds:[FileCluSize],ecx

ReadFileClu:
push edi
mov ebx,ds:[PartNumPtr]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
mov eax,ds:[FileSecPtr]
mov bh,0
int 8eh
call GetNextCluNum
pop edi
add edi,dword ptr ds:[FileCluSize]
test dword ptr ds:[FileCluStatus],7
jz ReadFileClu

ReadFileEnd:
mov dword ptr ds:[FileCluStatus],0
pop es
pop ds
popad
iretd



GetNextCluNum:
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov ax,HdBufSeg
mov es,ax
mov eax,ds:[FileCluPtr]
shl eax,2
mov edx,0
mov ecx,512
div ecx 		
push edx
mov ebx,ds:[PartNumPtr]
add eax,ds:[ebx+Disk0FATptr]
mov ecx,1
mov edi,0
mov bh,0
int 8eh
pop edx
mov eax,dword ptr es:[edx]
and eax,0fffffffh
cmp eax,2
jb NotValidFileCluValue
cmp eax,0fffffefh
jbe GetValidFileCluValue
cmp eax,0ffffff7h
jz BadFileCluValue
cmp eax,0ffffff8h
jae EndFileCluValue
NotValidFileCluValue:
or dword ptr ds:[FileCluStatus],4
jmp GetNextCluNumEnd
BadFileCluValue:
or dword ptr ds:[FileCluStatus],2
jmp GetNextCluNumEnd
EndFileCluValue:
or dword ptr ds:[FileCluStatus],1
jmp GetNextCluNumEnd

GetValidFileCluValue:
mov ds:[FileCluPtr],eax
mov ebx,ds:[PartNumPtr]
sub eax,ds:[ebx+Disk0FirstClu]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
mul ecx
add eax,ds:[ebx+Disk0FDTptr]
mov ds:[FileSecPtr],eax

GetNextCluNumEnd:
pop es
pop ds
popad
ret
ReadFile Endp






GetDiskInfo proc near
pushad
push ds
push es
push fs
push gs
mov ax,ParamSeg
mov ds,ax
mov ax,HdBufSeg
mov es,ax
cld
mov eax,0
mov ecx,1
mov edi,0
mov bh,0
int 8eh
mov al,byte ptr es:[1c2h]
cmp al,0bh
jz  MainPartFat32
cmp al,0ch
jz  MainPartFat32
cmp al,1bh
jz  MainPartFat32
cmp al,1ch
jnz CheckExtPartType
MainPartFat32:		 
mov eax,dword ptr es:[1c6h]
mov ecx,1
mov edi,400h
mov bh,0
int 8eh
call CopyBPB

CheckExtPartType:
mov al,byte ptr es:[1d2h]
cmp al,0fh
jz CheckExtPart
cmp al,5
jnz CheckPartEnd

CheckExtPart:
mov eax,dword ptr es:[1d6h]
mov ds:[ExtPartPtr],eax
mov ecx,1
mov edi,200h
mov bh,0
int 8eh

ExtMainPart:
cmp word ptr es:[3feh],0aa55h
jnz CheckPartEnd
mov eax,dword ptr es:[3c6h]
cmp eax,0
jz CheckPartEnd
add eax,ds:[ExtPartPtr]
;mov ds:[ExtpartPtr],eax
mov ecx,1
mov edi,400h
mov bh,0
int 8eh
cmp dword ptr es:[452h],33544146h
jnz NextLogicalPart
call CopyBPB
NextLogicalPart:
mov eax,dword ptr es:[3d6h]
cmp eax,0
jz CheckPartEnd
add eax,ds:[ExtPartPtr]
mov ds:[ExtPartPtr],eax
mov ecx,1
mov edi,200h
mov bh,0
int 8eh
jmp ExtMainPart

CheckPartEnd:
cmp dword ptr ds:[DiskNumPtr],0
jz MsgBoxNotFat32
shr dword ptr ds:[DiskNumPtr],5
call CalcDiskParam
call MsgShowPart
GetDiskInfoReturn:
pop gs
pop fs
pop es
pop ds
popad
iretd



MsgShowPart:
pushad
mov esi,offset Disk0FdtPtr
mov ebx,0
mov ecx,ds:[DiskNumPtr]

GetDiskFdtAsc:
push ecx
push esi
push ebx
lodsd
mov edi,eax
mov bh,1
int 83h
mov dx,ax
shl edx,16
mov eax,edi
shr eax,8
mov bh,1
int 83h
mov dx,ax
pop ebx
mov dword ptr ds:[Disk0FdtAddr+4+ebx],edx

push ebx
mov eax,edi
shr eax,16
mov bh,1
int 83h
mov dx,ax
shl edx,16
mov eax,edi
shr eax,24
mov bh,1
int 83h
mov dx,ax
pop ebx
mov dword ptr ds:[DIsk0FdtAddr+ebx],edx
add ebx,10
pop esi
add esi,20h
pop ecx
loop GetDiskFdtAsc
mov dword ptr ds:[Disk0FdtAddr+ebx+8],0

mov esi,offset MsgDiskPartInfo
mov bh,1
int 82h
popad
ret



MsgBoxNotFat32:
mov esi, offset MsgNotFat32
mov bh,1
int 82h
jmp GetDiskInfoReturn

CopyBPB:
pushad
push ds
push es
mov ax,ds
mov bx,es
xchg ax,bx
mov ds,ax
mov es,bx
mov esi,40dh
mov edi,offset Disk0SecPerClu
add edi,dword ptr es:[DiskNumPtr]
cld
movsd
mov esi,41ch
movsd
movsd                                              
movsd
mov esi,42ch		
movsd
mov esi,430h
movsd
add dword ptr es:[DiskNumPtr],20h
pop es
pop ds
popad
ret

CalcDiskParam:
push eax
push ebx
push ecx
push edx
mov ebx,0
mov ecx,ds:[DiskNumPtr]
CalcFAT:
mov eax,ds:[ebx+Disk0Hidden]
mov dx,ds:[ebx+Disk0Reserved]
movzx edx,dx
add eax,edx
mov ds:[ebx+Disk0FATptr],eax
add ebx,20h
loop CalcFAT
mov ebx,0
mov ecx,ds:[DiskNumPtr]
CalcFDT:
mov eax,ds:[ebx+Disk0FATSize]
mov dl,ds:[ebx+Disk0FATnum]
movzx edx,dl
mul edx
add eax,ds:[ebx+Disk0FATptr]
mov ds:[ebx+Disk0FDTptr],eax
add ebx,20h
loop CalcFDT
pop edx
pop ecx
pop ebx
pop eax
ret
GetDiskInfo endp


PmIntProcLenth                  equ $-1
PmIntProc ends














PmCode16Proc segment para use16
assume cs:PmCode16Proc
db 0eah
dw 0
dw PmCode32Seg

ToDosMode:
cli
mov ax,NormalSeg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
db 0eah
dw offset DosMode
dw seg DosMode
;jmp far ptr DosMode
PmCode16ProcLenth              equ $-1
PmCode16Proc ends







PmCode32Proc segment para use32
assume cs:PmCode32Proc
cli
mov bx,Tss0Seg
ltr bx
clts


mov ax,ParamSeg
mov ds,ax
mov fs,ax
mov gs,ax
mov ax,VesaSeg
mov es,ax
mov ax,Stack0Seg
mov ss,ax
mov esp,8000h
pushfd
pop eax
and eax,0ffffbfffh
push eax
popfd

call SetPageTable
mov eax,cr0
or eax,80000000h
mov cr0,eax
jmp EnablePaging
EnablePaging:
mov bh,1
int 8ch

cli	                                                             
call Init8259
call SetSysTimerPort
call SetRltPort
call SetMousePort
call GetHdPortBase
sti

call AdjustMouse

mov ax,ParamSeg
mov ds,ax
mov bh,2
int 8fh
cmp dword ptr ds:[DiskNumPtr],0
jz GetMsg

GraphicProcMain:
call SetDeskTopBkgrd

GetMsg:
sti
mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov bh,0
int 8ch
cmp eax,-1
jz CheckKbdMsg
cmp ebx,32
jb CheckKbdMsg
cmp ebx,352
ja CheckKbdMsg
cmp ecx,8
jb CheckKbdMsg
cmp ecx,64
ja CheckKbdMsg
test eax,1
jz CheckKbdMsg

Call MyComPuterProc

CheckKbdMsg:
cli
mov bh,1
int 81h
cmp eax,-1
jz ToDisplayKbdPrompt
cmp al,1bh
jz ToRealMode

cmp al,9
jnz CheckStrikeBack
mov eax,0
call ShowClearKbdPrompt
add dword ptr ds:[PromptPos],256
jmp AdjustPromptPos

CheckStrikeBack:
cmp al,8
jnz CheckStrikeEnter
dec dword ptr ds:[FileNamePtr]
mov eax,0
call ShowClearKbdPrompt
sub dword ptr ds:[PromptPos],32
cmp dword ptr ds:[PromptPos],456*2560
jae ToDisplayKbdPrompt
mov dword ptr ds:[PromptPos],456*2560
jmp ToDisplayKbdPrompt

CheckStrikeEnter:
cmp al,0dh
jnz CheckStrikeAscii
mov edi,2560*456
mov ecx,640*8
mov eax,0
rep stosd
mov dword ptr ds:[PromptPos],456*2560
mov dword ptr ds:[FileNamePtr],offset FileName
call KbdCommand
jmp GetMsg

CheckStrikeAscii:
push eax
mov eax,0
call ShowClearKbdPrompt
pop eax
mov esi,ds:[FileNamePtr]
mov ds:[esi],al
inc dword ptr ds:[FileNamePtr]
push dword ptr ds:[VesaCharColor]
pop dword ptr ds:[FontColor]
mov edi,ds:[PromptPos]
mov bh,0
int 82h
add dword ptr ds:[PromptPos],32
AdjustPromptPos:
cmp dword ptr ds:[PromptPos],2560*457
jb ToDisplayKbdPrompt
mov dword ptr ds:[FileNamePtr],offset FileName
mov dword ptr ds:[PromptPos],2560*456
mov edi,2560*456
mov ecx,640*8
mov eax,0
rep stosd
ToDisplayKbdPrompt:
mov eax,ds:[KbdPromptAlterFlag]
call ShowClearKbdPrompt
jmp GetMsg





ToRealMode:
mov eax,cr0
and eax,7fffffffh
mov cr0,eax
jmp DisEnablePaging
DisEnablePaging:
cli
mov al,0ffh
out 21h,al
out 0a1h,al
call Restore8259
db 0eah
dw offset ToDosMode
dw 0
dw PmCode16Seg






MyComPuterProc:
pushad
push ds
push es
push fs
push gs
mov ax,HdBufSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov ax,DeskTopFileSeg
mov fs,ax
mov ax,ParamSeg
mov gs,ax

cld
call ClearDeskTop

mov ecx,gs:[DiskNumPtr]        
mov edi,2560*64+96
mov edx,3a43h
DrawDIskIcon:
push ecx
push edx
push edi
mov eax,0ffff00h
call DrawIcon
add edi,2560*48+96
mov eax,edx
mov bh,0
int 82h
add edi,32
shr eax,8
mov bh,0
int 82h
pop edi
add edi,352
mov eax,edi
mov edx,0
mov ebx,2560
div ebx
cmp edx,0
jnz DiskCountInc
add edi,2560*63+96
DiskCountInc:
pop edx
inc edx
pop ecx
loop DrawDiskIcon	                    

mov bh,1
int 8ch

GetDiskIconPos:
call GetIconPos
cmp eax,gs:[DiskNumptr]
jae GetDiskIconPos
shl eax,5
mov gs:[PartNumPtr],eax
mov eax,gs:[eax+Disk0FdtPtr]
mov ebx,0
mov gs:[ParentDirPtr],ebx
mov fs:[ebx],eax
mov eax,4096
mov gs:[IconPagePtr],eax
mov dword ptr fs:[eax],0

pushad
push es
mov ax,HdBufSeg
mov es,ax
mov ebx,gs:[PartNumPtr]
mov eax,gs:[ebx+Disk0FdtPtr]
mov cl,gs:[ebx+Disk0SecPerClu]
movzx ecx,cl
mov edi,0
mov bh,0
int 8eh
pop es
popad

call ClearDeskTop
ReadFileDirContent:
call ClearDeskTop
mov ebx,gs:[PartNumPtr]
mov cl,gs:[ebx+Disk0SecPerClu]
movzx ecx,cl
shl ecx,4
mov esi,0
mov edi,2560*64+96
mov dword ptr gs:[FileDirInfoPtr],8192

ShowFileDirIcon:
push ecx
push esi
push edi
lodsb
cmp al,5
jz InvalidFileDir
cmp al,0e5h
jz InvalidFileDir
cmp al,0
jz InvalidFileDir
add esi,10
lodsb
cmp al,0fh
jz InvalidFileDir
test al,10h
jnz FileDirFolderIcon
mov eax,0
jmp ToDrawFileDirIcon
FileDirFolderIcon:
mov eax,0ffff00h
ToDrawFileDirIcon:
call DrawIcon
add edi,2560*48
sub esi,12
mov ecx,8
ShowFileDirMainName:
lodsb
mov bh,0
int 82h
add edi,32
loop ShowFileDirMainName
add edi,2560*8-256		                                            
mov ecx,3
ShowFileDirExtName:
lodsb
mov bh,0
int 82h
add edi,32
loop ShowFileDirExtName

sub esi,11
mov edi,gs:[FileDirInfoPtr]
mov ecx,8
CopyFileDirInfo:
mov eax,ds:[esi]
mov fs:[edi],eax
add esi,4
add edi,4
loop CopyFileDirInfo
add dword ptr gs:[FileDirInfoPtr],32

pop edi
add edi,352
mov eax,edi
mov edx,0
mov ecx,2560
div ecx
cmp edx,0
jnz ShowFileDirIconNextLine
add edi,2560*63+96
ShowFileDirIconNextLine:
cmp edi,384*2560		
jae GetMouseAction
pop esi
add esi,20h
pop ecx
dec ecx
cmp ecx,0
jnz ShowFileDirIcon
mov dword ptr gs:[IconPageEndFlag],1
jmp ShowIconMouseAction		
InvalidFileDir:
pop edi
jmp ShowFileDirIconNextLine



DrawArrowDown:
pushad
mov ecx,1
mov eax,0
Triangle:
push ecx
push edi
rep stosd
pop edi
sub edi,2564
pop ecx
add ecx,2
cmp ecx,ebx
jnz Triangle
popad
ret


DrawArrowFrame:
pushad
mov ecx,40
mov eax,0ff0000h
ShowArrowFrame:
push ecx
push edi
mov ecx,ebx
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowArrowFrame
popad
ret

DrawArrowUp:
pushad
mov ecx,1
mov eax,0
ReverseTriangle:
push ecx
push edi
rep stosd
pop edi
add edi,2556
pop ecx
add ecx,2
cmp ecx,ebx
jnz ReverseTriangle
popad
ret



GetMouseAction:
pop esi
add esi,32
add dword ptr gs:[IconPagePtr],4
mov eax,gs:[IconPagePtr]
mov fs:[eax],esi
pop ecx

ShowIconMouseAction:
pushad
;mov edi,384*2560+280*4
;mov ebx,80
;call ShowArrowFrame
mov edi,388*2560+320*4
mov ebx,65
call DrawArrowUp

;mov edi,280*4
;mov ebx,80
;call ShowArrowFrame
mov edi,28*2560+320*4
mov ebx,65
call DrawArrowDown

popad
mov bh,1
int 8ch

call GetIconPos
cmp eax,0fffffffeh
jz ShowIconNextPage
cmp eax,0ffffffffh
jz ShowIconParentDir

shl eax,5
add eax,8192
mov esi,eax
mov ax,fs:[esi+20]
shl eax,16
mov ax,fs:[esi+26]
mov gs:[FileCluPtr],eax
mov ebx,fs:[esi+28]
mov gs:[FileSize],ebx
mov ebx,gs:[PartNumPtr]
mov cl,gs:[ebx+Disk0SecPerClu]
movzx ecx,cl
sub eax,gs:[ebx+Disk0FirstClu]
mul ecx
add eax,gs:[ebx+Disk0FdtPtr]
mov gs:[FileSecPtr],eax

mov ebx,gs:[ParentDirPtr]
add ebx,4
mov gs:[ParentDirPtr],ebx
mov fs:[ebx],eax
mov dword ptr gs:[IconPageEndFlag],0
test byte ptr fs:[esi+11],10h
jz FileSubDirEnd
push es
push eax
mov ax,HdBufSeg
mov es,ax
pop eax
mov edi,0
mov bh,0
int 8eh
pop es
jmp ReadFileDirContent



FileSubDirEnd:
pop gs
pop fs
pop es
pop ds
popad
ret



ShowIconNextPage:
cmp dword ptr gs:[IconPageEndFlag],1
jz ShowIconMouseAction
mov eax,gs:[IconPagePtr]
mov esi,fs:[eax]
mov dword ptr gs:[FileDirInfoPtr],8192
mov edi,2560*64+96
call ClearDeskTop
dec ecx
cmp ecx,0
jnz ShowFileDirIcon
mov dword ptr gs:[IconPageEndFlag],1
jmp ShowIconMouseAction



ShowIconParentDir:
call ClearDeskTop
sub dword ptr gs:[ParentDirPtr],4
cmp dword ptr gs:[ParentDirPtr],0
jge ParentDirPtrNotBound
mov dword ptr gs:[ParentDirPtr],0
ParentDirPtrNotBound:
mov ebx,gs:[ParentDirPtr]
mov eax,fs:[ebx]
push es
push eax
mov ax,HdBufSeg
mov es,ax
pop eax
mov ebx,gs:[PartNumPtr]
mov cl,gs:[ebx+Disk0SecPerClu]
movzx ecx,cl
mov edi,0
mov bh,0
int 8eh
pop es
mov dword ptr gs:[IconPageEndFlag],1
mov dword ptr gs:[FileDirInfoPtr],8192
jmp ReadFileDirContent






GetIconPos:
push ecx
push edx
push ebx
push esp
push ebp
push esi
push edi
WaitIconGetClick:
sti
mov bh,0
int 8ch
cmp eax,-1
jz WaitIconGetClick
test eax,1
jz WaitIconGetClick
mov eax,ecx
mov edx,0
mov ecx,64
div ecx
cmp eax,7
jae WaitIconGetClick
cmp eax,0
jz CheckIconPage
cmp eax,6
jz CheckParentDir
dec eax
mov ecx,7
mul ecx
mov edi,eax
mov ecx,7
mov eax,24
CheckVerticleIconPos:
cmp ebx,eax
jb WaitIconGetClick
add eax,64
cmp ebx,eax
jb GetVerticalIconPos
add eax,24
inc edi
loop CheckVerticleIconPos
jmp WaitIconGetClick
GetVerticalIconPos:
mov eax,edi
GetIconPosEnd:
pop edi
pop esi
pop ebp
pop esp
pop ebx
pop edx
pop ecx
ret

CheckIconPage:
cmp edx,40
jae WaitIconGetClick
cmp ebx,280
jb WaitIconGetClick
cmp ebx,360
ja WaitIconGetClick
mov eax,0fffffffeh
jmp GetIconPosEnd

CheckParentDir:
cmp edx,40
jae WaitIconGetClick
cmp ebx,280
jb WaitIconGetClick
cmp ebx,360
ja WaitIconGetClick
mov eax,0ffffffffh
jmp GetIconPosEnd




KbdCommand:
ret


ShowClearKbdPrompt:
push eax
push ecx
push edi
push es
push eax
mov ax,VesaSeg
mov es,ax
pop eax
mov edi,ds:[PromptPos]
mov ecx,8
ShowClearKbdPromptGraph:
push ecx
push edi
mov ecx,8
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowClearKbdPromptGraph
pop es
pop edi
pop ecx
pop eax
ret





DrawIcon:
push eax
push ecx
push edi
push es
push eax
mov ax,VesaSeg
mov es,ax
pop eax
mov ecx,48
DrawFileIcon:
push ecx
push edi
mov ecx,64
rep stosd
add eax,5
pop edi
add edi,2560
pop ecx
loop DrawFileIcon
pop es
pop edi
pop ecx
pop eax
ret






ClearDeskTop:
push eax
push ecx
push ebx
push edi
push es
mov ax,VesaSeg
mov es,ax
mov edi,0
mov ecx,640*448
mov eax,0ffffffffh
cli
rep stosd
pop es
pop edi
pop ebx
pop ecx
pop eax
sti
ret




AdjustMouse:
pushad
push ds
mov ax,ParamSeg
mov ds,ax
mov esi,offset MsgAdjustMouse
mov bh,1
int 82h
cmp eax,0
jnz AdjustMouseEnd
cli
mov dword ptr ds:[MousePacketSize],16
mov dword ptr ds:[MousePacketSequence],0
ResendMouseReset:
call WaitIbe
mov al,0d4h
out 64h,al
call WaitIbe
mov al,0ffh
out 60h,al
call WaitObf
in al,60h
cmp al,0fah
jnz ResendMouseReset
call WaitObf
in al,60h
cmp al,0aah
jnz ResendMouseReset
call WaitObf
in al,60h
call SetMousePort
mov dword ptr ds:[MousePos],2560*240+1280
mov dword ptr ds:[MouseX],320
mov dword ptr ds:[MouseY],240
mov bh,1
int 8ch
sti
AdjustMouseEnd:
pop ds
popad
ret





SetDeskTopBkgrd:
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov esi,offset FileName
mov bh,0
int 8fh
mov ax,HdDataSeg
mov es,ax
mov edi,0
mov bh,1
int 8fh

cld
mov ax,HdDataSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov esi,54
mov edi,2560*447
mov ecx,448
ShowDeskTopBmp:
push ecx
push edi
mov ecx,640
ShowDeskTopBmpLine:
lodsb
stosb
lodsb
stosb
lodsb
stosb
inc edi
loop ShowDeskTopBmpLine
pop edi
sub edi,2560
pop ecx
loop ShowDeskTopBmp

mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov edi,2560*448
mov eax,0
mov ecx,640*16
rep stosd
mov edi,2560*464
mov eax,0ffffffffh
mov ecx,640*16
rep stosd

mov edi,8*2560+32
mov ecx,56
mov eax,0
ShowMyComPuterFrame:
push ecx
push edi
mov ecx,80
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowMyComPuterFrame

mov edi,2560*16+64
mov ecx,36
mov eax,404060h
ShowMyComPuterScreen:
push ecx
push edi
mov ecx,64
rep stosd
pop edi
add edi,2560
pop ecx
add eax,4
loop ShowMyComPuterScreen

mov edi,2560*54+32
mov esi,offset AscMyComputer
ShowAscMyComPuter:
lodsb
cmp al,0
jz ShowAscMyComPuterEnd
mov bh,0
int 82h
add edi,32
jmp ShowAscMyComPuter
ShowAscMyComPuterEnd:
mov bh,1
int 8ch

pop es
pop ds
popad
ret





SetPageTable proc near
push eax
push ecx
push ebx
push edi
push es
mov eax,11600001h
mov cr3,eax
mov ax,PdeSeg
mov es,ax
mov edi,0
mov ebx,4096
mov ecx,1024
mov eax,11700001h
cld
SetPdeEntry:
stosd
add eax,ebx
loop SetPdeEntry

mov ax,PteSeg
mov es,ax
mov edi,0
mov eax,1
mov ebx,4096
mov ecx,100000h
SetPteEntry:
stosd
add eax,ebx
loop SetPteEntry
pop es
pop edi
pop ebx
pop ecx
pop eax
ret
SetPageTable endp





GetHdPortBase proc near
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov es,ax
mov dx,1f6h
mov al,0e0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov dx,1f6h
mov al,0f0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov dx,176h
mov al,0e0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov dx,176h
mov al,0f0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
call GetHdPciPort
mov byte ptr ds:[HdSlaveFlag],0e0h
call GetHdPciPortBase
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov byte ptr ds:[HdSlaveFlag],0f0h
call GetHdPciPortBase
GetHdPortOk:
mov dx,ds:[HdPortBase]
add dx,7
in al,dx
cmp al,50h
jnz GetHdPortOk
mov ax,ds:[HdPortBase]
mov si,ax
mov bh,1
int 83h
mov cx,ax
shl ecx,16
mov ax,si
shr ax,8
mov bh,1
int 83h
mov cx,ax
mov ds:[AscHdPortBase],ecx
mov al,ds:[HdSlaveFlag]
mov bh,1
int 83h
mov word ptr ds:[AscHdSlaveFlag],ax
mov esi,offset MsgHdPortBase
mov bh,1
int 82h
pop es
pop ds
popad
ret




GetHdPciPortBase:
pushad
mov esi,offset HdPciPortBuf
mov ecx,2
CheckHdPciPort:
push ecx
push esi
lodsw
mov dx,ax
add dx,6
mov al,ds:[HdSlaveFlag]
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz FindHdPciPortBase
pop esi
add esi,10
pop ecx
loop CheckHdPciPort
popad
ret
FindHdPciPortBase:
pop esi
pop ecx
add esi,8
lodsw
cmp byte ptr ds:[HdSlaveFlag],0e0h
jz BusMasterPrimary
add ax,8
BusMasterPrimary:
add ax,2
mov ds:[BmHdPortBase],ax
mov byte ptr ds:[SataFlag],1
popad
ret



CheckHdPort:
push ax
push dx
out dx,al

sub dx,4
mov al,1
out dx,al

dec dx
mov al,0
out dx,al

add dx,6
mov al,0ech
out dx,al

call WaitHdResponse
in al,dx
cmp al,58h
jnz CheckHdPortRet
pop dx
pop ax
push ax
push dx
sub dx,6
mov ds:[HdPortBase],dx
mov ds:[HdSlaveFlag],al
push ecx
push edi
mov ecx,100h
mov edi,offset ParamBuf
cld
rep insw
mov ax,word ptr ds:[ParamBuf+5eh]
mov byte ptr ds:[MultiModeSecNum],al
pop edi
pop ecx
CheckHdPortRet:
pop dx
pop ax
ret



WaitHdResponse:
cli
push eax
mov ax,0
WaitTickCount:
in al,40h
cmp al,0
jnz WaitTickCount
inc ah
cmp ah,80h
jnz WaitTickCount
pop eax
sti
ret



GetHdPciPort:
pushad
mov edi,offset HdPciPortBuf
mov eax,80000008h
SearchPciDev:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
shr eax,16
cmp eax,0101h
jnz ReadNextPciDev 
pop eax
push eax
add eax,8
mov ecx,5
Read5Port:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and ax,0fffeh
stosw
pop eax
add eax,4
loop Read5Port
add eax,18h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
cmp ax,0
jz ReadNextPciDev
mov word ptr ds:[HdIntLinePin],ax
ReadNextPciDev:
pop eax
add eax,100h
cmp eax,80010008h
jb SearchPciDev                 ;32 bit jump instruction is all 4G range addressing 
popad
ret
GetHdPortBase endp



Init8259 proc near
cli
push eax
push edx
push ds
mov al,11h
out 20h,al
out 0a0h,al
mov al,20h
out 21h,al
mov al,28h
out 0a1h,al
mov al,4
out 21h,al
mov al,2
out 0a1h,al
mov al,11h
out 21h,al
out 0a1h,al
mov al,0     ;IRQ2 must be enabled!
out 21h,al
mov al,0
out 0a1h,al

mov ax,ParamSeg
mov ds,ax
mov dx,4d0h
in al,dx
mov byte ptr ds:[PicElcr],al
mov al,0
out dx,al
mov dx,4d1h
in al,dx
mov byte ptr ds:[PicElcr+1],al
mov al,0
out dx,al
pop ds
pop edx
pop eax
ret
Init8259 endp



Restore8259  proc near
cli
push eax
push edx
push ds
mov al,11h
out 20h,al
out 0a0h,al
mov al,8
out 21h,al
mov al,70h
out 0a1h,al
mov al,4
out 21h,al
mov al,2
out 0a1h,al
mov al,11h
out 21h,al
out 0a1h,al
mov ax,ParamSeg
mov ds,ax
mov dx,4d0h
mov al,byte ptr ds:[PicElcr]
out dx,al
mov dx,4d1h
mov al,byte ptr ds:[PicElcr+1]
out dx,al
pop ds
pop edx
pop eax
ret
Restore8259 endp



SetSysTimerPort proc near
cli
push eax
mov al,36h
out 43h,al
mov al,0
out 40h,al
out 40h,al
mov al,76h
out 43h,al
mov al,0
out 41h,al
out 41h,al
mov al,0b6h
out 43h,al
mov al,0
out 42h,al
out 42h,al
in al,61h		     ;Port 61h function ???
mov al,3
out 61h,al
pop eax
ret
SetSysTimerPort endp



SetRltPort proc near
cli
push eax
mov al,0bh
out 70h,al
mov al,72h      ;BCD and 24h format
out 71h,al
pop eax
ret
SetRltPort endp



SetMousePort proc near
cli
push eax
call WaitIBE
mov al,0adh
out 64h,al
call WaitIBE
mov al,0a8h
out 64h,al
call WaitIBE
mov al,0d4h
out 64h,al
ResendMouseCom:
call WaitIBE
mov al,0f4h
out 60h,al
call WaitOBF
in al,60h
cmp al,0fah
jnz ResendMouseCom
call WaitIBE
mov al,60h
out 64h,al
call WaitIBE
mov al,47h
out 60h,al
call WaitIBE
mov al,0aeh
out 64h,al
pop eax
ret

WaitOBF:
in al,64h
test al,1
jz WaitOBF
ret
WaitIBE:
in al,64h
test al,2
jnz WaitIBE
ret
SetMousePort endp







PmCode32ProcLenth               equ $-1
PmCode32Proc ends
end start
