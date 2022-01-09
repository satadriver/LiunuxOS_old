del %1.exe
del %1.obj
del %1.com

masm %1%.asm;
link %1%;
exe2bin.exe %1 %1.com
del %1.obj