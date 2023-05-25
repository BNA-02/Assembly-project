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
    buffer db 256 dup(0)      ; Hardcoded input string
    newline db 10                       ; Newline character
    uppercase db 256 dup(0)             ; Buffer to store uppercase string
    resultMsg db 13, 10, "Character count: %d", 0 ; Message format for the result, including new line characters

; Define code section
.code
; Subprogram to convert a string to uppercase
convertToUppercase PROC C uses ebx edi esi, pBuffer:DWORD
    pushad                  ; Save registers

    mov edi, [pBuffer]      ; Source string (input buffer)
    mov esi, edi            ; Destination string (output buffer)

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

    popad                   ; Restore registers
    ret                     ; Return from the subprogram
convertToUppercase ENDP

; Subprogram to count the number of characters in a string
countCharacters PROC C uses ebx edi, pBuffer:DWORD
    pushad                  ; Save registers

    mov edi, [pBuffer]      ; Source string (input buffer)

    mov ecx, 0              ; Counter for the number of characters
    mov al, [edi]           ; Get the first character from the string

count_loop:
    cmp al, 0               ; Check if the character is null (end of string)
    je count_done           ; If yes, jump to the count_done label

    inc ecx                 ; Increment the character count
    inc edi                 ; Move to the next character
    mov al, [edi]           ; Load the next character

    jmp count_loop          ; Jump back to count_loop to process the next character

count_done:
    popad                   ; Restore registers
    mov eax, ecx            ; Move the character count to eax (return value)
    ret                     ; Return from the subprogram
countCharacters ENDP

start:
    ; Display prompt
    push offset prompt         ; Push the address of the prompt string
    call crt_printf         ; Call printf

    ; Read user input
    lea eax, buffer       ; Address of the buffer to store user input
    push eax              ; Push the buffer address
    call crt_gets         ; Call gets

    ; Call the subprogram to count the number of characters
    push offset buffer     ; Push the address of the input buffer
    call countCharacters   ; Call the subprogram to count the characters

    ; Display the uppercase string
    push offset buffer     ; Push the address of the uppercase string
    call convertToUppercase ; Call the subprogram to convert the string to uppercase
    push offset buffer     ; Push the address of the uppercase string
    call crt_printf         ; Call printf

    ; Display the character count
    push eax                ; Push the character count
    push offset resultMsg   ; Push the address of the result message format
    call crt_printf         ; Call printf

    ; Exit the program
    xor eax, eax            ; Zero out eax (equivalent to mov eax, 0)
    xor ebx, ebx            ; Zero out ebx (equivalent to mov ebx, 0)
    push eax                ; Push the exit code
    call crt_exit           ; Call exit

end start                  ; End of the code and specify the entry point
