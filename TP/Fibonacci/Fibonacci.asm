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
    resultMsg db "Result: %d", 0   ; Format string for result output

; Define code section
.code
fibonacci PROC C uses ebx edi esi, n:DWORD
    pushad                  ; Save registers

    cmp [n], 0              ; Compare n with 0
    jl fibonacci_negative   ; If n is less than 0, jump to fibonacci_negative

    mov ecx, [n]            ; Move the value of n into ecx
    mov eax, 1              ; Initialize the first Fibonacci number (F(0)) with 1
    mov ebx, 1              ; Initialize the second Fibonacci number (F(1)) with 1

    cmp ecx, 0              ; Compare n with 0
    jle fibonacci_done      ; If n is less than or equal to 0, jump to fibonacci_done

fibonacci_loop:
    add eax, ebx            ; Add F(i-1) and F(i), store the result in eax
    xchg eax, ebx           ; Swap the values of eax and ebx

    dec ecx                 ; Decrement n
    jnz fibonacci_loop      ; If n is not zero, jump to fibonacci_loop

fibonacci_done:
    ret                     ; Return from the function

fibonacci_negative:
    xor eax, eax            ; Set the result to 0
    ret                     ; Return from the function
fibonacci ENDP

start:
    ; Calculate the Fibonacci number for n = -3
    mov eax, 5              ; Value of n = -3
    invoke fibonacci, eax           ; Call the fibonacci function

    ; Store the result in a variable
    mov ebx, eax             ; Move the result value into ebx

    ; Display the result
    push ebx                 ; Push the result value
    push offset resultMsg    ; Push the address of the result message format
    call crt_printf          ; Call printf
    add esp, 8               ; Clean up the stack after the printf call

    ; Exit the program
    xor eax, eax             ; Zero out eax (equivalent to mov eax, 0)
    xor ebx, ebx             ; Zero out ebx (equivalent to mov ebx, 0)
    push eax                 ; Push the exit code
    call crt_exit            ; Call exit

end start                   ; End of the code and specify the entry point
