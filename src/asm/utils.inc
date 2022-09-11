; 97
ARRAY_LENGTH equ 83521
PIXELS equ 289

; 10
; ARRAY_LENGTH equ 100
; PIXELS equ 10

PIXELS_MUL_BY_2 equ 2*PIXELS
PIXELS_MUL_BY_3 equ 3*PIXELS
ARRAY_LENGTH_MINUS_3PIXELS equ ARRAY_LENGTH - PIXELS_MUL_BY_3 
MULTIPLIER  equ 100



space       equ 32
newline     equ 10
tab         equ 09
F           equ 70

section	.data

    i           dw 0
    value       db 4; string buffer to store results
    strAsciiResult TIMES 3 db 0x30


section .bss

    
; -------------------------------------------------------------------------------
; push_reg()
; Function that pushes all registers to stack
%macro push_reg 0
    push rax
    push rbx
    push rcx
    push rdx
%endmacro


; -------------------------------------------------------------------------------
; pop_reg()
; Function that pops all registers to stack
%macro pop_reg 0
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro


; -------------------------------------------------------------------------------
; clear_reg()
; Function that clears most used registers
%macro clear_reg 0
    mov rax, 0
    mov rbx, 0
    mov rcx, 0
    mov rdx, 0
    mov rsi, 0
    mov rdi, 0
%endmacro

; -------------------------------------------------------------------------------
; mod(num)
; Function that executes: eax % (%1)
; MAKE SURE TO PUSH EAX AND EDX
%macro mod 1
; mod of - %1
mov edx, 0             ; dividend high half = 0.  prefer  xor edx,edx
mov ebx, %1            ; divisor can be any register or memory
div ebx ; Divides eax = 1234 by ebx = 3.
        ; EDX =   4 = 1234 % 10  remainder
        ; EAX = 123 = 1234 / 10  quotient
%endmacro


; -------------------------------------------------------------------------------
; ascii_to_dec()
; Function that convert from ascii to decimal 
%macro ascii_to_dec 2
; > Input
;   %1 : pointer to buffer
;   %2 : multiplier
; > Output
;   result in rax

; set pointer
    mov  rdx, %1                ; move (buffer ptr) to rdx
    ; xor  r10, r10             ; init r10 (counter) value to 0
; set multiplier
    mov  rbx, %2                ; move (multiplier) in rbx
    mov  rcx, 0                 ; set rcx on 0, to use it for the result
%%_ascii_loop:
    mov  rax, 0                 ; set rax on 0, to clear and operate with it
    mov  al, byte[rdx]          ; read in al first byte at pointer rdx (buffer ptr)

; conversion from ASCII to dec
    sub     rax, 48             ; substract 48('0') to get decimal on rax
    push    rdx                 ; store rdx (buffer ptr) in stack - for multiplication operation
    mul     rbx                 ; rax (product) <- multiply rax (dec num) with rbx (multiplier)
    add     rcx, rax            ; add rax (product) into rbx (result)
    pop     rdx                 ; restore rdx (buffer ptr) from stack

; divide multiplier by 10
    push    rax                 ; store rax (dec num) in stack - for division operation
    mov     rax, rbx            ; move rbx (multiplier) into rax
    push    rdx                 ; store rdx (buffer ptr) in stack - for division operation
    mod     10                  ; EAX (quotient) <= rax // 10.  ej: 1000 // 10 = 100
    mov     rbx, rax            ; restore rax to rbx (module)
    pop     rdx                 ; restore rdx (buffer ptr)
    pop     rax                 ; restore rax (dec num)

; condition
    cmp     rbx, 0              ; compare number in rbx to (1//10 = 0) to determine end of num in buffer
    jz      %%returnAscii       ; break if multiplier becomes 0 (end of number)

; loop
    inc     rdx                 ; next memory position in rdx 
    jmp     %%_ascii_loop

%%returnAscii:
    inc     rdx               ; leave memory pointer in last byte
    mov   rax, rcx            ; move rcx (result) to rax
%endmacro



; -------------------------------------------------------------------------------
; dec_to_ascii()
; Function that convert from decimal to ascii
%macro dec_to_ascii 0
; > Input
;   Load pointer to value in rax before call
; > Output
;   result in rax
    mov rcx, 10                     ; divisor
    mov r10, 2

    mov rsi, strAsciiResult         ; DS:SI points to string buffer
                                    ; p /u(char[3])strAsciiResult
 %%divide:
    xor rdx, rdx                    ; high part = 0
    div rcx                         ; EAX (quotient)  ej: 123 / 10 => 12
                                    ; EDX (remainder) ej: 123 / 10 => 3
    add dl, '0'                     ; convert to ASCII -  DL is a digit in range [0..9]
    lea rbx, [rsi+r10]                  
    mov [rbx], dl                   ; write it to the buffer
    mov r12,rdx
    sub r10, 1
    test rax, rax                   ; EAX is 0?
    jnz %%divide                    ; no, continue

    mov rax, strAsciiResult         ; return pointer in rax
%endmacro



; -------------------------------------------------------------------------------
; _loadArray():
; Load 'al' register into ARRAY[index]
%macro load_to_array 2
; %1 : pointer to array
; %2 : pointer to index
    mov  ebx,[%2]          ; bx will point to the current index in ARRAY [zero extended] 
    mov  [%1+rbx], al     ; give the rbx-th array element the value al
    ; inc     word[%2]         ; increment the index by 4.
%endmacro



; -------------------------------------------------------------------------------
; _write():
; Write to file
%macro write 2
; > Input
;   %1 : pointer to data to be written
    ; write line on file
    mov rax, 4                  ; kernel op code 4 to sys_write
    mov rbx, [fd_out]           ; move file descriptor of out file to ebx
    mov rcx, %1                 ; write contents received
    mov rdx, %2                  ; write 6 bytes to new txt file
    int 80h                     ; os execute
%endmacro


; -------------------------------------------------------------------------------
%macro print_f 2 
    mov   eax, 4
    mov   ebx, 1
    mov   ecx, %1   ; msg
    mov   edx, %2   ; text len
    int   80h
%endmacro



; -------------------------------------------------------------------------------
%macro interpolation_operation 2
; > Input
; %1 : value x
; %2 : value y
; > OUTPUT
;    cl = unknownValue
; cl = (2 * x) // 3
    xor  rax, rax           ; clear rax
    xor  rcx, rcx           ; clear rcx
    mov  al, %1             ; move bl in al (as numbers are just 1 byte) [zero extend]
    mov  dl, 2              ; move a 2 in dl (multiplier)
    mul  dl                 ; AX (product) => (2 * x)
    mov  dl, 3              ; move a 3 in dl (divisor)
    div  dl                 ; AL (quotient) => (2 * y) // 3
    mov cl, al              ; move al to r8b. (8bits) 0-255
; cl += (1 * y) // 3
    xor  rax, rax           ; clear rax
    mov  al, %2             ; move bh in al
    mov  dl, 3              ; move a 3 in dl (divisor)
    div  dl                 ; AL (quotient) => knownValue2 // 3
    add  cl, al             ; add to r8b the value in al (8bits)
    xor  rax, rax           ; clear rax
%endmacro
