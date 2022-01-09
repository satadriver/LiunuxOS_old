@echo off
REM Name this file make16.bat
REM Revised 1/21/02

REM Assembling and linking with ML.EXE, along with the book's link library. 
REM 
REM Command-line options (unless otherwise noted, they are case-sensitive):
REM 
REM /Cp         Enforce case-sensitivity for all identifiers
REM /Zi		Include source code line information for debugging
REM /Fm		Generate a MAP file (see page 89)
REM /Fl		Generate a listing file (see page 88)
REM /CODEVIEW   Generate CodeView debugging information (linker)
REM %1.asm      The name of the source file, passed on the command line

REM ************* The following lines can be customized:
path c:\masm615
SET INCLUDE=c:\masm615\include
SET LIB=c:\masm615\lib
REM **************************** End of customized lines

REM Invoke ML.EXE (the assembler):

ML /nologo -c -Fl -Zi seg2.asm seg2a.asm
if errorlevel 1 goto terminate

REM Run the 16-bit linker:

LINK /nologo /CODEVIEW seg2 seg2a,,seg2,Irvine16;
if errorlevel 1 goto terminate

REM Display all files related to this program:
DIR %1.*

:terminate
pause
