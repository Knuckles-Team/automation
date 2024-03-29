#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
import json
from transformers import pipeline
import html
import barchart_api

class NewsScrape:
    def __init__(self):
        self.barchart_client = barchart_api.Api(url="https://www.barchart.com/")
        self.tickers = self.barchart_client.get_top_stocks_top_own(max_pages=1)
        self.tickers = self.tickers[0]['data'][2:7]
        print(f"Top Stocks: {json.dumps(self.tickers, indent=2)}")

        self.companies = []

        self.urls = [
            'https://www.bbc.com/news',
            'https://www.bbc.com/news/business',
            'https://www.bbc.com/news/technology',
            'https://www.forbes.com/news',
            'https://www.forbes.com/money',
            'https://www.forbes.com/policy',
            'https://www.forbes.com/banking-insurance',
            'https://www.forbes.com/etfs-mutual-funds/',
            'https://www.forbes.com/hedge-funds-private-equity',
            'https://www.forbes.com/investing',
            'https://www.forbes.com/markets',
            'https://www.forbes.com/personal-finance',
            'https://www.foxnews.com/us',
            'https://www.foxnews.com/politics',
            'https://www.foxnews.com/world',
            'https://www.foxnews.com/science',
            'https://www.foxnews.com/tech',
            'https://www.foxbusiness.com/economy',
            'https://www.foxbusiness.com/markets',
            'https://finance.yahoo.com/news',
            'https://finance.yahoo.com/live/politics/',
            'https://www.cnn.com/us',
            'https://www.cnn.com/world',
            'https://www.cnn.com/politics',
            'https://www.cnn.com/business',
            'https://www.nytimes.com/',
            'https://www.nytimes.com/section/world',
            'https://www.nytimes.com/section/us',
            'https://www.nytimes.com/section/politics',
            'https://www.nytimes.com/section/business',
            'https://www.nytimes.com/section/science',
            'https://www.theguardian.com/us',
            'https://www.theguardian.com/us-news',
            'https://www.theguardian.com/world',
            'https://www.theguardian.com/us-news/us-politics',
            'https://www.theguardian.com/us/business',
            'https://www.theguardian.com/us/technology',
            'https://www.theguardian.com/science',
            'http://www.thedailybeast.com/',
            'https://www.thedailybeast.com/category/us-news',
            'https://www.thedailybeast.com/category/politics',
            'https://www.thedailybeast.com/category/world',
            'https://www.thedailybeast.com/category/innovation',
            'https://www.thedailybeast.com/category/tech',
            'https://www.reuters.com/',
            'https://www.reuters.com/world/',
            'https://www.reuters.com/business/',
            'https://www.reuters.com/technology/',
            'https://www.huffpost.com/',
            'https://www.huffpost.com/news/politics',
            'https://www.usatoday.com/news/nation/',
            'https://www.usatoday.com/money/',
            'https://www.usatoday.com/tech/',
            'https://www.businessinsider.com/',
            'https://www.businessinsider.com/sai',
            'https://www.businessinsider.com/clusterstock',
            'https://markets.businessinsider.com/',
            'https://www.businessinsider.com/warroom',
            'https://www.businessinsider.com/retail',
            'https://www.newsweek.com/',
            'https://www.newsweek.com/us',
            'https://www.newsweek.com/world',
            'https://www.newsweek.com/tech-science',
            'https://www.npr.org/',
            'https://www.npr.org/sections/national/',
            'https://www.npr.org/sections/world/',
            'https://www.npr.org/sections/business/',
            'https://www.npr.org/sections/science/',
            'https://www.npr.org/sections/climate/',
            'https://www.npr.org/sections/politics/',
            'https://www.politico.com/',
            'https://www.latimes.com/',
            'https://www.latimes.com/business',
            'https://www.latimes.com/politics',
            'https://www.latimes.com/world-nation',
            'https://www.nbcnews.com/',
            'https://www.nbcnews.com/politics',
            'https://www.nbcnews.com/us-news',
            'https://www.nbcnews.com/world',
            'https://www.nbcnews.com/tech-media',
            'https://news.google.com/topics/CAAqIggKIhxDQkFTRHdvSkwyMHZNRGxqTjNjd0VnSmxiaWdBUAE?hl=en-US&gl=US&ceid=US%3Aen',
            'https://news.google.com/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGx1YlY4U0FtVnVHZ0pWVXlnQVAB?hl=en-US&gl=US&ceid=US%3Aen',
            'https://news.google.com/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGRqTVhZU0FtVnVHZ0pWVXlnQVAB?hl=en-US&gl=US&ceid=US%3Aen',
            'https://news.google.com/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRFp0Y1RjU0FtVnVHZ0pWVXlnQVAB?hl=en-US&gl=US&ceid=US%3Aen',
        ]
        # https://huggingface.co/docs/transformers/main_classes/pipelines
        self.sentiment_pipeline = pipeline("sentiment-analysis")

    def scrape_news_yahoo(self):
        for ticker_index in range(0, len(self.tickers)):
            self.companies.append(self.search_company(self.tickers[ticker_index]['symbolName']))
            self.companies.append(self.search_company(self.tickers[ticker_index]['symbol']))

    def search_company(self, search):
        yfinance = "https://query2.finance.yahoo.com/v1/finance/search"
        user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
        params = {"q": search, "quotes_count": 1, "country": "United States"}
        print(f"Searching: {search}...")
        res = requests.get(url=yfinance, params=params, headers={'User-Agent': user_agent})
        data = res.json()
        data.pop('explains', None)
        data.pop('count', None)
        data.pop('nav', None)
        data.pop('lists', None)
        data.pop('researchReports', None)
        data.pop('screenerFieldResults', None)
        data.pop('totalTime', None)
        data.pop('timeTakenForQuotes', None)
        data.pop('timeTakenForNews', None)
        data.pop('timeTakenForAlgowatchlist', None)
        data.pop('timeTakenForPredefinedScreener', None)
        data.pop('timeTakenForCrunchbase', None)
        data.pop('timeTakenForNav', None)
        data.pop('timeTakenForResearchReports', None)
        data.pop('timeTakenForScreenerField', None)
        data.pop('timeTakenForCulturalAssets', None)
        for quote_index in range(0, len(data['quotes'])):
            data['symbol'] = data['quotes'][0]['symbol']
            data['symbolName'] = data['quotes'][0]['longname']
            data['quotes'][quote_index].pop('index', None)
            data['quotes'][quote_index].pop('typeDisp', None)
            data['quotes'][quote_index].pop('isYahooFinance', None)
            data['quotes'][quote_index].pop('shortname', None)
        data.pop('quotes', None)
        data['news_headlines'] = []
        for news_index in range(0, len(data['news'])):
            data['news'][news_index].pop('uuid', None)
            data['news'][news_index].pop('type', None)
            data['news'][news_index].pop('thumbnail', None)
            title = html.unescape(data['news'][news_index]['title'])
            title = title.encode("ascii", "ignore")
            title = title.decode()
            data['news_headlines'].append(title)
        data['url'] = "Yahoo News"
        data.pop('news', None)
        return data

    def scrape_news(self):
        for url in self.urls:
            response = requests.get(url)
            soup = BeautifulSoup(response.text, 'html.parser')
            headlines_1 = None
            headlines_2 = None
            headlines_3 = None
            headlines_4 = None
            paragraphs = None
            search_terms = None
            try:
                headlines_1 = soup.find('body').find_all('h1')
            except Exception as e:
                print(f"Unable to find body of request. \nError: {e}")
            try:
                headlines_2 = soup.find('body').find_all('h2')
            except Exception as e:
                print(f"Unable to find body of request. \nError: {e}")
            try:
                headlines_3 = soup.find('body').find_all('h3')
            except Exception as e:
                print(f"Unable to find body of request. \nError: {e}")
            try:
                headlines_4 = soup.find('body').find_all('h4')
            except Exception as e:
                print(f"Unable to find body of request. \nError: {e}")
            try:
                paragraphs = soup.find('body').find_all('p')
            except Exception as e:
                print(f"Unable to find body of request. \nError: {e}")
            search_terms = headlines_1 + headlines_2 + headlines_3 + headlines_4 + paragraphs
            if not search_terms:
                print(f"Nothing found for: {url}")
                return
            unwanted_filters = ['BBC World News TV', 'BBC World Service Radio',
                                'News daily newsletter', 'Mobile app', 'Get in touch']
            cleaned_text = []
            for text in list(dict.fromkeys(search_terms)):
                for unwanted_filter in unwanted_filters:
                    if unwanted_filter not in text.text.strip():
                        cleaned_text.append(text.text.strip())
            cleaned_text = list(set(cleaned_text))
            for text in cleaned_text:
                text = html.unescape(text)
                text = text.encode("ascii", "ignore")
                text = text.decode()
                for ticker in self.tickers:
                    if ticker['symbolName'] in text:
                        print(f"{ticker['symbolName']} was found in {text}")
                        if len(self.companies) == 0:
                            new_company = {
                                "symbolName": ticker['symbolName'],
                                "symbol": ticker['symbol'],
                                "news_headlines": [text],
                                "url": url,
                            }
                            self.companies.append(new_company)
                        company_index = 0
                        if ticker['name'] in self.companies[company_index]['name']:
                            self.companies[company_index]['news_headlines'].append(text)
                        elif ticker['name'] not in self.companies[company_index]['name']:
                            new_company = {
                                "symbolName": ticker['symbolName'],
                                "symbol": ticker['symbol'],
                                "news_headlines": [text],
                                "url": url,
                            }
                            self.companies.append(new_company)

    def get_sentiment(self, company_index):
        result = self.sentiment_pipeline(self.companies[company_index]['news_headlines'])
        for data_index in range(0, len(self.companies[company_index]['news_headlines'])):
            self.companies[company_index]['news_headlines'][data_index] = {
                "headline": self.companies[company_index]['news_headlines'][data_index],
                "label": result[data_index]['label'],
                "score": result[data_index]['score'],
            }

    def deduplicate_news_headlines(self):
        res_list = []
        for i in range(len(self.companies)):
            if self.companies[i] not in self.companies[i + 1:]:
                res_list.append(self.companies[i])
        self.companies = res_list
        for company_index in range(0, len(self.companies)):
            self.companies[company_index]['news_headlines'] = list(set(self.companies[company_index]['news_headlines']))

    def retreive_news(self):
        self.scrape_news()
        #self.scrape_news_yahoo()
        self.deduplicate_news_headlines()
        for company_index in range(0, len(self.companies)):
            self.get_sentiment(company_index=company_index)
        print(f"Data: {json.dumps(self.companies, indent=2)}")

if __name__ == "__main__":
    pynews_client = NewsScrape()
    pynews_client.retreive_news()
    print("Complete!")