global adenvel

section .text

adenvel:
    ; filename start at [rsi + 7] because create + " " (0x20)
    ; so need to iterate through rsi until 0x20
    add rsi, 7
    call retrieve_filename_to_create

    ret

retrieve_filename_to_create:
   mov rax, 85
   mov rdi, rsi
   mov rsi, mode
   syscall
   
   ret

section .data
    mode equ 0755   ;Permissions mode (rwxr-xr-x)
