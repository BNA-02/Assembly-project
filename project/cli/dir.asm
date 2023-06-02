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
    dirString db "<DIR>", 0 ; <DIR> string
    formatString db "%u ", 0  ; Format string for file size
    sizeString db 32 dup(?)       ; Buffer for formatted file size
    tabString db "      ", 0  ; Tab character

.CODE

RecursiveSearch proc uses ebx esi edi path:DWORD
    ; print the current directory 
    push path
    call crt_printf
    add esp, 8
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
    test findData.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
    jnz printDir

    invoke crt_printf, offset tabString ; Print a tab for formatting

    ; Print the file size
    mov eax, findData.nFileSizeLow  ; Get the low-order 32 bits of the file size
    invoke crt_printf, offset formatString, eax
    
    ; Print the file name
    jmp printFileName

    ; Print <DIR> in front of directories
printDir:
    invoke crt_printf, offset dirString
    invoke crt_printf, offset tabString ; Print a tab for formatting


    ; Print the name for the files and folders
printFileName:
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

    
getNextFile:
    ; Get the next file
    invoke FindNextFile, ebx, offset findData
    cmp eax, 0
    jne nextFile

    ; Close the search handle
    invoke FindClose, ebx

    ; Restart the search for directories
    invoke FindFirstFile, offset searchPattern, offset findData
    mov ebx, eax ; Store the search handle in ebx

    ; Loop through all directories
nextDirectory:
    ; If the found file is a directory and not "." or "..", call RecursiveSearch recursively
    test findData.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
    jz getNextDirectory

    lea eax, findData.cFileName
    cmp byte ptr [eax], '.'
    je getNextDirectory

    ; Concatenate directory name to the path
    mov esi, path
    lea edi, [buffer]
copyPathLoop:
    lodsb
    stosb
    test al, al
    jnz copyPathLoop

    dec edi

    ; Concatenate "/" and the directory name to the path
    mov byte ptr [edi], '\'
    inc edi
    mov esi, offset findData.cFileName
copyDirectoryNameLoop2:
    lodsb
    stosb
    test al, al
    jnz copyDirectoryNameLoop2

    ; Call RecursiveSearch recursively
    invoke RecursiveSearch, offset buffer

    ; Remove the directory name from the path
    mov edi, offset buffer
    dec edi
removeDirectoryNameLoop:
    cmp byte ptr [edi], '\'
    je removeDirectoryNameDone
    dec edi
    jmp removeDirectoryNameLoop
removeDirectoryNameDone:
    mov byte ptr [edi], 0

getNextDirectory:
    ; Get the next directory
    invoke FindNextFile, ebx, offset findData
    cmp eax, 0
    jne nextDirectory

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
