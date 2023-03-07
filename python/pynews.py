#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
import json
from transformers import pipeline

tickers = [
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

companies = []


def get_company_information():
    for ticker_index in range(0, len(tickers)):
        companies.append(search_company(tickers[ticker_index]))
        print(f"Ticker: {companies[ticker_index]['symbol']}\n"
              f"Name: {companies[ticker_index]['longname']}\n"
              f"Exchange: {companies[ticker_index]['exchange']}\n"
              f"Industry: {companies[ticker_index]['industry']}\n"
              f"Sector: {companies[ticker_index]['sector']}\n"
              f"News: {companies[ticker_index]['news']}\n")


def search_company(search):
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
    data['symbol'] = data['quotes'][0]['symbol']
    data['longname'] = data['quotes'][0]['longname']
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


urls = [
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


def scrape_news():
    for url in urls:
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
            for ticker in tickers:
                if ticker['name'] in text:
                    print(f"{ticker['name']} IN {text}")
                    if len(companies) == 0:
                        new_company = {
                            "name": ticker['name'],
                            "ticker": ticker['ticker'],
                            "news": [text]
                        }
                        companies.append(new_company)
                    for company_index in range(0, len(companies)):
                        if ticker['name'] in companies[company_index]['name']:
                            print("APPENDING TEXT")
                            companies[company_index]['news'].append(text)
                        else:
                            print("CREATING NEW TEXT")
                            new_company = {
                                "name": ticker['name'],
                                "ticker": ticker['ticker'],
                                "news": [text]
                            }
                            companies.append(new_company)
                elif ticker['ticker'] in text:
                    print(f"{ticker['ticker']} IN {text}")

    print(f"COMPANIES: {companies}")


def get_sentiment(data):
    sentiment_pipeline = pipeline("sentiment-analysis")
    # data = ["I love you", "I hate you"]
    result = sentiment_pipeline(data)
    for data_index in range(0, len(data)):
        result[data_index]['title'] = data[data_index]
    print(json.dumps(result, indent=4))


# scrape_news()
get_company_information()
for company in companies:
    #print(f"TRYING: {company['longname']} - {company['news_headlines']}")
    get_sentiment(data=company['news_headlines'])
