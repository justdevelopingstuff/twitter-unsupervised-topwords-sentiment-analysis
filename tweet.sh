#!/bin/bash

#defining functions
function mining () {
    #introudction and warnings
    echo "Please update the twitter-steaming.py file with your twitter token and key credentials."

    #select first country criteria
    echo "What is the first country's name you would like to twitter mine:"
    read nation1
    #seelction second country criteria
    echo "What is the second country's name you would like to twitter mine:"
    read nation2

    #making the new folder
    DIRECTORY=$nation1$nation2-$(date +"%Y-%B-%d-%H-%M-%S")
    mkdir $DIRECTORY

    #tweepy mining
    nohup python twitter-streaming.py $nation1 $nation2 > /dev/null 2>&1 &
    echo $! > $DIRECTORY/save_pid.txt

    #killing the mining process
    while true; do
        echo "type STOP (upper case) to stop mining and initiate analysis. Ideally leave this running for as long as you can."
        read input
        if [ "$input" = "STOP" ]; then
            kill -9 `cat $DIRECTORY/save_pid.txt` &&
            echo "Tweet mining for $nation1 and $nation2 has successfully stopped."
            mv -t $DIRECTORY twitter_raw_${nation1}_${nation2}.txt
            break
        else
            echo "invalid response"
            continue
        fi
    done
}

function tweetanalysis () {
        #making the error files
        ERRORSDIR=$DIRECTORY/errorlogs
        mkdir $ERRORSDIR
        
        #parsing the raw twitter files
        nohup python tweet-parser.py $nation1 $nation2 $DIRECTORY/twitter_raw_${nation1}_${nation2}.txt > $ERRORSDIR/parsingerrors.txt &&

        #generating the graphs and peak csv files
        nohup ./tweet-analyzer.R $nation1 $nation2 > $ERRORSDIR/peakfindingerrors.txt &&

        #combine the raw raw tweetfiles
        nohup python combine_txtfiles.py combine_${nation1}_all.txt combine_${nation2}_all.txt combine_${nation1}${nation2}_all.txt $nation1 $nation2 > $ERRORSDIR/combiningerrors.txt &&

        #finding the top 10 words for each peak
        nohup python find_topwords.py noise-peaks-${nation1}-${nation2}.csv ${nation1}${nation2}combined.txt $nation1 $nation2 > $ERRORSDIR/topwordsearcherrors.txt &&

        #concatenating the top words with the peaks
        nohup python combine_csv.py noise-peaks-${nation1}-${nation2}.csv ${nation1}${nation2}top10words.csv $nation1 $nation2 > $ERRORSDIR/finalerrors.txt
      
        #cleaning up files
        RESULTS=$DIRECTORY/results
        mkdir $RESULTS
        mv -t $RESULTS *png ${nation1}${nation2}top10wordsupdated.csv
        mv -t $DIRECTORY combine_* dates_* tweets_* *peaks* *top10* *combined* error* summary*
        echo "Analysis is complete."
        break
}

#check if a raw twitter data file is already available
while true; do
    echo "Would you like to 1.Mine tweets followed by analysis; 2.Mine tweets only; or 3.Analyze tweets (usually if you already have a raw twitter mined file. !!WARNING: make sure to only have a single directory using the intended country pairs in this current directory.)."
    echo "Select 1,2,3:"
    read selection
    if [ "$selection" = "1" ]; then
        mining &&
        tweetanalysis &&
        break
    elif [ "$selection" = "2" ]; then
        mining && 
        break
    elif [ "$selection" = "3" ]; then
        while true; do
		echo "Please enter the countries in the same order in which it appears on the directory with the raw twitter file"
		echo "What is the first country's name in which you mined?"
		read nation1
		echo "What is the second country's name in which you mined?"
		read nation2
		#checking for the directory with the raw mined tweets
		EXIST=$(ls | grep $nation1$nation2 | wc -l)
		if [ $EXIST = "1" ]; then
			echo "Directory found with countries $nation1 $nation2"
			DIRECTORY=$(ls | grep $nation1$nation2)
			tweetanalysis &&
			break
		elif [ $EXIST -ge "1" ]; then
			echo "There are more than one directory with your intended country pairs"
			echo "Please choose again or remove the other directories"
			continue
		else
			echo "You do not have a mined twitter directory with the selected country pairs. Please select again."
			continue
		fi
	done
	break
    else
        echo "invalid response"
        continue
    fi
done
