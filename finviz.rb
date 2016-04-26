require 'open-uri'
require 'nokogiri'
require 'json'
require 'fileutils'
require 'date'

unless ARGV.size == 1
  puts "Usage: ruby finviz.rb <sector>"
  puts "Example: ruby finviz.rb healthcare"
end

$sector = ARGV[0]
dirname = "/Users/xieliang12/ruby/stock_analysis_app/data/finviz"

unless File.directory?(dirname)
  FileUtils.mkdir_p(dirname)
end
#download the data from finviz website
# 151 is custom dataset; 121 is valuation dataset; 131 is ownership dataset
# 141 is performance dataset
overview_url = "http://finviz.com/screener.ashx?v=111&f=sec_#{$sector}"

#get the total number of stocks from the screening
html = open(overview_url)
doc = Nokogiri::HTML(html)
rows1 = doc.xpath('//table[@border="0"]/tr')
numbers = rows1.collect do |row|
  number = {}
  [
    [:total, 'td[1]/text()'],].each do |name, xpath|
      number[name] = row.at_xpath(xpath).to_s.strip
    end
    number
end

numbers.each do |number|
  $count = number[:total].split(/\s/)[0].to_f if number[:total] =~ /\d+/
  $count
end

custom_url = "http://finviz.com/screener.ashx?v=151&f=sec_#{$sector}"

#parse the table of each stock information from custom page#
def get_custom(link, pages)
  i = 1
  records = []
  while i < pages
    url = link+"&r="+i.to_s
    html = open(url)
    doc = Nokogiri::HTML(html)
    rows = doc.xpath('//table[@bgcolor="#d3d3d3"]/tr')
    records << rows.collect do |row|
      record = {}
      [
        [:no, 'td[1]/a/text()'],
        [:ticker, 'td[2]/a/text()'],
        [:country, 'td[6]/a/text()'],
      ].each do |name, xpath|
        record[name] = row.at_xpath(xpath).to_s.strip
      end
      record
    end
    sleep 1
    i += 20
  end

  File.open("data/finviz/finviz_#{$sector}_#{Time.now.strftime("%Y%m%d%H%M")}.json", "w") do |f|
    f.write(JSON.pretty_generate(records))
  end
end

old_filename = Dir["data/finviz/finviz_#{$sector}*.json"]
unless old_filename.empty?
  if Date.parse(File.basename(old_filename[0], ".json").split("_")[2][0..7]) < Date.today
    File.delete(old_filename[0])
  end  
end

get_custom(custom_url, $count)


