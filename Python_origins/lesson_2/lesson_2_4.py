words = input("Введите слова через пробел: ").split()

for n, el in enumerate(words):
    print(n, el[:10])
