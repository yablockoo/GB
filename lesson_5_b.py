from pprint import pprint
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from pymongo import MongoClient
from selenium.webdriver.common.keys import Keys
import time

sleep = 3

client = MongoClient('localhost', 27017)
goods = client['goods']
products = goods.products

chrome_options = Options()
chrome_options.add_argument("start-maximized")
# chrome_options.add_argument("--headless")


def scraping():
    driver = webdriver.Chrome(executable_path='./chromedriver.exe', options=chrome_options)
    driver.get("https://www.mvideo.ru/promo/novinki-tehniki-mark163900062")

    html = driver.find_element_by_tag_name('html')
    html.send_keys(Keys.END)

    wait = WebDriverWait(driver, 10)

    wait.until(EC.visibility_of_all_elements_located(
            (By.XPATH, '//a[@class="fl-product-tile-title__link sel-product-tile-title"]')
        ))

    goods_set = driver.find_elements_by_xpath('//a[@class="fl-product-tile-title__link sel-product-tile-title"]')

    for g in goods_set:
        product_data_r = g.get_attribute('data-product-info')
        product_data_raw = product_data_r.split('"')

        product_data = {product_data_raw[1]: product_data_raw[3], product_data_raw[5]: product_data_raw[7],
                        product_data_raw[9]: product_data_raw[11], product_data_raw[13]: product_data_raw[15],
                        product_data_raw[17]: product_data_raw[19], product_data_raw[21]: product_data_raw[23],
                        product_data_raw[25]: product_data_raw[27], product_data_raw[29]: product_data_raw[31],
                        product_data_raw[33]: product_data_raw[34]}

        p_id = product_data['productId']

        search_res = products.find_one({'productId': p_id})
        if search_res is None:
            goods.products.insert_one(product_data)
            print("\033[32m {} \33[36m".format('NEW DATA:'))
            pprint(product_data)
        else:
            print('Новые данные не обнаружены.')

    driver.close()


while True:
    scraping()
    time.sleep(sleep)
