@echo off
c:\masm32\bin\ml /c /Zd /coff Messagebox.asm
c:\masm32\bin\Link /SUBSYSTEM:CONSOLE Messagebox.obj
pause