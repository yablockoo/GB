def my_func(x, y):
    for i in range(1, abs(y)):
        x *= x
    return 1 / x


ext_x = float(input("Введите х: "))
ext_y = int(input("Введите отрицательную степень у: "))
print(f"{ext_x} в степени {ext_y} = {my_func(ext_x, ext_y)}")
