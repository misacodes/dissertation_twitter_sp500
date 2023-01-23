# install.packages("TSstudio")
library(TSstudio)

all_results <- read.csv("~/Desktop/all_results (1).csv")

# Adjust Date Variable, UK Time Zone
typeof(all_results$date)
all_results$date <-gsub("|","",as.character(all_results$date))
date_format <- strptime(all_results$date, "%a %b %d %H:%M:%S %z %Y", tz = "GMT")
all_results$date <- as.POSIXct(date_format, tz = "GMT")
all_results[ order(all_results$date , decreasing = FALSE ),]
all_results$date <- as.Date(all_results$date)
# dta.sum <- aggregate(x = all_results[c("X","index", "anger", "anticipation", "disgust", "fear", "joy", "sadness", "suprise", "trust", "positive", "negative")], 
#                      FUN = mean,
#                      by = list(Group.date = all_results$date))
aggregate <- aggregate(. ~date, data=all_results, mean, na.rm=TRUE)
plot(aggregate$index)

# S&P500
# install.packages("tidyquant")
# install.packages("timetk")
library(tidyquant)
library(timetk)
sp500 <- read.csv("~/Desktop/SP500.csv")
plot(sp500$SP500, type="l", col="blue", lwd=2, 
     ylab="Adjusted close", main="Daily closing price of S&P500 Index")
sp500_prices <- sp500[, "SP500", drop = FALSE]

# Denote n the number of time periods:
n <- nrow(sp500_prices)
sp500_daily_returns <- sp500 %>%
  tq_transmute(select = SP500,           # this specifies which column to select   
               mutate_fun = periodReturn,   # This specifies what to do with that column
               period = "daily",      # This argument calculates Daily returns
               col_rename = "nflx_returns") # renames the column

data <- sp500

# Generate **all** timestamps at which you want to have your result. 
# I use `seq`, but you may use any other method of generating those timestamps. 
data$DATE <- as.Date(data$DATE)
alldates = seq(min(data$DATE), max(data$DATE), 1)

# Filter out timestamps that are already present in your `data.frame`:
# Construct a `data.frame` to append with missing values:
dates0 = alldates[!(alldates %in% data$DATE)]
data0 = data.frame(DATE = dates0, SP500 = NA_real_)

# Append this `data.frame` and resort in time:
data = rbind(data, data0)
data = data[order(data$DATE),]

# forward fill the values 
# I would recommend to move this code into a separate `ffill` function: 
# proved to be very useful in general):
current = NA_real_
data$SP500 = sapply(data$SP500, function(x) { 
  current <<- ifelse(is.na(x) || x < 0.1, current, x); current })

# plot(data$SP500, 
#      type="l", 
#      col="blue", 
#      lwd=2, 
#      ylab="Close", 
#      xlab = "S&P 500 Index", 
#      main="Daily Closing price of S&P500 Index")
# class(data$DATE)
plot(data$SP500 ~ data$DATE, 
     data, 
     xaxt = "n", 
     type = "l",
     col="blue", 
     lwd=2)
tt <- time(data$DATE)
ix <- seq(1, length(tt), by=30) #every 60 days
fmt <- "%b-%d" # format for axis labels
labs <- format(tt[ix])
axis(side = 1, at = tt[ix], labels = labs,  cex.axis = 0.7)

