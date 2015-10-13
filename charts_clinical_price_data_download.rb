require 'open-uri'
require 'nokogiri'
require 'json'
require 'fileutils'
require_relative 'download_url_from_file'

unless ARGV.size == 1
  puts "ruby stock_clinical_chart_link.rb <stock_list.dat>"
  puts "ruby stock_clinical_chart_link.rb stock_list.dat"
end

#get stock symbols from stock_list.dat line by line
stock_symbols = []
File.open("./stock_list.dat","r") do |file|
  while line = file.gets
    stock_symbols << line.chomp unless (line == nil || line.length == 0)
  end
end

#create new directory if the directory is not exist
def create_directory(dirname)
  unless Dir.exists?(dirname)
    Dir.mkdir(dirname)
  else
    puts "Skipping creating directory " + dirname + ". It already exists."
  end
end

def get_company(name)
  first_part = name.split(",")[0] unless name == nil
  if first_part.scan(/\w+/).size >= 2
    company_name = first_part.split(" ")[0..1].join("+")
  else company_name = first_part.scan(/\w+/).join("")
    end
  return company_name
end

#get the news headlines from yahoo from stock_symbol
def get_headlines(symbol)
  url = "http://finance.yahoo.com/q/h?s=#{symbol}+Headlines"
  doc = Nokogiri::HTML(open(url))
  rows = doc.xpath('//table/tr/td/div/ul/li')
  details = rows.collect do |row|
    detail = {}
    [
      [:link, 'a[@href]'],
      [:title, 'a/text()'],
      [:cite, 'cite/text()'],
      [:date, 'cite/span/text()'],
    ].each do |name, xpath|
      detail[name] = row.at_xpath(xpath).to_s.strip
    end
    detail
  end
    File.open("data/charts_prices_clinical/#{symbol}/#{symbol}_yahoo_headlines.json", "w") do |f|
      f.write(JSON.pretty_generate(details))
    end
end

#build the clinical data download link for each stock symbols from 
#clinicaltrials.gov and save each download link into clinical_link.dat
#build historical prices download link of stock symbols

x = 0
while x < stock_symbols.size
  create_directory("./data/charts_prices_clinical/#{stock_symbols[x]}")
  year, month, day = Time.now.strftime("%Y-%m-%d").split("-") 
  tag = Time.now.strftime("%Y%m%d")
  filenames = Dir.glob("./data/charts_prices_clinical/#{stock_symbols[x]}/*")
  filenames.each do |f|
    bname = File.basename(f).split(".")[0] unless f.nil?
    re = Regexp.union("_6m_yahoo_","_daily_finviz_","_monthly_finviz_","_weekly_finviz_", "_clinical_", "_5years_prices_")
    if bname.match(re) and bname[-8..-1] < tag
      FileUtils.rm(f)
    end
  end
  link_file = "./data/charts_prices_clinical/#{stock_symbols[x]}/links.dat"
  if File.exist?(link_file)
    FileUtils.rm(link_file)
  end
  data_hash = JSON.parse(File.read(Dir.glob("./data/yahoo/healthcare/mid_healthcare_yahoo_statistics_*.json").join("")))
  company = get_company(data_hash[stock_symbols[x]]['company_name'])
  link_c = "https://www.clinicaltrials.gov/ct2/results/download?down_stds=all&down_typ=fields&down_flds=all&down_fmt=csv&term="+company+"&show_down=Y"
  url = "http://ichart.finance.yahoo.com/table.csv?s=#{stock_symbols[x]}&a=#{month.to_i-1}&b=#{day.to_i-1}&c=#{year.to_i-5}&d=#{month.to_i-1}&e=#{day.to_i-1}&f=#{year.to_i}&g=d&ignore=.csv"
  link_d = "http://finviz.com/chart.ashx?t=#{stock_symbols[x]}&ty=c&ta=0&p=d&s=l"
  link_w = "http://finviz.com/chart.ashx?t=#{stock_symbols[x]}&ty=c&ta=0&p=w&s=l"
  link_m = "http://finviz.com/chart.ashx?t=#{stock_symbols[x]}&ty=c&ta=0&p=m&s=l"
  link_y = "http://chart.finance.yahoo.com/z?s=#{stock_symbols[x]}&t=6m&q=c&l=off&z=l&p=e15,m50,m200,v&a=r14,fs"
  File.open(link_file, "a") do |f|
    f.puts(url+" "+stock_symbols[x]+"_5years_prices_#{tag}.csv")
    f.puts(link_d+" "+stock_symbols[x]+"_daily_finviz_#{tag}.png")
    f.puts(link_w+" "+stock_symbols[x]+"_weekly_finviz_#{tag}.png")
    f.puts(link_m+" "+stock_symbols[x]+"_monthly_finviz_#{tag}.png")
    f.puts(link_y+" "+stock_symbols[x]+"_6m_yahoo_#{tag}.png")
    f.puts(link_c+" "+stock_symbols[x]+"_clinical_#{tag}.zip")
  end
  get_headlines(stock_symbols[x])
  download("./data/charts_prices_clinical/#{stock_symbols[x]}/links.dat","./data/charts_prices_clinical/#{stock_symbols[x]}")
  x +=1
end
