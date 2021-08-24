import scrapy
from scrapy.http import HtmlResponse
from books.items import BooksItem


class LabSpider(scrapy.Spider):
    name = 'lab'
    allowed_domains = ['labirint.ru']
    start_urls = ['https://www.labirint.ru/search/%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5/?stype=0']

    def parse(self, response: HtmlResponse):
        links = response.xpath('//a[@class="product-title-link"]/@href').extract()
        next_page = response.xpath('//a[@class="pagination-next__text"]/@href').extract_first()

        if next_page:
            yield response.follow(next_page, callback=self.parse)

        for link in links:
            yield response.follow(link, callback=self.book_parse)

    def book_parse(self, response: HtmlResponse):
        link_data = response.url
        name_data = response.xpath('//h1/text()').extract_first()
        author_data = response.xpath('//div[@class="authors"]/a[@data-event-content]/text()').extract_first()
        price_data = response.xpath('//span[@class="buying-priceold-val-number"]/text()').extract_first()
        sale_price_data = response.xpath('//span[@class="buying-pricenew-val-number"]/text()').extract_first()
        rate_data = response.xpath('//div[@id="rate"]/text()').extract_first()

        item = BooksItem(link=link_data, name=name_data, author=author_data, price=price_data,
                         sale_price=sale_price_data, rate=rate_data)
        yield item
