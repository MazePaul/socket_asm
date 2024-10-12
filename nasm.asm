global _start

section .text

_start:
    call create_socket
    mov [socket_file_descriptor], rax 

    call do_bind

    call do_listen

    call do_accept
    mov [accepted_file_descriptor], rax

    call handle_connection

    xor rdi, rdi
    mov rax, 60
    syscall

handle_connection:
    
    push rbp
    mov rbp, rsp

    ; retrieve the new file descriptor
    mov rdi, [accepted_file_descriptor]

    lea rsi, [client_message]
    mov rdx, 0x10
    mov rax, 45
    mov r10, 0
    mov r8, 0
    mov r9, 0
    syscall

    call send_message

    mov rsp, rbp
    pop rbp

    call handle_connection

    ret

send_message:
    push rbp
    mov rbp, rsp

    mov rsi, msg_received  
    mov rdi, [accepted_file_descriptor]
    mov rdx, 16
    mov r10, 0
    mov r8, 0
    mov r9, 0
    mov rax, 44

    syscall

    mov rsp, rbp
    pop rbp

    ret

do_accept:
    ; int accept(int sockfd, struct sockaddr addr, socklen_t restrict addrlen)
    ; sockfd  : File descriptor created by *create_socket*
    ; addr    : Struct pointer that contains informations of our client
    ; addrlen : Lenght of the strucure
    push rbp
    mov rbp, rsp

    mov rdi, [socket_file_descriptor]                           ; fd created by socket

    ;mov rsi, client_addr ; rsi is the struct pointer
    xor rsi, rsi
    xor rdx, rdx

    mov rax, 43
    syscall

    mov rsp, rbp
    pop rbp

    ret

do_listen:
    ; int listen(int sockfd, int backlog)
    ; sockfd  : File descriptor created by *create_socket*
    ; backlog : argument defines the max length to which the queue of pending connections for sockfd may grow

    push rbp
    mov rbp, rsp

    mov rdi, [socket_file_descriptor] ; fd create by socket
    mov rax, 50                       ; syscall for listen
    mov rsi, 1                        ; backlog
    syscall

    mov rsp, rbp
    pop rbp
    ret

do_bind:
    ; int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
    ; sockfd  : File descriptor created by *create_socket*
    ; addr    : Struct that contains information to bind our socket
    ; addrlen : Length of the structure

    push rbp
    mov rbp, rsp

    ; retrieve sockfd
    mov rdi, [socket_file_descriptor]

    sub rsp, 16
    mov rsi, rsp
    
    ; addr
    mov word [rsi], 0x2             ; AF_INET
    mov word [rsi + 2], 0x7487      ; Port in little endian
    mov dword [rsi + 4], 0x1000007F ; Ipv4 address

    ; addrlen
    mov rdx, 0x10
    mov rax, 49
    syscall

    mov rsp, rbp
    pop rbp
    ret


create_socket:
    ; int socket(int domain, int type, int protocol)
    ; domain   : AF_INET (2) (Ipv4)
    ; type     : SOCK_STREAM (1)
    ; protocol : By default, set to 0

    ; Prologue permits to prepare the stack to store local variable 
    ; Prologue and Epilogue, I do this every time I enter in a new subroutine
    push rbp 
    mov rbp, rsp

    mov rax, 41 ; syscall for socket
    mov rdi, 2  ; AF_INET
    mov rsi, 1  ; SOCKT_STREAM
    xor rdx, rdx
    syscall

    ; Epilogue
    ; Clean the stack before returning to the caller
    mov rsp, rbp
    pop rbp
    ret

section .data
    msg_received db "Message received", 0

section .bss
    ; This is something that I struggled with, so I'll try to be as clear as possible
    ; Addr struct is 16 Bytes long, se we need to reserve 16 Bytes 
    ; First we have the family (ie: AF_INET) 
    ; Secondly, client's port
    ; Thirdly, client's addr
    ; And the we need to add padding of 8 Bytes of zeroes
    client_addr resb 16 ; addr struc to store client informations *WIP*
    client_message resb 16
    socket_file_descriptor resb 1
    accepted_file_descriptor resb 1
