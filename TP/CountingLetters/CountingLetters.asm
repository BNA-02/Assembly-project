; Set the processor to 80386 instruction set
.386

; Set the memory model to flat and calling convention to stdcall
.model flat, stdcall

; Disable case sensitivity for symbols
option casemap:none

; Include necessary header files
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib

; Define data section
.data
    wordMsg db "Enter a word: ", 0     ; Prompt for user input
    buffer db 256 dup(0)                ; Buffer to store the word
    countMsg db "Count of 'a': %d", 13, 10, 0 ; Format string for count output
    countMsgB db "Count of 'b': %d", 13, 10, 0 ; Format string for count output
    countMsgC db "Count of 'c': %d", 13, 10, 0 ; Format string for count output
    aCount DWORD ?
    bCount DWORD ?
    cCount DWORD ?

; Define code section
.code
countLetters PROC C uses ebx edi esi
    ; Initialize local variables
    mov aCount, 0
    mov bCount, 0
    mov cCount, 0

    ; Iterate through the word
    mov edi, OFFSET buffer  ; Set edi to point to the beginning of the word

count_loop:
    cmp byte ptr [edi], 0               ; Check for end of string
    je count_done                       ; If equal, jump to count_done

    cmp byte ptr [edi], 'a'             ; Compare the character with 'a'
    je increment_a                      ; If equal, jump to increment_a

    cmp byte ptr [edi], 'b'             ; Compare the character with 'b'
    je increment_b                      ; If equal, jump to increment_b

    cmp byte ptr [edi], 'c'             ; Compare the character with 'c'
    je increment_c                      ; If equal, jump to increment_c

    jmp next_character                  ; Jump to next_character to process the next character

increment_a:
    inc aCount                          ; Increment 'a' count
    jmp next_character                  ; Jump to next_character to process the next character

increment_b:
    inc bCount                          ; Increment 'b' count
    jmp next_character                  ; Jump to next_character to process the next character

increment_c:
    inc cCount                          ; Increment 'c' count
    jmp next_character                  ; Jump to next_character to process the next character

next_character:
    inc edi                             ; Increment the word pointer
    jmp count_loop                      ; Jump back to count_loop to process the next character

count_done:
    ret                                 ; Return from the function

countLetters ENDP

start:
    ; Display prompt to enter a word
    push offset wordMsg                 ; Push the address of the prompt message
    call crt_printf                     ; Call printf

    ; Read user input
    lea eax, buffer                     ; Address of the buffer to store user input
    push eax                            ; Push the buffer address
    call crt_gets                       ; Call gets

    ; Call the countLetters function
    call countLetters

    ; Print the letter counts
    push aCount                          ; Push 'a' count
    push offset countMsg                 ; Push the address of the count message format
    call crt_printf                     ; Call printf

    ; Print the letter counts
    push bCount                          ; Push 'b' count
    push offset countMsgB                ; Push the address of the count message format
    call crt_printf                     ; Call printf

    ; Print the letter counts
    push cCount                          ; Push 'c' count
    push offset countMsgC                ; Push the address of the count message format
    call crt_printf                     ; Call printf

    ; Exit the program
    xor eax, eax                        ; Zero out eax (equivalent to mov eax, 0)
    push eax                            ; Push the exit code
    call crt_exit                       ; Call exit

end start                               ; End of the code and specify the entry point
