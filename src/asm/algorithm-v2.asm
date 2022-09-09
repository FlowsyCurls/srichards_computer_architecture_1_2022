;; nasm -felf64 -o algorithm-v2.o algorithm-v2.asm && ld -o algorithm-v2 algorithm-v2.o && ./algorithm-v2
;; gdb algorithm-v2
;p /t(char[10])ARRAY

%include "linux64.inc"
%include "utils.inc"
section .data
    
    ; in gdb    -   p /t(char[10])ARRAY
    ARRAY TIMES 100 db 0                ; matrix memory allocation
    index       dw 0
    arr_len     dw 100
    arr_col     dw 10
    num_multiplier    db 100

    file_in     db  '../../files/image.txt', 0      ; name of input image file
    file_out    db  '../../files/image-i.txt', 0    ; name of output image file

    ; messages
    msg1 db	'The current ARRAY is:',0xA,0xD 	
    len1 equ $ - msg1

    MULTIPLIER  equ 100

section .bss
; file management
    fd_in       resb    4      ; in file descriptor
    fd_out      resb    4      ; out file descriptor

; sample information
    buffer      resd     1     ; buffer length
    byte_ctr    resd     1     ; current input sample


section .text
        global _start

_start:
    call _openFiles
    call _read
    call _vertical_pixels
    call _closeFiles
    call _exit

; ------
; _read()
; Read file contents
_read:
    mov rax, 3                ; kernel op code 3 sys_read
    mov rbx, [fd_in]          ; store descriptor in rbx
    mov rcx, buffer           ; store input line on rcx
    mov rdx, 4                ; amount of bytes read on rdx
    int 80h                   ; os execute

; load number
    ascii_to_dec buffer, MULTIPLIER        ; return decimal value in rax
    mov  r10b, byte[rdx]      ; read in dl forth byte at pointer rdx (buffer ptr)

;#####################
    push_reg
    call _write
    pop_reg
;######################

b3:
; conditions
    cmp  r10, space             ; compare number in rax to (space ~32) to determine end of num in buffer
    jz   _loadSpace             ; break if analyzed byte is ' ' (end of number)
b4:
    cmp  r10, newline           ; compare number in rax to (new line ~10) to determine end of line in buffer
    jz   _loadNewLine           ; break if analyzed byte is '\n' (end of line)
;loop
    cmp  r10, F                 ; compare number in rax to (F ~70) to determine end of file in buffer
    jne   _read                 ; break if analyzed byte is 'F' (end of file)

    ret

; ------
; _loadSpace():
; Load al into ARRAY[index], also index increase by 3.
_loadSpace:
    load_to_array ARRAY, index  ; load value
    ; bx is pointing to the index from the prev function
    add     bx, 3               ; increment the index by 3.
    mov     [index], bx         ; load new value to index
    jmp     _read

; ------
; _loadNewLine():
; Load al into ARRAY[index], also index increase by 21.
_loadNewLine:
    load_to_array ARRAY, index  ; load value
    ; bx is pointing to the index from the prev function
    add     bx, 21               ; increment the index by 21.
    mov     [index], bx
    jmp     _read




_vertical_pixels:
    ;; calculate vertical pixeles


; ------
; _write():
; Write to file
_write:
    ; write line on file
    mov rax, 4                  ; kernel op code 4 to sys_write
    mov rbx, [fd_out]           ; move file descriptor of out file to ebx
    mov rcx, buffer             ; write contents of line in to new file
    mov rdx, 4                  ; write 6 bytes to new txt file
    int 80h                     ; os execute
    ret


; ------
; _openFiles()
; Open txt files
_openFiles:
    ; open input file
    mov rax, 5          ; kernel code 5 - sys_open
    mov rbx, file_in    ; rbx on file name
    mov rcx, 0          ; rcx on 0 for file on read mode
    mov rdx, 0777       ; exe by all
    int 0x80            ; os execute

    ; store input file descriptor
    mov [fd_in], rax    ; store input file descriptor

    ; open input file
    mov rax, 8          ; kernel code for sys_create
    mov rbx, file_out   ; rbx on file name
    mov rcx, 0          ; rcx on 0 for file on read mode
    mov rdx, 0777o      ; exe by all
    int 0x80            ; os execute

    ; store output file descriptor
    mov [fd_out], rax   ; store output file descriptor

    ret

; ------
; _closeFiles()
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

; ------
; _exit()
; exit system
_exit:
; exit program
    mov rax, 1          ; ID for sys_close
    mov rbx, 0
    int 0x80