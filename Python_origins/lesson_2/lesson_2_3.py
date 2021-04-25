month = int(input("Введите номер месяца (от 1 до 12): "))
winter = [12, 1, 2]
spring = [3, 4, 5]
summer = [6, 7, 8]
autumn = [9, 10, 11]
seasons = {"Зима": winter, "Весна": spring, "Лето": summer, "Осень": autumn}

for key, value in seasons.items():
    if month in value:
        print(f"Месяц №{month} это {key}")
        break
    else:
        continue
