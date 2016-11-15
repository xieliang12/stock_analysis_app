args = commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  stop("Three arguments must be supplied.n", call.=FALSE)
  }

library(quantmod)
library(ggplot2)
ticker <- args[2]
getSymbols(ticker, src='google')
ChartTool <- function(period_data, title, ta) {
  if (missing(ta)) {
    chartSeries(period_data, "candlesticks", show.grid = TRUE,
              name = title, theme = "white", up.col = "green", dn.col = "red", TA='addVo()')
  } else {
    chartSeries(period_data, "candlesticks", show.grid = TRUE,
                name = title, theme = "white", up.col = "green", dn.col = "red", 
                TA=paste('addVo()', ta, sep=";"))
  }
}

DrawChart <- function(ticker, time_period ) {
  if (time_period == "daily") { 
  #for daily chart, draw a chart for the last 7 months
    daily_cutoff = paste0(seq(as.Date(Sys.Date()), length = 2, by = "-8 months")[2], "::")
    title = paste0(ticker, " daily chart")
    daily = eval(parse(text=ticker))[daily_cutoff]
    ChartTool(daily, title, ta='addSMA(n=50, on=1, col="brown");addEMA(n = 15, on = 1, col = "blue", overlay = TRUE)')
  } else if (time_period == "weekly") {
    weekly_cutoff <- paste0(as.numeric(format(Sys.Date(), "%Y"))-2, "-", 
                            format(Sys.Date(), "%m-%d"), "::")
    title = paste0(ticker, " weekly chart")
    weekly = to.weekly(eval(parse(text=ticker))[weekly_cutoff])
    ChartTool(weekly, title)
  } else if (time_period == "monthly") {
    monthly_cutoff <- paste0(as.numeric(format(Sys.Date(), "%Y"))-8, "-", 
                             format(Sys.Date(), "%m-%d"), "::")
    title = paste0(ticker, " monthly chart")
    monthly = to.monthly(eval(parse(text=ticker))[monthly_cutoff])
    ChartTool(monthly, title)
  }
}

png(filename=paste0(args[1],"/",args[2],"_dchart_",args[3],".png"), width=900, height=600)
  DrawChart(args[2], "daily")
dev.off()
png(filename=paste0(args[1],"/",args[2],"_wchart_",args[3],".png"), width=900, height=600)
  DrawChart(args[2], "weekly")
dev.off()
png(filename=paste0(args[1],"/",args[2],"_mchart_",args[3],".png"), width=900, height=600)
  DrawChart(args[2], "monthly")
dev.off()

    #get price dataframe for the past 5 years of trading
if (file.exists(paste0(args[1],"/",args[2],"_insider_transactions_",args[3],".csv"))) {
    insider_cutoff <- paste0(as.numeric(format(Sys.Date(), "%Y"))-5, "-", 
           format(Sys.Date(), "%m-%d"), "::")
    price <- as.data.frame(eval(parse(text=args[2]))[insider_cutoff])
    price$Date <- rownames(price)
    rownames(price) <- NULL
    price$Date <- as.Date(price$Date)
    colnames(price) <- gsub('.*\\.', '', colnames(price))
    first_label <- paste(args[2], "Close")

    #load insider transaction data if avaliable
    insider <- read.table(paste0(args[1],"/",args[2],"_insider_transactions_",args[3],".csv"),
                          header = TRUE, sep = ",", stringsAsFactors = FALSE)
    insider$transaction_date <- as.Date(insider$transaction_date)
    insider$shares <- as.numeric(gsub(",", "", insider$shares))
    insider$transaction_type <- as.factor(insider$transaction_type)
    merged <- merge(price, insider, by.x = 'Date', by.y = 'transaction_date', all=TRUE)
    sell_max <- max(merged$shares[which(merged$transaction_type == "Sell")], na.rm = T)
    buy_max <- max(merged$shares[which(merged$transaction_type == "Buy")], na.rm = T)
    ylimit <- min(sell_max, buy_max)
    merged$plot_shares <- ifelse(merged$shares > ylimit, ylimit, merged$shares)
    merged$plot_shares <- with(merged, ifelse(transaction_type == "Sell", -plot_shares, plot_shares))

    png(filename=paste0(args[1],"/",args[2],"_insider_",args[3], ".png"), width=900, height=600)
    par(mar = c(5,5,2,5))
    with(merged, plot(Date, Close, type="l", col="blue",
                      ylab = first_label))
    par(new = T)
    with(merged, barplot(merged$plot_shares, axes=F, ylim = c(-ylimit, ylimit), 
                         col = ifelse(merged$plot_shares>0, "darkgreen", "lightcoral"), border = NA))
    axis(side = 4)
    mtext(side=4, line = 3, 'Shares Traded by Insider')
    dev.off()
}

#plot1 <- ggplot(data=merged, aes(x = Date, y = Close)) + geom_line(colour = "blue") +
#  ylab(first_label)
#plot2 <- ggplot(data=merged, aes(x = Date, y = shares, fill=transaction_type)) +
#  geom_bar(stat = 'identity', position='dodge')
#g1 <- ggplotGrob(plot1)
#g2 <- ggplotGrob(plot2)
#g1 <- gtable_add_cols(g1, unit(0, "mm"))
#g <- rbind(g1, g2, size="first")
#grid.newpage()
#grid.draw(g)
