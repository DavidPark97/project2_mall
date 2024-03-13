#!"C:\Users\ssss\AppData\Local\Programs\Python\Python38\python.exe"
# -*- coding: utf-8 -*-
import pymysql
from itertools import combinations
import sys
conn = pymysql.connect(host='localhost', user='root', password='1234', db='mall', charset='utf8')
cur = conn.cursor()

MIN_SUPPORT = 0.015
    
def getData(selected):
    sql = "select distinct(buy_idx) from buy_product where detail_idx in ("+selected+") order by buy_idx;"
    cur.execute(sql)

    result = cur.fetchall()
    data = list()
    items= set()
    for col in result:
        sql= "select distinct(product_idx) from buy_product,detail where buy_product.detail_idx = detail.detail_idx and buy_idx="+str(col[0])+";"
        cur.execute(sql)
        res = cur.fetchall()
        tmp = list()
        for item in res:
            tmp.append(item[0])
            items.add(item[0])
        data.append(tmp)
    return data,items

def getSupport(item,data):
    cnt =0
    for col in data:
        if item.issubset(set(col)):
          cnt+=1
          
    return cnt
    
def findRules(data,items):
    total = len(data)
    frequent_itemsets = dict()
    itemset_size = 0
    frequent_itemsets[itemset_size] = list()
    Rules = list()
    for item in items:
        tmp=set()
        tmp.add(item)
        cnt = getSupport(tmp,data)
        if cnt/total >= MIN_SUPPORT:
            frequent_itemsets[itemset_size].append(tmp)
        
    itemset_size += 1
    while frequent_itemsets[itemset_size - 1]:
        frequent_itemsets[itemset_size] = list()
        candidate_itemsets = generate_candidate_itemsets(frequent_itemsets, itemset_size)
        
        for item in candidate_itemsets:
            cnt = getSupport(item,data)
            if cnt/total >= MIN_SUPPORT:
                k = list()
                frequent_itemsets[itemset_size].append(item)
                k.append(item)
                k.append(cnt)
                Rules.append(k)
        itemset_size += 1
    return Rules,itemset_size-1

def generate_candidate_itemsets(frequent_itemsets, itemset_size):
    selective_set = selective_joining(frequent_itemsets,itemset_size)
    if itemset_size>=2:
        pruend_set = apriori_prune(selective_set,frequent_itemsets,itemset_size)
    else:
        pruend_set=selective_set
    
    return pruend_set
       
       
def selective_joining(frequent_itemsets,itemset_size):
    selective_set =list()
    for idx1 in range(0,len(frequent_itemsets[itemset_size-1])-1):
        for idx2 in range(idx1+1,len(frequent_itemsets[itemset_size-1])):
            tmp = frequent_itemsets[itemset_size-1][idx1].union(frequent_itemsets[itemset_size-1][idx2])
            if len(tmp) == itemset_size+1:
                selective_set.append(tmp)
    
    return selective_set

def apriori_prune(selective_set,frequent_itemsets,itemset_size):
    pruned_set = list()
    for item in selective_set:
        flag = 1
        tmps = list(combinations(item,itemset_size))
        for tmp in tmps:
            k = set(tmp)
            if k not in frequent_itemsets[itemset_size-1]:
                flag=0
                break
        if flag==1:
            pruned_set.append(item)
    
    return pruned_set

def get_result(selected,data,Rules,itemset_size):
    a = selected.split(',')
    b= {int(i) for i in a}
    size = min(itemset_size,len(b))
    get_cnt = dict()
    finalList = dict()
    for i in reversed(range(1,size+1)):
        c = list(combinations(b,i))
        for item in c:
            cnt=getSupport(set(item),data)
            get_cnt[item] = cnt
            finalList[item] = list()
    for item in Rules:
        tmp = set(item[0])
        inter = b.intersection(tmp)
        subs = tmp.difference(b)        
        if len(inter)!=0 and len(subs) ==1:
            if item[1]/get_cnt.get(tuple(inter))>=0.10:
                k = list()
                k.append(subs)
                k.append(round(item[1]/get_cnt.get(tuple(inter)),2))
                finalList[tuple(inter)].append(k)

    return finalList 

def output(finalList):
    sql = "select product_idx,p_name from product;"
    cur.execute(sql)
    products = dict()
    result = cur.fetchall()
    for item in result:
        products[item[0]]= item[1]
        
    strs = '{ "webnautes": [' 
    for key in finalList:
        for value in finalList.get(key):
            strs += '{"items":"'
            strs+=products.get(tuple(value[0])[0])
            strs+='","perc": "'+str(value[1])
            strs+='","idx": "'+str(tuple(value[0])[0])
            strs+='", "keys": "'
            for item in key:
                strs+=products.get(item)
                strs+=' '            
            strs+='"},'
    strs= strs.strip(',')
    strs+=']}'
    print(strs)
        
    
        
def main():
    selected = sys.argv[1]
    data,items = getData(selected)
    Rules,itemSize = findRules(data,items)
    finalList = get_result(selected,data,Rules,itemSize)
    output(finalList)
    
if __name__ == '__main__':
    main()