###### x86 ######
** compilar, enlazar y ejecutar
nasm -felf64 -o algorithm.o algorithm.asm
ld -o algorithm algorithm.o
./algorithm


objdump -M intel -d algorithm.o
gdb algorithm
b _loop
run
** utilizar 's' para correr cada un ciclo a la vez.
s
** registro con los numeros generados.
i r rcx
