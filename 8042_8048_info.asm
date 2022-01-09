
; intel 8042 芯片，位于主板上，CPU 通过 IO 端口直接和这个芯片通信，获得按键的扫描码或者发送各种键盘命令。
;另一个是 intel 8048 ;芯片或者其兼容芯片，位于键盘中，这个芯片主要作用是从键盘的硬件中得到被按的键所产生的扫描码，与 i8042 通信，控制键盘本身

;向i8042发命令,当命令被发往i8042的时候，命令被放入输入缓冲器，同时引起状态寄存器的 Bit1 置1，表示输入缓冲器满，同时引起状态寄存器的 Bit2 ;置1，表示写入输入缓冲器的是一个命令。
;向i8042发命令的方法，首先，读取状态寄存器，判断bit1，状态寄存器bit1为0，说明输入缓冲器为空，可以写入。保证状态寄存器bit1为0，然后对64h端口进行写操作，写入命令
;间接向i8048发命令,向i8048发命令，是通过写60h端口，而后面发命令的参数，也是写60h端口,向i8042发这些命令，i8042会转发i8048，命令被放入输入缓冲器，同时引起状态寄存器的Bi;t1 置1，表示输入缓冲器满，同时引起状态寄存器的 Bit2 置1，表示写入输入缓冲器的是一个命令。

;i8042如何判断输入缓冲器中的内容是命令还是参数呢。i8042是这样判断的，如果当前状态寄存器的Bit3为1，
;表示之前已经写入了一个命令，那么现在通过写60h端口放入输入缓冲器中的内容，就被当做之前命令的参数，并且引起状态寄存器的 Bit3置0。如果当前状态寄存器的 Bit3 ;为0，表示之前没有写入命令，那么现在通过写60h端口放入输入缓冲器中的内容，就被当做一个间接发往i8048的命令，并且引起状态寄存器的 Bit3置1

;Status Register 状态寄存器 64h,Output Buffer 输出缓冲器 60h,Input Buffer 输入缓冲器 60h,Control Register 控制寄存器 64h
;status register:
;Bit7: PARITY-EVEN(P_E): 从键盘获得的数据奇偶校验错误
;Bit6: RCV-TMOUT(R_T): 接收超时置1（PS:Bit6: 该位兼容芯片改为 0 无超时错误，1 出现超时错误）
;Bit5: TRANS_TMOUT(T_T): 发送超时，置1（PS: Bit5:该位兼容芯片改为 0 鼠标输出缓冲区空， 1 鼠标缓冲区满）
;Bit4: KYBD_INH(K_I): 为1，键盘没有被禁止。为0，键盘被禁止。（PS: Bit4:该位兼容芯片定义可能为 1 禁止与设备通信，为 0 使能与设备通信，一般不影响程序的编写）
;Bit3: CMD_DATA(C_D): 为1，输入缓冲器中的内容为命令，为0，输入缓冲器中的内容为数据。
;Bit2: SYS_FLAG(S_F): 系统标志，加电启动置0，自检通过后置1
;Bit1: INPUT_BUF_FULL(I_B_F): 输入缓冲器满置1，i8042 取走后置0
;Bit0: OUT_BUF_FULL(O_B_F): 输出缓冲器满置1，CPU读取后置0（PS: Bit0: 如果使能中断的话，当数据来时会触发中断，CPU读取后把该位置0，同时i8042自动清除中断）

;Control register:
;Bit7: 保留，应该为0
;Bit6: 将第二套扫描码翻译为第一套
;Bit5: 置1，禁止鼠标
;Bit4: 置1，禁止键盘
;Bit3: 置1，忽略状态寄存器中的 Bit4（PS:Bit3 该位，i8042兼容的芯片可能保留，linux内核自带的i8042芯片驱动没有涉及该位）
;Bit2: 设置状态寄存器中的 Bit2
;Bit1: 置1，enable 鼠标中断
;BitO: 置1，enable 键盘中断


;当计算机启动的时候，BIOS会自动检测鼠标，这个时候它会向鼠标发送0xFF（复位）命令，然后鼠标会自检，并通知主机自检是否正常，然后鼠标就将处于Stream模式，
;此时，鼠标已经开始检测鼠标是否移动及是否有键按下了，但是它不会立即就向主机发送数据，鼠标会等待主机的通知，直到主机给它发送0xF4命令后，它才开始向主机发送数据
;port:
;1 发命令给键盘60h,通过直接将一个Byte写到输入寄存器，就可以实现向键盘发送读定命令的功能
;2 发命令给鼠标(64h,60h)
;首先要向命令寄存器64h写入一个控制命令(D4H)，接着再向输入寄存器60h写入一个命令，这个命令就会被发送给鼠标
;3 发命令给控制器自身
;直接向0x64端口写入命令即可。如果该命令需要参数的话，再接着向输入寄存器所写入参数，如果该命令对应有返回值的话，返回值会放在输出寄存器所

;8042键盘控制器命令(64h)
;20h 准备读取8042芯片的Command Byte；其行为是将当前8042 Command Byte的内容放置于Output Register中，下一个从60H端口的读操作将会将其读取出来。
;60h 准备写入8042芯片的Command Byte；下一个通过60h写入的字节将会被放入Command Byte。(PS:下边与密码有关的命令一般不用，i8042兼容控制器可能会没有实现)
;A4h 测试一下键盘密码是否被设置；测试结果放置在Output Register，然后可以通过60h读取出来。测试结果可以有两种值：FAh=密码被设置；F1h=没有密码。
;A5h 设置键盘密码。其结果被按照顺序通过60h端口一个一个被放置在Input Register中。密码的最后是一个空字节（内容为0）。
;A6h 让密码生效。在发布这个命令之前，必须首先使用A5h命令设置密码。
;AAh 自检。诊断结果放置在Output Register中，可以通过60h读取。55h=OK。
;ADh 禁止键盘接口。Command Byte的bit-4被设置。当此命令被发布后，Keyboard将被禁止发送数据到Output Register。
;AEh 打开键盘接口。Command Byte的bit-4被清除。当此命令被发布后，Keyboard将被允许发送数据到Output Register。
;C0h 准备读取Input Port。Input Port的内容被放置于Output Register中，随后可以通过60h端口读取。
;D0h 准备读取Outport端口。结果被放在Output Register中，随后通过60h端口读取出来。
;D1h 准备写Output端口。随后通过60h端口写入的字节，会被放置在Output Port中。
;D2h 准备写数据到Output Register中。随后通过60h写入到Input Register的字节会被放入到Output ;Register中，此功能被用来模拟来自于Keyboard发送的数据。如果中断被允许，则会触发一个中断。
;0xD3 写鼠标缓冲区命令。把紧随该命令的参数写到输出缓冲区就像是从鼠标接收到的一样。 
;0xD4 写鼠标设备命令。把紧随该命令的参数发给鼠标。


;通过i8042间接给i8048发命令(60h)
;EDh 设置LED。Keyboard收到此命令后，一个LED设置会话开始。
;Keyboard首先回复一个ACK（FAh），然后等待从60h端口写入的LED设置字节，如果等到一个，则再次回复一个ACK，然后根据此字节设置LED。
;然后接着等待 直到等到一个非LED设置字节(高位被设置)，此时LED设置会话结束。
;EEh 诊断Echo。此命令纯粹为了检测Keyboard是否正常，如果正常，当Keyboard收到此命令后，将会回复一个EEh字节。
;F0h 选择Scan code set。Keyboard系统共可能有3个Scan code set。当Keyboard收到此命令后，将回复一个ACK，然后等待一个来自于60h端口的Scan code ;set代码。系统必须在此命令之后发送给Keyboard一个Scan code set代码。当Keyboard收到此代码后，将再次回复一个ACK，然后将Scan code set设置为收到的Scan code ;set代码所要求的。
;F2h 读取Keyboard ID。由于8042芯片后不仅仅能够接Keyboard。此命令是为了读取8042后所接的设备ID。
;设备ID为2个字节，KeyboardID为83ABh。
;PS:现在的一些PS/2键盘可能回复的ID不止两个字节，Intel做的带PS/2键盘鼠标控制器的芯片如83627等在这里可能直接就屏蔽了无用的不符合兼容性的数据，
;对上次软件屏蔽了下层的差异，但如果你用的一些兼容I8042的PS/2控制器没这个功能的话就需要你在linux内核里自己修改了，
;一般在读取ID这一步增加判断是否是键盘，如果是，就把ID写成上边说的KeyboardID就可以了，如果是鼠标，则继续读取ID即可。
;毕竟现在所用的键盘一般都是标准键盘，否则的话，如果驱动收到的ID不正常的话，驱动可能会报错，退出对当前键盘的控制
;当键盘收到此命令后，会首先回复一个ACK，然后，将2字节的Keyboard ID一个一个回复回去。
;F3h 设置Typematic Rate/Delay。当Keyboard收到此命令后，将回复一个ACK。然后等待来自于60h的设置字节。一旦收到，将回复一个ACK，然后将Keyboard Rate/Delay设置为相应的值。
;F4h 清理键盘的Output Buffer。一旦Keyboard收到此命令，将会将Output buffer清空，然后回复一个ACK。然后继续接受Keyboard的击键。
;F5h 设置默认状态(w/Disable)。一旦Keyboard收到此命令，将会将Keyboard完全初始化成默认状态。之前所有对它的设置都将失效——Output buffer被清空，Typematic ;Rate/Delay被设置成默认值。然后回复一个ACK，接着等待下一个命令。需要注意的是，这个命令被执行后，键盘的击键接受是禁止的。如果想让键盘接受击键输入，必须Enable ;Keyboard。
;F6h 设置默认状态。和F5命令唯一不同的是，当此命令被执行之后，键盘的击键接收是允许的。 
;FEh Resend。如果Keyboard收到此命令，则必须将刚才发送到8042 Output ;Register中的数据重新发送一遍。当系统检测到一个来自于Keyboard的错误之后，可以使用自命令让Keyboard重新发送刚才发送的字节。
;FFh Reset Keyboard。如果Keyboard收到此命令，则首先回复一个ACK，然后启动自身的Reset程序，
;并进行自身基本正确性检测（BAT-Basic AssuranceTest。等这一切结束之后，
;将返回给系统一个单字节的结束码（AAh=Success,FCh=Failed），并将键盘的Scan code set设置为2。


comment @
发送到鼠标的命令列表 
0xFF(Reset)：复位鼠标命令。 
0xF6(Set Defaults)：设置鼠标的默认工作模式。 
0xF5(Disable Data Reporting)：禁止鼠标的数据报告功能并复位它的位移算数器。 
0xF4(Enable Data Reporting)： 使能鼠标的数据报告功能并复位它的位移算数器这条命令只对Stream 模式下的数据报告科效。 
0xF3(Set Sample Rate)： 设置鼠标采样率。鼠标用0xFA 回统,然后从主机指入一个或更多字节作为新的采样速率。在收到采样速率后鼠标再次用统答0xFA 回统并复位它的位移算数器。有效的采样速率是10, 20, 40,60, 80, 100和200采样点/秒。 
0xF2(Get Device ID)：  指取鼠标的设备ID。 
0xF0(Set Remote Mode)： 设置鼠标进入Remote模式。 
0xE7设置缩放比例
0xE8 设置分辨率
0xEE(Set Wrap Mode)： 设置鼠标进入Wrap模式。 
0xEC(Reset Wrap Mode)：重设鼠标的工作模式为进入Wrap模式之前的模式。 
0xEB(Read Data)： 指取鼠标采样到的位移数据包。 
0xEA(Set Stream Mode): 设置鼠标的工作模式为Stream 模式
comment

;读到的数据
;00h/FFh 当击键或释放键时检测到错误时，则在Output Bufer后放入此字节，如果Output Buffer已满，则会将Output Buffer的最后一个字节替代为此字节。使用Scan code set ;1时使用00h，Scan code 2和Scan Code 3使用FFh。
;AAh BAT完成代码。如果键盘检测成功，则会将此字节发送到8042 Output Register中。
;EEh Echo响应。Keyboard使用EEh响应从60h发来的Echo请求。
;F0h 在Scan code set 2和Scan code set 3中，被用作Break Code的前缀。
;FAh ACK。当Keyboard任何时候收到一个来自于60h端口的合法命令或合法数据之后，都回复一个FAh。
;FCh BAT失败代码。如果键盘检测失败，则会将此字节发送到8042 Output Register中。
;FEh Resend。当Keyboard任何时候收到一个来自于60h端口的非法命令或非法数据之后，或者数据的奇偶交验错误，都回复一个FEh，要求系统重新发送相关命令或数据。
;83ABh 当键盘收到一个来自于60h的F2h命令之后，会依次回复83h，ABh。83AB是键盘的ID。

;初始化鼠标：
;outportb( 0x64 , 0xa8 ) ;激活鼠标接口
;outportb( 0x64 , 0xd4 ) ;下一个数据发给鼠标
;outportb( 0x60 , 0xf4 ) ;允许鼠标发送数据
;outportb( 0x64 , 0x60 ) ;下一个数据写入鼠标控制寄存器
;outportb( 0x60 , 0x47 ) ;允许键盘和鼠标，使用第一套扫描码，允许中断，
;中断时读0x60端口，总共3个字节。
;第一字节为按键信息以及x,y位移量符号，后两个字节是x，y位移量。


0xaa、0x00是在鼠标重起或者上电时向主机发送的
最简单的初始化就是当鼠标上电自检完成后，主机给鼠标发送一个使能鼠标数据传送命令字节(0xf4)，鼠标就会在默认设置状态下工作。主机也可实现自定义初始化，如：

    复位三次(Snd_CMD(0xff),Snd_CMD(0xff),Snd_CMD(0xff)；

    [设置采样率（采样率为200 ）：Snd_CMD(0xf3)，Snd_CMD(0xc8)；

     设置采样率（采样率为100）：Snd_CMD(0xf3)，Snd_CMD(0x64)；

     设置采样率（采样率为80 ）：Snd_CMD(0xf3)，Snd_CMD(0x50)；]

    设置解析度（2点／毫米）：Snd_CMD(0xe8),Snd_CMD(0x01)；

    设置缩放比例（1:1）: Snd_CMD(0xe6)；

    使能鼠标数据传送: Snd_CMD(0xf4)。鼠标每收到一个命令字节都会给出一个应答字节(0xfa)。
	
	
	comment @

Status Register（状态寄存器）

Bit7: PARITY-EVEN(P_E): 从键盘获得的数据奇偶校验错误
Bit6: RCV-TMOUT(R_T): 接收超时，置1
（PS:Bit6: 该位兼容芯片改为 0 无超时错误， 1 出现超时错误）
Bit5: TRANS_TMOUT(T_T): 发送超时，置1
（PS: Bit5:该位兼容芯片改为 0 鼠标输出缓冲区空， 1 鼠标缓冲区满， linux内核自带的i8042控制器驱动采用该兼容模式的定义编写）
Bit4: KYBD_INH(K_I): 为1，键盘没有被禁止。为0，键盘被禁止。
（PS: Bit4: 该位兼容芯片定义可能为 1 禁止与设备通信，为 0 使能与设备通信，一般不影响程序的编写）
Bit3: CMD_DATA(C_D): 为1，输入缓冲器中的内容为命令，为0，输入缓冲器中的内容为数据。
Bit2: SYS_FLAG(S_F): 系统标志，加电启动置0，自检通过后置1
Bit1: INPUT_BUF_FULL(I_B_F): 输入缓冲器满置1，i8042 取走后置0
Bit0: OUT_BUF_FULL(O_B_F): 输出缓冲器满置1，CPU读取后置0
（PS: Bit0: 如果使能中断的话，当数据来时会触发中断， CPU读取后把该位置0，同时i8042自动清除中断）


Control Register（控制寄存器）

Bit7: 保留，应该为0
Bit6: 将第二套扫描码翻译为第一套
Bit5: 置1，禁止鼠标
Bit4: 置1，禁止键盘
Bit3: 置1，忽略状态寄存器中的 Bit4
（PS:Bit3 该位，i8042兼容的芯片可能保留，linux内核自带的i8042芯片驱动没有涉及该位）
Bit2: 设置状态寄存器中的 Bit2
Bit1: 置1，enable 鼠标中断
BitO: 置1，enable 键盘中断

comment
