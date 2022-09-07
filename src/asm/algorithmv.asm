%include "linux64.inc"
; %include "/home/jey/Documents"

section .data
    inImageFile    db  'image.txt', 0h                  ; name of input image file
    outImageFile   db  'image-interpolated.txt', 0h     ; name of output image file
    
section .bss
    ; file management
    inDescr        resb     4     ; in file descriptor
    outDescr       resb     4     ; out file descriptor
    lineIn         resb     6     ; store input image line
    
    ; sample information
    x_n          resd     1     ; current input sample
    y_n          resd     1     ; current output sample
    y_n_temp    resd     1     ; current output sample copy for string conversion
    k              resd     1     ; k parameter

    bufferPtr      resd     1     ; current buffer pointer length
    bufferCtr      resd     1     ; buffer counter to see if it reaches k    
    buffer         resd     2205  ; buffer length

section .text
        global _start
_start:
    mov ebp, esp; for correct debugging

    call    rwAll                 ; read write loop

    call    closeFiles            ; close files

    call    done                  ; exit function


; ------
; closeFiles()
; Close txt files
closeFiles:
    ; close input file
    mov     ebx, [inDescr]       ; move descriptor to ebx
    mov     rax, 6               ; kernel op code 6 sys_close
    int     80h                  ; os execute
    
    ; close output file
    mov     ebx, [outDescr]      ; move descriptor to ebx
    mov     rax, 6               ; kernel op code 6 sys_close
    int     80h                  ; os execute
    
    ret

; ------
; void exit()
; Exit program and restore resources    
done:
    mov     ebx, 0                ; return 0 status on exit - 'No Errors'
    mov     rax, 1                ; kernel op code 1 sys_exit
    int     80h                   ; os execute
    
    ret

; ------
; loadInput()
; Converts ASCII to num and lods it in input x_n
loadInput:
    mov     edx, lineIn           ; move current line pos to edx
    mov     rax, 0                ; set rax on 0
    mov     ebx, x_n              ; move x_n pos to ebx
    mov     [ebx], rax            ; move a 0 in the current sample memory pos
    
    mov     ebx, 10000            ; set ebx multiplier to 10000
    mov     ecx, 0                ; mov ecx to 0 (result)
    
; ------
; rwAll()
; Read-write loop 
rwAll:
    ; first line is sample rate, which is useless in assembly
    call    readFirstLine         ; read first line subroutine
    
    ; get k value
    ; call    readNextLine          ; read second line (k value)
    call    loadInput             ; convert k ascii to num and store in x_n
    push    rax                   ; store rax
    mov     rax, [x_n]            ; move k num in rax
    mov     [k], rax              ; save k (rax) in k position
    pop     rax                   ; restore rax
    ; call    writeNextLine         ; write k back to txt
    call    writeFirstLine        ; write first line subroutine
    ret

;     ; get alpha value
;     call    readNextLine          ; read third line (alpha value)
;     call    loadInput             ; convert alpha ascii to num and store in x_n
;     push    rax                   ; store rax
;     mov     rax, [x_n]            ; move alpha num in rax
;     mov     [alpha], rax          ; save alpha (rax) in alpha position
;     pop     rax                   ; restore rax
;     call    writeNextLine         ; write alpha back to txt
    
;     ; get inverted 1 - alpha value
;     call    readNextLine          ; read third line (alpha value)
;     call    loadInput             ; convert alpha inverted ascii to num and store in x_n
;     push    rax                   ; store rax
;     mov     rax, [x_n]            ; move alpha inverted num in rax
;     mov     [alphaInverted], rax  ; save alpha inverted (rax) in alpha position
;     pop     rax                   ; restore rax
;     call    writeNextLine         ; write alpha inverted back to txt
    
;     ; calculate 1-alpha value
;     call    calculateOneAlpha     ; calculates 1 - alpha parameter
    
;     ; set buffer pointer at first position in buffer
;     mov     rax, buffer           ; store buffer start memory pos on rax
;     mov     [bufferPtr], rax      ; move buffer memory pos on buffer pointer pos
;     mov     ebx, 0
;     mov     [bufferCtr], ebx      ; buffer counter starts at 0


; ------
; readFirstLine()
; Opens and reads first line of in txt file
readFirstLine:
    ; open file
    mov     ecx, 0                ; ecx on 0 for file on read mode
    mov     ebx, inImageFile      ; ebx on file name
    mov     rax, 5                ; kernel code for sys_open file
    int     80h                   ; os execute
    
    ; store input file descriptor
    mov     [inDescr], rax        ; store input file descriptor
    
    ; seek place in file
    mov     edx, 0                ; seek end 0 - start from beggining
    mov     ecx, 0                ; move the cursor 0 bytes
    mov     ebx, [inDescr]        ; move file descriptor to ebx
    mov     rax, 19               ; kernel opcode 19 for sys_lseek
    int     80h                   ; os execute
    
    ; read file contents
    mov     edx, 6                ; amount of bytes read on edx
    mov     ecx, lineIn           ; store input line on ecx
    mov     ebx, [inDescr]        ; store descriptor in ebx
    mov     rax, 3                ; kernel op code 3 sys_read
    int     80h                   ; os execute
    
    ret


; ------
; writeFirstLine()
; Opens and writes the first line of out txt file
writeFirstLine:
    ; create file
    mov     ecx, 0777o            ; set permissions to read, write and execute
    mov     ebx, outImageFile     ; file name to create
    mov     rax, 8                ; kernel opcode 8 sys_create
    int     80h                   ; os execute
    
    ; store image 
    mov     [outDescr], rax       ; store output file descriptor

    ; write line on file
    mov     edx, 6                ; write 6 bytes to new txt file
    mov     ecx, lineIn           ; write contents of line in to new file
    mov     ebx, [outDescr]       ; move file descriptor of out file to ebx
    mov     rax, 4                ; kernel op code 4 to sys_write
    int     80h                   ; os execute
   
    ret