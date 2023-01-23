# install.packages("TSstudio")
# install.packages("tidyquant")
# install.packages("timetk")
# install.packages("msbvar")
# install.packages("slider")
# install.packages("dLagM")
# install.packages("tictoc")
# install.packages("egcm")
# install.packages("MTS")
# install.packages("vars")
rm(list=ls()) 
dev.off()
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
library(stats)

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
# before_aggregate <- read.csv("~/Desktop/aggregate_sentiment_before.csv")
# aggregate_sentiment <- read.csv("~/Desktop/aggregate_sentiment.csv")
# file_before <- subset(before_aggregate, select = -c(i))
# file_main <- subset(aggregate_sentiment, select = -c(X))
# datafile <- rbind(file_before,file_main)
# write.csv(datafile,"~/Desktop/alldays.csv", row.names = FALSE)

################################################################################
# DATA PREPARATION - SENTIMENT INDICES
# alldays <- read.csv("~/Desktop/alldays.csv")
# alldays$date <- as.Date(alldays$date)
# aggregate_sentiment_index2 <- read.csv("~/Desktop/aggregate_sentiment_index2.csv")
# aggregate_sentiment_index2$date <- as.Date(aggregate_sentiment_index2$date)
# everything <- left_join(alldays,aggregate_sentiment_index2,  by=c("date"))
# everything <- subset(everything, select = -c(X,i))
# write.csv(everything,"~/Desktop/everything.csv", row.names = FALSE)

# everything$date <-gsub("|","",as.character(everything$date))
# date_format2 <- strptime(everything$date, "%a %b %d %H:%M:%S %z %Y", tz = "GMT")
# everything$date <- as.POSIXct(date_format2, tz = "GMT")
# everything[ order(everything$date, decreasing = FALSE ),]
# everything$date <- as.Date(everything$date)
# index_aggregate <- aggregate(. ~date, data=everything, mean, na.rm=TRUE)

################################################################################
# PREPARING S&P 500 DATASET
# sp500 <- read.csv("~/Desktop/SP500.csv")
# plot(sp500$SP500, type="l", col="blue", lwd=2, 
#      ylab="Adjusted close", main="Daily closing price of S&P500 Index")
# sp500_prices <- sp500[, "SP500", drop = FALSE]
# 
# Generate **all** timestamps at which you want to have your result. 
# use `seq`
# data <- sp500
# data$DATE <- as.Date(data$DATE)
# alldates = seq(min(data$DATE), max(data$DATE), 1)
# Filter out timestamps that are already present in the `data.frame`:
# Construct a `data.frame` to append with missing values:
# dates0 = alldates[!(alldates %in% data$DATE)]
# data0 = data.frame(DATE = dates0, SP500 = NA_real_)
# 
# Append this `data.frame` and resort in time:
# data = rbind(data, data0)
# data = data[order(data$DATE),]
# 
# forward fill the values 
# current = NA_real_
# data$SP500 = sapply(data$SP500, function(x) { 
#   current <<- ifelse(is.na(x) || x < 0.1, current, x); current })

################################################################################
# COMBINE S&P 500 AND TWITTER DATASET
# data$date <- data$DATE
# FINITO <- left_join(everything, data, by=c("date"))
# write.csv(FINITO,"~/Desktop/FINITO.csv", row.names = FALSE)
FINITO <- read.csv("~/Desktop/FINITO.csv")
FINITO$date <- as.Date(FINITO$date)

################################################################################
# NORMALIZE INDEPENDENT VARIABLES

FINITO$syuzhet_index_z <- (FINITO$syuzhet_index-mean(FINITO$syuzhet_index))/
  (sd(FINITO$syuzhet_index))
hist(FINITO$syuzhet_index_z)
FINITO$bing_index_z <- (FINITO$bing_index-mean(FINITO$bing_index))/
  (sd(FINITO$bing_index))
hist(FINITO$bing_index_z)
FINITO$nrc_index_z <- (FINITO$nrc_index-mean(FINITO$nrc_index))/
  (sd(FINITO$nrc_index))
hist(FINITO$nrc_index_z)

FINITO$syuzhet_index_norm <- -1 + ((FINITO$syuzhet_index-min(FINITO$syuzhet_index))*2)/
  (max(FINITO$syuzhet_index)-min(FINITO$syuzhet_index))
FINITO$bing_index_norm <- -1 + ((FINITO$bing_index-min(FINITO$bing_index))*2)/
  (max(FINITO$bing_index)-min(FINITO$bing_index))
FINITO$nrc_index_norm <- -1 + ((FINITO$nrc_index-min(FINITO$nrc_index))*2)/
  (max(FINITO$nrc_index)-min(FINITO$nrc_index))

FINITO$fear_z <- (FINITO$fear-mean(FINITO$fear))/
  (sd(FINITO$fear))
FINITO$joy_z <- (FINITO$joy-mean(FINITO$joy))/
  (sd(FINITO$joy))
FINITO$anticipation_z <- (FINITO$anticipation-mean(FINITO$anticipation))/
  (sd(FINITO$anticipation))
FINITO$trust_z <- (FINITO$trust-mean(FINITO$trust))/
  (sd(FINITO$trust))

FINITO$fear_norm <- -1 + ((FINITO$fear-min(FINITO$fear))*2)/
  (max(FINITO$fear)-min(FINITO$fear))
hist(FINITO$fear_z)
FINITO$joy_norm <- -1 + ((FINITO$joy-min(FINITO$joy))*2)/
  (max(FINITO$joy)-min(FINITO$joy))
hist(FINITO$joy_z)
FINITO$anticipation_norm <- -1 + ((FINITO$anticipation-min(FINITO$anticipation))*2)/
  (max(FINITO$anticipation)-min(FINITO$anticipation))
hist(FINITO$anticipation_z)
FINITO$trust_norm <- -1 + ((FINITO$trust-min(FINITO$trust))*2)/
  (max(FINITO$trust)-min(FINITO$trust))
hist(FINITO$trust_z)


################################################################################
# PLOTTING
# FOR PLOTTING USE PACKAGE 

plot(FINITO$SP500 ~ FINITO$date, 
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

plot(FINITO$date,
     FINITO$SP500,
     type="l",
     col="black",
     lwd=2,
     ylab="Close",
     xlab = "Sentiment Index")
par(new=TRUE)
plot(FINITO$date, FINITO$syuzhet_index_z, type="l", col="orange", ylim = c(-5,5), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$fear_z, type="l", col="red", ylim = c(-5,5), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$joy_z, type="l", col="yellow", ylim = c(-5,5), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$anticipation_z, type="l", col="green", ylim = c(-5,5), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$trust_z, type="l", col="blue", ylim = c(-5,5), ylab = "", xlab = "")
legend("topleft", legend=c("SP500", "index_1", "fear", "joy", "anticipation", "trust"),
       col=c("black", "orange", "red", "yellow", "blue", "green"), lty=1, cex=0.4)

plot(FINITO$date, FINITO$fear_z, type="l", col="black", ylim = c(-5,5), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$fear, type="l", col="red", ylim = c(0,1), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$fear_norm, type="l", col="yellow", ylim = c(-1,1), ylab = "", xlab = "")

plot(FINITO$date, FINITO$trust_z, type="l", col="black", ylim = c(-5,5), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$trust, type="l", col="red", ylim = c(0,1), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$trust_norm, type="l", col="yellow", ylim = c(-1,1), ylab = "", xlab = "")

plot(FINITO$date,
     FINITO$SP500,
     type="l",
     col="black",
     lwd=2,
     ylab="Close",
     xlab = "Sentiment Index")
par(new=TRUE)
plot(FINITO$date, FINITO$syuzhet_index, type="l", col="orange", ylim = c(-1,1), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$fear, type="l", col="red", ylim = c(-1,1), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$joy, type="l", col="yellow", ylim = c(-1,1), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$anticipation, type="l", col="green", ylim = c(-1,1), ylab = "", xlab = "")
par(new=TRUE)
plot(FINITO$date, FINITO$trust, type="l", col="blue", ylim = c(-1,1), ylab = "", xlab = "")
legend("topleft", legend=c("SP500", "index_1", "fear", "joy", "anticipation", "trust"),
       col=c("black", "orange", "red", "yellow", "blue", "green"), lty=1, cex=0.4)

aggregate <- aggregate[, "index", drop = FALSE]
alldates = seq(min(aggregate$date), max(aggregate$date), 1)

################################################################################
everything_subset <- FINITO
write.csv(everything_subset,"~/Desktop/PRICES_WITH_WEEKENDS.csv")
everything_subset$date <- as.POSIXlt(everything_subset$date,format="%Y-%m-%d")
esdate <- everything_subset$date
everything_subset$weekday <- esdate$wday
everything_subset1 <- everything_subset[!grepl("6|0", everything_subset$weekday),]
everything_subset1 <- everything_subset1[!grepl("2020-02-27|2020-04-10|2020-05-25|2020-07-03|2020-09-07", everything_subset1$date),]
write.csv(everything_subset1,"~/Desktop/PRICES_NO_WEEKENDS.csv")

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
FINITODATA <- read.csv("~/Desktop/PRICES_NO_WEEKENDS.csv")
mood <- cbind(FINITODATA$nrc_index,
              FINITODATA$syuzhet_index, 
              FINITODATA$bing_index,
              FINITODATA$fear, 
              FINITODATA$joy, 
              FINITODATA$anticipation, 
              FINITODATA$trust)
normalized_mood <- cbind(FINITODATA$nrc_index_norm,
                         FINITODATA$syuzhet_index_norm, 
                         FINITODATA$bing_index_norm,
                         FINITODATA$fear_norm, 
                         FINITODATA$joy_norm, 
                         FINITODATA$anticipation_norm, 
                         FINITODATA$trust_norm)
zscore_mood <- cbind(FINITODATA$syuzhet_index_z, 
                         FINITODATA$fear_z, 
                         FINITODATA$joy_z, 
                         FINITODATA$anticipation_z, 
                         FINITODATA$trust_z)
diff_SP500 <- cbind(diff_SP500)
mood <- mood[-c(1),]
normalized_mood <- normalized_mood[-c(1),]
zscore_mood <- zscore_mood[-c(1),]
granger_data <- cbind(mood, normalized_mood, zscore_mood, diff_SP500)
colnames(diff_SP500) <- cbind("diff_sp500")
colnames(granger_data) <- cbind("nrc_index", 
                                "syuzhet_index", 
                                "bing_index", 
                                "fear", 
                                "joy", 
                                "anticipation",
                                "trust",
                                "nrc_index_norm",
                                "syuzhet_index_norm", 
                                "bing_index_norm",
                                "fear_norm", 
                                "joy_norm", 
                                "anticipation_norm", 
                                "trust_norm",
                                "nrc_index_z",
                                "syuzhet_index_z", 
                                "bing_index_z",
                                "fear_z", 
                                "joy_z", 
                                "anticipation_z", 
                                "trust_z",
                                "SP500 differences")
write.csv(granger_data,"~/Desktop/PRICE_DIFFERENCES_NO_WEEKENDS.csv", row.names = FALSE)

################################################################################
# JUST Z SCORES - GRANGER CAUSALITY ANALYSIS

granger_data1 <- cbind(zscore_mood, diff_SP500)
diff_SP500 <- cbind(diff_SP500)
index <- cbind(granger_data1[,1])
fear = cbind(granger_data1[,2])
joy = cbind(granger_data1[,3])
anticipation = cbind(granger_data1[,4])
trust = cbind(granger_data1[,5])
index_norm <- (index-min(index))/(max(index)-min(index))
################################################################################
# INDEX
L2i6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6) + Lag(index_norm, k=1:6))
L2i5 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:5) + Lag(index_norm, k=1:5))
L2i4 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:4) + Lag(index_norm, k=1:4))
L2i3 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:3) + Lag(index_norm, k=1:3))
L2i2 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:2) + Lag(index_norm, k=1:2))
L2i1 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1) + Lag(index_norm, k=1))
AIC(L2i6) # AIC minimised - 1627.375
AIC(L2i5)
AIC(L2i4)
AIC(L2i3)
AIC(L2i2)
AIC(L2i1)

BIC(L2i6) # BIC minimised - 1666.898
BIC(L2i5)
BIC(L2i4)
BIC(L2i3)
BIC(L2i2)
BIC(L2i1)


L1i6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=6))
L2i6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=6) + Lag(index_norm, k=6))
waldtest(L1i6,L2i6)
 # significant at 0.05

################################################################################
# INDEX - REVERSE CAUSALITY
L1i6r = dynlm(index ~ Lag(index, k=1:i))
L2i6r = dynlm(index ~ Lag(diff_SP500, k=1:i) + Lag(index, k=1:i))
waldtest(L1i6r,L2i6r)["Pr(>F)"]
# not significant at 0.05

################################################################################
# FEAR
L2f6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6) + Lag(fear, k=1:6))
L2f5 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:5) + Lag(fear, k=1:5))
L2f4 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:4) + Lag(fear, k=1:4))
L2f3 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:3) + Lag(fear, k=1:3))
L2f2 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:2) + Lag(fear, k=1:2))
L2f1 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1) + Lag(fear, k=1))
AIC(L2f6) # AIC minimised - 1620.819
AIC(L2f5)
AIC(L2f4)
AIC(L2f3)
AIC(L2f2)
AIC(L2f1)

BIC(L2f6) # AIC minimised - 1620.819
BIC(L2f5)
BIC(L2f4)
BIC(L2f3)
BIC(L2f2)
BIC(L2f1)


L1f6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6))
L2f6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6) + Lag(fear, k=1:6))
waldtest(L1f6,L2f6)
# significant at 0.05

################################################################################
# FEAR - REVERSE CAUSALITY
L1f6r = dynlm(fear ~ Lag(fear, k=1:6))
L2f6r = dynlm(fear ~ Lag(fear, k=1:6) + Lag(diff_SP500, k=1:6))
waldtest(L1f6r,L2f6r)
# not significant at 0.05

################################################################################
# JOY
L2j6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6) + Lag(joy, k=1:6))
L2j5 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:5) + Lag(joy, k=1:5))
L2j4 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:4) + Lag(joy, k=1:4))
L2j3 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:3) + Lag(joy, k=1:3))
L2j2 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:2) + Lag(joy, k=1:2))
L2j1 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1) + Lag(joy, k=1))
AIC(L2j6) # AIC minimised - 1647.951
AIC(L2j5)
AIC(L2j4)
AIC(L2j3)
AIC(L2j2)
AIC(L2j1)

BIC(L2j6) # AIC minimised - 1647.951
BIC(L2j5)
BIC(L2j4)
BIC(L2j3)
BIC(L2j2)
BIC(L2j1)

L1j6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:i))
L2j6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:i) + Lag(joy, k=1:i))
waldtest(L1j6,L2j6)

 # NOT SIGNIFICANT

################################################################################
# JOY - REVERSE CAUSALITY
pvalues_j6r = NULL
for (i in 1:6){
  L1j6r = dynlm(joy ~ Lag(joy, k=1:i))
  L2j6r = dynlm(joy ~ Lag(joy, k=1:i) + Lag(diff_SP500, k=1:i))
  pvalues_j6r = c(pvalues_j6r, waldtest(L1j6r,L2j6r)["Pr(>F)"])
}
pvalues_j6r # NOT SIGNIFICANT

################################################################################
# ANTICIPATION
L2a6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6) + Lag(anticipation, k=1:6))
L2a5 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:5) + Lag(anticipation, k=1:5))
L2a4 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:4) + Lag(anticipation, k=1:4))
L2a3 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:3) + Lag(anticipation, k=1:3))
L2a2 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:2) + Lag(anticipation, k=1:2))
L2a1 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1) + Lag(anticipation, k=1))
AIC(L2a6) # AIC minimised
AIC(L2a5)
AIC(L2a4)
AIC(L2a3)
AIC(L2a2)
AIC(L2a1)

BIC(L2a6) # AIC minimised
BIC(L2a5)
BIC(L2a4)
BIC(L2a3)
BIC(L2a2)
BIC(L2a1)


L1a6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6))
L2a6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6) + Lag(anticipation, k=1:6))
waldtest(L1a6,L2a6)

pvalues_a6 # NOT SIGNIFICANT

################################################################################
# ANTICIPATION - REVERSE CAUSALITY
pvalues_a6r = NULL
for (i in 1:6){
  L1a6r = dynlm(anticipation ~ Lag(anticipation, k=1:i))
  L2a6r = dynlm(anticipation ~ Lag(anticipation, k=1:i) + Lag(diff_SP500, k=1:i))
  pvalues_a6r = c(pvalues_a6r, waldtest(L1a6r,L2a6r)["Pr(>F)"])
}
pvalues_a6r # NOT SIGNIFICANT

################################################################################
# TRUST
L2t6 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:6) + Lag(trust, k=1:6))
L2t5 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:5) + Lag(trust, k=1:5))
L2t4 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:4) + Lag(trust, k=1:4))
L2t3 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:3) + Lag(trust, k=1:3))
L2t2 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1:2) + Lag(trust, k=1:2))
L2t1 = dynlm(diff_SP500 ~ Lag(diff_SP500, k=1) + Lag(trust, k=1))
AIC(L2t6) # AIC minimised
AIC(L2t5)
AIC(L2t4)
AIC(L2t3)
AIC(L2t2)
AIC(L2t1)

BIC(L2t6) # AIC minimised
BIC(L2t5)
BIC(L2t4)
BIC(L2t3)
BIC(L2t2)
BIC(L2t1)

L1t6 = dynlm(diff_SP500 ~ Lag(diff_SP500, 1:6))
L2t6 = dynlm(diff_SP500 ~ Lag(diff_SP500, 1:6) + Lag(trust, 1:6))
waldtest(L1t6,L2t6)


################################################################################
# TRUST - REVERSE CAUSALITY
pvalues_t6r = NULL
for (i in 1:6){
  L1t6r = dynlm(trust ~ Lag(trust, 1:i))
  L2t6r = dynlm(trust ~ Lag(trust, 1:i) + Lag(diff_SP500, 1:i))
  pvalues_t6r = c(pvalues_t6r, waldtest(L1t6r,L2t6r)["Pr(>F)"])
} 
pvalues_t6r # NOT SIGNIFICANT

install.packages("stargazer")
install.packages("textreg")
library(stargazer)
library(textreg)
model <- lm(index ~  fear + joy + anticipation + trust)
summary(model)
stargazer(model, type = "latex", 
          title="Regression Results",
          align=TRUE, dep.var.labels="Sentiment Index",
          covariate.labels=c("Fear","Joy", "Anticipation","Trust"),
          omit.stat=c("LL","ser","f"), 
          no.space=TRUE)
textreg(model)
