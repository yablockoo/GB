from pymongo import MongoClient
import json
from pprint import pprint
from bs4 import BeautifulSoup as bs
import pandas as pd
import requests

client = MongoClient('localhost', 27017)
grades = client['grades']
products = grades.products

url = "https://roscontrol.com"
add_url = '/category/produkti/'
final_df = []
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'}

with open('data2.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
    for d in data:
        grades.products.insert_many(d)


# Вывод продуктов с общей оценкой выше указанной
def show_grades(grade):
    return grades.products.find(
        {'avg_grade': {'$gt': grade}},
        {'name': 1, 'avg_grade': 1}
    )


# Добавление нового продукта
def insert_new(u):
    response = requests.get(u, headers=headers)

    soup = bs(response.text, 'html.parser')

    products_list = soup.find_all('div', {
        "wrap-product-catalog__item grid-padding grid-column-4 grid-column-large-6 grid-column-middle-12 grid-column-small-12 grid-left js-product__item"})

    for prod in products_list:
        product_data = {}
        try:
            name = prod.find('div', {'class': 'product__item-link'}).getText()
            rating = prod.find_all('i')
            safety = int(rating[0]['data-width'])
            naturalness = int(rating[1]['data-width'])
            nutritional_value = int(rating[2]['data-width'])
            quality = int(rating[3]['data-width'])
            avg_grade = int(
                prod.find('div', {'class': "product-rating util-table-cell js-has_vivid_rows"}).contents[1].getText())
            product_url = prod.a['href']
        except Exception as ex:
            print("Тут что-то пошло не так...")
            continue
        else:
            product_data['name'] = name
            product_data['safety'] = safety
            product_data['naturalness'] = naturalness
            product_data['nutritional_value'] = nutritional_value
            product_data['quality'] = quality
            product_data['avg_grade'] = avg_grade
            product_data['url'] = url + product_url

            search_res = products.find_one({'name': name})
            if search_res is None:
                grades.products.insert_one(product_data)
                print("\033[32m {} \33[36m".format('NEW DATA:'))
                pprint(product_data)
            else:
                print('Новые данные не обнаружены.')


for gr in show_grades(50):
    pprint(gr)

insert_new('https://roscontrol.com/category/produkti/molochnie_produkti/moloko/')
