REM makeLib.bat

REM by Kip Irvine
REM Last update: 2/1/02

REM Adds Irvine32.obj to the IRVINE32.LIB link library
REM Requires the 32-bit LIB.EXE program in the Microsoft Visual Studio directory.
REM (Microsoft does not supply this program with MASM.)

@ECHO OFF
cls

REM *** You must edit the following path to match your own system *****

SET EXEPATH="d:\ProgramFiles2000\Microsoft Visual Studio\VC98\BIN\LIB" 


%EXEPATH% /SUBSYSTEM:CONSOLE Irvine32.obj


:terminate
SET EXEPATH=
pause