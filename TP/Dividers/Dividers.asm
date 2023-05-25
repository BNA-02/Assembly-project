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
    inputString DWORD 0                  ; Input number
    strFormat db "%d", 0                 ; Format string for input
    inputMsg db "Enter a number: ", 0    ; Message for user input
    strMsgSortie db "Divisors of the chosen number: ", 0 ; Message for output
    strSortie db "%d ", 0                ; Format string for divisor output

; Define code section
.code
start:
    push offset inputMsg            ; Push the address of the input message
    call crt_printf                 ; Call printf to display the input message

    ; Read user input
    push offset inputString         ; Push the address of the input variable
    push offset strFormat           ; Push the address of the input format string
    call crt_scanf                  ; Call scanf to read the integer

    push offset strMsgSortie        ; Push the address of the output message
    call crt_printf                 ; Call printf to display the output message

    mov eax, 1                      ; Initialize the counter
    mov [ebp-4], eax                ; Move the input number to ebx

for_loop:
    mov ebx, inputString
    cmp [ebp-4], ebx                ; Compare the counter with the input number
    jg end_for                      ; If greater, exit the loop

    xor edx, edx                    ; Clear the high 32 bits of edx for division
    mov eax, inputString            ; Move the input to eax
    mov ecx, [ebp-4]
    div ecx                         ; Divide the input number by the counter
    
    cmp edx, 0                      ; Compare the remainder with 0
    je afficher                     ; If not zero, jump to next_divisor

    ; Increment the counter
    mov eax,[ebp-4]                 ; Move the current counter value to EAX
    inc eax                         ; Increment the value in EAX by 1
    mov [ebp-4], eax                ; Store the incremented value back to the counter
    jmp for_loop                    ; Jump back to the beginning of the loop

afficher:
    push [ebp-4]                    ; Push the current counter value onto the stack
    push offset strSortie           ; Push the address of the divisor output format string
    call crt_printf                 ; Call printf to display the output and wait
    mov eax,[ebp-4]                 ; Move the current counter value to EAX
    inc eax                         ; Increment the value in EAX by 1
    mov [ebp-4], eax                ; Store the incremented value back to the counter
    jmp for_loop                    ; Jump back to the beginning of the loop

end_for:
    invoke ExitProcess, NULL       ; Quit the program

end start
