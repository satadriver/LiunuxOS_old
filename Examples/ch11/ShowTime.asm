TITLE  Calculate Elapsed Time           (ShowTime.asm)


INCLUDE Irvine32.inc

.data
sysTime SYSTEMTIME <>

.code
main PROC
	INVOKE GetLocalTime,ADDR sysTime



	exit
main ENDP
END main