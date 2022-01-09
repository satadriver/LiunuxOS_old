TITLE Macro Functions            (HelloNew.asm)

; This program shows how to use macros to configure
; a program to run on multiple platforms.
; Last update: 8/16/01.

INCLUDE Macros.inc
IF IsDefined( RealMode )
	INCLUDE Irvine16.inc
ELSE
	INCLUDE Irvine32.inc
ENDIF

.code
main PROC
	Startup

	mWriteLn "This program can be assembled to run "
	mWriteLn "in both Real mode and Protected mode."

	exit
main ENDP
END main