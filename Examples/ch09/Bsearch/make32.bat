REM  make32.bat -  Batch file for assembling/linking 32-bit Assembly programs
REM  Revised: 11/3/01

@echo off
cls

REM The following three lines can be customized for your system:
REM ********************************************BEGIN customize
PATH c:\masm615
SET INCLUDE=c:\masm615\include
SET LIB=c:\masm615\lib
REM ********************************************END customize

ML -Zi -c -Fl -coff B_main.asm Bsort.asm FillArry.asm PrtArry.asm BSearch.asm
if errorlevel 1 goto terminate

REM add the /MAP option for a map file in the link command.

LINK32 B_main.obj Bsearch.obj Bsort.obj FillArry.obj PrtArry.obj irvine32.lib kernel32.lib /SUBSYSTEM:CONSOLE /DEBUG
if errorLevel 1 goto terminate

dir %1.*

:terminate
pause