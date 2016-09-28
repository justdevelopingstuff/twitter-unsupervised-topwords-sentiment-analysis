#Import the necessary methods from tweepy library
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
from sys import argv
    
script, nation1, nation2 = argv

access_token = "748696796881301504-TtItkkAkWPaca2IX4ZXEJR1OYJXECRt"
access_token_secret = "TlWLUPmJflBianwa10HhEiTSFIWMc6mGU2oDTXaSdvN3s"
consumer_key = "Pgrr5vICdnGPeQXK7dFf4FVbY"
consumer_secret = "KrlOviDgHgx2Mom6DbKWQzYHJFqfoEOZq4pjbgVdBXTBdotBK9"

#Variables that contains the user credentials to access Twitter API 
#access_token = 
#access_token_secret = 
#consumer_key = 
#consumer_secret = 


#This is a basic listener that just prints received tweets to stdout.
class StdOutListener(StreamListener):

    def on_data(self, data):
        #print (data)
        with open('twitter_raw_'+ nation1 + '_' + nation2 + '.txt', 'a') as f:
                f.write(data)
        return True
    
    def on_status(self, status):
        print status.text
        if status.coordinates:
            print 'coordinates:', status.coordinates
        if status.place:
            print 'place:', status.place.full_name

        return True

    on_event = on_status

    def on_error(self, status):
        print (status)


if __name__ == '__main__':

    #This handles Twitter authetification and the connection to Twitter Streaming API
    l = StdOutListener()
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    stream = Stream(auth, l)

    #This line filter Twitter Streams to capture data by the keywords: 'python', 'javascript', 'ruby'
    stream.filter(track=[nation1, nation2])
