import random


def generate():
    with open("text_5.txt", "w") as f_obj:
        for i in range(20):
            f_obj.write(str(random.randint(0, 100)) + " ")
    pass


def output():
    with open("text_5.txt", "r") as file_obj:
        numerals = file_obj.read().split()
        numerals = [int(el) for el in numerals]
        print(f"Числа в файле: {numerals}")
        print(f"Сумма чисел = {sum(numerals)}")


generate()
output()
