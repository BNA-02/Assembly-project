; Set the processor to 80386 instruction set
.386

; Set the memory model to flat and calling convention to stdcall
.model flat, stdcall

.stack 4096

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
    n DWORD 0                            ; Input number
    strFormat db "%d", 0                 ; Format string for input
    inputMsg db "Enter a number: ", 0    ; Message for user input

.code
start:
    push offset inputMsg            ; Push the address of the input message
    call crt_printf                 ; Call printf to display the input message

    ; Read user input
    push offset n                   ; Push the address of the input variable
    push offset strFormat           ; Push the address of the input format string
    call crt_scanf                  ; Call scanf to read the integer

    mov eax, 1                      ; Initialize the result to 1
    mov ecx, n                      ; Move the input number to ecx

    call factorial                  ; Call the factorial function

    ; Display the result
    push eax                        ; Push the result
    push offset formatString        ; Push the format string
    call crt_printf                 ; Call printf to display the result
    add esp, 8                      ; Clean up the stack after printf

    ; Exit the program
    xor eax, eax                    ; Zero out eax (equivalent to mov eax, 0)
    push eax                        ; Push the exit code
    call crt_exit                   ; Call exit

factorial:
    cmp ecx, 1                      ; Compare the input number with 1
    jbe end_factorial               ; If less than or equal to 1, end the factorial calculation

    push ecx                        ; Save the current value of ecx
    dec ecx                         ; Decrement ecx by 1

    call factorial                  ; Recursive call to calculate factorial for the decremented value

    pop ecx                         ; Restore the original value of ecx

    mul ecx                         ; Multiply the result (eax) by ecx

end_factorial:
    ret                             ; Return from the factorial function

formatString db "Factorial: %d", 0

end start

