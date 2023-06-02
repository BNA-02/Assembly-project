.386
.model flat, stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\msvcrt.lib

.DATA
    buffer db 260 dup(?) ; MAX_PATH = 260
    searchPattern db 260 dup(?)
    findData WIN32_FIND_DATA <>
    newLine db 10, 0 ; '\n' in ASCII is 10

.CODE

RecursiveSearch proc uses ebx esi edi path:DWORD
    ; Print the current directory
    invoke crt_printf, offset buffer
    invoke crt_printf, offset newLine
    
    ; Copy the directory to the search pattern
    mov esi, path
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

    ; If the found file is a directory, call RecursiveSearch recursively
    test findData.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
    jz getNextFile

    ; Skip directories starting with "."
    lea eax, findData.cFileName
    cmp byte ptr [eax], '.'
    je getNextFile

    ; Concatenate directory name to the search pattern
    mov esi, path
    lea edi, [buffer]
copyDirectoryLoop:
    lodsb
    stosb
    test al, al
    jnz copyDirectoryLoop

    dec edi

    ; Concatenate "/" and the directory name to the search pattern
    mov byte ptr [edi], '\'
    inc edi
    mov esi, offset findData.cFileName
copyDirectoryNameLoop:
    lodsb
    stosb
    test al, al
    jnz copyDirectoryNameLoop

    ; Call RecursiveSearch recursively
    invoke RecursiveSearch, offset buffer

getNextFile:
    ; Get the next file
    invoke FindNextFile, ebx, offset findData
    cmp eax, 0
    jne nextFile

    ; Close the search handle
    invoke FindClose, ebx

    ret
searchFailed:
    ret
RecursiveSearch endp

start:
    ; Call GetCurrentDirectory
    invoke GetCurrentDirectory, sizeof buffer, offset buffer

    ; buffer now contains the current directory
    invoke RecursiveSearch, offset buffer

    ; Terminate the program
    invoke ExitProcess, 0

end start
