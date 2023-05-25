@echo off
c:\masm32\bin\ml /c /Zd /coff Factorial.asm
c:\masm32\bin\Link /SUBSYSTEM:CONSOLE Factorial.obj
pause