# S&P500 Prices

The equity price dataset consists of daily closing prices of S&P500
downloaded from Federal Reserve Economic Data (FRED of St. Louis,
2021). These closing prices are updated only on trading days in the U.S.
stock market, i.e., they are updated only on weekdays. Moreover, closing
prices for some weekdays are also unavailable due to stock market
holidays. During the investigated time period between February 28, 2020
and October 5, 2020, there were 4 weekdays worth of stock market
holidays, when S&P500 trading was halted (i.e.,. 10 April 2020; 25 May
2020; 3 July, 2020; and 7 September 2020. Data for these days are,
therefore, unavailable.

The missing S&P500 prices for weekends and stock market holidays can be
addressed either by (a) using linear interpolation to fill in the time
series gaps, as in Davis et al. (2021) or by (b) excluding these days
entirely from analysis, as in Bollen et al. (2011). We exclude the days
from analysis to prevent potential bias that interpolation could
introduce. Nonetheless, to be able to link S&P500 prices to the Twitter
data, we must also exclude the same days from the Twitter dataset.

## References
Bollen, J., Mao, H., & Zeng, X. (2011). Twitter mood predicts the stock market. Journal of computational
science, 2 (1), 1–8.
Davis, S. J., Liu, D., & Sheng, X. S. (2021). Stock prices and economic activity in the time of coronavirus
FRED of St. Louis (2021). The St. Louis Fed’s force of data: SP 500 (SP500). Link: https://fred.stlouisfed.org/series/SP500
