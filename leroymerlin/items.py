# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html
from itemloaders.processors import MapCompose, TakeFirst
import scrapy


def get_price(value: str):
    try:
        return int(value.replace(' ', ''))
    except:
        return value


class LeroymerlinItem(scrapy.Item):
    # define the fields for your item here like:
    name = scrapy.Field(output_processor=TakeFirst())
    price = scrapy.Field(input_processor=MapCompose(get_price), output_processor=TakeFirst())
    link = scrapy.Field(output_processor=TakeFirst())
    photos = scrapy.Field()
