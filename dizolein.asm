global dizo

section .text

dizo:
    call list_current_directory
    ret

list_current_directory:
    ; list... [complete subroutines description]
    push rbp
    mov rbp, rsp

    sub rsp, 8

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

    ; get directory entries
    lea rsi, [getdents_struct]
    mov rdi, rax
    mov rdx, 1024
    xor rax, rax
    mov rax, 78
    syscall

    ; On gcwd call success, rax, will hold the number of bytes read
    mov [rsp], rax ; We gonna store it to use it later
    xor rcx, rcx   ; Make sure rcx set to 0 to use it as a counter
    xor r11, r11

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

    sub rsp, 24                     ; allocating space to store local variables

    xor rcx, rcx
    add rcx, 18                     ; rcx points now to the file name from this very structure
    
    xor rax, rax                    ; rax: counter for destination string
    xor rbx, rbx                    ; rbx: counter for source string (getdents_struct) at 18 bits offset
    lea rdi, [current_file_name]    ; rdi: holds variable address for future file name
    call iterate_through_file_name

    mov [rsp + 16], r11

    mov [rsp], rcx                  ; Store the counter in the stack
    mov [rsp + 8], rsi              ; Store the buffer entry directories
    call send_message_to_client
    
    mov r11, [rsp + 16]
    
    cmp r11, [rsp + 40]             ; We need to compare rcx with the value store in [rsp] being the total bytes read
    je breakdown_struct_ends

    ; Points rcx to the next structure in the buffer
    ; rcx: points to d_type in current struct
    ; rbx: holds the size of the file name
    ; 2 bytes for the length of the directory 
    ; poping rcx is useless thus store it in stack too
    pop rcx ; to remove
    pop rsi                 ; Directory entries buffer (containing structure)
    movzx rcx, word[rsi+16] ; Retrieving length of current structure
    add rsi, rcx

    pop r11
    add r11, rcx

    mov rsp, rbp
    pop rbp

    ; Recursive call to iterate through current directory
    ; WARNING: might be a problem because of the stack, if it has too much files on the directory, 
    ; thus it might increase the stack too much and cause a stack overflow, but I have to check it out
    jne breakdown_getdents_structure


breakdown_struct_ends:
    ; Epilogue
    mov rsp, rbp
    pop rbp

    ret

iterate_through_file_name:
    ; al : -> rax 8 bits will contains char to compare
    ; rcx: counter inside the structure
    ; rsi: file_on_path
    ; rdi: file_name
    ; rbx: length of the current string
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

    ; Send the newline character
    mov rdx, 1               ; Length of the newline (1 byte)
    lea rsi, [newline]       ; Load address of the newline
    mov rdi, 4               ; File descriptor 
    mov rax, 44              
    syscall                  

    ret

section .data
    newline db 0x0A

section .bss
    getdents_struct resb 1024
    current_file_name resb 255
    current_directory_path resb 255
