from functools import reduce

even_list = [el for el in range(100, 1001) if el % 2 == 0]
print(even_list)
print(reduce(lambda a, b: a * b, even_list))
