@echo off
c:\masm32\bin\ml /c /Zd /coff MajRoutine.asm
c:\masm32\bin\Link /SUBSYSTEM:CONSOLE MajRoutine.obj
pause