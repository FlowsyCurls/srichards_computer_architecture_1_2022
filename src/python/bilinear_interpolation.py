from re import I
import numpy as np
import os
import time

asm_filename = "algorithm"
filename = "image.txt"
outfilename = "image-i.txt"
filename = os.path.join(os.getcwd(), 'files', filename)
outfilename = os.path.join(os.getcwd(), 'files', outfilename)


def execute():
    path = "cd $HOME/Documents/Project1/src/asm"
    cmd = 'nasm -felf64 -o {0}.o {0}.asm && ld -o {0} {0}.o && ./{0}'.format(
        asm_filename)
    os.system(path + "&&" + cmd)


def algorithm(matrix, n):
    size = (3*n)-2
    write_file(matrix)
    execute()
    lst = read_file(outfilename)
    image = np.reshape(lst, (size, size))
    return image
# Parse a np matrix to a list

def algorithm_revision():
    execute()
    lst = read_file(outfilename)
    image = np.reshape(lst, (10, 10))
    return image

def print_matrix(matrix):
    lst = []
    for r in matrix:
        lst.extend(r)
    # print(lst)
# Parse the image pixels to a $name$.txt in a cleaner way.


def write_file(matrix):
    with open(filename, 'w') as f:
        for row in matrix[:-1]:
            f.write(write_file_aux(row))
            f.write('\n')
        f.write(write_file_aux(matrix[-1])+'F')


def write_file_aux(row):
    s = ''
    for col in range(0, len(row)):
        n = str(row[col])
        if (len(n) == 3):
            s += n + " "
        elif (len(n) == 2):
            s += '0' + n + " "
        else:
            s += '0' + n + "0 "
    # print(s)
    return s[:-1]  # Remove last space

# For reading image file and test.


def read_file(filename):
    f = open(filename, "r")
    tmp = f.read()
    tmp = tmp[:-2].split('\n')
    arr = []
    for n in tmp:
        arr += (n.split(' '))
    # print(arr)
    return [int(i) for i in arr]


def pprint_matrix(label, arr):
    print(label)
    print('\n'.join(['\t'.join([str(cell) for cell in row]) for row in arr]))


def pprint_vector(label, arr):
    print(label)
    print('\t'.join([str(cell) for cell in arr]))


def bilinear_interpolation(arr, n):
    # ctr = 0
    k = (3*n)-2
    bucket = [0] * (k*k)
    print("Number colums:\t", k)
    print("Bucket spaces:\t", len(bucket))

    # First place values
    # pprint_vector("\narray: ", arr)
    bucket = place_values(arr, bucket, k)
    # pprint_matrix("\nUnfilled bucket: ", np.reshape(bucket, (10, 10)))

    # Now algorithm
    vertical_interpolation(bucket, k)
    horizontal_interpolation(bucket, k)


def vertical_interpolation(bucket, PIXELS):
    # unknownIndex1 = currentIndex + PIXELS
    # unknownIndex2 = currentIndex + 2*PIXELS
    # knownIndex1 = currentIndex
    # knownIndex2 = currentIndex + 3*PIXELS

    # print(knUP, knDN, ukUP, ukDN)

    for j in range(0, 10, 3):
        for i in range(0, len(bucket)-30, 30):
            i += j
            unknownIndex1 = i + PIXELS
            unknownIndex2 = i + 2*PIXELS
            knownIndex1 = i
            knownIndex2 = i + 3*PIXELS

            knUP = bucket[knownIndex1]
            knDN = bucket[knownIndex2]
            ukUP = round((2/3)*knUP + (1/3)*knDN)
            ukDN = round((1/3)*knUP + (2/3)*knDN)
            print(knUP, knDN, ukUP, ukDN)
            bucket[unknownIndex1] = ukUP
            bucket[unknownIndex2] = ukDN

    # pprint_matrix("\nbucket: ", np.reshape(bucket, (10, 10)))


def horizontal_interpolation(bucket, PIXELS):
    i = 0
    j = 0
    while (j < (len(bucket)-3)):

        knownIndex1 = j + i*PIXELS
        knownIndex2 = knownIndex1 + 3
        unknownIndex1 = knownIndex1 + 1
        unknownIndex2 = knownIndex1 + 2
        ukLF = round((2/3)*bucket[knownIndex1] + (1/3)*bucket[knownIndex2])
        ukRG = round((1/3)*bucket[knownIndex1] + (2/3)*bucket[knownIndex2])
        bucket[unknownIndex1] = ukLF
        bucket[unknownIndex2] = ukRG

        j += 3
        if ((j != 0) and ((j+1) % PIXELS == 0)):
            j += 1

    # pprint_matrix("\nbucket: ", np.reshape(bucket, (10, 10)))


def place_values(arr, bucket, k, base=1, n=0, i=0):
    if (n > len(bucket)-1):
        return bucket

    limit = base*k
    # print("\nn: ", n, "➜", limit,
    #       "\t k: ", k,
    #       "\t i: ", i)

    while n < limit:
        if (n % 3 == 0):
            bucket[n] = int(arr[i])
            print('arr :', int(arr[i]))
            i += 1
        n += 1
    n += 20
    return place_values(arr, bucket, k, base+3, n, i)
