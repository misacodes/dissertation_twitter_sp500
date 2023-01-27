# Twitter Data

### Dataset overview
I utilize a Twitter dataset accessible from IEEE dataport Lamsal (2021). This dataset was collected based on 118 English-language keywords and Twitter hashtags that have been frequently used when referring to Covid-19 outbreaks. The exact keywords and hashtags that have been used to compile the IEEE dataset are included in this folder. The dataset contains Tweet IDs only, and it is subdivided into CSV files separated by date. 

### Rehydration
In order to obtain the original Tweet texts, I rehydrate the Tweet IDs using `twarc` Python library. More specifically, I recover a random sample of 100,000 Tweet IDs for each day under analysis, rather than all the Tweet IDs that are available in the IEEE dataset. This decision is driven by computational limitations on one hand, and my objective to ensure an equal representation of Tweets from all time zones in the analysis on the other hand. 

### Time window selection
I center the analysis on the time period between the end of February and beginning of October 2020 to capture the stock market crash in early
March 2020 and then the stock market recovery. Although I would like to incorporate a longer time period prior to the March market crash,
Covid-related Twitter data from prior to February 28, 2020 are very limited in number and the data collection procedure for this period
considerably differs from the data collection procedure in the rest of my dataset Lamsal (2021). I, therefore, decide against the
inclusion of January and most of February data in order to prevent potential bias that these procedural differences might introduce. 

### Sample size
Since my investigated time period spans between 28 February 2020 and 5 October 2020 (i.e., 222 days), the maximum possible sample size is 22,200,000 Tweets. However, due to Tweet deletion by users after publishing and Tweet access issues, I cannot successfully rehydrate all the randomly selected Tweet IDs. And, as a consequence, my final dataset contains a total of 13,981,417 recovered Tweets. 

### Data pre-processing
Once the Tweets are recovered, I follow the Tweet pre-processing procedure outlined in Van Der Rul (2019). I remove all white spaces, hyperlinks, punctuation, stop words and redundant symbols from the Tweets. I also convert the text to lowercase and subsequently save them as a character
vector. 

### Sentiment evaluation
Once the pre-processing stage is finished, I utilize the `syuzhet` R package. The package comes with `syuzhet` lexicon, which I
use to calculate the overall sentiment of each Tweet. The `syuzhet` sentiment lexicon was developed in the Nebraska Literary Lab by Matthew
Jockers and colleagues and it incorporates 10748 sentiment-charged words. Negative sentiment words are more prevalent in the lexicon (i.e., 7161 negative words in total), relative to the positive words (i.e., 3587 positive words in total). Moreover, the `syuzhet` sentiment evaluation procedure assigns to each Tweet one of 16 possible values ranging between −1 (i.e., the most positive sentiment possible) and +1
(i.e., the most negative sentiment possible) (Jockers, 2017). Our decision to choose the `syuzhet` lexicon, rather than alternative
sentiment lexicons, such as `afinn` and `bing`, stems from its superior word size and 16-value resolution. In comparison to `syuzhet`, the alternative `afinn` lexicon has a smaller word library of only 2477 words and a lower, 11-point resolution. Likewise, the `bing` lexicon has a smaller sentiment word bank of 6789 words and it considers only 2 potential sentiment scores, i.e., it can only assign either a sentiment value of -1 or +1 to Tweets (Naldi, 2019). In addition to the `syuzhet` sentiment lexicon, I also use the NRC Lexicon developed by Saif Mohammad (2013) which returns the emotion scores for each Tweet. The NRC Lexicon is a list of English words and their associations with eight basic emotions, as defined by Plutchik (1982). Specifically, the considered emotions are anger, fear, anticipation, trust, surprise, sadness, joy and disgust. Additionally, two sentiments are captured by the lexicon; one negative and one positive. As to its size, the NRC lexicon comprises 13889 words. The exact distribution of the lexicon words among the different emotions and sentiments is outlined in Appendix B. With respect to NRC procedure output, it returns a data frame where each column represents the number of words expressing a given emotion, plus a number of words expressing positive and negative sentiment. The NRC function calculates the number of words expressing each of the eight emotions, whereas the `syuzhet` sentiment index yields a single value between -1 and +1.

### Data post-processing
Once these emotions and the sentiment index are obtained, I aggregate them at a daily frequency. This is to enable integration of the sentiment and emotion series with S&P500 price series. Furthermore, to enable the comparison of the sentiment index and the emotion time series, I perform a z-score normalization. Unlike Bollen et al. (2011) who perform a local normalization based on mean and standard deviation within a sliding window of k days, my z-score normalization is calculated based on a mean and standard deviation values in the entire dataset. This decision is driven by past research of Lachanski (2016) who finds that localized z-score normalization can bias Granger causality results. This form of normalization causes all emotion and sentiment time series to have a zero mean and a standard deviation of 1.

## References
Bollen, J., Mao, H., & Zeng, X. (2011). Twitter mood predicts the stock market. Journal of computational science, 2 (1), 1–8.\
Jockers, M. (2017). Package ‘syuzhet’. URL: https://cran.r-project.org/web/packages/syuzhet \
Lachanski, M. (2016). Did twitter mood really predict the djia?: Misadventures in big data for finance. Penn Journal of Economics, 8–48.\
Lamsal, R. (2021). Design and analysis of a large-scale covid-19 tweets dataset. Applied Intelligence, 51 (5), 2790–2804.\
Mohammad, S. M., & Turney, P. D. (2013). Nrc emotion lexicon. National Research Council, Canada, 2.\
Naldi, M. (2019). A review of sentiment computation methods with r packages. arXiv preprint arXiv:1901.08319.\
Van Den Rul, C. (2019). A guide to mining and analysing tweets with r. Towards Data Science.\
