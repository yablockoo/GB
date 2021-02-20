from sys import argv

script_name, work_hours, rate, prize = argv
work_hours = int(work_hours)
rate = int(rate)
prize = int(prize)
print(f"Выработка: {work_hours}, ставка: {rate}, премия: {prize}. Ваша зарплата: {work_hours * rate + prize}р.")
