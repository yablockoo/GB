workers = {}
average = 0
count = 0

with open("text_3.txt", "r", encoding="utf-8") as f_obj:
    for line in f_obj:
        var_str = line.split()
        var_str[1] = float(var_str[1])
        workers[var_str[0]] = var_str[1]
        average += var_str[1]
        count += 1


print("Работники с зарплатой менее 20000:")
for key, val in workers.items():
    if val < 20000:
        print(key)

print(f"\nСредняя зарплата: {average / count :.2f}")
