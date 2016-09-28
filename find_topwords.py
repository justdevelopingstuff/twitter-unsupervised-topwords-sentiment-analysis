import pandas as pd
import numpy as np
import re
from nltk.corpus import stopwords
import string
from collections import Counter
from sys import argv

script, peaks_fn, txt_file, nation1, nation2 = argv

#### FUNCTIONS #################################
#print n number of lines from file
def readafew(file, num):
	with open(file) as f:
		for i in xrange(num): print f.readline()


#### DEFINE VARIBALES #########################
#peaks_fn = 'testing_peaks.csv'
#txt_file = 'testing_combined.txt'

#add punctuation into stop list
punctuation = list(string.punctuation)

#add french stop words into stop list
stopwords_fr = []
with open('user_stopwords.txt') as f:
    stopwords_usr = f.readlines()[1:]
stop = stopwords.words('english') + punctuation + stopwords_usr
stop = [word.strip() for word in stop]
print stop

#### LOAD CSV FILES INTO DATAFRAMES ############
df_peaks = pd.read_csv(peaks_fn, header=0)
df = pd.read_csv(txt_file, sep="\n")
df.columns = ['combined']
total_lines = len(df_peaks) 


lst_times = {}
for x in range(0, total_lines): #for going through all 509 rows
lst_times[x] = df_peaks.iloc[x]['adj.date'][11:17]

#print "lst_times list: ", lst_times
df = df['combined'].str.lower().str.split(' ', expand=True, n=5)
df.columns= ['weekday','month','day', 'time', 'zone', 'tweet']
df['time'] = df['time'].map(lambda x: x[0:6])
        
df = df[df.time.isin(lst_times.values())] #remove rows where times are not in peak list

grouped = df.groupby('time') #return a dictionary where keys are 'time' and values arerows in the groups

top_words_dict = {}
for key, value in lst_times.iteritems():
    top_words = []
    new_group = df.groupby('time').get_group(value)
    all_words = " ".join(new_group['tweet']).split()
    for word in stop:
        while True:
            try:
                all_words.remove(word)
            except ValueError:
                break
    print 'Processing at', value, '// Line: ', key #commandline viewing
    top_words_dict[key] = Counter(all_words).most_common(10)
    print 'Top words: ', top_words_dict[key], "\n" #commandline viewing

#print len(top_words_dict)    
index = top_words_dict.keys()
df_top10 = pd.DataFrame.from_dict(top_words_dict,orient='index')
#df_top10.index = top_words_dict.keys()
df_top10.to_csv(nation1 + nation2 + 'top10words.csv')

#columns = ['top10']
#top10 = pd.DataFrame(index=index, columns=columns)
#for key in lst_times.iterkeys():
#    df_peaks.set_value(key, 'top10', top_words_dict[key])
#print df_peaks[0:5]
