from lxml import html
import requests
from pprint import pprint
import datetime
from pymongo import MongoClient

client = MongoClient('localhost', 27017)
news = client['news']
articles = news.articles

header = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36'}
response_y = requests.get('https://yandex.ru/news/', headers=header)
dom_y = html.fromstring(response_y.text)

yandex = dom_y.xpath("//article ")

for y in yandex:
    yandex_data = {}

    link = y.xpath(".//a[@class='mg-card__link']/@href")

    raw_date = y.xpath(".//span[@class='mg-card-source__time']/text()")
    date = []
    for d in raw_date:
        date.append(datetime.datetime.today().strftime("%Y.%m.%d.") + d)

    raw_title = y.xpath(".//h2[@class='mg-card__title']/text()")
    title = []
    for s in raw_title:
        title.append(s.replace(u'\xa0', u' '))

    source = y.xpath(".//a[@class='mg-card__source-link']/text()")

    yandex_data['source'] = source
    yandex_data['title'] = title
    yandex_data['link'] = link
    yandex_data['date'] = date

    news.articles.insert_one(yandex_data)
    pprint(yandex_data)
    