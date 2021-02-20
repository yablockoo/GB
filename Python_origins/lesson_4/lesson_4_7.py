from itertools import count


def fact(n):
    factorial = 1
    for elem in count(1):
        if elem > n:
            break
        else:
            factorial *= elem
            yield factorial


for el in fact(int(input("Введите число: "))):
    print(el)
