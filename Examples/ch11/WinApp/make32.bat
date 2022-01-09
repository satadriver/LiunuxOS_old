REM  make32.bat -  Custom batch file for assembling/linking the 
REM  WinApp.asm program.
REM  Revised: 2/1/01

@echo off
cls

REM The following three lines can be customized for your system:
REM ********************************************BEGIN customize
PATH C:\Masm615
SET INCLUDE=C:\Masm615\include
SET LIB=C:\Masm615\lib
REM ********************************************END customize

ML -Zi -c -Fl -coff %1.asm
if errorlevel 1 goto terminate

REM add the /MAP option for a map file in the link command.

LINK32 %1.obj kernel32.lib user32.lib /SUBSYSTEM:WINDOWS
if errorLevel 1 goto terminate

dir %1.*

:terminate
pause