@echo off
REM Special version of make16.bat used only for the HelloNew.asm 
REM program in Chapter 10.
REM Revised 2/1/02

REM ************* The following lines can be customized:
path c:\Masm615
SET INCLUDE=c:\Masm615\include
SET LIB=c:\Masm615\lib
REM **************************** End of customized lines

REM Invoke ML.EXE (the assembler):

ML /nologo -c -Zi -Fl -DRealMode=1 %1.asm
if errorlevel 1 goto terminate

REM Run the 16-bit linker:

LINK /nologo /CODEVIEW %1,,NUL,Irvine16;
if errorlevel 1 goto terminate

REM Display all files related to this program:
DIR %1.*

:terminate
pause
