masm kernel.asm;
masm kutils.asm;
masm kvideo.asm;
masm kintr.asm;
masm kdevice.asm;
masm kpower.asm;
masm kmemory.asm;


link kernel.obj kutils.obj kvideo.obj kdevice.obj kpower.obj kmemory.obj kintr.obj ;
