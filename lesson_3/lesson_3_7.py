def int_func(word_list):
    for i in range(len(word_list)):
        word_list[i] = word_list[i].title()
    return " ".join(word_list)


tmp_list = input("Введите слова через пробел на латинице: ").split()
print(int_func(tmp_list))
