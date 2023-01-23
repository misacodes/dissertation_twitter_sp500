# install.packages("TSstudio")
# install.packages("tidyquant")
# install.packages("timetk")
# install.packages("msbvar")
# install.packages("slider")
# install.packages("dLagM")
# install.packages("tictoc")
# install.packages("egcm")
# install.packages("MTS")

install.packages("vars")
rm(list=ls()) 
library(dLagM)
library(tictoc)
library(lmtest)
library(tseries)
library(forecast)
library(pracma)
library(egcm)
library(tidyquant)
library(timetk)
library(TSstudio)
library(dplyr)
library(slider)
library(tseries)
library(lmtest)
library(zoo)
library(MTS)
library(vars)
dev.off()

################################################################################
# DATA PREPARATION - MAIN TWITTER DATASET
# all_results <- read.csv("~/Desktop/all_results (1).csv")
# Adjust Date Variable, UK Time Zone
# typeof(all_results$date)
# all_results$date <-gsub("|","",as.character(all_results$date))
# date_format <- strptime(all_results$date, "%a %b %d %H:%M:%S %z %Y", tz = "GMT")
# all_results$date <- as.POSIXct(date_format, tz = "GMT")
# all_results[ order(all_results$date , decreasing = FALSE ),]
# all_results$date <- as.Date(all_results$date)
# aggregate <- aggregate(. ~date, data=all_results, mean, na.rm=TRUE)
# write.csv(aggregate,"~/Desktop/aggregate_sentiment.csv", row.names = FALSE)

################################################################################
# DATA PREPARATION - PRECEEDING TWITTER DATASET
# index_results_additional <- read.csv("~/Desktop/index_results_additional")
# before_results <- index_results_additional
# before_results$date <-gsub("|","",as.character(before_results$date))
# date_format1 <- strptime(before_results$date, "%a %b %d %H:%M:%S %z %Y", tz = "GMT")
# before_results$date <- as.POSIXct(date_format1, tz = "GMT")
# before_results[ order(before_results$date, decreasing = FALSE ),]
# before_results$date <- as.Date(before_results$date)
# before_aggregate <- aggregate(. ~date, data=before_results, mean, na.rm=TRUE)
# write.csv(before_aggregate,"~/Desktop/aggregate_sentiment_before.csv", row.names = FALSE)

################################################################################
# TWO TWITTER DATASETS COMBINED
file_before <- subset(before_aggregate, select = -c(i))
file_main <- subset(aggregate_sentiment, select = -c(X))
datafile <- rbind(file_before,file_main)

################################################################################
# PREPARING S&P 500 DATASET
sp500 <- read.csv("~/Desktop/SP500.csv")
plot(sp500$SP500, type="l", col="blue", lwd=2, 
     ylab="Adjusted close", main="Daily closing price of S&P500 Index")
sp500_prices <- sp500[, "SP500", drop = FALSE]

# Generate **all** timestamps at which you want to have your result. 
# use `seq`
data <- sp500
data$DATE <- as.Date(data$DATE)
alldates = seq(min(data$DATE), max(data$DATE), 1)
# Filter out timestamps that are already present in the `data.frame`:
# Construct a `data.frame` to append with missing values:
dates0 = alldates[!(alldates %in% data$DATE)]
data0 = data.frame(DATE = dates0, SP500 = NA_real_)

# Append this `data.frame` and resort in time:
data = rbind(data, data0)
data = data[order(data$DATE),]

# forward fill the values 
current = NA_real_
data$SP500 = sapply(data$SP500, function(x) { 
  current <<- ifelse(is.na(x) || x < 0.1, current, x); current })

plot(data$SP500 ~ data$DATE, 
     data, 
     ylab="Close", 
     xlab = "S&P 500 Index", 
     main="Daily Closing price of S&P500 Index",
     type = "l",
     col="blue", 
     minor.ticks = "week", 
     lwd=2)
tt <- time(data$DATE)
ix <- seq(1, length(tt), by=30) #every 30 days
fmt <- "%b-%d" # format for axis labels
labs <- format(tt[ix])
axis(side = 1, at = tt[ix], labels = labs,  cex.axis = 0.7)

################################################################################
# COMBINE S&P 500 AND TWITTER DATASET
everything <- left_join(datafile, data, by=c("date"))

################################################################################
# PLOTTING
plot(everything$date,
     everything$SP500,
     type="l",
     col="black",
     lwd=2,
     ylab="Close",
     xlab = "Sentiment Index")
par(new=TRUE)
plot(everything$date, everything$anticipation, type="l", col="orange", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything$date, everything$fear, type="l", col="red", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything$date, everything$joy, type="l", col="yellow", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything$date, everything$trust, type="l", col="blue", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything$date, everything$SP500, type="l", col="pink", ylab = "", xlab = "")
legend("topleft", legend=c("Index", "anticipation", "fear", "joy", "trust"),
       col=c("black", "orange", "red", "yellow", "blue"), lty=1, cex=0.4)

aggregate <- aggregate[, "index", drop = FALSE]
alldates = seq(min(aggregate$date), max(aggregate$date), 1)

################################################################################
everything_subset <- everything
everything_subset$date <- as.POSIXlt(everything_subset$date,format="%Y-%m-%d")
esdate <- everything_subset$date
everything_subset$weekday <- esdate$wday
everything_subset1 <- everything_subset[!grepl("6|0", everything_subset$weekday),]
everything_subset1 <- everything_subset1[!grepl("2020-02-27|2020-04-10|2020-05-25|2020-07-03|2020-09-07", everything_subset1$DATE),]
nrow(everything_subset1)

write.csv(everything_subset1,"~/Desktop/data_for_training_without_weekend.csv")

plot(everything_subset1$date,
     everything_subset1$index,
     type="l",
     col="black",
     lwd=2,
     ylab="Close",
     xlab = "Sentiment Index",
     ylim = c(0.1,0.9))
par(new=TRUE)
plot(everything_subset1$date, everything_subset1$anticipation, type="l", col="orange", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything_subset1$date, everything_subset1$fear, type="l", col="red", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything$date, everything$joy, type="l", col="yellow", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything$date, everything$trust, type="l", col="blue", ylim = c(0.1,0.9), ylab = "", xlab = "")
par(new=TRUE)
plot(everything$date, everything$SP500, type="l", col="pink", ylab = "", xlab = "")
legend("topleft", legend=c("Index", "anticipation", "fear", "joy", "trust"),
       col=c("black", "orange", "red", "yellow", "blue"), lty=1, cex=0.4)

################################################################################
# STATIONARITY TESTS FOR LEVELS
adf.test(everything_subset1$SP500) # We reject the null hypothesis of unit root at the 5% significance level.
kpss.test(everything_subset1$SP500) # We reject the null hypothesis of stationarity at the 5% significance level.
pp.test(everything_subset1$SP500) # We fail to reject the null hypothesis of unit root at the 5% significance level.
# To run the Granger Causality analysis, we need stationary time series 
# ADF and PP signal stationarity, but KPSS signals non-stationarity, therefore, we will do the first differencing.

################################################################################
# STATIONARITY TESTS FOR FIRST DIFFERENCES 
everything_subset1$SP500 <- as.numeric(everything_subset1$SP500)
diff_SP500 = diff(everything_subset1$SP500, differences = 1)
adf.test(diff_SP500) # We reject the null hypothesis that diff_SP500 has a unit root at the 5% significance level.
kpss.test(diff_SP500) # We fail to reject the null hypothesis that diff_SP500 is stationary at the 5% significance level.
pp.test(diff_SP500) # We reject the null hypothesis that diff_SP500 has a unit root at the 5% significance level.

################################################################################
# GRANGER CAUSALITY ANALYSIS
mood <- cbind(everything_subset1$index, everything_subset1$fear, everything_subset1$joy, everything_subset1$anticipation, everything_subset1$trust)
mood <- mood[-1,]
diff_SP500 <- cbind(diff_SP500)
granger_data <- cbind(mood, diff_SP500)
colnames(granger_data) <- cbind("index", "fear", "joy", "anticipation", "trust", "sp500")
model_6 <- VAR(granger_data, p = 6, type = "const")
model_5 <- VAR(granger_data, p = 5, type = "const")
model_4 <- VAR(granger_data, p = 4, type = "const")
model_3 <- VAR(granger_data, p = 3, type = "const")
causality(model_6, cause = c("joy", "fear", "index", "anticipation", "trust"))
causality(model_5, cause = c("joy", "fear", "index", "anticipation", "trust"))
causality(model_4, cause = c("joy", "fear", "index", "anticipation", "trust"))
causality(model_3, cause = c("joy", "fear", "index", "anticipation", "trust"))

diff_SP500 <- cbind(diff_SP500)
GrangerTest(granger_data, p = 6, locInput = c(6))
grangertest(diff_SP500 ~ mood, order = 3)
lmtest::grangertest(SP500, everything_subset1$fear, order = 3, data = everything_subset1)
