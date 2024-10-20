global dizo

section .text

dizo:
    call list_current_directory
    ret

list_current_directory:
; list... [complete subroutines description]
    push rbp
    mov rbp, rsp

    ; get current directory
    xor rax, rax
    mov rax, 79
    lea rdi, [current_directory_path]
    mov rsi, 255
    syscall

    ; open current directory
    xor rax, rax
    mov rax, 2
    mov rsi, 0
    mov rdx, 440
    syscall

    lea rsi, [getdents_struct]
    mov rdi, rax
    mov rdx, 255
    xor rax, rax
    mov rax, 78
    syscall

    call breakdown_getdents_structure

    mov rsp, rbp
    pop rbp

    ret

breakdown_getdents_structure:
    ; From man getdents

    ; struct linux_dirent {
    ;           unsigned long  d_ino;
    ;           unsigned long  d_off;
    ;           unsigned short d_reclen;
    ;           char           d_name[];
    ;                                  
    ;           char           pad;   
    ;           char           d_type;
    ;       }

    ; d_ino    : 8 Bytes This is the inode number of the file or directory.
    ; d_off    : 8 Bytes This offset points to the next directory entry in the buffer. 
    ; d_reclen : 2 Bytes This indicates the length of this directory entry (in bytes).
    ; d_name   : (char) depends on file name. Null terminated string
    ; d_type   : Type of the file This indicates the type of the file (e.g., regular file, directory, etc.).

    ; Retrieve d_name d_type
    ; And pass those arguments to send_message_to_client

    push rbp
    mov rbp, rsp

    xor rcx, rcx
    mov rcx, 18

    ; rax: counter for destination string
    ; rbx: counter for source string (getdents_struct) at 18 bits offset
    ; rdi: holds variable address for future file name
    xor rax, rax
    xor rbx, rbx
    lea rdi, [current_file_name] 
    call iterate_through_file_name

    push rbx

    call send_message_to_client

    mov rsp, rbp
    pop rbp

    ret

iterate_through_file_name:
    ; al : -> rax 8 bits will contains char to compare
    ; rcx: counter
    ; rsi: file_on_path
    ; rdi: file_name
    mov al, [rsi+rcx]
    mov [rdi+rbx], al
    inc rbx
    inc rcx
    cmp al, 0
    jne iterate_through_file_name
    ret

send_message_to_client:

    mov rdx, rbx
    lea rsi, [current_file_name]
    mov rdi, 4
    mov r10, 0
    mov r8, 0
    mov r9, 0
    mov rax, 44

    syscall

    ret

section .bss
    getdents_struct resb 1024
    current_file_name resb 255
    current_directory_path resb 255
