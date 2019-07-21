import requests
import os

url2 = ("http://vod-vip1.streaming.in2ip.nl:1935/vod/_definst_/"  
"smil:smil/KIvvPXHW0BfoqcAZdJQH66P8IahTY1pz.smil/media_w1576039657_b500000_")

app = ".ts"

header_of_null = {}
headers = {
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate, sdch',
    'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4',
    'Connection': 'keep-alive',
    'Referer': 'http://dorcel-handsoff.com/',
    'Host': 'vod-vip1.streaming.in2ip.nl:1935',
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent': 
    ('Mozilla/5.0 (Windows NT 6.3; WOW64) Ap'
    'pleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36'),
    'X-Requested-With': 'ShockwaveFlash/19.0.0.245'
    }
# url to the resources
url_of_Lola = ("http://vod-vip1.streaming.in2ip.nl:1935/vod/_definst_/"
"smil:smil/Ki8OQ2GYImEPBZVZzg9qdFaenD778VSI.smil/media_w1159455849_b4"
"000000_{}.ts")

url_of_en = ("http://vod-vip1.streaming.in2ip.nl:1935/vod/_definst_/"
"smil:smil/PEfkqzg26aui0FkROB7ui1voAeDIXR9C.smil/media_w1878580204_b5"
"00000_{}.ts")

chunk_size = 1024 * 64
first = 608
last = 650
 
path = os.getcwd()
save_dir = os.path.join(path, "dorcel_handsoff")
if not os.path.exists(save_dir):
    os.mkdir(save_dir)

for i in range(first, last):
    url = url_of_en.format(i)
    try:
        r = requests.get(url, stream=True, headers=header_of_null)
        file_name = os.path.join(save_dir, "dorcel{:04d}.ts".format(i))   
        with open(file_name, 'wb') as f:
            for chunk in r.iter_content(chunk_size):
                if chunk:
                    f.write(chunk)
    except Exception as e:
        raise e
