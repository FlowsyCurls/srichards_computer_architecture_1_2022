import numpy as np
import os

filename = "image.txt"
filename = os.path.join(os.getcwd(), 'files', filename)

# Parse a np matrix to a list


def matrix_to_list(matrix):
    lst = []
    for r in matrix:
        lst.extend(r)
    # print(lst)
    return lst

# Parse the image pixels to a $name$.txt in a cleaner way.


def write_file(matrix):
    with open(filename, 'w') as f:
        for row in matrix:
            f.write(write_file_aux(row))
            f.write('\n')
        f.write('F')


def write_file_aux(row):
    s = ''
    for col in range(0, len(row)):
        n = str(row[col])
        if (len(n) == 3):
            s += n + " "
        else:
            s += '0' + n + " "
    print(s)
    return s[:-1]  # Remove last space

# For reading image file and test.


def read_file():
    f = open(filename, "r")
    tmp = f.read()
    tmp = tmp[:-2].split('\n')
    arr = []
    for n in tmp:
        arr += (n.split(' '))
    # print(arr)
    return arr


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
    pprint_vector("\narray: ", arr)
    bucket = place_values(arr, bucket, k)
    pprint_matrix("\nbucket: ", np.reshape(bucket, (10, 10)))

    # Now algorithm


def place_values(arr, bucket, k, base=1, n=0, i=0):
    if (n > len(bucket)-1):
        return bucket

    limit = base*k
    print("\nn: ", n, "➜", limit,
          "\t k: ", k,
          "\t i: ", i)

    while n < limit:
        if (n % 3 == 0):
            bucket[n] = int(arr[i])
            print('arr :', int(arr[i]))
            i += 1
        n += 1
    n += 20
    return place_values(arr, bucket, k, base+3, n, i)


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


# print(im[0][:16])
# print(im[1][:16])
# print(im[2][:16])
# print(im[3][:16])
# print(im[4][:16])
# print(im[5][:16])

arr = read_file()
bilinear_interpolation(arr, 4)
