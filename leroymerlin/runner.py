from scrapy.crawler import CrawlerProcess
from scrapy.settings import Settings

from leroymerlin import settings
from leroymerlin.spiders.lm import LmSpider

if __name__ == '__main__':

    crawler_settings = Settings()
    crawler_settings.setmodule(settings)

    process = CrawlerProcess(settings=crawler_settings)
    process.crawl(LmSpider)

    process.start()
