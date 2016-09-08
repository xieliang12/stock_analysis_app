require 'nokogiri'
# require 'open-uri'
require 'json'
=begin
all_papers = [
  {
    "pmid": "26255071",
    "title": "Methotrexate administration directly into the fourth ventricle in children with malignant fourth ventricular brain tumors: a pilot clinical trial.",
    "magazine": "J Neurooncol.",
    "publish_date": "2015 Oct;125(1):133-41. doi: 10.1007/s11060-015-1878-y. Epub  2015 Aug 9.",
  },
  {
    "pmid": "25381261",
    "title": "Darinaparsin inhibits prostate tumor-initiating cells and Du145 xenografts and is an inhibitor of hedgehog signaling.",
    "magazine": "Mol Cancer Ther.",
    "publish_date": "2015 Jan;14(1):23-30. doi: 10.1158/1535-7163.MCT-13-1040. Epub  2014 Nov 7.",
  }
]
records = [
  {
    "inventor": "WALIGORA; Frank W.; et al.",
    "report_date": "November 19, 2015",
    "title": "SYNTHESIS AND FORMULATIONS OF SALTS OF ISOPHOSPHORAMIDE MUSTARD AND ANALOGS THEREOF",
  },
  {
    "inventor": "MORGAN; Lee R.",
    "report_date": "June 4, 2015",
    "title": "SALTS OF ISOPHOSPHORAMIDE MUSTARD AND ANALOGS THEREOF AS ANTI-TUMOR AGENTS",
  }
]


def process_array(label,array,xml)
  array.each do |hash|
    xml.send(label) do
      hash.each do |key,value|
        if value.is_a?(Array)
          process_array(key,value,xml)
        else
          xml.send(key,value)
        end
      end
    end
  end
end
=end

statistics=JSON.parse(File.read("/Users/xieliang12/ruby/stock_analysis_app/data/yahoo/healthcare/mid_healthcare_yahoo_statistics_201512201551.json"))["ZIOP"]

builder = Nokogiri::XML::Builder.new do |xml|
  xml.root {
#    xml.patents do
#      process_array('patent', records, xml)
#    end
#   xml.papers do
#      process_array('paper', all_papers, xml)
#    end
    xml.statistics do
      statistics.each do |key, value|
        xml.send(key, value)
      end
    end
  }
end

File.open("test.xml","w") do |f|
  f.write(builder.to_xml)
end

=begin
def get_headlines(symbol)
  url = "http://finance.yahoo.com/q/h?s=#{symbol}+Headlines"
  doc = Nokogiri::HTML(open(url))
  rows = doc.xpath('//table/tr/td/div/ul/li')
  details = rows.collect do |row|
    detail = {}
    [
      [:link, 'a/@href'],
      [:title, 'a/text()'],
      [:cite, 'cite/text()'],
      [:date, 'cite/span/text()'],
    ].each do |name, xpath|
      detail[name] = row.at_xpath(xpath).to_s.strip
    end
    detail
  end

  puts details
end

get_headlines("ZIOP")

=end
