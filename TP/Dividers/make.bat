@echo off
c:\masm32\bin\ml /c /Zd /coff Dividers.asm
c:\masm32\bin\Link /SUBSYSTEM:CONSOLE Dividers.obj
pause