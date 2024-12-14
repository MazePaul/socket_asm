global skriven


section .text

skriven:
    ; need to write to client
    ; Filename start at [rsi + 4] "get" + " "
    add rsi, 4
    call open_file
    mov [fd], rax
    call read_file
    call write_file_to_client

    ret

open_file:
    mov rdi, rsi
    mov rsi, 2
    mov rax, 2
    syscall

    ret

read_file:
    mov rdi, 5
    lea rsi, [file_content]
    mov rdx, 1024
    mov rax, 0
    syscall

    ret

write_file_to_client:
    mov rdi, 4
    lea rsi, [file_content]
    mov rdx, 1024
    mov r10, 0
    mov r8, 0
    mov r9, 0
    mov rax, 44
    syscall

    ret

section .bss
    file_content resb 2048
    fd           resb 1
