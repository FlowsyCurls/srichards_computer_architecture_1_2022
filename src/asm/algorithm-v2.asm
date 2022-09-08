%include "linux64.inc"
; %include "io.inc"
section .data
    
    ; in gdb    -   p /t(char[10])ARRAY
    ARRAY TIMES 100 db 0                ; matrix memory allocation
    index dw 0

    file_in     db  'image.txt', 0      ; name of input image file
    file_out    db  'image-i.txt', 0    ; name of output image file


section .bss
; file management
    fd_in       resb    4      ; in file descriptor
    fd_out      resb    4      ; out file descriptor

    bufferPtr   resd     1     ; current buffer pointer length
    bufferCtr   resd     1     ; buffer counter to see if it reaches k
    buffer      resd     1  ; buffer length


; sample information
    x_n         resd     1     ; current input sample
    y_n         resd     1     ; current output sample
    y_n_temp    resd     1     ; current output sample copy for string conversion
    k           resd     1     ; k parameter

    resultMulti resd     1     ; multiplication result value


section .text
        global _start

_start:
    call _openFiles
    call _read
    call _closeFiles

_continue:
    call _exit

; ------
; openFiles()
; Open txt files
_openFiles:
    ; open input file
    mov rax, 5          ; kernel code 5 - sys_open
    mov rbx, file_in    ; rbx on file name
    mov rcx, 0          ; rcx on 0 for file on read mode
    mov rdx, 0777       ; exe by all
    int 0x80            ; os execute

    ; store input file descriptor
    mov [fd_in], rax        ; store input file descriptor

    ; open input file
    mov rax, 8          ; kernel code for sys_create
    mov rbx, file_out   ; rbx on file name
    mov rcx, 0          ; rcx on 0 for file on read mode
    mov rdx, 0777o      ; exe by all
    int 0x80            ; os execute

    ; store output file descriptor
    mov [fd_out], rax       ; store output file descriptor

    ret

; ------
; closeFiles()
; Close txt files
_closeFiles:
    ; close input file
    mov rbx, [fd_in]    ; move descriptor to rbx
    mov rax, 6          ; kernel op code 6 sys_close
    int 80h             ; os execute
    
    ; close output file
    mov rax, 6          ; kernel op code 6 sys_close
    mov rbx, [fd_out]   ; move descriptor to rbx
    int 80h             ; os execute
    
    ret

_exit:
; exit program
    mov rax, 1              ; ID for sys_close
    mov rbx, 0
    int 0x80

_read:
; read file contents
    mov rax, 3                ; kernel op code 3 sys_read
    mov rbx, [fd_in]          ; store descriptor in rbx
    mov rcx, buffer           ; store input line on rcx
    mov rdx, 4                ; amount of bytes read on rdx
    int 80h                   ; os execute
    
    cmp rax, 0      ;cmp EOF
_stop:
    je _exit


_append_array:
; append to the array
    ; r12 is pointing to the current element to be summed
    ; mov  rax,3           ;number bytes to be summed
    ; mov  rbx,0           ;EBX will store the sum
    ; mov  r12
    ; add  rbx, [rcx]
    ; inc  r12,1             ;move pointer to next element

loopArray:
    movzx  r12w, [index]       ;rcx will point to the current element to be summed
    mov    cl, byte[buffer]
    mov    byte[ARRAY+r12], cl    ;Give the BX-th array element the value BL
    inc    word[index]
    cmp    word[index], 10
    jb     loopArray
;p /t(char[10])ARRAY
; write to file
_write:
    ; write line on file
    mov rax, 4                  ; kernel op code 4 to sys_write
    mov rbx, [fd_out]           ; move file descriptor of out file to ebx
    mov rcx, buffer             ; write contents of line in to new file
    mov rdx, 4                  ; write 6 bytes to new txt file
    int 80h                     ; os execute

    ; inc r12
    ; mov rax, 0
    ; mov al, byte[rdx]

    jmp _read