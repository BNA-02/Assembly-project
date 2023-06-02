.386
.model flat, stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\msvcrt.lib


STACK_SIZE equ 100   ; Define the size of the stack

.DATA
    buffer db 260 dup(?) ; MAX_PATH = 260
    searchPattern db 260 dup(?)
    findData WIN32_FIND_DATA <>
    newLine db 10, 0 ; '\n' in ASCII is 10
    dirString db "<DIR>", 0 ; <DIR> string
    pathFormat db " Directory of %s", 0 ; Format string for path
    formatString db "%u ", 0  ; Format string for file size
    sizeString db 32 dup(?)       ; Buffer for formatted file size
    tabString db "      ", 0  ; Tab character
    fileCountString db "%u File(s)", 0 ; Format string for file count
    fileCount DWORD ? ; Variable to hold the file count
    folderSize DWORD 0     ; Variable to hold the folder size
    folderSizeString db "    %u bytes", 0 ; Format string for folder size
    dirCountString db "%u Dir(s)", 0 ; Format string for directory count
    dirCount DWORD ? ; Variable to hold the directory count
    totalfilecount DWORD ? ; Variable to hold the total files count
    totalfileSize DWORD 0  ; Variable to hold the total files size
    directoryIndex dd 0            ; Index to keep track of the next available slot in the array
    directoryNames db 256 dup(0) ; Array to store directory names
    stack db STACK_SIZE dup(0)   ; Define the stack as an array of bytes
    stack_top db 0   ; Pointer to the top of the stack

.CODE

RecursiveSearch proc uses ebx esi edi path:DWORD
    ; print the current directory 
    push path
    push offset pathFormat
    call crt_printf
    add esp, 8
    invoke crt_printf, offset newLine
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

    ; Initialize the file count for the directory
    mov esi, 0 ; File count

    ; Loop through all files
nextFile:
    test findData.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
    jnz printDir

    invoke crt_printf, offset tabString ; Print a tab for formatting

    ; Print the file size
    mov eax, findData.nFileSizeLow  ; Get the low-order 32 bits of the file size
    add folderSize, eax
    invoke crt_printf, offset formatString, eax


    ; Increment the file count
    inc fileCount

    ; Print the file name
    jmp printFileName

    ; Print <DIR> in front of directories
printDir:
    invoke crt_printf, offset dirString
    invoke crt_printf, offset tabString ; Print a tab for formatting

    inc dirCount

    ; Increment the file count
    inc esi

    ; Save the directory name in the global variable
    mov eax, offset findData.cFileName
    pushad

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

    ; Check if the search was successful
    cmp eax, INVALID_HANDLE_VALUE
    je searchFailed

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

    ; Print the number of files
    invoke crt_printf, offset fileCountString, fileCount
    mov edx,fileCount
    add totalfilecount,edx
    mov fileCount,0
    
    ; Print the size of the folder
    invoke crt_printf, offset folderSizeString, folderSize
    invoke crt_printf, offset newLine
    invoke crt_printf, offset newLine
    mov edx,folderSize
    add totalfileSize,edx
    mov folderSize,0

    
    ; Call RecursiveSearch recursively
    invoke RecursiveSearch, offset buffer

    ; Remove the directory name from the path
    mov edi, offset buffer
    dec edi

getNextDirectory:
    ; Get the next directory
    invoke FindNextFile, ebx, offset findData
    cmp eax, 0
    jne nextDirectory

    ; Close the search handle
    invoke FindClose, ebx

    ; Print the number of files
    invoke crt_printf, offset fileCountString, fileCount
    invoke crt_printf, offset folderSizeString, folderSize
    invoke crt_printf, offset newLine
    invoke crt_printf, offset newLine

    ; Add the fileCount to the totalfilecount
    mov edx,fileCount
    add totalfilecount,edx

    ; Add the folderSize to the totalfileSize
    mov edx,folderSize
    add totalfileSize,edx
    mov folderSize,0
    mov fileCount,0

    invoke crt_printf, offset fileCountString, totalfilecount
    invoke crt_printf, offset folderSizeString, totalfileSize
    invoke crt_printf, offset newLine
    invoke crt_printf, offset dirCountString, dirCount
    invoke crt_printf, offset newLine

    ret
searchFailed:
    cmp eax, 0
    jle noPreviousDirectory

    ; Get the directory name from the stack
    pop eax

    ; Perform recursive search on the directory
    invoke RecursiveSearch, eax

    ; Handle the result of the recursive search if necessary

    ret

noPreviousDirectory:
    ; Handle the case when there are no previous directory names in the array
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