t_sec = int((input("Введите количество секунд: ")))

t_sec = t_sec - 86400 * (t_sec // 86400)  # Вычитание суток из общего кол-ва секунд
t_hour = t_sec // 3600
t_sec %= 3600
t_min = t_sec // 60
t_sec %= 60

print(f"Время на часах [{t_hour:02}:{t_min:02}:{t_sec:02}]")
