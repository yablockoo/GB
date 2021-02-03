castling_list = input("Введите через пробел элементы списка: ").split(" ")

# Установка длинны списка для будущего цикла
len_list = len(castling_list) if len(castling_list) % 2 == 0 else len(castling_list) - 1

for i in range(0, len_list, 2):
    var = castling_list[i]
    castling_list[i] = castling_list[i + 1]
    castling_list[i + 1] = var

print(f"Вашщ список перекручен вот так: {castling_list}")
