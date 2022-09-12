; -------------------------------------------------------------------------------
; CONSTANTS 
PIXELS equ 3*N-2
ARRAY_LENGTH equ PIXELS*PIXELS
PIXELS_MUL_BY_2 equ 2*PIXELS
PIXELS_MUL_BY_3 equ 3*PIXELS
ARRAY_LENGTH_MINUS_3PIXELS equ ARRAY_LENGTH - PIXELS_MUL_BY_3 
MULTIPLIER  equ 100
space       equ 32
newline     equ 10
tab         equ 09
F           equ 70

; N equ 97
; N equ 86
; N equ 8
N equ 4

; -------------------------------------------------------------------------------
; VARIABLES
section .data
; files
    ; file_in   db  '../../files/image.txt', 0      ; name of input image file
    file_in   db  '../../files/image4x4.txt', 0      ; name of input image file
    ; file_in   db  '../../files/image8x8.txt', 0      ; name of input image file
    ; file_in   db  '../../files/image86x86.txt', 0      ; name of input image file
    ; file_in   db  '../../files/image97x97.txt', 0      ; name of input image file
    file_out    db  '../../files/image-i.txt', 0    ; name of output image file
; messages
    msg_space db	'',32
    msg_newline db	'',0xA
; matrix memory allocation
    ARRAY TIMES ARRAY_LENGTH db 0       ; in gdb    -   p /u(char[100])ARRAY
; ascii
    strAsciiResult TIMES 3 db 0x30



; -------------------------------------------------------------------------------
;Block Started by Symbol
section .bss
; file management
    fd_in       resb    4      ; in file descriptor
    fd_out      resb    4      ; out file descriptor
; sample information
    buffer      resd     1     ; buffer length
    byte_ctr    resd     1     ; current input sample
    ascii_value resd     3     ; stores the ascii output sample
; algorithm
    unknownIndex1    resd     4     ; unknownIndex1 variable
    unknownIndex2    resd     4     ; unknownIndex2 variable
    INDEX            resd     4     ; index for array       p /u(int)INDEX