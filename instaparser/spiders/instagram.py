import scrapy
from scrapy.http import HtmlResponse
import re
import json
from instaparser.items import InstaparserItem


class InstagramSpider(scrapy.Spider):
    name = 'instagram'
    allowed_domains = ['instagram.com']
    start_urls = ['https://www.instagram.com']
    insta_login = 'Onliskill_udm'
    insta_pass = '#PWD_INSTAGRAM_BROWSER:10:1629825416:ASpQAMvl1EAdo0NdRZNcM1/pjlU9rRg4n4cjCM00SDGSV5pDN6XbC93ZbYN67HUOHkXZnGGe2gIWPU2qtQY0HAkIjR5U5syu+lv8qtqeI7cyy2ua6WmBV6AngVo1apn3eJ6O3UAFVgb+q5HtHsQ='
    insta_login_link = 'https://www.instagram.com/accounts/login/ajax/'
    user_parse = ['yablockoo', 'polyzolo', 'mun_kafka']
    query_hash = '8c2a529969ee035a5063f2fc8602a0fd'
    instapi_url = 'https://i.instagram.com/api/v1/friendships/'

    def parse(self, response: HtmlResponse):
        csrf = self.fetch_csrf_token(response.text)
        yield scrapy.FormRequest(self.insta_login_link,
                                 method='POST',
                                 callback=self.user_login,
                                 formdata={'username': self.insta_login,
                                           'enc_password': self.insta_pass},
                                 headers={'X-CSRFToken': csrf,
                                          'User-Agent': 'Instagram 155.0.0.37.107'})

    def user_login(self, response: HtmlResponse):
        j_body = response.json()
        if j_body['authenticated']:
            for u in self.user_parse:
                yield response.follow(f'/{u}',
                                      callback=self.user_data_parse,
                                      cb_kwargs={'username': u})

    def user_data_parse(self, response: HtmlResponse, username):
        user_id = self.fetch_user_id(response.text, username)

        url_followers = f'{self.instapi_url}{user_id}/followers/?count=12&search_surface=follow_list_page'

        yield response.follow(url_followers,
                              callback=self.user_followers_parse,
                              cb_kwargs={'username': username,
                                         'user_id': user_id},
                              headers={'User-Agent': 'Instagram 155.0.0.37.107'})

        url_subscribes = f'{self.instapi_url}{user_id}/following/?count=12'

        yield response.follow(url_subscribes,
                              callback=self.user_subscribes_parse,
                              cb_kwargs={'username': username,
                                         'user_id': user_id},
                              headers={'User-Agent': 'Instagram 155.0.0.37.107'})

    def user_followers_parse(self, response: HtmlResponse, username, user_id):
        if response.status == 200:
            j_data = response.json()

            if j_data.get('big_list'):
                max_id_f = j_data.get('next_max_id')

                url_followers = f'{self.instapi_url}{user_id}/followers/?count=12&max_id={max_id_f}' \
                                f'&search_surface=follow_list_page'

                yield response.follow(url_followers,
                                      callback=self.user_followers_parse,
                                      cb_kwargs={'username': username,
                                                 'user_id': user_id},
                                      headers={'User-Agent': 'Instagram 155.0.0.37.107'})

            followers = j_data.get('users')

            for follower in followers:
                item = InstaparserItem(followed_user_id=user_id,
                                       followed_username=username,
                                       user_id=follower.get('pk'),
                                       username=follower.get('username'),
                                       profile_pic_url=follower.get('profile_pic_url'),
                                       follower_data=follower
                                       )
                yield item

    def user_subscribes_parse(self, response: HtmlResponse, username, user_id):
        if response.status == 200:
            j_data = response.json()

            if j_data.get('big_list'):
                max_id_s = j_data.get('next_max_id')

                url_subscribes = f'{self.instapi_url}{user_id}/following/?count=12&max_id={max_id_s}'

                yield response.follow(url_subscribes,
                                      callback=self.user_followers_parse,
                                      cb_kwargs={'username': username,
                                                 'user_id': user_id},
                                      headers={'User-Agent': 'Instagram 155.0.0.37.107'})

            subscribes = j_data.get('users')

            for subscribe in subscribes:
                item = InstaparserItem(subscribe_by_user_id=user_id,
                                       subscribe_by_username=username,
                                       user_id=subscribe.get('pk'),
                                       username=subscribe.get('username'),
                                       profile_pic_url=subscribe.get('profile_pic_url'),
                                       follower_data=subscribe
                                       )
                yield item

    def fetch_csrf_token(self, text):
        matched = re.search('\"csrf_token\":\"\\w+\"', text).group()
        return matched.split(':').pop().replace(r'"', '')

    def fetch_user_id(self, text, username):
        matched = re.search(
            '{\"id\":\"\\d+\",\"username\":\"%s\"}' % username, text
        ).group()
        return json.loads(matched).get('id')

