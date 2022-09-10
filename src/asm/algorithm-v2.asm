;; nasm -felf64 -o algorithm-v2.o algorithm-v2.asm && ld -o algorithm-v2 algorithm-v2.o && ./algorithm-v2
;; gdb algorithm-v2
;p /t(char[10])ARRAY

%include "linux64.inc"
%include "utils.inc"

section .text
        global _start

_start:
    call _openFiles
    call _read
    ; call _vertical_pixels
    call _write
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

; conditions
    cmp  r10, space             ; compare number in rax to (space ~32) to determine end of num in buffer
    jz   _loadSpace             ; break if analyzed byte is ' ' (end of number)

    cmp  r10, newline           ; compare number in rax to (new line ~10) to determine end of line in buffer
    jz   _loadNewLine           ; break if analyzed byte is '\n' (end of line)
;loop

    cmp  r10, F                 ; compare number in rax to (F ~70) to determine end of file in buffer
    jne   _read                 ; break if analyzed byte is 'F' (end of file)

    load_to_array ARRAY, index  ; load value
    ret

; ------
; _loadSpace():
; Load al into ARRAY[index], also index increase by 3.
_loadSpace:
    load_to_array ARRAY, index  ; load value
    ; bx is pointing to the index from the prev function
    add     bx, 0x3               ; increment the index by 3.
    mov     [index], bx         ; load new value to index

    jmp     _read

; ------
; _loadNewLine():
; Load al into ARRAY[index], also index increase by 21.
_loadNewLine:
    load_to_array ARRAY, index  ; load value
    ; bx is pointing to the index from the prev function
    add     bx, 0x15               ; increment the index by 21.
    mov     [index], bx
    jmp     _read

_vertical_pixels:
    ;; calculate vertical pixeles


; ------
; _write():
; Write to output file
_write:
    mov r15, 1                  ; set counter to 1 - 0 is module of any number, to prevent new line we start in 1
    mov rax, 0                  ; clear rax
    mov rcx, 0                  ; clear rcx
    mov rbx, 0                  ; clear rbx
    mov rdx, 0                  ; clear rdx
    mov r14, ARRAY              ; save pointer to initial value in array
_writing:
    mov al, byte[r14]           ; current value to analyze
    push_reg
; get ascii value

    dec_to_ascii                  ; return array address in rax
a:    call _writeASCII_3digits

; writing new line
    movzx ecx, word[ARRAY_ROWS]     ; save number of rows to know when to make new line.
    mov rax, r15                    ; move counter value to rax
    mov rdx, 0                      ; reset rdx to prevent error in division
    div rcx                         ; EDX =   0 = 97 % 97  (remainder)
    cmp dx, 0
w:  jz _writing_newline

; writing space
    write msg_space, 1

_continue_writing:
    pop_reg

    add r15d, 1
    inc r14b

; stop condition
    movzx r13d, word[ARRAY_LENGTH]
c:    add r13, 1
    cmp r15, r13             
    jne _writing                    ; If counter is equal to array length stop.

    ret

; _writeASCIInum()
; Write digit of ascii to txt
_writeASCII_3digits:
; array address in rax
    mov sil, 3                      ; number of iterations 3
    xor cl, cl                      ; set counter
d:    mov rdx, buffer                 ; load buffer address
_writing_ascii_3digits_loop:
    mov bl, [rax+rcx]               ; load value in efective address
    mov byte[rax+rcx], 0x30         ; load a 0 to value in efective address
c1:    mov [rdx], bl                   ; save value in buffer
    push_reg
    write buffer, 1                    ; write buffer
    pop_reg
    inc cl
    cmp cl, sil
    jne _writing_ascii_3digits_loop ; if counter is greater or equal to 3, get out
    ret

_writing_newline:
    push_reg
    write msg_newline, 1
    pop_reg
    jmp _continue_writing

; ; ------
; ; _write():
; ; Write to file
; _writef:
; ; > Input
; ;   %1 : pointer to data to be written
;     ; write line on file
;     mov rax, 4                  ; kernel op code 4 to sys_write
;     mov rbx, [fd_out]           ; move file descriptor of out file to ebx
;     mov rcx, buffer                 ; write contents received
;     mov rdx, 4                  ; write 6 bytes to new txt file
;     int 80h 

;     ret




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


section .data
;97
    index           dd 0
    ARRAY_LENGTH    dd 83521
    ARRAY_ROWS      dd 289
; ; 10
;     index           dd 0
;     ARRAY_LENGTH    dd 100
;     ARRAY_ROWS      dd 10
; files
    ; file_in     db  '../../files/image.txt', 0      ; name of input image file
    file_in     db  '../../files/image97.txt', 0      ; name of input image file
    file_out    db  '../../files/image-i.txt', 0    ; name of output image file
; messages
    msg1 db	'The current ARRAY is:',0xA,0xD
    len1 equ $ - msg1
    msg_space db	'',0x20
    msg_newline db	'',0xA
    MULTIPLIER  equ 100
    ; in gdb    -   p /u(char[100])ARRAY    /    p/u(char)index

    ; ARRAY TIMES 100 db 0                            ; matrix memory allocation
    ARRAY TIMES 83521 db 0                            ; matrix memory allocation


section .bss
; file management
    fd_in       resb    4      ; in file descriptor
    fd_out      resb    4      ; out file descriptor
; sample information
    buffer      resd     1     ; buffer length
    byte_ctr    resd     1     ; current input sample
    ascii_value resd     3     ; stores the ascii output sample

