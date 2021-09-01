# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter
from pymongo import MongoClient

class BooksPipeline:
    def __init__(self):
        client = MongoClient('localhost', 27017)
        self.books = client['books']

    def process_item(self, item, spider):
        collection = self.books[spider.name]
        item.update({'price': int(item['price'])})
        item.update({'sale_price': int(item['sale_price'])})
        item.update({'rate': float(item['rate'])})
        collection.insert_one(item)
        return item
