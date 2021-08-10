from bs4 import BeautifulSoup as bs
import requests
from pprint import pprint
import pandas as pd
import json

url = "https://roscontrol.com"
add_url = '/category/produkti/'
final_df = {}

headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'}


def get_categories(u):
    gc_url = u
    response = requests.get(gc_url, headers=headers)

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


def content_load(u):
    cl_url = u
    response = requests.get(cl_url, headers=headers)

    soup = bs(response.text, 'html.parser')

    products_list = soup.find_all('div', {"wrap-product-catalog__item grid-padding grid-column-4 grid-column-large-6 grid-column-middle-12 grid-column-small-12 grid-left js-product__item"})

    products = []
    for prod in products_list:
        product_data = {}
        name = prod.find('div', {'class': 'product__item-link'}).getText()
        rating = prod.find_all('i')
        safety = rating[0]['data-width']
        naturalness = rating[1]['data-width']
        nutritional_value = rating[2]['data-width']
        quality = rating[3]['data-width']
        avg_grade = prod.find('div', {'class': "rate green rating-value"}).getText()
        product_url = prod.a['href']

        product_data['name'] = name
        product_data['safety'] = safety
        product_data['naturalness'] = naturalness
        product_data['nutritional_value'] = nutritional_value
        product_data['quality'] = quality
        product_data['avg_grade'] = avg_grade
        product_data['url'] = url + product_url

        products.append(product_data)

    return products


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
            data = content_load(subcategories[inp_2 - 1]["cat_url"])
            pprint(data)
            save_inp = input('\nСохранить данные? (y/n)')
            if save_inp == 'y':
                final_df.update(data)
                print('Данные успешно сохранены!')
            else:
                final_inp = input('Закончить работу? (y/n)')
                if final_inp == 'y':
                    pd.DataFrame(final_df)
                    with open('data2.json', 'w') as f:
                        json.dump(final_df.json(), f)
                    print('Конец работы.')
                else:
                    category_choose()


category_choose()
