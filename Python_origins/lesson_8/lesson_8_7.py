"""
Реализовать проект «Операции с комплексными числами».
Создайте класс «Комплексное число», реализуйте перегрузку методов
сложения и умножения комплексных чисел. Проверьте работу проекта,
создав экземпляры класса (комплексные числа) и выполнив сложение и
умножение созданных экземпляров. Проверьте корректность полученного результата.
"""


class ComplexNumber:
    def __init__(self, real, imagine):
        self.comp_num = []
        self.comp_num.append(int(real))
        self.comp_num.append(int(imagine))

    def __add__(self, other):
        comp_sum = [self.comp_num[0] + other.comp_num[0], self.comp_num[1] + other.comp_num[1]]
        return comp_sum

    def __mul__(self, other):
        comp_mul = [self.comp_num[0] * other.comp_num[0], self.comp_num[1] * other.comp_num[1]]
        return comp_mul

    def __str__(self):
        return f"z = {self.comp_num[0]} + {self.comp_num[1]}i"


complex_1 = ComplexNumber(1, 2)
complex_2 = ComplexNumber(2, 3)
temp_sum = complex_1 + complex_2
temp_mul = complex_1 * complex_2
complex_sum = ComplexNumber(temp_sum[0], temp_sum[1])
complex_mul = ComplexNumber(temp_mul[0], temp_mul[1])
print(f"Число 1: {complex_1}")
print(f"Число 2: {complex_2}")
print(f"Сумма чисел = {complex_sum}")
print(f"Произведение чисел = {complex_mul}")
