REM  make32.bat -  Batch file for 32-bit assembling and linking to Irvine32.lib

Last update: 2/1/02
By: Kip Irvine

***********************************************************************
REM special version for the LIB32 directory. This batch file links
REM the current program to the IRVINE32.LIB in the current directory
REM (rather than the one in the C:\Masm615\LIB directory.
REM Also, the Irvine32.inc file is used from the current directory.
***********************************************************************

@echo off
cls

PATH C:\Masm615

ml -Zi -c -Fl -coff %1.asm
if errorLevel 1 goto terminate

Link32 %1.obj irvine32.lib kernel32.lib /SUBSYSTEM:CONSOLE /DEBUG
if errorLevel 1 goto terminate

dir %1.*

:terminate

pause