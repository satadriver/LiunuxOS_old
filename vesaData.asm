VESAInformation struc					;//共256字节
	ModeAttr 			dw ?			;//模式的属性
	WinAAttr 			db ?			;//
	WinBAttr 			db ?			;//窗口A,B的属性
	WinGran  			dw ?			;位面大小(窗口粒度),以KB为单位
	WinSize  			dw ?			;窗口大小,以KB为单位
	WinASeg  			dw ?			;窗口A的起始段址
	WinBSeg  			dw ?			;窗口B的起始段址
	BankFunc 			dd ?		  	;换页调用入口指针
;16
	BytesPerScanLine 	dw ?		;每条水平扫描线所占的字节数
	XRes 				dw ?		;
	YRes 				dw ?		;水平,垂直方向的分辨率
	XCharSize 			db ?		;
	YCharSize 			db ?		;字符的宽度和高度
	NumberOfplanes 		db ?		;位平面的个数
;25
	BitsPerPixel 		db ?		;每像素的位数
	NumberOfBanks 		db ?    	;CGA逻辑扫描线分组数
	MemoryModel 		db ?		;显示内存模式
	BankSize 			db ?		;CGA每组扫描线的大小
	NumberOfImagePages 	db ?		;可同时载入的最大满屏图像数
	reserve_1 			db ?		;为页面功能保留
;31
	;对直接写颜色模式的定义区域
	RedMaskSize 		db ?		;红色所占的位数
	RedFieldPosition 	db ?		;红色的最低有效位位置
	GreenMaskSize 		db ?		;绿色所占位数
	GreenFieldPosition 	db ?		;绿色的最低有效位位置
	BlueMaskSize 		db ?		;蓝色所占位数
	BlueFieldPosition 	db ?		;蓝色最低有效位位置
	RsvMaskSize 		db ?		;保留色所占位数
	RsvFieldPosition 	db ?		;保留色的最低有效位位置
	DirectColorModeInfo db ?		;直接颜色模式属性
;40
	;以下为VBE2.0版本以上定义
	PhyBasePtr 				dd ?		;可使用的大的帧缓存时为指向其首址的32位物理地址
	OffScreenMenOffset 		dd ?		;帧缓存首址的32位偏移量
	OffScreenMemSize 		dw ?		;可用的,连续的显示缓冲区,以KB为单位
;50
	;以下为VBE3.0版以上定义
	LinBytesPerScanLine 	dw ?		;线形缓冲区中每条扫描线的长度,以字节为单位
	BnkNumberOfImagePages 	db ?		;使用窗口功能时的显示页面数
	LinNumberOfImagePages 	db ?		;使用大的线性缓冲区时的显示页面数
	LinRedMaskSize 			db ?		;使用大的线性缓冲区时红色所占位数
	LinRedFieldPosition 	db ?		;使用大的线性缓冲区时红色最低有效位位置
	LinGreenMaskSize 		db ?		;使用大的线性缓冲区时绿色所占的位数
	LinGreenFieldPosition 	db ?		;使用大的线性缓冲区时绿色最低有效位位置
	LinBlueMaskSize 		db ?		;使用大的线性缓冲区时蓝色所占的位数
	LinBlueFieldPosition 	db ?		;使用大的线性缓冲区时蓝色最低有效位位置
	LinRsvMaskSize 			db ?		;使用大的线性缓冲区时保留色所占位数
	LinRsvFieldPosition 	db ?		;使用大的线性缓冲区时保留色最低有效位位置
;62
	reserve_2				db 194 dup (?)	;保留
VESAInformation ends