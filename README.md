Version 1.0
Last edit date: 2016-09-28

#Introduction
The following are scripts written in python, R, and bash shell scripting to achieve the mining, parsing, and analysis of twitter tweets. The scripts are currently setup with mine only tweets with the criteria following two country names (technically any two search terms you are interested in).

#Dependencies
R version 3.3.1 was used for testing
R packages ggplot2 and scales must be installed beforehand. e.g.
sudo R
install.packages("ggplot2")
install.packages("scales")

python 2.7.12 with Anaconda 4.1.1 (for python 2) were used for testing
Anaconda will install the majority of dependencies. The following should be installed on top of Anaconda:
$ pip install tweepy
$ python -m nltk.downloader stopwords

However, if you are independently installing, ensure the following packages are installed: tweepy, pandas, json, re, sys, numpy, nltk.corpus stopwords, collections.

#Running the script
Update the twitter-steaming.py file with your access token, access token secret, consumer key, and consumer secret credientials.

#To Run
$ bash tweet.sh

#Running and analyzing live
Run tweet.sh and select option 2 to only mine. In a separate terminal, run the tweet.sh again but this time selecting option 3. This will analyze the current raw twitter data file and produce a the results. This analysis can be setup with a bash script to rerun over an interval and thus producing 'live' results.
