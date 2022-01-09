REM  make32.bat -  Specific batch file for assembling/linking 
REM  the ModSum program
REM  Revised: 2/1/02

@echo off
cls

REM The following three lines can be customized for your system:
REM ********************************************BEGIN customize
PATH c:\masm615
SET INCLUDE=c:\masm615\include
SET LIB=c:\masm615\lib
REM ********************************************END customize

ML -Zi -c -Fl -coff Sum_main.asm _display.asm _arrysum.asm _prompt.asm
if errorlevel 1 goto terminate

REM add the /MAP option for a map file in the link command.

LINK32 Sum_main.obj _display.obj _arrysum.obj _prompt.obj irvine32.lib kernel32.lib /SUBSYSTEM:CONSOLE /DEBUG
if errorLevel 1 goto terminate

dir %1.*

:terminate
pause