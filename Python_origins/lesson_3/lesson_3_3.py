def my_func(arg_1, arg_2, arg_3):
    if arg_1 >= arg_2 >= arg_3:
        return arg_1 + arg_2
    elif arg_2 >= arg_3 >= arg_1:
        return arg_2 + arg_3
    else:
        return arg_1 + arg_3


arg_list = (input("Введите три чилса через пробел: ")).split()
print(f"Сумма наибольших двух чисел: {my_func(float(arg_list[0]), float(arg_list[1]), float(arg_list[2]))}")
