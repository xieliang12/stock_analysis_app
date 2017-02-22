require 'json'
require 'open-uri'
require 'yahoo-finance'
require 'csv'
require 'fileutils'
require 'date'

#if ARGV.size > 1
#  puts "Usage: ruby yahoo_finance.rb <sector>"
#  puts "Example: ruby yahoo_finance.rb healthcare"
#  exit
#end

$sector = ARGV.last
tickers = []
finviz_hash = []

fname = Dir["data/finviz/*.json"].grep(/#{$sector}/).join("")
if File.exist?(fname)
  file = File.read(fname)
  finviz_hash = JSON.parse(file)
else
  puts "#{fname} not found."
end

i = 0
page_num = finviz_hash.size
while i < page_num
  finviz_hash.each do |x|
    x.each do |element|
      tickers << element['ticker'] if element['ticker'] != ""
    end
    i +=1
  end
end

#collect the stock symbols screened by sector from saved json data file in data/finviz folder
yahoo_client = YahooFinance::Client.new
results = yahoo_client.quotes(tickers, [:market_capitalization, :average_daily_volume, :book_value, :change, :change_from_200_day_moving_average, :change_from_50_day_moving_average, :change_in_percent, :close, :day_value_change, :days_range, :dividend_pay_date, :dividend_per_share, :dividend_yield, :earnings_per_share, :ebitda, :eps_estimate_current_year, :eps_estimate_next_quarter, :eps_estimate_next_year, :float_shares, :high, :high_52_weeks, :low, :low_52_weeks, :moving_average_200_day, :moving_average_50_day, :name, :one_year_target_price, :open, :pe_ratio, :peg_ratio, :percent_change_from_200_day_moving_average, :percent_change_from_50_day_moving_average, :previous_close, :price_per_book, :price_per_sales, :revenue, :shares_outstanding, :shares_owned, :short_ratio, :stock_exchange, :symbol, :volume], { raw: false })

$header = []
results[0].to_h.keys.each do |k|
  $header << k.to_s
end

#write the stocks statistics data to csv file
def save_to_csv(hash_data, file)
  hash_data.each do |v|
    row = v.to_h.values
    row.map!{ |x| x == "N/A" ? -999 : x}.map!{ |x| x ? x: -999}.map!{ |x| x == "NaN" ? -999 : x}
    row.map!{ |x| x =~ /%/ ? (x.gsub(',','').gsub('%','').to_f)/100 : x}
    row.map!{ |x| x =~ /k/i ? x.gsub(',','').to_f*1000 : x}
    CSV.open(file, "a+", {:col_sep => "\t"}) do |csv|
      csv << $header if csv.count.eql? 0
      csv << row
    end
  end
end

def not_newest?(old_file)
  if File.exist?(old_file)
    file_date = Date.parse(File.basename(old_file, ".csv").split("_")[3][0..7])
    if file_date < Date.today
      return true
    end
  end
end

yahoo_data = File.join(File.expand_path(File.dirname(__FILE__)), "data/yahoo")
unless File.directory?(yahoo_data)
  FileUtils.mkdir_p(yahoo_data)
end   

current_time = Time.now.strftime("%Y%m%d%H%M")
statistics_file = Dir.glob("data/yahoo/yahoo_#{$sector}_statistics*.csv").join("")
new_stat_file = "data/yahoo/yahoo_#{$sector}_statistics_#{current_time}.csv"

if !File.exist?(statistics_file)
  save_to_csv(results, new_stat_file)
elsif File.exist?(statistics_file) && not_newest?(statistics_file)
  File.delete(statistics_file)
  save_to_csv(results, new_stat_file)
end
=begin
#get the historical price of the last five years of each symbol
def get_price(symbol, file)
  url = "http://ichart.finance.yahoo.com/table.csv?s=#{symbol}&a=#{Time.now.month-1}&b=#{Time.now.day}&c=#{Time.now.year-1}&d=#{Time.now.month-1}&e=#{Time.now.day}&f=#{Time.now.year}&g=d&ignore=.csv"
  
  doc = CSV.parse(open(url).read)  

  header = ["symbol", "date", "open", "high", "low", "close", "volume", "adj_close"]
  CSV.open(file, 'a+', {:col_sep => ","}) do |csv|
    csv << header if csv.count.eql? 0
    doc[1..-1].each do |row|
      csv << row.unshift("#{symbol}")
    end
  end
end

price_file = Dir.glob("data/yahoo/yahoo_#{$sector}_daily*.csv").join("")
new_price_file = "data/yahoo/yahoo_#{$sector}_daily_#{current_time}.csv"

def get_all_price(quotes, file_name)
  quotes.each do |quote|
    begin
      get_price(quote, file_name)
    rescue
      next
    end
  end
end

#loop each of stock tickers for getting price information
if !File.exist?(price_file)
  get_all_price(tickers, new_price_file)
elsif File.exist?(price_file) && not_newest?(price_file)
  File.delete(price_file)
  get_all_price(tickers, new_price_file)
end
=end
