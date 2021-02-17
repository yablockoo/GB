print("Введите строки-данные:")
with open("text_1.txt", 'w') as f_obj:
    while True:
        context = input()
        if context:
            f_obj.write(context + "\n")
        else:
            break
