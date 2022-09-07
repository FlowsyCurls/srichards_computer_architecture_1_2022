%include "linux64.inc"
; %include "io.inc"
section .data
    inFile    db  'image.txt', 0                   ; name of input image file
    outFile   db  'image-interpolated.txt', 0      ; name of output image file
    

section .bss
    lineIn         resb     6     ; store input audio line

    k              resd     1     ; k parameter
    bufferPtr      resd     1     ; current buffer pointer length
    bufferCtr      resd     1     ; buffer counter to see if it reaches k    
    buffer         resd     2205  ; buffer length

section .text
        global _start

_start:
    mov ebp, esp; for correct debugging
    call    _read                 ; read write loop
    call    _write                ; read write loop
    ; call    closeFiles          ; close files
    call    _exit                 ; exit function

_exit:  
    mov rax, 60     ; The system call for exit (sys_exit)
    mov rbx, 0      ; Exit with return call of 0 (no error)
    syscall         ; Call the kernel

; ------
; readFirstLine()
; Opens and reads first line of in txt file
readFirstLine:
    ; open file
    mov eax, 5          ; kernel code for sys_open
    mov ebx, inFile;    ; Pointer to string for the file name to open
    mov ecx, 0          ; O_RDONLY - read flag(0)

    ; store input file descriptor
    mov     [inDescr], eax        ; store input file descriptor

    ; seek place in file
    mov     eax, 19               ; kernel opcode 19 for sys_lseek
    mov     ebx, [inDescr]        ; move file descriptor to ebx
    mov     ecx, 0                ; move the cursor 0 bytes
    mov     edx, 0                ; seek end 0 - start from beggining
    int     80h                   ; os execute

    ; read file contents
    mov     eax, 3                ; kernel op code 3 sys_read
    mov     ebx, [inDescr]        ; store descriptor in ebx
    mov     ecx, lineIn           ; store input line on ecx
    mov     edx, 6                ; amount of bytes read on edx
    int     80h                   ; os execute
    
    ret



; ------
; rwAll()
; Read-write loop 
rwAll:
    ; first line is sample rate, which is useless in assembly
    call    readFirstLine         ; read first line subroutine
    call    writeFirstLine        ; write first line subroutine

; ------
; writeFirstLine()
; Opens and writes the first line of out txt file
writeFirstLine:
    ; create file
    mov     eax, 8                ; kernel opcode 8 sys_create
    mov     ebx, outAudioFile     ; file name to create
    mov     ecx, 0777o            ; set permissions to read, write and execute
    int     80h                   ; os execute
    
    ; store 
    mov     [outDescr], eax       ; store output file descriptor

    ; write line on file
    mov     eax, 4                ; kernel op code 4 to sys_write
    mov     ebx, [outDescr]       ; move file descriptor of out file to ebx
    mov     ecx, lineIn           ; write contents of line in to new file
    mov     edx, 6                ; write 6 bytes to new txt file
    int     80h                   ; os execute

    ret
    
    
; ------
; writeNextLine()
; Writes the next line of new out txt from cursor
writeNextLine:
    ; move cursor to next line
    mov     eax, 19               ; kernel op code 19 for sys_lseek
    mov     ebx, [outDescr]       ; file descriptor
    mov     ecx, 0                ; move cursor 0 bytes
    mov     edx, 1                ; seek end 1 - start where it left

    int     80h                   ; os execute 

    ; write next bytes from file
    mov     edx, 6                ; write 6 bytes
    mov     eax, 4                ; kernel op code 3 sys_write
    mov     ebx, [outDescr]       ; file descriptor
    mov     ecx, lineIn           ; move memory address of file to ecx

    int     80h                   ; os execute
    
    ret

