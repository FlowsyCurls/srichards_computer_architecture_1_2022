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

    ;; array para guardar vaores
    

section .text
        global _start

_start:
;     call _rw
;     call _exit

; _rw:
;     call _read
;     call _write
;     ; call _print
    
;     ret

; _read:
    ; ## intentar poner lo de readnextline.
    ; open file
    mov  rax, 5                ; kernel code for sys_open file
    mov  rbx, file_in           ; ebx on file name
    mov  rcx, 0                ; ecx on 0 for file on read mode
    mov  rdx, 0777       ; exe by all
    int  80h                   ; os execute
    
    ; store input file descriptor
    mov     [fd_in], rax        ; store input file descriptor
    
_read:
; read file contents
    mov     rax, 3                ; kernel op code 3 sys_read
    mov     rbx, [fd_in]          ; store descriptor in rbx
    mov     rcx, buff             ; store input line on rcx
    mov     rdx, 1                ; amount of bytes read on rdx
    int     80h                   ; os execute
    
    
    cmp rax, 0      ;cmp EOF
    je _exit

    jmp _write

_write:
; write to file
    ; create file
    mov     rcx, 0777o            ; set permissions to read, write and execute
    mov     rbx, file_out     ; file name to create
    mov     rax, 8                ; kernel opcode 8 sys_create
    int     80h                   ; os execute
    
    ; ; store audio 
    mov     [fd_out], rax       ; store output file descriptor

    ; ; write line on file
    mov     rax, 4                  ; kernel op code 4 to sys_write
    mov     rbx, 1           ; move file descriptor of out file to ebx
    mov     rcx, buff               ; write contents of line in to new file
    mov     rdx, 1                 ; write 6 bytes to new txt file
    int     80h                     ; os execute
    
    ; ;print  
    ; mov rax, 4      ;sys call write
    ; mov rbx, 1      ;std out
    ; mov rcx, buff
    ; mov rdx, 1
    ; int 0x80

    jmp _read

; ; ------
; ; closeFiles()
; ; Close txt files
; _closeFiles:
;     ; close input file
;     mov     rbx, [fd_in]       ; move descriptor to ebx
;     mov     rax, 6               ; kernel op code 6 sys_close
;     int     80h                  ; os execute
    
;     ; close output file
;     mov     rbx, [fd_out]      ; move descriptor to ebx
;     mov     rax, 6               ; kernel op code 6 sys_close
;     int     80h                  ; os execute
    
;     ret


    
_exit:
; exit program
    mov rax, 1              ; ID for sys_close
    ; mov rbx, 0
    int 80h
    

    ; mov al, byte[text]
    ; add al, '0'         ; character code




_print:
    print buff

; exit
;     mov   eax,  1           ; exit(
;     mov   ebx,  0           ;   0
;     int   80h               ; );
    ; exit

    


