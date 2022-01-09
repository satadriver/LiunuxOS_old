
;windows

;16位偏移的段间直接转移指令的宏定义(在16位代码段中使用)

;----------------------------------------------------------------------------

JUMP16 MACRO Selector,Offsetv

	DB 0eah ;操作码

	DW Offsetv ;16位偏移量

	DW Selector ;段值或段选择子

ENDM

;----------------------------------------------------------------------------

;32位偏移的段间直接转移指令的宏定义(在32位代码段中使用)

;----------------------------------------------------------------------------

COMMENT <JUMP32>

JUMP32 MACRO Selector,Offsetv

	DB 0eah ;操作码

	DD Offsetv

	DW Selector ;段值或段选择子

ENDM

<JUMP32>

;-------------------------------------------------

JUMP32 MACRO Selector,Offsetv

	DB 0eah ;操作码

	DW Offsetv

	DW 0

	DW Selector ;段值或段选择子

ENDM

;----------------------------------------------------------------------------

;门描述符结构类型定义

;----------------------------------------------------------------------------

Gate STRUC

	OffsetL DW 0 ;32位偏移的低16位

	Selector DW 0 ;选择子

	DCount DB 0 ;双字计数

	GType DB 0 ;类型

	OffsetH DW 0 ;32位偏移的高16位

Gate ENDS

;----------------------------------------------------------------------------

 

;16位偏移的段间调用指令的宏定义(在16位代码段中使用)

;----------------------------------------------------------------------------

CALL16 MACRO Selector,Offsetv

	DB 9ah ;操作码

	DW Offsetv ;16位偏移量

	DW Selector ;段值或段选择子

ENDM

;----------------------------------------------------------------------------

;32位偏移的段间调用指令的宏定义(在32位代码段中使用)

;----------------------------------------------------------------------------

COMMENT <CALL32>

CALL32 MACRO Selector,Offsetv

	DB 9ah ;操作码

	DD Offsetv

	DW Selector ;段值或段选择子

ENDM

<CALL32>

;-------------------------------------------------

CALL32 MACRO Selector,Offsetv

	DB 9ah ;操作码

	DW Offsetv

	DW 0

	DW Selector ;段值或段选择子

ENDM

;----------------------------------------------------------------------------

;存储段描述符结构类型定义

;----------------------------------------------------------------------------

Desc STRUC

	LimitL DW 0 ;段界限(BIT0-15)

	BaseL DW 0 ;段基地址(BIT0-15)

	BaseM DB 0 ;段基地址(BIT16-23)

	Attributes DB 0 ;段属性

	LimitH DB 0 ;段界限(BIT16-19)(含段属性的高4位)

	BaseH DB 0 ;段基地址(BIT24-31)

Desc ENDS

;----------------------------------------------------------------------------

 

 

;伪描述符结构类型定义(用于装入全局或中断描述符表寄存器)

;----------------------------------------------------------------------------

PDesc STRUC

	Limit DW 0 ;16位界限

	Base DD 0 ;32位基地址

PDesc ENDS

;----------------------------------------------------------------------------

;任务状态段结构类型定义

;----------------------------------------------------------------------------

TSS STRUC

	TRLink 	DW 0 ;链接字段

		DW 0 ;不使用,置为0

	TRESP0 	DD 0 ;0级堆栈指针

	TRSS0 	DW 0 ;0级堆栈段寄存器	

		DW 0 ;不使用,置为0

	TRESP1 	DD 0 ;1级堆栈指针

	TRSS1 	DW 0 ;1级堆栈段寄存器

		DW 0 ;不使用,置为0

	TRESP2 	DD 0 ;2级堆栈指针

	TRSS2 	DW 0 ;2级堆栈段寄存器

		DW 0 ;不使用,置为0

	TRCR3 	DD 0 ;CR3

	TREIP 	DD 0 ;EIP

	TREFlag DD 0 ;EFLAGS

	TREAX 	DD 0 ;EAX

	TRECX 	DD 0 ;ECX

	TREDX 	DD 0 ;EDX

	TREBX 	DD 0 ;EBX

	TRESP 	DD 0 ;ESP

	TREBP 	DD 0 ;EBP

	TRESI 	DD 0 ;ESI

	TREDI 	DD 0 ;EDI

	TRES 	DW 0 ;ES

		DW 0 ;不使用,置为0

	TRCS 	DW 0 ;CS

		DW 0 ;不使用,置为0

	TRSS 	DW 0 ;SS

		DW 0 ;不使用,置为0

	TRDS 	DW 0 ;DS

		DW 0 ;不使用,置为0

	TRFS 	DW 0 ;FS

		DW 0 ;不使用,置为0

	TRGS 	DW 0 ;GS

		DW 0 ;不使用,置为0

	TRLDTR 	DW 0 ;LDTR

		DW 0 ;不使用,置为0

	TRTrip 	DW 0 ;调试陷阱标志(只用位0)

	TRIOMap DW $+2 ;指向I/O许可位图区的段内偏移

		DB 0ffh                      ;I/O许可位图结束标志

TSS ENDS

;----------------------------------------------------------------------------

 

;存储段描述符类型值说明

;----------------------------------------------------------------------------

D32 EQU 40h ;32位代码段标志

ATDR EQU 90h ;存在的只读数据段类型值

ATDW EQU 92h ;存在的可读写数据段属性值

ATDWA EQU 93h ;存在的已访问可读写数据段类型值

ATCE EQU 98h ;存在的只执行代码段属性值

ATCER EQU 9ah ;存在的可执行可读代码段属性值

 

;----------------------------------------------------------------------------

;系统段描述符类型值说明

;----------------------------------------------------------------------------

ATLDT EQU 82h ;局部描述符表段类型值

 

;----------------------------------------------------------------------------

;DPL值说明

;----------------------------------------------------------------------------

DPL0 EQU 00h ;DPL=0

DPL1 EQU 20h ;DPL=1

DPL2 EQU 40h ;DPL=2

DPL3 EQU 60h ;DPL=3

;----------------------------------------------------------------------------

;RPL值说明

;----------------------------------------------------------------------------

RPL0 EQU 00h ;RPL=0

RPL1 EQU 01h ;RPL=1

RPL2 EQU 02h ;RPL=2

RPL3 EQU 03h ;RPL=3

;----------------------------------------------------------------------------

 

;----------------------------------------------------------------------------

;其它常量值说明

;----------------------------------------------------------------------------

 

TIL EQU 04h ;TI=1(局部描述符表标志)

AT386TSS EQU 89h ;可用386任务状态段类型值

AT386CGate EQU 8ch ;386调用门类型值

ATTaskGate EQU 85h ;任务门类型值

;----------------------------------------------------------------------------

 

.386p

 

GDTSeg          SEGMENT PARA USE16                ;全局描述符表数据段(16位)

;----------------------------------------------------------------------------

                ;全局描述符表

GDT             LABEL   BYTE

                ;空描述符

DUMMY           Desc    <>

                ;规范段描述符及选择子

Normal          Desc    <0ffffh,,,ATDW,,>

Normal_Sel      =       Normal-GDT

                ;视频缓冲区段描述符(DPL=3)及选择子

VideoBuf        Desc    <0ffffh,8000h,0bh,ATDW+DPL3,,>

Video_Sel       =       VideoBuf-GDT

;----------------------------------------------------------------------------

EFFGDT          LABEL   BYTE

                ;演示任务的局部描述符表段的描述符及选择子

DemoLDTab       Desc    <DemoLDTLen-1,DemoLDTSeg,,ATLDT,,>

DemoLDT_Sel     =       DemoLDTab-GDT

                ;演示任务的任务状态段描述符及选择子

DemoTSS         Desc    <DemoTSSLen-1,DemoTSSSeg,,AT386TSS,,>

DemoTSS_Sel     =       DemoTSS-GDT

                ;临时任务的任务状态段描述符及选择子

TempTSS         Desc    <TempTSSLen-1,TempTSSSeg,,AT386TSS+DPL2,,>

TempTSS_Sel     =       TempTSS-GDT

                ;临时代码段描述符及选择子

TempCode        Desc    <0ffffh,TempCodeSeg,,ATCE,,>

TempCode_Sel    =       TempCode-GDT

                ;子程序代码段描述符及选择子

SubR            Desc    <SubRLen-1,SubRSeg,,ATCE,D32,>

SubR_Sel        =       SubR-GDT

;----------------------------------------------------------------------------

GDNum           =       ($-EFFGDT)/(SIZE Desc)    ;需处理基地址的描述符个数

GDTLen          =       $-GDT                     ;全局描述符表长度

;----------------------------------------------------------------------------

GDTSeg          ENDS                              ;全局描述符表段定义结束

;----------------------------------------------------------------------------

DemoLDTSeg      SEGMENT PARA USE16                ;局部描述符表数据段(16位)

;----------------------------------------------------------------------------

DemoLDT         LABEL   BYTE                      ;局部描述符表

                ;0级堆栈段描述符(32位段)及选择子

DemoStack0      Desc    <DemoStack0Len-1,DemoStack0Seg,,ATDW,D32,>

DemoStack0_Sel  =       DemoStack0-DemoLDT+TIL

                ;2级堆栈段描述符(32位段)及选择子

DemoStack2      Desc    <DemoStack2Len-1,DemoStack2Seg,,ATDW+DPL2,D32,>

DemoStack2_Sel  =       DemoStack2-DemoLDT+TIL+RPL2

                ;演示任务代码段描述符(32位段,DPL=2)及选择子

DemoCode        Desc    <DemoCodeLen-1,DemoCodeSeg,,ATCE+DPL2,D32,>

DemoCode_Sel    =       DemoCode-DemoLDT+TIL+RPL2

                ;演示任务数据段描述符(32位段,DPL=3)及选择子

DemoData        Desc    <DemoDataLen-1,DemoDataSeg,,ATDW+DPL3,D32,>

DemoData_Sel    =       DemoData-DemoLDT+TIL

                ;把LDT作为普通数据段描述的描述符(DPL=2)及选择子

ToDLDT          Desc    <DemoLDTLen-1,DemoLDTSeg,,ATDW+DPL2,,>

ToDLDT_Sel      =       ToDLDT-DemoLDT+TIL

                ;把TSS作为普通数据段描述的描述符(DPL=2)及选择子

ToTTSS          Desc    <TempTSSLen-1,TempTSSSeg,,ATDW+DPL2,,>

ToTTSS_Sel      =       ToTTSS-DemoLDT+TIL

;----------------------------------------------------------------------------

DemoLDNum       =       ($-DemoLDT)/(SIZE Desc)   ;需处理基地址的LDT描述符数

;----------------------------------------------------------------------------

                ;指向子程序SubRB代码段的调用门(DPL=3)及选择子

ToSubR          Gate    <SubRB,SubR_Sel,,AT386CGate+DPL3,>

ToSubR_Sel      =       ToSubR-DemoLDT+TIL+RPL2

                ;指向临时任务Temp的任务门(DPL=3)及选择子

ToTempT         Gate    <,TempTSS_Sel,,ATTaskGate+DPL3,>

ToTempT_Sel     =       ToTempT-DemoLDT+TIL

;----------------------------------------------------------------------------

DemoLDTLen      =       $-DemoLDT

;----------------------------------------------------------------------------

DemoLDTSeg      ENDS                              ;局部描述符表段定义结束

;----------------------------------------------------------------------------

DemoTSSSeg      SEGMENT PARA USE16                ;任务状态段TSS

;----------------------------------------------------------------------------

                DD      0                         ;链接字

                DD      DemoStack0Len                ;0级堆栈指针

                DW      DemoStack0_Sel,0             ;0级堆栈选择子

                DD      0                         ;1级堆栈指针(实例不使用)

                DW      0,0                       ;1级堆栈选择子(实例不使用)

                DD      0                         ;2级堆栈指针

                DW      0,0                       ;2级堆栈选择子

                DD      0                         ;CR3

                DW      DemoBegin,0                 ;EIP

                DD      0                         ;EFLAGS

                DD      0                         ;EAX

                DD      0                         ;ECX

                DD      0                         ;EDX

                DD      0                         ;EBX

                DD      DemoStack2Len                ;ESP

                DD      0                         ;EBP

                DD      0                         ;ESI

                DD      320                       ;EDI

                DW      Video_Sel,0                 ;ES

                DW      DemoCode_Sel,0               ;CS

                DW      DemoStack2_Sel,0             ;SS

                DW      DemoData_Sel,0               ;DS

                DW      ToDLDT_Sel,0                 ;FS

                DW      ToTTSS_Sel,0                ;GS

                DW      DemoLDT_Sel,0               ;LDTR

                DW      0                         ;调试陷阱标志

                DW      $+2                       ;指向I/O许可位图

                DB      0ffh                      ;I/O许可位图结束标志

DemoTSSLen      =       $-DemoTSSSeg

;----------------------------------------------------------------------------

DemoTSSSeg      ENDS                              ;任务状态段TSS结束

;----------------------------------------------------------------------------

DemoStack0Seg   SEGMENT PARA USE32                ;演示任务0级堆栈段(32位段)

DemoStack0Len   =       1024

                DB      DemoStack0Len DUP(0)

DemoStack0Seg   ENDS                              ;演示任务0级堆栈段结束

;----------------------------------------------------------------------------

DemoStack2Seg   SEGMENT PARA USE32               ;演示任务2级堆栈段(32位段)

DemoStack2Len   =       512

                DB      DemoStack2Len DUP(0)

DemoStack2Seg   ENDS                              ;演示任务2级堆栈段结束

;----------------------------------------------------------------------------

DemoDataSeg     SEGMENT PARA USE32                ;演示任务数据段(32位段)

Message         DB      'Value=',0

DemoDataLen     =       $-DemoDataSeg

DemoDataSeg     ENDS                              ;演示任务数据段结束

;----------------------------------------------------------------------------

SubRSeg         SEGMENT PARA USE32                ;子程序代码段(32位)

                ASSUME  CS:SubRSeg

;----------------------------------------------------------------------------

SubRB           PROC    FAR

                push    ebp

                mov     ebp,esp

                pushad                            ;保护现场

                mov     esi,DWORD PTR [ebp+12]    ;从0级栈中取出显示串偏移

                mov     ah,4ah                    ;设置显示属性

                jmp     SHORT SubR2

SubR1:          stosw

SubR2:          lodsb

                or      al,al

                jnz     SubR1

                mov     ah,4eh                    ;设置显示属性

                mov     edx,DWORD PTR [ebp+16]    ;从0级栈中取出显示值

                mov     ecx,8

SubR3:          rol     edx,4

                mov     al,dl

                call    HToASCII

                stosw

                loop    SubR3

                popad

                pop     ebp

                ret     8

SubRB           ENDP

;----------------------------------------------------------------------------

HToASCII        PROC

                and     al,0fh

                add     al,90h

                daa

                adc     al,40h

                daa

                ret

HToASCII        ENDP

;----------------------------------------------------------------------------

SubRLen         =       $-SubRSeg

SubRSeg         ENDS                              ;子程序代码段结束

;----------------------------------------------------------------------------

DemoCodeSeg     SEGMENT PARA USE32                ;演示任务的32位代码段

                ASSUME  CS:DemoCodeSeg,DS:DemoDataSeg

;----------------------------------------------------------------------------

DemoBegin       PROC    FAR

                ;把要复制的参数个数置入调用门

                mov     BYTE PTR fs:ToSubR.DCount,2

                ;向2级堆栈中压入参数

                push    DWORD PTR gs:TempTask.TREIP

                push    OFFSET Message

                ;通过调用门调用SubRB

                CALL32  ToSubR_Sel,0

                ;把指向规范数据段描述符的选择子填入临时任务TSS

                ASSUME  DS:TempTSSSeg

                push    gs

                pop     ds

                mov     ax,Normal_Sel

                mov     WORD PTR TempTask.TRDS,ax

                mov     WORD PTR TempTask.TRES,ax

                mov     WORD PTR TempTask.TRFS,ax

                mov     WORD PTR TempTask.TRGS,ax

                mov     WORD PTR TempTask.TRSS,ax

                ;通过任务门切换到临时任务

                JUMP32  ToTempT_Sel,0

                jmp     DemoBegin

DemoBegin       ENDP

DemoCodeLen     =       $-DemoCodeSeg

;----------------------------------------------------------------------------

DemoCodeSeg     ENDS                              ;演示任务的32位代码段结束

;----------------------------------------------------------------------------

TempTSSSeg      SEGMENT PARA USE16                ;临时任务的任务状态段TSS

TempTask        TSS     <>

                

TempTSSLen      =       $-TempTSSSeg

TempTSSSeg      ENDS

;----------------------------------------------------------------------------

TempCodeSeg     SEGMENT PARA USE16                ;临时任务的代码段

                ASSUME  CS:TempCodeSeg

;----------------------------------------------------------------------------

Virtual         PROC    FAR

                mov     ax,TempTSS_Sel            ;装载TR

                ltr     ax

                JUMP16  DemoTSS_Sel,0             ;直接切换到演示任务

                clts                              ;清任务切换标志

                mov     eax,cr0                   ;准备返回实模式

                and     al,11111110b

                mov     cr0,eax

                JUMP16  <SEG Real>,<OFFSET Real>

Virtual         ENDP

;----------------------------------------------------------------------------

TempCodeSeg     ENDS

;============================================================================

RDataSeg        SEGMENT PARA USE16                ;实方式数据段

VGDTR           PDesc   <GDTLen-1,>               ;GDT伪描述符

SPVar           DW      ?                         ;用于保存实方式下的SP

SSVar           DW      ?                         ;用于保存实方式下的SS

RDataSeg        ENDS

;----------------------------------------------------------------------------

RCodeSeg        SEGMENT PARA USE16

                ASSUME  CS:RCodeSeg,DS:RDataSeg,ES:RDataSeg

;----------------------------------------------------------------------------

Start           PROC

                mov     ax,RDataSeg

                mov     ds,ax

                cld

                call    InitGDT                   ;初始化全局描述符表GDT

                mov     ax,DemoLDTSeg

                mov     fs,ax

                mov     si,OFFSET DemoLDT

                mov     cx,DemoLDNum

                call    InitLDT                   ;初始化局部描述符表LDT

                mov     SSVar,ss

                mov     SPVar,sp

                lgdt    FWORD PTR VGDTR           ;装载GDTR并切换到保护方式

                cli

                mov     eax,cr0

                or      al,1

                mov     cr0,eax

                JUMP16  <TempCode_Sel>,<OFFSET Virtual>

Real:           mov     ax,RDataSeg

                mov     ds,ax

                lss     sp,DWORD PTR SPVar        ;又回到实方式

                sti

                mov     ax,4c00h

                int     21h

Start           ENDP

;----------------------------------------------------------------------------

InitGDT         PROC

                push    ds

                mov     ax,GDTSeg

                mov     ds,ax

                mov     cx,GDNum

                mov     si,OFFSET EFFGDT

InitG:          mov     ax,[si].BaseL

                movzx   eax,ax

                shl     eax,4

                shld    edx,eax,16

                mov     WORD PTR [si].BaseL,ax

                mov     BYTE PTR [si].BaseM,dl

                mov     BYTE PTR [si].BaseH,dh

                add     si,SIZE Desc

                loop    InitG

                pop     ds

                mov     bx,16

                mov     ax,GDTSeg

                mul     bx

                mov     WORD PTR VGDTR.Base,ax

                mov     WORD PTR VGDTR.Base+2,dx

                ret

InitGDT         ENDP

;----------------------------------------------------------------------------

;入口参数:FS:SI=第一个要初始化的描述符,CX=要初始化的描述符数

;----------------------------------------------------------------------------

InitLDT         PROC

                mov     ax,WORD PTR fs:[si].BaseL

                movzx   eax,ax

                shl     eax,4

                shld    edx,eax,16

                mov     WORD PTR fs:[si].BaseL,ax

                mov     BYTE PTR fs:[si].BaseM,dl

                mov     BYTE PTR fs:[si].BaseH,dh

                add     si,SIZE Desc

                loop    InitLDT

                ret

InitLDT         ENDP

;----------------------------------------------------------------------------

RCodeSeg        ENDS

                END     Start
