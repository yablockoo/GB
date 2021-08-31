# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class InstaparserItem(scrapy.Item):
    # define the fields for your item here like:
    followed_user_id = scrapy.Field()
    followed_username = scrapy.Field()
    subscribe_by_user_id = scrapy.Field()
    subscribe_by_username = scrapy.Field()
    user_id = scrapy.Field()
    username = scrapy.Field()
    profile_pic_url = scrapy.Field()
    follower_data = scrapy.Field()
    _id = scrapy.Field()
