@echo off
c:\masm32\bin\ml /c /Zd /coff Fibonacci.asm
c:\masm32\bin\Link /SUBSYSTEM:CONSOLE Fibonacci.obj
pause