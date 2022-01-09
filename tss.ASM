

TASKSTATESEG struc
	mPrev 		dd 0		;0
	mEsp0 		dd 0		;4
	mSs0		dd 0		;8
	mEsp1 		dd 0		;12
	mSs1		dd 0		;16
	mEsp2		dd 0		;20
	mSs2		dd 0		;24
	mCr3		dd 0		;28
	mEip		dd 0		;32
	mEflags		dd 0		;36					
	mEax		dd 0		;40
	mEcx		dd 0		;44
	mEdx		dd 0		;48
	mEbx		dd 0		;52
	mEsp		dd 0		;56
	mEbp		dd 0		;60
	mEsi		dd 0		;64
	mEdi		dd 0		;68
	mEs			dd 0		;72
	mCs			dd 0		;76
	mSs			dd 0		;80
	mDs			dd 0		;84
	mFs			dd 0		;88
	mGs			dd 0		;92
	mLdt		dd 0		;96
	mTrap		dw 0		;100
	mIomap		dw 0		;102 此地址是在TSS中以0为起始的偏移量
	mIomapEnd	db 0ffh		;104
	;vmIntMap	db	32 dup (0)
TASKSTATESEG ends


TSSINFO struc
pid				dd 0
tssSize 		dd 0
tssFlag			dd 0
filePath		db 256 dup (0)
tss 			TASKSTATESEG <0>
tssIoMapEnd		db 0
TSSINFO ends


;处理器在进行端口读写时，若当前特权级CPL低于IO特权级IOPL时，
;如果有I/O位图的话，处理器会在I/O位图中检查端口相应的bit是否为0。若在某个端口中读取多个字节，
;处理器必然会检查连续的多个端口在I/O位图中对应的多个bit，这些bit必须都得为0 才允许访问它们。
;连续的多个bit也许会跨字节，比如端口0x234对应的bit在前一个字节的最后一位，0x235对应的bit在后一个字节的第0位，这样处理器必须将这两个字节都读进来处理。
;大多数情况下跨字节都没问题，但当第1个bit在位图的最后一个字节时就会出问题，处理器要读进多个字节，
;所以，第2个bit所在的字节就越界了，该字节已经不属于位图范围