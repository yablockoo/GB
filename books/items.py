# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class BooksItem(scrapy.Item):
    # define the fields for your item here like:
    link = scrapy.Field()
    name = scrapy.Field()
    author = scrapy.Field()
    price = scrapy.Field()
    sale_price = scrapy.Field()
    rate = scrapy.Field()
    _id = scrapy.Field()



