; ; 97
; RESOLUTION equ 83521
; PIXELS equ 289

; 10
RESOLUTION equ 100
PIXELS equ 10



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
%macro vertical_interpolation 4
; > Input
;   edx current index address
;   r10 current index num
;   %1 = pointer to knownIndex1
;   %2 = pointer to knownIndex2
;   %3 = pointer to unknownIndex1
;   %4 = pointer to unknownIndex2

; > Output
;   al = unknownUp - value
;   bl = unknownDown - value
;   cl = unknownIndex1
;   dl = unknownIndex2



; knownIndex1 = i
    mov eax, r10d                ; load current index
%%k1:
    mov   ecx, PIXELS 
%%k2:
; knownIndex2 = i + 3*PIXELS
    mov   eax, 3                ; move a 3 into eax
    mul   ecx                   ; 3 * PIXELS
    add   eax, r10d             ; i + 3*PIXELS
    lea   rax, [rdx+rax]        ; effective address  =>  array[i + 3pixels]
    mov   [%3], eax             ; change unknownIndex2 value

; %%k3:
; ; unknownIndex1 = i + PIXELS
;     mov   eax, ecx              ; move PIXELS to eax
;     add   eax, edx              ; i + PIXELS
;     mov   [%4], eax             ; change unknownIndex1 value
; ; %%k4:
; ; unknownIndex2 = i + 2*PIXELS
;     mov   eax, 2                ; move a 2 into eax
;     mul   ecx                   ; 2 * PIXELS
;     add   eax, edx              ; i + 2*PIXELS
;     mov   [%5], eax             ; change unknownIndex2 value

%%sop:
    ; push  eax
    






    ; mov   ebx, 1
    ; mov   ecx, %1   ; msg
    ; mov   edx, %2   ; text len
    ; int   80h
%endmacro
