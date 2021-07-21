from selenium import webdriver
import time
import re

import logging
import pandas as pd
import numpy as np

logging.basicConfig(
    format='%(asctime)s %(levelname)-8s %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S')
    
def parseItem(i):
    try:
        first_td_list = i[0].find_elements_by_xpath('./td')
        first_record = map(lambda x: x.text, first_td_list)
        second_record = map(
            lambda x: x.find_elements_by_xpath('./td[2]')[0].text, i[1:])
    except:
        logging.exception("parse error")
    return list(first_record) + list(second_record)

class Form:
    def __init__(self, driver):
        self.driver = driver
        self.form = driver.find_element_by_id("searchform_advanced")
    def input_search_name(self, name):
        self.search_name= name
    def input_start_time(self, time):
        self.start_time = time
    def input_end_time(self, time):
        self.end_time = time
    def submit(self):
        n = self.form.find_element_by_id('name')
        n.send_keys(self.search_name)
        start_time = self.form.find_element_by_id('startTime')
        start_time.send_keys(self.start_time)
        end_time = self.form.find_element_by_id('endTime')
        end_time.send_keys(self.end_time)
        button = self.form.find_element_by_id('submit')
        button.click()

class Crawler:
    def __init__(self, driver):
        self.driver = driver 
    def input(self):
        form = Form(self.driver)
        form.input_search_name('扰动')
        form.input_start_time('2019')
        form.input_end_time('2019')
        form.submit()
    def report(self):
        pages = Pages(self.driver)
        result = []
        for page in pages.iter_pages():
            pa = PageAnalyzer(page)
            result.extend(pa.get_plans())
            #print(pa.get_plans())
        pd_df = pd.DataFrame(result)
        print(pd_df)
        pd_df.to_excel("letpub_save.xlsx")
    def start(self):
        self.input()
        self.report()
class PageAnalyzer:
    def __init__(self, page):
        self.page = page
    def header(self):
        header_path = '//*[@id="dict"]/table/tbody/tr[2]/th[1]'
        headers = self.page.find_elements_by_xpath(header_path)
        if len(headers):
            raise Exception("No header!")
        self.header = headers[0]
        return self.header
    def get_plans(self):
        item_list = self.page.find_elements_by_xpath('//*[@id="dict"]/table/tbody/tr[position()>2 and position() <last()]')
        length = int(len(item_list)/5)
        item_list = [item_list[i*5:5+5*i] for i in range(length)]
        return (list(map(parseItem, item_list)))
class Pages:
    def __init__(self, driver):
        self.driver = driver
    def iter_pages(self):
        self.total_pages = self.counting_pages()
        self.curr_page = 1
        while self.curr_page < self.total_pages:
            page = self.get_page()
            if page is None:
                break
            self.curr_page += 1
            yield page
    def get_page(self):
        page_xpath = '//*[@id="dict"]/table/tbody/tr[1]/td/a[{}]'.format(self.curr_page+2)
        page_list = self.driver.find_elements_by_xpath(page_xpath)
        if len(page_list) > 0:
            return page_list[0]
        return None

    def counting_pages(self):
        pages = self.driver.find_elements_by_xpath('//*[@id="dict"]/center/div/b')
        tries = 0
        while len(pages) == 0 and tries < 10:
            logging.info('counting pages...')
            pages = self.driver.find_elements_by_xpath('//*[@id="dict"]/center/div/b')
            tries += 1
        return int(pages[0].text)
if __name__ == '__main__':
    logging.info('start crawling...')
    capabilities = webdriver.DesiredCapabilities.CHROME
    driver = webdriver.Chrome(desired_capabilities=capabilities)
    url = "https://www.letpub.com.cn/index.php?page=grant"
    driver.get(url)
    crawler = Crawler(driver)
    crawler.start()
    driver.close()
    logging.info('fnish crawling.')
