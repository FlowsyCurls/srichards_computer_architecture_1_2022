section	.data
space       equ 32
newline     equ 52
tab         equ 09
F           equ 70
i           dw 0

; ------
; push_reg()
; Function that pushes all registers to stack
%macro push_reg 0
    push rax
    push rbx
    push rcx
    push rdx
%endmacro

; ------
; pop_reg()
; Function that pops all registers to stack
%macro pop_reg 0
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro


; ------
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


; ------
; ascii()
; Function that convert from ascii to decimal 
%macro ascii_to_dec 2
; %1 : pointer to buffer
; %2 : multiplier

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


; ------
; _loadArray():
; Load 'al' register into ARRAY[index]
%macro load_to_array 2
; %1 : pointer to array
; %2 : pointer to index
    movzx   bx,[%2]          ; bx will point to the current index in ARRAY [zero extended] 
    mov     [%1+rbx], al     ; give the rbx-th array element the value al
    ; inc     word[%2]         ; increment the index by 4.
%endmacro


; %macro print_row 2

;     ; mov     esi, array                      ; get pointer to array
;     ; mov     edi, arraylen - 1               ; edi = number of array elements

;     mov rdx, %1 ; array ptr
;     mov rbx, %2 ; number of columns

; %%loop:    
;     mov  rcx, [rdx]                          ; get current array element
;     add  rcx, 48                             ; add 48 to convet to ASCII
;     push_reg                                ; push to stack since we need an address of item to print
;     printf rcx, 1                           ; now print it
;     pop_reg                                 ; recover
;     inc  rdx            
;     dec  rbx                                ; decrease loop counter
;     jns  %%loop                             ; if edi ! -1 continue loop

; ; PrintLineFeed:
; ;     sub     esp, 4
; ;     mov     byte [esp], 10
; ;     mov     edx, 1
; ;     mov     ecx, esp
; ;     mov     ebx, stdout
; ;     mov     eax, sys_write
; ;     int     80h
; ;     add     esp, 4
; %endmacro



%macro print_f 2 
    mov   eax, 4
    mov   ebx, 1
    mov   ecx, %1   ; msg
    mov   edx, %2   ; text len
    int   80h
%endmacro








; %macro print_row 2
;     ; array ptr
;     ; array column size

;     push_reg
;     xor   r10, r10         ;This make the 'index' = 0
; %%loop:
;     print_value newline, 1
;     cmp   r10, %2           ; until n < k 
;     jb    %%loop
;     pop_reg
; %endmacro



; %macro print_matrix 3
;     ; array ptr
;     ; array length
;     ; array column size
;     xor   r11, r11          ; 'index' = 0
; %%loop:
;     print_array %1, %3, r11
;     mov   eax, 4
;     mov   ebx, 1
;     mov   r12, [%1+r11]     ; save value in r10
;     mov   ecx, r12d            ; '\n'
;     mov   edx, 1            ; 1 byte
;     int   80h
;     cmp   r11, %2           ; until n < k 
;     jb    %%loop
; %endmacro

; %macro print_array 3
;     ; array ptr
;     ; array column size
;     xor   r10, r10         ;This make the 'index' = 0
; %%loopRow:
;     mov   r10, [%1+r11]     ; save value in r10
;     inc   r10
;     inc   r11b

;     mov   eax, 4
;     mov   ebx, 1
;     mov   cl, r10b         ; array
;     mov   edx, 1           ; 1 byte
;     int   80h

;     cmp   r10, %3           ; until n < k 
;     jb    %%loopRow

;     mov   eax, 4
;     mov   ebx, 1
;     mov   ecx, 8            ; '\t'
;     mov   edx, 1            ; 1 byte
;     int   80h
; %endmacro