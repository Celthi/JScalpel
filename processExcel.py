import pandas as pd
from pandas import ExcelWriter
from pandas import ExcelFile
class SampleItem:
    def __init__(self, name, per):
        self.name = name
        self.per = per

class EndLei:
    def __init__(self, name, keyword):
        self.name = name
        self.keyword = keyword
        self.members = []

    def addIfMatch(self, item):
        if item.name.endswith(self.keyword):
            self.members.append(item)
            return True
        return False

class QueLei:
    def __init__(self):
        self.name = '烃类'
        self.members = []

    def addIfMatch(self, item):
        if item.name.endswith('烷') or item.name.endswith('苯'):
            self.members.append(item)
            return True
        return False

class Others:
    def __init__(self):
        self.name = '其他'
        self.members = []

    def addIfMacth(self, item):
        self.members.append(item)

'''categories = {
    '醛类': {},
    '酮类': {},
    '醇类':{},
    '羧酸类':{},
    '酯类':{},
    '胺类': {},
    '烃类':{},
    '其他':{}
}'''
 
def processSheet(sheet_name):
    df = pd.read_excel(
        open('/Users/xialu/Downloads/整理_xialu.xlsx', 'rb'), sheet_name)

    originalNames = df.iloc[:,[0,1]]
    sizeOfYuanYang = len(originalNames)
    yuangYuan = []
    leis = [
        EndLei('醛类', '醛'),
        EndLei('酮类', '酮'),
        EndLei('醇类', '醇'),
        EndLei('羧酸类', '酸'),
        EndLei('酯类', '酯'),
        EndLei('胺类', '胺'),
        QueLei(),
    ]
    others = Others()
    for i in range(sizeOfYuanYang):
        item = originalNames.iloc[i]
        yuangYuan.append(SampleItem(item.iloc[0], item.iloc[1]))
    for item in yuangYuan:
        inLei = False
        for lei in leis:
            if  lei.addIfMatch(item):
                inLei = True
        if not inLei:
            others.addIfMacth(item)
    leis.append(others)
    for item in leis:
        item.members.sort(key = lambda test_list: test_list.name)
    return leis

yuanYangProcessed = processSheet('yuanyang')
print('=======')
sanHaoProcessed = processSheet('sanhao')

for yuanYangLei in yuanYangProcessed:
    for sanHaoLei in sanHaoProcessed:
        if sanHaoLei.name == yuanYangLei.name:
            print('{}\t化学成分\t原样\t3号'.format(sanHaoLei.name))   
            def existsInMembers(name, members):
                for sample in members:
                    if name == sample.name:
                        return sample
                return None
            for item in yuanYangLei.members:
                sample =existsInMembers(item.name, sanHaoLei.members)
                if sample:
                    print('\t{}\t{}\t{}'.format(item.name, item.per, sample.per))
                else:
                    print('\t{}\t{}\t{}'.format(item.name, item.per, 'null'))
            for sanHaoItem in sanHaoLei.members:
                sample = existsInMembers(sanHaoItem.name, yuanYangLei.members)
                if sample is None:
                    print('\t{}\t{}\t{}'.format(sanHaoItem.name, 'null', sanHaoItem.per))






