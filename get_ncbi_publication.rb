require 'open-uri'
require 'nokogiri'
require 'mechanize'

stock_symbols = []
File.open("stock_list.dat", "r") do |file|
  while line = file.gets
    stock_symbols << line.chomp unless (line == nil || line.length == 0)
  end
end

$data_hash = JSON.parse(File.read(Dir.glob("./data/yahoo/healthcare/mid_healthcare_yahoo_statistics_*.json").join("")))

def get_company(name, separator)
  first_part = name.split(",")[0] unless name == nil
  if first_part.scan(/\w+/).size >= 2
    company_name = first_part.split(" ")[0..1].join(separator)
  else company_name = first_part
    return company_name
  end
end

def get_paper_information(pmid)
  detail = {}
  url = "http://www.ncbi.nlm.nih.gov/pubmed/#{pmid}"
  doc = Nokogiri::HTML(open(url))
  detail["title"] = doc.xpath('//div[@class="rprt_all"]/div/h1/text()').to_s
  detail["magazine"] = doc.xpath('//div[@class="rprt_all"]/div/div[1]/a/text()').to_s
  detail["publish_date"] = doc.xpath('//div[@class="rprt_all"]/div/div[1]').children[1].to_s.strip 
  rows = doc.xpath('//div[@class="abstr"]/div/h4')
  i = 0
  while i < rows.size
    name = doc.xpath('//div[@class="abstr"]/div/h4/text()')[i].to_s.strip.gsub!(":","").downcase!
    value = doc.xpath('//div[@class="abstr"]/div/p')[i].children.text().to_s.strip
    detail[name] = value unless value.nil?
    i +=1
  end
  detail["abstract"] = doc.xpath('//div[@class="abstr"]/div/p/abstracttext/text()').to_s.strip if rows.size == 0
  detail
end

def download_ncbi_paper(ticker)
  company = get_company($data_hash[ticker]['company_name'], " ")
  url = "http://www.ncbi.nlm.nih.gov/pubmed/advanced"
  agent = Mechanize.new
  page = agent.get(url)
  search_form = page.form
  search_form["EntrezSystem2.PEntrez.DbConnector.Term"] = "#{company}"
  search_form["EntrezSystem2.PEntrez.DbConnector.LastQueryKey"] = "1"
  page = agent.submit(search_form)
  html = page.content
  doc = Nokogiri::HTML(html)
  unless doc.xpath('//title/text()').to_s !~ /No items found/
    abort("No results found for #{company}")
  end
  items_size = doc.xpath('//h3[@class="result_count left"]/text()').to_s.split(":")[1].split(" ")[-1]
  ids = doc.xpath('//div/div/dl/dd/text()')
  pmids = []
  ids.each do |id|
    pmids << id.to_s.strip
  end
  
  records = {}
  pmids.each do |pmid|
    records[pmid] = get_paper_information(pmid)
  end
  File.open("data/charts_prices_clinical/#{ticker}/#{ticker}_ncbi_publication.json", "w") do |f|
    f.write(JSON.pretty_generate(records))
  end
end

i = 0
while i < stock_symbols.size
  download_ncbi_paper(stock_symbols[i])
  i +=1
end
