import scrapy
from leroymerlin.items import LeroymerlinItem
from scrapy.http import HtmlResponse
from scrapy.loader import ItemLoader


class LmSpider(scrapy.Spider):
    name = 'lm'
    allowed_domains = ['leroymerlin.ru']
    start_urls = ['https://leroymerlin.ru/catalogue/umnyy-dom/']

    def parse(self, response: HtmlResponse):
        prod_links = response.xpath('//a[@data-qa="product-name"]')
        next_page = response.xpath('//a[@class="bex6mjh_plp s15wh9uj_plp l7pdtbg_plp r1yi03lb_plp sj1tk7s_plp"]/@href')\
            .get()

        for link in prod_links:
            yield response.follow(link, callback=self.prod_parse)

        if next_page:
            yield response.follow(next_page, callback=self.parse)

    def prod_parse(self, response: HtmlResponse):
        loader = ItemLoader(item=LeroymerlinItem(), response=response)
        loader.add_value('link', response.url)
        loader.add_xpath('name', '//h1/text()')
        loader.add_xpath('price', '//span[@slot="price"]/text()')
        loader.add_xpath('photos', '//source[@media=" only screen and (min-width: 1024px)"]/@srcset')
        # //img[@slot="thumbs"]/@src
        yield loader.load_item()

