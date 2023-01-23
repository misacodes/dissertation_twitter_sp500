# Manuals
# https://www.red-gate.com/simple-talk/sql/bi/text-mining-and-sentiment-analysis-with-r/ -> the right emotions, in line with Plutchik
# https://rpubs.com/connorrothschild/sentiment2020 -> the right data format, they use a csv file

# Install Packages
# install.packages("tm")  # for text mining
# install.packages("SnowballC") # for text stemming
# install.packages("wordcloud") # word-cloud generator 
# install.packages("RColorBrewer") # color palettes
# install.packages("syuzhet") # for sentiment analysis
# install.packages("ggplot2") # for plotting graphs
# install.packages("stringr") # for preparing text
# install.packages("BBmisc")

# Load Packages
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("syuzhet")
library("ggplot2")
library("tidyverse")
library("knitr")
library("base")
library("stringr")
library("BBmisc")

# Load Data
setwd("/Users/michaelafricova/Desktop/Dissertation/Data")
uncleaned <- read_csv("corona_tweets_01.csv.processed.csv")

# Adjust Date Variable, UK Time Zone
typeof(uncleaned$date)
uncleaned$date <-gsub("|","",as.character(uncleaned$date))
date_format <- strptime(uncleaned$date, "%a %b %d %H:%M:%S %z %Y", tz = "GMT")
dt.gmt <- as.POSIXct(date_format, tz = "GMT")

# remove Tweets that include links
uncleaned <- uncleaned[- grep(" ?(f|ht)(tp)(s?)(://)(.*)[.|/](.*)", uncleaned$text),]

# Adjust Text Variable
kable(head(uncleaned$text))
cleaned <- uncleaned %>%
  mutate(text = str_replace_all(text, "/", "")) %>% 
  mutate(text = str_replace_all(text, "|", "")) %>% 
  mutate(text = str_replace_all(text, "@", "")) %>% 
  filter(!is.na(text)) %>% 
  filter(text!="")

# Prepare for text analysis
cleaned$text <- lapply(cleaned$text, tolower)
cleaned$text <- lapply(cleaned$text, removeNumbers)
cleaned$text <- lapply(cleaned$text, removeWords, stopwords("english"))
cleaned$text <- lapply(cleaned$text, removePunctuation)
cleaned$text <- lapply(cleaned$text, stripWhitespace)

# sentiment analysis
syuzhet_vector <- get_sentiment(cleaned$text, method="syuzhet")
normalized_sentiment_index <- normalize(syuzhet_vector, method = "range", range = c(-1, 1))
summary(normalized_sentiment_index)
emotion_index <- map(cleaned$text, get_nrc_sentiment)

### Creating a Data Frame 
result_df <- as.data.frame(do.call(rbind, emotion_index), stringsAsFactors=F)
cleaned$anger <- result_df$anger
cleaned$anticipation <- result_df$anticipation
cleaned$disgust <- result_df$disgust
cleaned$fear <- result_df$fear
cleaned$joy <- result_df$joy
cleaned$sadness <- result_df$sadness
cleaned$surprise <- result_df$surprise
cleaned$trust <- result_df$trust
cleaned$positive <- result_df$positive
cleaned$negative <- result_df$negative
cleaned$index <- normalized_sentiment_index

### Exporting Results
df <- as.data.frame(cleaned)
df1 <- subset(df, select=-c(text))
write.csv(df1, file = "index_results")
