@echo off
c:\masm32\bin\ml /c /Zd /coff CountingLetters.asm
c:\masm32\bin\Link /SUBSYSTEM:CONSOLE CountingLetters.obj
pause