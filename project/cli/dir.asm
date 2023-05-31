.386
.model flat, stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\gdiplus.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\msvcrt.lib

.DATA
    buffer db 260 dup(?) ; MAX_PATH = 260
    searchPattern db 260 dup(?)
    findData WIN32_FIND_DATA <>
    newLine db 10, 0 ; '\n' in ASCII is 10

.CODE
start:
    ; Call GetCurrentDirectory
    invoke GetCurrentDirectory, sizeof buffer, offset buffer
    
    ; buffer now contains the current directory

    ; Copy the directory to the search pattern
    lea esi, [buffer]
    lea edi, [searchPattern]
copyLoop:
    lodsb
    stosb
    test al, al
    jnz copyLoop

    ; Subtract 1 from edi because stosb incremented edi after copying the null terminator
    dec edi

    ; Concatenate "/*" to the search pattern
    mov byte ptr [edi], '\'
    inc edi
    mov byte ptr [edi], '*'
    inc edi
    mov byte ptr [edi], 0

    invoke crt_printf, addr searchPattern  

    ; Start file search
    invoke FindFirstFile, offset searchPattern, offset findData
    mov ebx, eax ; Store the search handle in ebx

    ; Check if the search was successful
    cmp eax, INVALID_HANDLE_VALUE
    je searchFailed

    ; Loop through all files
nextFile:
    ; Print the file name
    invoke crt_printf, offset findData.cFileName
    invoke crt_printf, offset newLine

    ; Get the next file
    invoke FindNextFile, ebx, offset findData
    cmp eax, 0
    jne nextFile

    ; Close the search handle
    invoke FindClose, ebx

searchFailed:
    ; Terminate the program
    invoke ExitProcess, 0

end start
