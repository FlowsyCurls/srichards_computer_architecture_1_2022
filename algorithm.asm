%include "linux64.inc"

section .data
        filename db "cropped.txt",0

section .bss
        text resb 1024
    
section .text
        global _start

_start:
    ; get the filename in ebx
    mov rax, SYS_OPEN       ; ID for sys_open (ID for system call)
    mov rdi, filename       ; Pointer to the zero-terminated string for the file name to open
    mov rsi, O_RDONLY       ; read flag(0)
    mov rdx, 0          ; file permission (o = NASM)
    syscall

; code to read from the opened file.
    push rax
    mov rdi, rax            ; move file descriptor to rdi
    mov rax, SYS_READ       ; ID for sys_read
    mov rsi, text           ; pointer to where text will be stored
    mov rdx, 1023             ; numbers of bytes to read from the file
    syscall

; code to close the opened file.
    mov rax, SYS_CLOSE      ; ID for sys_close
    pop rdi                 ; File descriptor of the file to close
    syscall

    print text
; exit
;     mov   eax,  1           ; exit(
;     mov   ebx,  0           ;   0
;     int   80h               ; );
    exit


