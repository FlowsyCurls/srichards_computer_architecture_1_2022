;; nasm -felf64 -o algorithm-v2.o algorithm-v2.asm && ld -o algorithm-v2 algorithm-v2.o && ./algorithm-v2
;; gdb algorithm-v2


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

; sample information
    buffer      resd     1     ; buffer length
    byte_ctr    resd     1     ; current input sample


section .text
        global _start

_start:
    call _openFiles
    call _read
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

    jmp _ascii2dec
_fileEnd: ret
    
;     cmp rax, 0                ;cmp exit
; _stop:
;     je _exit


; ------
; _ascii2dec()
; Converts buffer ASCII value to dec and load it into ARRAY[index]
_ascii2dec:
    mov  rdx, buffer            ; move current buffer pos to rdx
    mov  rax, 0                 ; set rax on 0, to operate with it
    mov  rbx, byte_ctr          ; move byte_ctr ptr to rbx
    mov  [rbx], rax             ; init byte_ctr value to 0
    
    mov  rbx, 100               ; set rbx to 100 (multiplier)
    mov  rcx, 0                 ; mov rcx to 0 (result)

_ascii2dec_aux:
    mov  rax, 0                 ; move a 0 to rax to restart register
    mov  al, byte[rdx]          ; read in al first byte at pointer rdx (buffer ptr)

; conditions
    cmp  rax, 32                ; compare number in rax to (space ~32) to determine end of num in buffer
    jz   _loadAscii             ; break if analyzed byte is ' ' (end of number)

    cmp  rax, 10                ; compare number in rax to (new line ~10) to determine end of line in buffer
    jz   _newLine               ; break if analyzed byte is '\n' (end of line)

    cmp  rax, 70                ; compare number in rax to (F ~70) to determine end of file in buffer
    jz   _fileEnd               ; break if analyzed byte is 'F' (end of file)

; conversion from ASCII to dec
    sub     rax, 48             ; substract 48('0') to get decimal on rax

    push    rdx                 ; store rdx (buffer ptr) in stack - for multiplication operation
    mul     rbx                 ; rax (product) <- multiply rax (dec num) with rbx (multiplier)
    add     rcx, rax            ; add rax (product) into rbx (result)
    pop     rdx                 ; restore rdx (buffer ptr) from stack

; divide multiplier by 2
    push    rax                 ; store rax (dec num) in stack - for division operation
    mov     rax, rbx            ; move rbx (multiplier) into rax
    push    rdx                 ; store rdx (buffer ptr) in stack - for division operation
    mov     rdx, 0              ; set rdx to 0 to avoid division issues
    mov     rbx, 10             ; move a 10 to rbx, this will be our divisor
    div     rbx                 ; divide rax (multiplier) by rbx (divisor ~10)
    mov     rbx, rax            ; restore rax to rbx
    pop     rdx                 ; restore rdx (buffer ptr)
    pop     rax                 ; restore rax (dec num)
    
; loop
    inc     rdx                 ; next memory position in rdx 
    jmp     _ascii2dec_aux      ; continue loop

_newLine:
    movzx   ax,[index]          ; ax will point to the current index in ARRAY [zero extended] 
    mov     [ARRAY+rax], cl     ; give the ax-th array element the value cl
    inc     word[index]         ; increment the index by 4.
    inc     word[index]         ; increment the index by 4.
    jmp _write
    
_loadAscii:
    movzx   ax,[index]          ; ax will point to the current index in ARRAY [zero extended] 
    mov     [ARRAY+rax], cl     ; give the ax-th array element the value cl
    inc     word[index]         ; increment the index by 4.
    ; jmp _read

; write to file
_write:
    ; write line on file
    mov rax, 4                  ; kernel op code 4 to sys_write
    mov rbx, [fd_out]           ; move file descriptor of out file to ebx
    mov rcx, buffer             ; write contents of line in to new file
    mov rdx, 4                  ; write 6 bytes to new txt file
    int 80h                     ; os execute

    jmp _read



;p /t(char[10])ARRAY


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
    mov rax, 1              ; ID for sys_close
    mov rbx, 0
    int 0x80