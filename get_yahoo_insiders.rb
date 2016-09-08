#collect the insider transactions of all stock symbols separately
require 'yahoo_finance'

insiders = YahooFinance::Stock.new(tickers, [:insider_transaction_history])
results1 = insiders.fetch
filename2 = Dir.glob("data/yahoo/#{sector}/#{market}_#{sector}_yahoo_insider*.json").join("")
if File.exist?(filename2)
  File.delete(filename2)
end
File.open("data/yahoo/#{sector}/#{market}_#{sector}_yahoo_insider_#{Time.now.strftime("%Y%m%d%H%M")}.json", "w") do |f|
  f.write(JSON.pretty_generate(results1))
end
