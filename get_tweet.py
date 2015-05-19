import sys
import tweepy
import os
import json
import pickle

#Set Twitter authentication keys
CONSUMER_KEY    = os.environ.get('CONSUMER_KEY')
CONSUMER_SECRET = os.environ.get('CONSUMER_SECRET')
ACCESS_KEY      = os.environ.get('ACCESS_KEY')
ACCESS_SECRET   = os.environ.get('ACCESS_SECRET')
    
class CustomStreamListener(tweepy.streaming.StreamListener):

    def on_data(self, raw_data):
        tweet = {}
        line = json.loads(raw_data)
        if line.get("coordinates") and line.get("lang") and line.get("text"):
            tweet['id'] = line.get("id")
            tweet['text'] = line.get("text")
            tweet['coordinates'] = line.get("coordinates")
            tweet['lang'] = line.get("lang")
            if line.get("entities") and line.get("entities").get("hashtags"):
                tweet['hashtags'] = line.get("entities").get("hashtags")
            with open('id_txt_co_lang_hash.txt','a') as f:
                pickle.dump(tweet, f)

        return True

    def on_error(self, status_code):
        print status_code
        return True # Don't kill the stream

    def on_timeout(self):
        print 'Timeout...'
        return True # Don't kill the stream

if __name__ == '__main__':

    my_listener = CustomStreamListener()
    auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)

    auth.set_access_token(ACCESS_KEY, ACCESS_SECRET)
    sapi = tweepy.streaming.Stream(auth, my_listener)  

    # locations is given as East, North GPS of lower left coordinate and East, North of upper right GPS
    sapi.filter(locations=[-180,-90,180,90])
    
