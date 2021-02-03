score_list = [1, 2, 5, 5, 1]

while True:
    new_score = int(input("Введите новое чилсо: "))

    if new_score not in score_list:
        score_list.insert(0, new_score)
    else:
        new_pos = score_list.index(new_score)
        new_pos += score_list.count(new_score)
        score_list.insert(new_pos, new_score)

    print(score_list.sort(key=))
