.386p 

;why use32 disassemblly error?
Kernel16 Segment public para use16
assume cs:Kernel16

__initDevices proc
call __initSysTimer

call __initCmosRlt16

call __initMousePort

call __init8259

call __enableA20

call __initNMI
ret
__initDevices endp





;端口70H的位7控制NMI 
;bit7 = 0,open NMI,else mask NMI
;enable NMI
;mov al,0
;out 70h,al
__initCmosRlt16 proc

mov al,0ah
out 70h,al

;normal devision,0110 = ABOUT 15ms interruption period,RS must set to invoke a interrupt
mov al,0aah
out 71h,al

mov al,0bh
out 70h,al

;daylight savings time updates ,not BCD, 24h format,all interruption occurred
mov al,7ah
out 71h,al

;These bits store the date of month alarm value. If set to 000000b, then a don’t care state is assumed. The host must configure the date alarm for these bits to do anything

mov al,0dh
out 70h,al

mov al,0
out 71h,al

ret
__initCmosRlt16 endp


;cmos manual:
;0        秒             
;1        秒报警             
;2        分             
;3        分报警          
;4        时             
;5        时报警           
;6        星期             
;7        日             
;8        月             
;9        年             
;A        状态寄存器A     
;B        状态寄存器B     
;C        状态寄存器C     
;D        状态寄存器D    
;E        诊断状态字节(0 正常)     
;F        停止状态字节（0 有市电）              
;10      软盘驱动器类型（位7-4：A驱，位3-0：B驱 1-360KB;2-1.2MB;6-1.44MB;7-720KB）                        
;11      保留
;12      硬盘驱动器类型（位7-4：C驱，位3-0：D驱）
;13      保留   
;14      设备字节（软驱数目，显示器类型，协处理器）
;15      基本存储器低字节 
;16      基本存储器高字节
;17      扩展存储器低字节
;18      扩展存储器高字节
;19      硬盘类型字节（低于15为0）
;1A—2D 	保留
;2E—2F 	CMOS校验和（10-2D各字节和）
;30      扩充存储器低字节
;31      扩充存储器高字节 
;32      日期世纪字节(19H:19世纪)
;33      信息标志
;34—3F 保留(34-0:没有密码;35-3F-密码位置)



__sendMouseCmd proc
push dx
mov dl,al

call __waitPs2In16
;next command send to mouse,not kbd or genenral command
mov al,0d4h
out 64h,al

call __waitPs2In16
mov al,dl
out 60h,al

;任何时候收到一个来自于60h端口的合法命令或合法数据之后，都回复一个FAh
call __waitPs2Out16
in al,60h
cmp al,0fah

pop dx
ret
__sendMouseCmd endp



__initMousePort proc

call __waitPs2In16
;disable keyboard
mov al,0adh
out 64h,al

call __waitPs2In16
;enable mouse interface
mov al,0a8h
out 64h,al

;Enable Data Reporting
mov al,0f4h
call __sendMouseCmd

call __waitPs2In16
;准备写入8042芯片的Command Byte；下一个通过60h写入的字节将会被放入Command Byte
mov al,60h
out 64h,al

call __waitPs2In16
;set control register:scan code set 2,enable kbd and mouse interruptions,self check ok
mov al,47h
out 60h,al

;任何时候收到一个来自于60h端口的合法命令或合法数据之后，都回复一个FAh
call __waitPs2Out16
in al,60h
cmp al,0fah

call __waitPs2In16
;enable keyboard
mov al,0aeh
out 64h,al

ret
__initMousePort endp



__waitPs2Out16 proc
in al,64h
test al,1
jz __waitPs2Out16
ret
__waitPs2Out16 endp



__waitPs2In16 proc
in al,64h
test al,2
jnz __waitPs2In16
ret
__waitPs2In16 endp







;d6 d7 select timer,00 = 40h,01=41h,02 = 42h
;d4 d5 mode:
;11 read read/write low byte first,than read/write high byte
;00 lock the counter,then could read it
;d1 d2 d3 select work mode
;d0 bcd or binary,0=binary,1=bcd
__initSysTimer proc
cli

;timer0,real time interruption
mov al,36h
out 43h,al
mov al,0
;0000 = 10000h,about 55ms tricker once
;first low 8 bits,then high 8 bits
;1.1931816MHZ 1193181.6/23864 = 50hz = 20ms
;mov ax,23864
;闪烁抖动显卡刷新率锁到85Hz以上就行
;75-85
mov ax,11932
;mov eax,0
out 40h,al
mov al,ah
out 40h,al

;timer1,memory flush
mov al,76h
out 43h,al

mov ax,0
out 41h,al
mov al,ah
out 41h,al

;time2,speaker(control from port 61h)
mov al,0b6h
out 43h,al

mov ax,0
out 42h,al
mov al,ah
out 42h,al

ret
__initSysTimer endp



;61h NMI Status and Control Register
__initNMI proc
;bit3:IOCHK NMI Enable (INE): When set, IOCHK# NMIs are disabled and cleared. When cleared, IOCHK# NMIs are enabled.
;bit2:SERR# NMI Enable (SNE): When set, SERR# NMIs are disabled and cleared. When cleared, SERR# NMIs are enabled.
;bit1:Speaker Data Enable (SDE): When this bit is a 0, the SPKR output is a 0. 
;When this bit is a 1, the SPKR output is equivalent to the Counter 2 OUT signal value.
;bit 0:Timer Counter 2 Enable (TC2E): When cleared, counter 2 counting is disabled. When set, counting is enabled.
in al,61h
mov al,3
out 61h,al
ret
__initNMI endp



__readTimerCounter proc
mov al,36h
out 43h,al
in al,40h
mov ah,al
in al,40h
xchg ah,al
ret
__readTimerCounter endp



;icw1-icw4
;icw1 use 20h,a0h,icw2-icw4 use 21h and 0a1h
__init8259 proc
cli

push eax
push edx

in al,21h
mov ah,al
in al,0a1h
xchg ah,al
mov ds:[_rmMode8259Mask],ax

;icw1
mov al,11h
out 20h,al
out 0a0h,al

;icw2
mov al,ICW2_MASTER_INT_NO
out 21h,al
mov al,ICW2_SLAVE_INT_NO
out 0a1h,al

;icw3
mov al,4
out 21h,al
mov al,2
out 0a1h,al

;icw4
;bit4= sfnm,0代表优先级从0到7，只有更高优先级才可以嵌套，同级以及以下不理会
;bit1 = 1,aeoi,auto end interruption,else we need to send 20h to 20h(or 0a0h) to terminate this interruption
;bit0 =1,8086
mov al,1
out 21h,al
MOV AL,1
out 0a1h,al

;ocw1
;set interruption mask
mov al,0	;IRQ2 must be enabled!
or al,40h
out 21h,al
mov al,0h
or al,0c0h
out 0a1h,al

;ELCR1—Master Edge/Level Control Register 4D0h
;ELCR2—Slave Edge/Level Control Register 4D1h

;In edge mode, (bit cleared), the interrupt is recognized by a low to high transition. 
;In level mode (bit set), the interrupt is recognized by a high level.
; The cascade channel, IRQ2, heart beat timer (IRQ0), and keyboard controller (IRQ1), cannot be put into level mode
mov dx,4d0h
in al,dx
mov byte ptr ds:[_rmPicElcr],al
mov al,0
out dx,al

mov dx,4d1h
in al,dx
mov byte ptr ds:[_rmPicElcr+1],al
mov al,0
out dx,al

pop edx
pop eax
ret
__init8259 endp



__restoreDos8259  proc
cli
push edx

mov al,11h
out 20h,al
out 0a0h,al

mov al,ICW2_MASTER_DOSINT_NO
out 21h,al
mov al,ICW2_SLAVE_DOSINT_NO
out 0a1h,al

mov al,4
out 21h,al
mov al,2
out 0a1h,al

mov al,1h
out 21h,al
out 0a1h,al

mov dx,4d0h
mov al,byte ptr ds:[_rmPicElcr]
out dx,al

mov dx,4d1h
mov al,byte ptr ds:[_rmPicElcr+1]
out dx,al

pop edx
ret
__restoreDos8259 endp



__enableA20 proc
;mov ax,0x2401
;int 15h

;in al,0eeh

in al,92h
or al,2
out 92h,al
ret
__enableA20 endp



__disableA20 proc
in al,92h
and al,0fdh
out 92h,al
ret
__disableA20 endp


Kernel16 ends
