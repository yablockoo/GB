lines = 0
words = 0

with open('text_2.txt', 'r', encoding="utf-8") as andrew:
    for line in andrew:
        words += len(line.split())
        lines += 1

print(f"lines = {lines}\nwords = {words}")
