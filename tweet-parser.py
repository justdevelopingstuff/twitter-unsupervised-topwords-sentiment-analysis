import pandas
import json
import re
from sys import argv

# python -m SimpleHTTPServer 8888

#### FUNCTIONS ####################################
def add_to_list(filename, lstname):
    fh = open(filename, 'r')
    for line in fh :
        line = line.rstrip()
        lstname.append(line)
        
def count_emotions() :
    count_emotions={'positive': 0, 'negative': 0}
    for i in wordList :
        i = str(i)
        if i in positive_words:
            count_emotions['positive'] += 1
        elif i in negative_words:
            count_emotions['negative'] += 1
    if count_emotions['positive'] > count_emotions['negative'] :
        return 'positive'
    elif count_emotions['negative'] > count_emotions['positive'] :
        return 'negative'
    else:
        return 'neutral'

def write_files(filename, lstvar):
    f = open(filename, 'w')
    for item in lstvar:
        f.write('%r\n' % item)
    f.close()

#### LIST VARIABLES ####################################

script, nation1, nation2, rawtweets = argv


hash1 = "#" + nation1
hash2 = "#" + nation2

lst_suffix = ['_all', '_pos', '_neu', '_neg']
lst_prefix = ['dates_', 'tweets_', 'combine_']

empty = 0
count = 0
linenum=0

positive_words = []
negative_words = []

listfiles = {}

#### DICTIONARIES  ###########################

def make_dicts(nation1, nation2):
    for prefix in lst_prefix:
        for suffix in lst_suffix:
            listfiles[prefix + nation1 + suffix] = []
            listfiles[prefix + nation2 + suffix] = []
            listfiles[prefix + nation1 + nation2 + suffix] = []
    listfiles['tweets_none'] = []

make_dicts(nation1, nation2)

#### APPEND SINGLE LINE  ############################
#this is used to ensure that all raw data files have at least 1 line so that the R script will fully run

date = u'Thu Jul 07 00:00:00 +0000 2016'
for suffix in lst_suffix:
    listfiles['dates_' + nation1 + suffix].append(date)
    listfiles['dates_' + nation2 + suffix].append(date)
    listfiles['dates_' + nation1 + nation2 + suffix].append(date)

#### OPEN FILES  ####################################
error_log = open('error_log.txt', 'w')
fname = rawtweets

add_to_list('positive-words.txt', positive_words)
add_to_list('negative-words.txt', negative_words)

#### PARSE TWITTER JSON  ####################################
with open(fname, 'r') as f :
    for line in f :
        linenum += 1
        #print 'LINENUM:', linenum

        try:
            tweet = json.loads(line)                 #load it as Python dict
            #print 'Length of line: ', len(tweet)  
        except: 
            count += 1
            #print 'didnt load line'
            empty += 1
            continue
        
        try:    
            terms_only = tweet['text'].lower()        #look for tweet text only
            #print 'terms only: ', terms_only
        except:
            error_msg = str(count) + '\n'
            error_log.write(error_msg)
            #print 'could not lower case it'
            count += 1
            continue
        #append to respective team lists
        if (hash1 in terms_only and hash2 in terms_only) and (nation1 in terms_only and nation2 in terms_only) :
            listfiles["combine_" + nation1 + nation2 + "_all"].append(tweet['created_at'] + tweet['text'])
            listfiles["dates_" + nation1 + nation2 + "_all"].append(tweet['created_at'])
            listfiles["tweets_" + nation1 + nation2 + "_all"].append(tweet['text'])
            if emotion == 'positive':
                listfiles["combine_" + nation1 + nation2 + "_pos"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation1 + nation2 + "_pos"].append(tweet['created_at'])
                listfiles["tweets_" + nation1 + nation2 + "_pos"].append(tweet['text'])
                #print 'positive nation1 added'
            elif emotion == 'negative':
                listfiles["combine_" + nation1 + nation2 + "_neg"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation1 + nation2 + "_neg"].append(tweet['created_at'])
                listfiles["tweets_" + nation1 + nation2 + "_neg"].append(tweet['text'])
                #print 'negative nation1 added'     
            else :
                listfiles["combine_" + nation1 + nation2 + "_neu"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation1 + nation2 + "_neu"].append(tweet['created_at'])
                listfiles["tweets_" + nation1 + nation2 + "_neu"].append(tweet['text'])
 
        elif hash1 in terms_only  or nation1 in terms_only:
            wordList = re.sub("[^\w]", " ",  terms_only).split()
            listfiles["combine_" + nation1 + "_all"].append(tweet['created_at'] + tweet['text'])
            listfiles["dates_" + nation1 + "_all"].append(tweet['created_at'])
            listfiles["tweets_" + nation1 + "_all"].append(tweet['text'])
            emotion = count_emotions()
            if emotion == 'positive':
                listfiles["combine_" + nation1 + "_pos"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation1 + "_pos"].append(tweet['created_at'])
                listfiles["tweets_" + nation1 + "_pos"].append(tweet['text'])
                #print 'positive nation1 added'
            elif emotion == 'negative':
                listfiles["combine_" + nation1 + "_neg"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation1 + "_neg"].append(tweet['created_at'])
                listfiles["tweets_" + nation1 + "_neg"].append(tweet['text'])
                #print 'negative nation1 added'     
            else :
                listfiles["combine_" + nation1 + "_neu"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation1 + "_neu"].append(tweet['created_at'])
                listfiles["tweets_" + nation1 + "_neu"].append(tweet['text'])
                #print 'neutral nation1 added'
        elif hash2 in terms_only or nation2 in terms_only:
            wordList = re.sub("[^\w]", " ",  terms_only).split()
            listfiles["combine_" + nation2 + "_all"].append(tweet['created_at'] + tweet['text'])
            listfiles["dates_" + nation2 + "_all"].append(tweet['created_at'])
            listfiles["tweets_" + nation2 + "_all"].append(tweet['text'])
            emotion = count_emotions()
            if emotion == 'positive' :
                listfiles["combine_" + nation2 + "_pos"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation2 + "_pos"].append(tweet['created_at'])
                listfiles["tweets_" + nation2 + "_pos"].append(tweet['text'])
            elif emotion == 'negative' :
                listfiles["combine_" + nation2 + "_neg"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation2 + "_neg"].append(tweet['created_at'])
                listfiles["tweets_" + nation2 + "_neg"].append(tweet['text'])     
            else :
                listfiles["combine_" + nation2 + "_neu"].append(tweet['created_at'] + tweet['text'])
                listfiles["dates_" + nation2 + "_neu"].append(tweet['created_at'])
                listfiles["tweets_" + nation2 + "_neu"].append(tweet['text']) 
        else:
            listfiles["tweets_none"].append(tweet['text'])
        count += 1
        #print '\n'
     #print 'empty: ', empty
    #print 'count: ', count

error_log.close()
                

#### WRITE LISTS INTO CSV FILE   ####################################

for k in range(len(listfiles)):
    write_files(listfiles.keys()[k] + ".txt", listfiles.values()[k])

summary = open('summary.txt', 'w')
summary.write(nation1 + ':' + str(len(listfiles["tweets_" + nation1 + "_pos"])+len(listfiles["tweets_" + nation1 + "_neg"])+len(listfiles["tweets_" + nation1 + "_neu"])) +'\n')
summary.write(nation2 + ':' + str(len(listfiles["tweets_" + nation2 + "_pos"])+len(listfiles["tweets_" + nation2 + "_neg"])+len(listfiles["tweets_" + nation2 + "_neu"])) +'\n')
summary.write(nation1 + nation2 + ':' + str(len(listfiles["tweets_" + nation1 + nation2 + "_pos"]) + len(listfiles["tweets_" + nation1 + nation2 + "_neg"]) + len(listfiles["tweets_" + nation1 + nation2 + "_neu"])) +'\n')
summary.write('none:' + str(len(listfiles["tweets_none"])) +'\n')
summary.write('empty:' + str(empty) +'\n')
summary.write('total_lines:' + str(count) +'\n')
summary.close()
