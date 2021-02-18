ru_list = []

with open("text_4_eng.txt", "r", encoding="utf-8") as eng_f:
    for line in eng_f:
        ru_list.append(line.split())


with open("text_4_ru.txt", "w", encoding="utf-8") as ru_f:
    ru_list[0][0] = "Один"
    ru_list[1][0] = "Два"
    ru_list[2][0] = "Три"
    ru_list[2][0] = "Четыре"

    for el in ru_list:
        ru_f.write(" ".join(el) + "\n")
