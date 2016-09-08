#this code can be used to download stock historical data from Yahoo Finance#
#Usage: ruby stockGrep.rb <input stock symbols separated by space and the last
#argument is a number, which indicates how many years of data we want to grep, and
#saved each symbol into separate csv file"
require 'open-uri'
require 'csv'
require 'fileutils'

output_file = "data/yahoo/yahoo_price_daily.csv"

if !File.exist?(output_file)
  FileUtils.touch(output_file)
end

def get_info(symbol, file)
  url = "http://ichart.finance.yahoo.com/table.csv?s=#{symbol}&a=#{Time.now.month-1}&b=#{Time.now.day}&c=#{Time.now.year-5}&d=#{Time.now.month-1}&e=#{Time.now.day}&f=#{Time.now.year}&g=d&ignore=.csv"
  
  doc = CSV.read(open(url))  

  header = ["symbol", "date", "open", "high", "low", "close", "volume", "adj_close"]
  CSV.open(file, 'a+', {:col_sep => ","}) do |csv|
    csv << header if csv.count.eql? 0
    doc[1..-1].each do |row|
      csv << row.unshift("#{symbol}")
    end
  end
end

def get_all_price(quotes, file)
  quotes.each do |quote|
    begin
      get_info(quote, file)
    rescue
      next
    end
  end
end

#transform the array of stock symbols into upcase single strings 
symbols = ARGV[0..(ARGV.size-1)].join(",").upcase.split(",")
get_all_price(symbols, output_file)
