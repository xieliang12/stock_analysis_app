require 'json'
require 'yahoo_finance'

if ARGV.size != 2
  puts "Usage: ruby yahoo_finance.rb <market_cap> <sector_name>"
  puts "Example: ruby yahoo_finance.rb mid healthcare"
  exit
end

market = ARGV[0]
sector = ARGV[1]

tickers = []
fname = Dir["data/finviz/#{sector}/*"].grep(/#{market}_#{sector}/).join("")
file = File.read(fname)
finviz_hash = JSON.parse(file)

i = 0
while i < finviz_hash.size
  finviz_hash.each do |x|
    x.each do |element|
      tickers << element['ticker'] if element['ticker'] != ""
    end
    i +=1
  end
end

stocks = YahooFinance::Stock.new(tickers, [:market_cap, :sector, :industry, :company_name, :p_e_ratio, :peg_ratio, :price_to_sales_ttm, :price_to_book_mrq, :earnings_per_share, :ebitda, :eps_estimate_current_year, :eps_estimate_next_quarter, :fifty_day_moving_average, :fifty_two_week_high, :fifty_two_week_low, :percent_change_from_200_day_moving_average, :percent_change_from_50_day_moving_average, :shares_owned, :short_ratio, :two_hundred_day_moving_average, :volume, :roa_ttm, :roe_ttm, :shares_outstanding, :pcnt_held_by_insiders, :pcnt_held_by_institutions, :pcnt_short_of_float, :operating_cash_flow_ttm, :levered_cash_flow_ttm, :next_earnings_announcement_date, :book_value_per_share_mrq])
results = stocks.fetch

File.open("data/yahoo/#{sector}/#{market}_#{sector}_yahoo_#{Time.now.strftime("%Y%m%d%H%M")}.json", "w") do |f|
    f.write(JSON.pretty_generate(results))
end
