require 'fileutils'
#require 'ticker_report/publications'
require './ticker_report/patents'
require './ticker_report/utility'

unless ARGV.size == 1
  puts "ruby stock_clinical_chart_link.rb stock_list"
end

$tag = Time.now.strftime("%Y%m%d")

#get stock symbols from input
stock_symbols = []
stock_symbols << ARGV[0]

#build the clinical data download link for each stock symbols from 
#clinicaltrials.gov and save each download link into clinical_link.dat
#build historical prices download link of stock symbols
  
i = 0
while i < stock_symbols.size
  create_directory(File.expand_path("../data/#{stock_symbols[i]}", __FILE__))
  #year, month, day = Time.now.strftime("%Y-%m-%d").split("-") 
  filenames = Dir.glob(File.expand_path("../data/#{stock_symbols[i]}", __FILE__)+"/*")
  file_version = ""
  bname = File.basename(filenames[0]).split(".")[0] unless filenames.empty?
  if !bname.nil? && bname.match("#{$tag}")
    file_version = "newest"
  end

  if file_version != "newest"
    filenames.each do |f|
      FileUtils.rm(f) if File.exist?(f)
    end

    StockReport::Patent.new.get_patent(stock_symbols[i])
    #download_ncbi_paper(stock_symbols[i])
  end
  i +=1
end
