def divide(arg_1, arg_2):
    try:
        return arg_1 / arg_2
    except ZeroDivisionError:
        print("Деление на 0 запрещено!")


x = float(input("Введите перове число: "))
y = float(input("Введите второе число: "))
print(f"Результат деления: {divide(x, y)}")
