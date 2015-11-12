require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'nokogiri'
require 'mongo'

stock_symbols = []
File.open("stock_list.dat","r") do |file|
  while line = file.gets
    stock_symbols << line.chomp unless (line == nil || line.length == 0)
  end
end

$db = Mongo::Client.new( ['127.0.0.1:27017' ], :database => 'stock_data')

$data_hash = JSON.parse(File.read(Dir.glob("./data/yahoo/healthcare/mid_healthcare_yahoo_statistics_*.json").join("")))

def get_company(name, separator)
  first_part = name.split(",")[0] unless name == nil
  if first_part.scan(/\w+/).size >= 2
    company_name = first_part.split(" ")[0..1].join(separator)
  else company_name = first_part.scan(/\w+/).join("")
    end
  return company_name
end

def get_patent(symbol)
  search_item = get_company($data_hash[symbol]['company_name'], " ")
  agent = Mechanize.new
  page = agent.get('http://appft.uspto.gov/netahtml/PTO/search-bool.html')
  search_form = page.form
  search_form.TERM1 = "#{search_item}"
  search_form.TERM2 = "#{search_item}"
  search_form.FIELD1 = "AS"
  search_form.FIELD2 = "AANM"
  search_form.co1 = "OR"

  page = agent.submit(search_form)
  rows = page.search('.//table/tr')
  details = rows.collect do |row|
    detail = {}
    [
      [:num, 'td[1]/text()'],
      [:link, 'td[2]/a[@href]'],
      [:patent_num, 'td[2]/a/text()'],
    ].each do |name, xpath|
      detail[name] = row.at_xpath(xpath).to_s.strip
    end
    detail
  end

  records = []
  details[1..-1].each do |detail|
    temporary_page =  (page.link_with(text: detail[:patent_num])).click
    temporary_link = temporary_page.uri
    h = Hash.new()
    h[:patent_id] = detail[:patent_num]
    h.merge!(parse_link(temporary_link))
    records << h
  end

  coll = "#{symbol}_patents".downcase
  $db[coll].indexes.create_one( {patent_id: 1}, :unique => true)
  $db[coll].insert_many(records)
#  File.open("data/charts_prices_clinical/#{symbol}/#{symbol}_patent_information.json","w") do |f|
#   f.write(JSON.pretty_generate(records))
#  end
end

def parse_link(page_link)
  doc = Nokogiri::HTML(open(page_link))
  content = {}
  replacements = [["\n", ""], [/\s+/, " "]]
  content[:inventor] = doc.xpath('//table[2]/tr[3]/td[1]/b/text()').to_s.strip
  content[:inventor].gsub!("\n; &amp;nbsp ", "; ")
  content[:report_date] = doc.xpath('//table[2]/tr[3]/td[2]/b/text()').to_s.strip
  content[:title] = doc.xpath('//font[@size="+1"]/text()').to_s.strip
  replacements.each {|replacement| content[:title].gsub!(replacement[0], replacement[1])}
  content[:abstract] = doc.xpath('//p/text()')[1].to_s.strip
  replacements.each {|replacement| content[:abstract].gsub!(replacement[0], replacement[1])}
  content[:link] = page_link.to_s.strip
  content
end

# get_patent(stock_symbols[0])
i = 0
while i < stock_symbols.size
  get_patent(stock_symbols[i])
  i +=1
end
