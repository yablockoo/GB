products = []
n = 1
products_dict = {"название": [], "цена": [], "количество": [], "единицы": []}

while True:
    user_str = input("Введите (через пробел) название товара, цену, количество, единицы: ").split()
    products.append((n, dict(zip(["название", "цена", "количество", "единицы"], user_str))))

    if input("вводим еще продукт? (д/н) :") == "д":
        n += 1
        continue
    else:
        print(products)
        break

for i in range(len(products)):
    for key in products[i][1]:
        products_dict[key].append(products[i][1].get(key))

print(products_dict)
