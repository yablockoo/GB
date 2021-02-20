def personal_data(name, firstname, birth_year, city, email, call):
    print(f"{name} {firstname}, {birth_year} г.р., г.{city}, e-mail: {email}, тел.: {call}")


data = input("Введите через пробел: Имя; Фамилия; год рождения; e-mail; телефон:   ").split()
personal_data(name=data[0], firstname=data[1], birth_year=data[2], city=data[3], email=data[4], call=data[5])
