import pickle
import csv

def load(filename):
    with open(filename, "rb") as f:
        while True:
            try:
                yield pickle.load(f)
            except EOFError:
                break

def addToCSV(filename):
    items = load(filename)
# lang, coordinates
    for tweet_dict in items:
        row = []
        if tweet_dict["coordinates"]["coordinates"]:
            row.append(tweet_dict["lang"])
            longitude = tweet_dict["coordinates"]["coordinates"][0]
            latitude = tweet_dict["coordinates"]["coordinates"][1]
            row.append(('%.6f' % (longitude)))
            row.append(('%.6f' % (latitude)))
            with open('lang-long-lat.csv', 'a') as csvf:
                csvfw = csv.writer(csvf)
                csvfw.writerow(row)
            
        

def main():
    addToCSV("geolang.txt")

if __name__ == '__main__':
   main()




