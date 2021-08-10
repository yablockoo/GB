from bs4 import BeautifulSoup as bs
import requests
from pprint import pprint

url = "https://roscontrol.com"
add_url = '/category/produkti/'

headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'}

def get_categories(u):
    c_url = u
    response = requests.get(c_url, headers=headers)

    soup = bs(response.text, 'html.parser')

    categories_list = soup.find_all('div', {"grid-padding grid-column-3 grid-column-large-6 grid-flex-mobile grid-column-middle-6 grid-column-small-12 grid-left"})

    categories = []
    cat_id = 1
    for cat in categories_list:
        cat_data = {}
        category = cat.find('div', {'class': 'catalog__category-name'}).getText()
        cat_url = url + cat.a['href']

        cat_data['id'] = cat_id
        cat_data['category'] = category
        cat_data['cat_url'] = cat_url

        categories.append(cat_data)

        cat_id += 1

    return categories

def category_choose():
    print("Выберите № категории продуктов:")
    categories = get_categories(url + add_url)
    for cat in categories:
        print(f"{cat['id']}: {cat['category']}")
    print('Для выхода выберите 0!')

    inp = int(input("Ввод: "))

    if inp > len(categories):
        print("Неправильный номер.")
        category_choose()
    elif inp == 0:
        print("\nКонец работы программы.")
    else:
        subcategories = get_categories(categories[inp - 1]["cat_url"])
        for cat in subcategories:
            print(f"{cat['id']}: {cat['category']}")
        print('Для выхода выберите 0!')

        inp_2 = int(input("Ввод: "))

        if inp_2 > len(subcategories):
            print("Неправильный номер.")
            category_choose()
        elif inp_2 == 0:
            print("\nКонец работы программы.")
        else:
            pass

category_choose()


