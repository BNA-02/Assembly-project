@echo off
c:\masm32\bin\ml /c /Zd /coff Uppercase.asm
c:\masm32\bin\Link /SUBSYSTEM:CONSOLE Uppercase.obj
pause