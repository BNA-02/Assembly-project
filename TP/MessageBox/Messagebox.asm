.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

.data
Caption  db "Error",0
Text       db "Restart your computer!",0

.code
start:
invoke MessageBox, NULL, addr Text, addr Caption, MB_OK
invoke ExitProcess, NULL
end start