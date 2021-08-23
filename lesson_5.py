from pprint import pprint
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from pymongo import MongoClient

client = MongoClient('localhost', 27017)
mail_db = client['mail_db']
products = mail_db.mails

chrome_options = Options()
# chrome_options.add_argument("start-maximized")
chrome_options.add_argument("--headless")

driver = webdriver.Chrome(executable_path='./chromedriver.exe', options=chrome_options)

driver.get("https://mail.ru")

login = driver.find_element_by_name('login')
login.send_keys('study.ai_172')
login.send_keys(Keys.ENTER)

wait = WebDriverWait(driver, 10)

wait.until(EC.element_to_be_clickable(
        (By.NAME, 'password')
    )).send_keys('NextPassword172!!!')

wait.until(EC.element_to_be_clickable(
        (By.NAME, 'password')
    )).send_keys(Keys.ENTER)

wait.until(EC.element_to_be_clickable(
        (By.CLASS_NAME, 'llc__container')
    ))

mail = driver.find_elements_by_class_name('llc__container')

i = 0

for m in mail:

    mail[i].click()

    wait.until(EC.element_to_be_clickable(
        (By.CLASS_NAME, 'letter-contact')
    ))

    sender = driver.find_element_by_class_name('letter-contact').get_attribute('title')
    date = driver.find_element_by_class_name('letter__date').text
    theme = driver.find_element_by_class_name('thread__subject').text
    try:
        text = driver.find_element_by_xpath("//body/div[@id='app-canvas']/div[1]/div[1]/div[1]/div[1]/div[2]/span[1]/div[2]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[3]/div[2]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]").text
    except Exception as exc:
        text = 'Что-то пошло не так...'

    mail_data = {'sender': sender, 'date': date, 'theme': theme, 'text': text}
    pprint(mail_data)
    mail_db.mails.insert_one(mail_data)

    i += 1

    driver.get('https://e.mail.ru/inbox/?back=1')

    wait.until(EC.element_to_be_clickable(
        (By.CLASS_NAME, 'llc__container')
    ))

    mail = driver.find_elements_by_class_name('llc__container')







