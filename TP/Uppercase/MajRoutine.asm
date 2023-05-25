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
    prompt db "Enter a string: ", 0     ; Prompt for user input
    buffer db 256 dup(0)        ; Hardcoded input string
    newline db 10                       ; Newline character
    uppercase db 256 dup(0)             ; Buffer to store uppercase string


; Define code section
.code
start:
    ; Display prompt
    push offset prompt         ; Push the address of the prompt string
    call crt_printf         ; Call printf

    ; Read user input
    lea eax, buffer       ; Address of the buffer to store user input
    push eax              ; Push the buffer address
    call crt_gets         ; Call gets

    ; Hardcoded input string
    mov edi, offset buffer         ; Source string (hardcoded input)
    mov esi, offset uppercase      ; Destination string (uppercase)

    ; Convert to uppercase
convert_loop:
    mov al, [edi]           ; Get the next character from the source string
    cmp al, 0               ; Check if the character is null (end of string)
    je convert_done         ; If yes, jump to the convert_done label

    cmp al, 'a'             ; Compare the character with 'a'
    jb skip_convert         ; If the character is less than 'a', jump to skip_convert
    cmp al, 'z'             ; Compare the character with 'z'
    ja skip_convert         ; If the character is greater than 'z', jump to skip_convert

    sub al, 32              ; Convert lowercase to uppercase by subtracting 32
    mov [esi], al           ; Store the uppercase character in the destination string

    jmp continue_convert    ; Jump to continue_convert to proceed with the next character

skip_convert:
    mov [esi], al           ; Copy the character as is (already uppercase or not a lowercase letter)

continue_convert:
    inc edi                 ; Increment the source string pointer
    inc esi                 ; Increment the destination string pointer
    jmp convert_loop        ; Jump back to convert_loop to process the next character

convert_done:
    mov byte ptr [esi], 0       ; Null-terminate the destination string

    ; Display the uppercase string
    push offset uppercase     ; Push the address of the uppercase string
    call crt_printf         ; Call printf

    ; Exit the program
    xor eax, eax            ; Zero out eax (equivalent to mov eax, 0)
    xor ebx, ebx            ; Zero out ebx (equivalent to mov ebx, 0)
    push eax                ; Push the exit code
    call crt_exit           ; Call exit

end start                  ; End of the code and specify the entry point
