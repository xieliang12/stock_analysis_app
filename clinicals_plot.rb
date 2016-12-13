require_relative './ticker_report/clinicaltrails'
require_relative './ticker_report/utility'
#require 'rinruby'
include StockReport::Clinical 

unless ARGV[0]
  puts "Usage: ruby clinicals_data_clean.rb <stock_symbol>"
  exit
end

$tag = Time.now.strftime("%Y%m%d")
symbol = ARGV[0].chomp
check_file(symbol, "clinical")
get_clinicals(symbol)

$path = File.expand_path("../data/#{symbol}/", __FILE__)
$filename = Dir.glob("#{$path}/#{symbol}_clinical*.zip")[0]
$basename = File.basename($filename).split(".")[0]
unzipped = $path+"/"+$basename+".csv"
$cleaned = $path+"/"+$basename+"_cleaned.csv" 
$filtered = []
$header = []

unzip_file($filename, unzipped)
if File.exists?(unzipped)
  data_clean(unzipped, $cleaned)
end

system "Rscript --vanilla /Users/xieliang12/ruby/stock_analysis_app/ticker_report/clinical_trails_plot.R #{$path} #{$cleaned} #{$basename}"
system "rm -rf #{unzipped} #{$filename} #{$cleaned}"
