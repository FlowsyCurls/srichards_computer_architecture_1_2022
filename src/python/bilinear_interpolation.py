from array import array
from logging import raiseExceptions
from re import S
import numpy as np
import cv2
import pathlib
from pathlib import Path
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

from binascii import hexlify
# os.getcwd(), 'imgs\\'
# filename = 'image.txt'
import os

filename = "image.txt"
filename = os.path.join(os.getcwd(), 'src', 'asm', filename)


def matrix_to_list(matrix):
    lst = []

    for r in matrix:
        lst.extend(r)
    print(lst)
    write_file(matrix)
    return lst


def write_file(matrix):
    with open(filename, 'w') as f:
        for row in matrix:
            f.write(write_file_aux(row))
            f.write('\n')
        f.write('F')


def write_file_aux(row):
    s = ''
    for col in range(0, len(row)-85):
        n = str(row[col])
        if (len(n) == 3):
            s += n + " "
        else:
            s += '0' + n + " "

    print(s)
    return s[:-1]  # Remove last space


def openFiles():
    global f
    f = open(filename, 'r')
    readFile()


k = 0
x_n = 0
x_nPtr = 0
output = []
inputCtr = 0  # when its 2 means I have A and B
size = 4
rax = 0
rbx = 0
rcx = 0
rdx = 0
lineIn = ""
# Read 4 bytes
# Counter in 0
# Analize and get the real value

def readFile():
    # read by character
    lineIn = f.read(4)
    lineIn = str_to_bytearray(lineIn)
    if (lineIn[3] is 70):  # F
        f.close()

    rax = loadInput()

# Converts ASCII to dec and load it in input x_n
def loadInput():
    
    # First Bit
    
    # mov rdx, lineIn   -   move current line pos to rdx.
    rdx = lineIn
    
    # mov rax, 0        -   set rax on 0, to operate with it.
    rax = 0
    
    # mov rbx, x_n      -   copy x_n pos to rbx
    # mov [rbx], rax    -   move a 0 into the current sample memory pos of x_n using rbx.
    rbx = rax
    
    # mov rbx, 100      -   set rbx to 100 (multiplier)
    rbx = 100
    # mov rcx, 0        -   set rcx to 0 (result)
    loadInputLoop()
    
def loadInputLoop():
    # mov rax, 0        -   mov a 0 to rax to restart register
    rax = 0
    # mov al, byte[rdx] -   move in al(rax) a byte in pos rdx (line in start)
    
    

    
    
    

def str_to_bytearray(s):
    encoded = s.encode('utf-8')
    b = bytearray(encoded)
    # print(hex(b[0]))
    return b


def bilinear_interpolate_aux(A, B, C, D):
    # Conocidos
    a = round((2/3)*A + (1/3)*B)
    b = round((1/3)*A + (2/3)*B)
    c = round((2/3)*A + (1/3)*C)
    g = round((1/3)*A + (2/3)*C)
    k = round((2/3)*C + (1/3)*D)
    l = round((1/3)*C + (2/3)*D)
    f = round((2/3)*B + (1/3)*D)
    j = round((1/3)*B + (2/3)*D)
    # Intermedios
    d = round((2/3)*c + (1/3)*f)
    e = round((1/3)*c + (2/3)*f)
    h = round((2/3)*g + (1/3)*j)
    i = round((1/3)*g + (2/3)*j)
    return [[A, a, b, B], [c, d, e, f], [g, h, i, j], [C, k, l, D]]

# v = bilinear_interpolate(10,20,30,40)


# print(np.matrix(I2))
# print('\n'.join(['\t'.join([str(cell) for cell in row]) for row in v]))

# print(im[0][:16])
# print(im[1][:16])
# print(im[2][:16])
# print(im[3][:16])
# print(im[4][:16])
# print(im[5][:16])

openFiles()
