%include "linux64.inc"
; %include "io.inc"
section .data
    file_in    db  'image.txt', 0                   ; name of input image file
    file_out   db  'image-i.txt', 0      ; name of output image file

section .bss
    ; file management
    fd_in       resb     4     ; in file descriptor
    fd_out      resb     4     ; out file descriptor
    buff        resb     1     ; store input line

    ;; array para guardar valores.
    

section .text
        global _start

_start:
    call _rw
    ; call _exit

_rw:
    call _read
    ; call _write
    ; call _print
    
    ret

_read:
    ; ## intentar poner lo de readnextline.


; open file
    ; mov     rcx, 0                ; rcx on 0 for file on read mode
    ; mov     rbx, file_in      ; rbx on file name
    ; mov     rax, 5                ; kernel code for sys_open file
    ; int     80h                   ; os execute

    ;open the file
    mov rax, 5          ;sys call open
    mov rbx, file_in  ;file name  
    mov rcx, 0          ;read only
    mov rdx, 0777       ; exe by all
    int 0x80

    ; store input file descriptor
    mov     [fd_in], rax        ; store input file descriptor


    ; ; seek place in file
    ; mov     rdx, 0                ; seek end 0 - start from beggining
    ; mov     rcx, 0                ; move the cursor 0 bytes
    ; mov     rbx, [fd_in]        ; move file descriptor to rbx
    ; mov     rax, 19               ; kernel opcode 19 for sys_lseek
    ; int     80h                   ; os execute


; read file contents
_loop:
    mov     rax, 3                ; kernel op code 3 sys_read
    mov     rbx, [fd_in]          ; store descriptor in rbx
    mov     rcx, buff             ; store input line on rcx
    mov     rdx, 1                ; amount of bytes read on rdx
    int     0x80                   ; os execute

    cmp rax, 0      ;cmp EOF
    je _exit


    ;print  
    mov rax, 4      ;sys call write
    mov rbx, 1      ;std out
    mov rcx, buff
    mov rdx, 1
    int 0x80

    jmp _loop

    ; ; open file
    ; mov rax, SYS_OPEN       ; ID for sys_open (ID for system call)
    ; mov rdi, file_in         ; Pointer to the zero-terminated string for the file name to open
    ; mov rsi, O_RDONLY       ; read flag(0)
    ; mov rdx, 0              ; file permission (o = NASM)
    ; syscall

    ; ; store input file descriptor
    ; mov [fd_in], rax        ; store input file descriptor

    ; ; read file contents
    ; mov rdi, [fd_in]      ; move file descriptor to rdi
    ; mov rax, SYS_READ       ; ID for sys_read
    ; mov rsi, buff           ; pointer to where text will be stored
    ; mov rdx, 30              ; numbers of bytes to read from the file
    ; syscall

_exit:
; exit program
    mov rax, 1              ; ID for sys_close
    ; mov rbx, 0
    int 0x80

_write:
; write to file
    ; create file
    ; mov     rcx, 0777o            ; set permissions to read, write and execute
    ; mov     rbx, file_out     ; file name to create
    ; mov     rax, 8                ; kernel opcode 8 sys_create
    ; int     80h                   ; os execute
    
    ; ; store audio 
    ; mov     [fd_out], rax       ; store output file descriptor

    ; ; write line on file
    ; mov     rdx, 15                ; write 6 bytes to new txt file
    ; mov     rcx, buff           ; write contents of line in to new file
    ; mov     rbx, [fd_out]       ; move file descriptor of out file to rbx
    ; mov     rax, 4                ; kernel op code 4 to sys_write
    ; int     80h                   ; os execute


    ; mov rax, SYS_OPEN
    ; mov rdi, file_out
    ; mov rsi, O_CREAT+O_WRONLY
    ; mov rdx, 0777o
    ; syscall

    ; ; store output file descriptor
    ; mov [fd_out], rax        ; store input file descriptor

    ; ; write line on file
    ; mov rdi, [fd_out]     ; move file descriptor to rdi
    ; mov rax, SYS_WRITE      ; ID for sys_write
    ; mov rsi, buff           ; 
    ; mov rdx, 16
    ; syscall
    
    ; ret


; ; ------
; ; closeFiles()
; ; Close txt files
; _closeFiles:
;     ; close input file
;     mov     rbx, [fd_in]       ; move descriptor to rbx
;     mov     rax, 6               ; kernel op code 6 sys_close
;     int     80h                  ; os execute
    
;     ; close output file
;     mov     rbx, [fd_out]      ; move descriptor to rbx
;     mov     rax, 6               ; kernel op code 6 sys_close
;     int     80h                  ; os execute
    
;     ret


    

    

    ; mov al, byte[text]
    ; add al, '0'         ; character code




; _print:
;     print buff

; exit
;     mov   rax,  1           ; exit(
;     mov   rbx,  0           ;   0
;     int   80h               ; );
    ; exit

    


