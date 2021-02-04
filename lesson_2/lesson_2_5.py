score_list = []

while True:
    new_score = int(input("Введите новое число: "))
    # Вставка числа в случае пустотого списка
    if len(score_list) == 0:
        score_list.append(new_score)
        print(score_list)
        continue

    for i in range(len(score_list)):
        if new_score <= score_list[i]:   # Если введенное число меньше, то идем на след. шаг
            if i == len(score_list) - 1:
                score_list.append(new_score)   # Если число меньше всех чисел, вставка в конец
            continue
        else:
            score_list.insert(i, new_score)   # Если число больше, вставка на тек. позицию
            break
    print(score_list)
