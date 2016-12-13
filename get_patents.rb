require_relative './ticker_report/patents'
require_relative './ticker_report/utility'

unless ARGV.size == 1
  puts "ruby stock_clinical_chart_link.rb stock_list"
end

$tag = Time.now.strftime("%Y%m%d")

#get stock symbols from input
stock_symbols = []
stock_symbols << ARGV[0]
  
i = 0
while i < stock_symbols.size
  create_directory(File.expand_path("../data/#{stock_symbols[i]}", __FILE__))
  data_type = "patents"
  check_file(stock_symbols[i], data_type)
  
  StockReport::Patent.new.get_patent(stock_symbols[i])
  i +=1
end
