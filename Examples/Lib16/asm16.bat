@echo off
REM asm16.bat
REM Revised 2/1/02

REM Assemble the current source file
REM 
REM Command-line options (unless otherwise noted, they are case-sensitive):
REM 
REM /nologo	Suppress the Microsoft logo
REM -c		Assemble only (do not link)
REM -Zi		Include source code line information for debugging
REM -Fl		Generate a listing file (see page 88)
REM /CODEVIEW   Generate CodeView debugging information (linker)
REM %1.asm      The name of the source file, passed on the command line

REM ************* The following lines can be customized:
PATH C:\Masm615
SET INCLUDE=C:\Masm615\INCLUDE
REM **************************** End of customized lines

REM Invoke ML.EXE (the assembler):

ML /nologo -c -Fl -Zi %1.asm
