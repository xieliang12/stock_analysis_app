require 'open-uri'
require 'nokogiri'
require_relative 'utility'
include StockReport::Utility

module StockReport
  module Insider
    def insider_link(symbol) 
      today = Time.now.strftime("%Y-%m-%d")
      year, month, day = Time.now.strftime("%Y-%m-%d").split("-")
      cut_off = (year.to_i-5).to_s+"-"+month+"-"+day
      $first_url = "http://www.insidertrading.org/?sort_by=acceptance_datetime&asc=&symbol=#{symbol}&date_from=#{cut_off}&date_to=#{today}&submit=+GO+"
    end

    def page_parse(link)
      doc = Nokogiri::HTML(open(link))
      if doc.at_xpath('//table[@id="tracker"]/tbody/tr/td[1]/text()').to_s.strip != "NO RESULTS"
        rows = doc.xpath('//table[@id="tracker"]/tbody/tr')
        transactions = rows.collect do |row|
          transaction = {}
          [
            ['transaction_type', 'td[1]/text()'],
            ['transaction_date', 'td[2]/text()'],
            ['issuer_symbol', 'td[5]/a/text()'],
            ['owner_name', 'td[6]/a/text()'],
            ['owner_relationship', 'td[7]/a/text()'],
            ['shares', 'td[8]/text()'],
            ['price_share', 'td[9]/text()'],
            ['total_value', 'td[10]/text()'],
          ].each do |field, xpath|
            transaction[field] = row.at_xpath(xpath).to_s.strip
          end
          transaction
        end
        ($all_transactions << transactions).flatten!
      end
      
      if doc.xpath('//div[@style="text-align:center;margin-top:10px;text-decoration: none;"]/span/a/text()').to_s == "Next"
        $next_page = "http://www.insidertrading.org"+doc.xpath('//div[@style="text-align:center;margin-top:10px;text-decoration: none;"]/span/a/@href').to_s.strip
      end
    end
  end
end
