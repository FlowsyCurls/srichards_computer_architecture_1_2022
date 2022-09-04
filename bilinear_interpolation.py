import numpy as np 
import cv2 
import pathlib
from pathlib import Path
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

def bilinear_interpolate(A, B, C, D):
    #Conocidos
    a = round((2/3)*A + (1/3)*B)
    b = round((1/3)*A + (2/3)*B)
    c = round((2/3)*A + (1/3)*C)
    g = round((1/3)*A + (2/3)*C)
    k = round((2/3)*C + (1/3)*D)
    l = round((1/3)*C + (2/3)*D)
    f = round((2/3)*B + (1/3)*D)
    j = round((1/3)*B + (2/3)*D)
    #Intermedios
    d = round((2/3)*c + (1/3)*f)
    e = round((1/3)*c + (2/3)*f)
    h = round((2/3)*g + (1/3)*j)
    i = round((1/3)*g + (2/3)*j)
    return [[A, a,b, B], [c,d,e,f],[g,h,i,j], [C, k,l, D]]

v = bilinear_interpolate(10,20,30,40)

# print(np.matrix(I2))
print('\n'.join(['\t'.join([str(cell) for cell in row]) for row in v]))

# print(im[0][:16])
# print(im[1][:16])
# print(im[2][:16])
# print(im[3][:16])
# print(im[4][:16])
# print(im[5][:16])

