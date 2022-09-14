; nasm -felf64 -o algorithm-v2.o algorithm-v2.asm && ld -o algorithm-v2 algorithm-v2.o && ./algorithm-v2
; gdb algorithm-v2
;   p /u(char[100])ARRAY

%include "utils.inc"

section .text
        global _start

_start:
    call _openFiles
    call _read
    call _bilinear_interpolation
    call _write
    call _closeFiles
    call _exit



; ________________________________________________________________________________________________________________
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
    
    xor r9, 0  ; This will be the counter.

    ret



; ________________________________________________________________________________________________________________
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

    mov [INDEX], r15            ; reset index value
    load_to_array ARRAY, INDEX  ; load value
    xor r10, r10                ; clear r10
    xor r15, r15                ; clear r15
    mov [INDEX], r15            ; reset index value
t:
    ret



; ------
; _loadSpace():
; Load al into ARRAY[INDEX], also index increase by 3.
_loadSpace:
    mov [INDEX], r15            ; store index new value
    load_to_array ARRAY, INDEX  ; load value
    add r15, 0x3                  ; increase the INDEX by 3.

    jmp     _read


; ------
; _loadNewLine():
; Load al into ARRAY[INDEX], also index increase by 2*PIXELS+1.
_loadNewLine:
    mov [INDEX], r15            ; store index new value
    load_to_array ARRAY, INDEX  ; load value
    add r15, 0x1                ; i + 1
    add r15, PIXELS_MUL_BY_2    ; i + 2*PIXELS

    jmp     _read



; ________________________________________________________________________________________________________________
; _bilinear_interpolation():
; This function is in charge of calling the functions that do the interpolation.
_bilinear_interpolation:
    call _vertical_pixels
    call _horizontal_pixels
    ret

; ------
; _vertical_pixels():
; Does the vertical interpolation and save values to their positions.
_vertical_pixels:
;; calculate vertical pixeles
    clear_reg
    xor r15, 0                  ; j - for j in range(0, PIXELS, 3):
    mov [INDEX], r15            ; store index new value
    jmp _vertical_loop_j
_vertical_pixels_end:
    ret


; ------
; _vertical_loop_j():
; Intermediate loop for columns
_vertical_loop_j:
; stop condition
    cmp r15, PIXELS             
    jge _vertical_pixels_end    ; If counter is greather or equal PIXELS, then stop
    push r15
; call vertical loop with i procedure
    mov r14, 0                  ; i - for i in range(0, len(array)-3*PIXELS, 3*PIXELS)
    add r14, r15                ; i += j
    jmp _vertical_loop_i
_continue_vertical_loop_j:
    pop r15
; increase references
    add r15, 3                  ; add 3 to counter
    jmp _vertical_loop_j


; ------
; _vertical_loop_i():
; Intermediate loop for rows.
_vertical_loop_i:
; stop condition
    cmp r14, ARRAY_LENGTH_MINUS_3PIXELS             
    jge _continue_vertical_loop_j        ; If counter is greather or equal array len(array)-3*PIXELS, then stop
    push r14
; call arithmethic procedure
    call _vertical_arithmetic
    pop r14
; increase references
    add r14, PIXELS_MUL_BY_3    ; add 3*PIXELS to counter
    jmp _vertical_loop_i


; ------
; _vertical_arithmetic():
; This function determines the corresponding index and performs the algebraic calculation, 
; then stores it where it should be.
_vertical_arithmetic:
    clear_reg
; knownIndex1
    mov bl, byte[ARRAY+r14]     ; load value at relative address to bl (low-order 8 bits)
; knownIndex2
    mov rax, r14                ; copy i value to rax
    add rax, PIXELS_MUL_BY_3    ; i + 3*PIXELS
    mov bh, byte[ARRAY+rax]     ; load value at relative address to bh (high-order 8 bits)
; unknownIndex1   -  p /u(char)unknownIndex1
    mov rax, r14                ; copy i value to rax
    add rax, PIXELS             ; i + PIXELS
    mov [unknownIndex1], rax    ; save in unknownIndex1
; unknownIndex2   -  p /u(char)unknownIndex2
    mov rax, r14                ; copy i value to rax
    add rax, PIXELS_MUL_BY_2    ; i + 2*PIXELS
    mov [unknownIndex2], rax  ; save in unknownIndex2
; til  here we got:
;       bl = knownValue1
;       bh = knownValue2
;store unknown value up
    interpolation_operation bl, bh
    mov al, cl
    push rbx
    load_to_array ARRAY, unknownIndex1      ; store 'al' register into ARRAY[unknownIndex1]
    pop rbx
;store unknown value down
    interpolation_operation bh, bl
    mov al, cl
    load_to_array ARRAY, unknownIndex2      ; store 'al' register into ARRAY[unknownIndex2]
    ret



; ------
; _horizontal_pixels():
; Does the horizontal interpolation and save values to their positions.
_horizontal_pixels:
;; calculate horizontal pixeles
    clear_reg
    mov r15, 0                      ; j -  while (j < (len(bucket)-3)):
    mov r14, 0
    jmp _horizontal_loop_j
_horizontal_pixels_end:
    ret


; ------
; _horizontal_loop_j():
; Intermediate loop for columns
_horizontal_loop_j:
; stop condition
    cmp r15, ARRAY_LENGTH-3
    jge _horizontal_pixels_end      ; for j in range(0, (len(bucket)-3), 3)
    push r15

; call arithmethic procedure
    call _horizontal_arithmetic
    pop r15
; increase references
    add r15, 3                      ; j += 3
; if j == 0 then keep forward
    test r15, r15                   ; r15 is 0?
    jz _horizontal_loop_j
; analized mod PIXELS
    xor rdx, rdx
    mov rax, r15
    add ax, 1
    mov ebx, PIXELS
    div ebx
    ; EDX is 0? (remainder) If j % PIXEL, then j+=1
    test edx, edx                    
    jnz _horizontal_loop_j          ; no, continue
    add  r15, 1                     ; j++

    jmp _horizontal_loop_j


; ------
; _horizontal_arithmetic():
; This function determines the corresponding index and performs the algebraic calculation, 
; then stores it where it should be.
_horizontal_arithmetic:
    clear_reg
; knownIndex1
    mov bl, byte[ARRAY+r15]     ; load value at relative address to bl (low-order 8 bits)
; knownIndex2
    mov rax, r15                ; copy i value to rax
    add rax, 3                  ; i + 3
    mov bh, byte[ARRAY+rax]     ; load value at relative address to bh (high-order 8 bits)
; unknownIndex1   -  p /u(char)unknownIndex1
    mov rax, r15                ; copy i value to rax
    add rax, 1                  ; i + 1
    mov [unknownIndex1], rax    ; save in unknownIndex1
; unknownIndex2   -  p /u(char)unknownIndex2
    mov rax, r15                ; copy i value to rax
    add rax, 2                  ; i + 2
    mov [unknownIndex2], rax  ; save in unknownIndex2
; til  here we got:
;       bl = knownValue1
;       bh = knownValue2
; store unknown value up
    interpolation_operation bl, bh
    mov al, cl
    push rbx
    load_to_array ARRAY, unknownIndex1      ; store 'al' register into ARRAY[unknownIndex1]
    ; mov r15, [unknownIndex1]
    pop rbx
; store unknown value down
    interpolation_operation bh, bl
    mov al, cl
    load_to_array ARRAY, unknownIndex2      ; store 'al' register into ARRAY[unknownIndex2]
    
    ret


    
; ________________________________________________________________________________________________________________
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
    movzx rax, byte[r14]           ; current value to analyze
    push_reg
; get ascii value
    dec_to_ascii                    ; return array address in rax  -  p /u(char[5])strAsciiResult
    call _writeASCII_3digits
; writing new line
    mov rcx, PIXELS                 ; save number of columns to know when to make new line.
    mov rax, r15                    ; move counter value to rax
    mov rdx, 0                      ; reset rdx to prevent error in division
    div rcx                         ; EDX =   0 = 97 % 97  (remainder)
    cmp dx, 0
    jz _writing_newline
; ; writing space
    write msg_space, 1
_continue_writing:
    pop_reg
    add r15d, 1
    add r14, 1
; stop condition
    mov r13, ARRAY_LENGTH
    add r13, 1
    cmp r15, r13             
    jne _writing                    ; If counter is equal to array length stop.

    ret

; ------
; _writeASCIInum()
; Write digit of ascii to txt
_writeASCII_3digits:
; array address in rax
    mov sil, 3                      ; number of iterations 3
    xor cl, cl                      ; set counter
    mov rdx, buffer                 ; load buffer address
_writing_ascii_3digits_loop:
    mov bl, [rax+rcx]               ; load value in efective address
    mov byte[rax+rcx], 0x30         ; load a 0 to value in efective address
    mov [rdx], bl                   ; save value in buffer
    push_reg
    write buffer, 1                    ; write buffer
    pop_reg
    inc cl
    cmp cl, sil
    jne _writing_ascii_3digits_loop ; if counter is greater or equal to 3, get out
    ret

; ------
; _writing_newline()
; Write newline to txt
_writing_newline:
    push_reg
    write msg_newline, 1
    pop_reg
    jmp _continue_writing




; ________________________________________________________________________________________________________________
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



; ________________________________________________________________________________________________________________
; _exit()
; exit system
_exit:
; exit program
    mov rax, 1          ; ID for sys_close
    mov rbx, 0
    int 0x80