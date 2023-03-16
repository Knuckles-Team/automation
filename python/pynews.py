#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
import json
from transformers import pipeline
import html

class NewsScrape:
    def __init__(self):

        self.tickers = [
            {
                'name': 'Tesla',
                'ticker': 'TSLA'
            },
            {
                'name': 'Apple',
                'ticker': 'AAPL'
            },
            {
                'name': 'Google',
                'ticker': 'GOOGL'
            },
        ]

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
        ]
        # https://huggingface.co/docs/transformers/main_classes/pipelines
        self.sentiment_pipeline = pipeline("sentiment-analysis")

    def get_company_information(self):
        for ticker_index in range(0, len(self.tickers)):
            self.companies.append(self.search_company(self.tickers[ticker_index]))
            print(f"Ticker: {self.companies[ticker_index]['ticker']}\n"
                  f"Name: {self.companies[ticker_index]['name']}\n"
                  f"Exchange: {self.companies[ticker_index]['exchange']}\n"
                  f"Industry: {self.companies[ticker_index]['industry']}\n"
                  f"Sector: {self.companies[ticker_index]['sector']}\n"
                  f"News: {self.companies[ticker_index]['news_headlines']}\n")

    def search_company(self, search):
        yfinance = "https://query2.finance.yahoo.com/v1/finance/search"
        user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
        params = {"q": search, "quotes_count": 1, "country": "United States"}

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
        data['ticker'] = data['quotes'][0]['symbol']
        data['name'] = data['quotes'][0]['longname']
        data['exchange'] = data['quotes'][0]['exchange']
        data['industry'] = data['quotes'][0]['industry']
        data['sector'] = data['quotes'][0]['sector']
        for quote_index in range(0, len(data['quotes'])):
            data['quotes'][quote_index].pop('index', None)
            data['quotes'][quote_index].pop('typeDisp', None)
            data['quotes'][quote_index].pop('isYahooFinance', None)
            data['quotes'][quote_index].pop('shortname', None)
        data['news_headlines'] = []
        for news_index in range(0, len(data['news'])):
            data['news'][news_index].pop('uuid', None)
            data['news'][news_index].pop('type', None)
            data['news'][news_index].pop('thumbnail', None)
            data['news_headlines'].append(data['news'][news_index]['title'])
        return data

    def scrape_news(self):
        for url in self.urls:
            response = requests.get(url)
            soup = BeautifulSoup(response.text, 'html.parser')
            headlines_1 = soup.find('body').find_all('h1')
            headlines_2 = soup.find('body').find_all('h2')
            headlines_3 = soup.find('body').find_all('h3')
            headlines_4 = soup.find('body').find_all('h4')
            paragraphs = soup.find('body').find_all('p')
            search_terms = headlines_1 + headlines_2 + headlines_3 + headlines_4 + paragraphs
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
                    if ticker['name'] in text:
                        print(f"{ticker['name']} was found in {text}")
                        if len(self.companies) == 0:
                            new_company = {
                                "name": ticker['name'],
                                "ticker": ticker['ticker'],
                                "news_headlines": [text]
                            }
                            self.companies.append(new_company)
                        company_index = 0
                        if ticker['name'] in self.companies[company_index]['name']:
                            #print(f"Appending news headline to {self.companies[company_index]['name']}")
                            self.companies[company_index]['news_headlines'].append(text)
                        elif ticker['name'] not in self.companies[company_index]['name']:
                            #print(f"Company not found, creating one for {ticker['name']}")
                            new_company = {
                                "name": ticker['name'],
                                "ticker": ticker['ticker'],
                                "news_headlines": [text]
                            }
                            self.companies.append(new_company)
                    #elif ticker['ticker'] in text:
                        #print(f"{ticker['ticker']} IN {text}")

        self.dedeplicate_news_headlines()

        #print(f"COMPANIES: {json.dumps(self.companies,indent=2)}")

    def get_sentiment(self, company_index):
        result = self.sentiment_pipeline(self.companies[company_index]['news_headlines'])
        for data_index in range(0, len(self.companies[company_index]['news_headlines'])):
            self.companies[company_index]['news_headlines'][data_index] = {
                "headline": self.companies[company_index]['news_headlines'][data_index],
                "label": result[data_index]['label'],
                "score": result[data_index]['score'],
            }
        #print(json.dumps(result, indent=4))

    def dedeplicate_news_headlines(self):
        #print("Deduping data")
        #self.companies = list(set(self.companies))
        res_list = []
        for i in range(len(self.companies)):
            if self.companies[i] not in self.companies[i + 1:]:
                res_list.append(self.companies[i])
        self.companies = res_list
        for company_index in range(0, len(self.companies)):
            self.companies[company_index]['news_headlines'] = list(set(self.companies[company_index]['news_headlines']))

    def retreive_news(self):
        self.scrape_news()

        # get_company_information()
        for company_index in range(0, len(self.companies)):
            #print(f"TRYING: {company['name']} - {company['news_headlines']}")
            self.get_sentiment(company_index=company_index)
        print(f"COMPANIES: {json.dumps(self.companies, indent=2)}")

if __name__ == "__main__":
    pynews_client = NewsScrape()
    pynews_client.retreive_news()
    print("Complete!")