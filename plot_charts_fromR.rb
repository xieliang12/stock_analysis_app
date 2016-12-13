require_relative './ticker_report/insider_transactions'
require_relative './ticker_report/utility'
require 'csv'
#require 'rinruby'
include StockReport::Insider

unless ARGV[0]
  puts "Usage: ruby clinicals_data_clean.rb <stock_symbol>"
  exit
end

symbol = ARGV[0].chomp
$tag = Time.now.strftime("%Y%m%d")
check_file(symbol, "chart")
check_file(symbol, "insider")

$path = File.expand_path("../data/#{symbol}/", __FILE__)
$first_url = ""
$next_page = ""
$all_transactions = []

create_directory(File.expand_path("../data/#{symbol}", __FILE__))

insider_link(symbol)
page_parse($first_url)
if $next_page != ""
  page_parse($next_page)
  $next_page = ""
end

insiders_file = File.expand_path("#{$path}/#{symbol}_insider_transactions_#{$tag}.csv", __FILE__)
if $all_transactions.any?
  headers = $all_transactions[0].keys
  CSV.open(insiders_file, "w") do |csv|
    csv << headers
    $all_transactions.each do |row|
      csv << row.values
    end
  end
end

system "Rscript --vanilla /Users/xieliang12/ruby/stock_analysis_app/ticker_report/price_insider_charts.R #{$path} #{symbol} #{$tag}"
system "rm #{insiders_file}"
