number = int(input("Введите число: "))
max_num = 0
divider = 1

while number / divider >= 1:
    if max_num == 9:
        break

    numeral = number // divider % 10  # Отсекаем цифру из числа
    divider *= 10
    if numeral > max_num:
        max_num = numeral

print(f"Максимальная цифра в числе {number} это {max_num}.")
