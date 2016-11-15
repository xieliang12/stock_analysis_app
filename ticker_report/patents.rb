require 'open-uri'
require 'nokogiri'
require 'json'
require 'mechanize'
require_relative 'utility'
include StockReport::Utility

module StockReport
  class Patent
    def get_patent(symbol)
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
      company_name = get_company(symbol, " ")
      agent = Mechanize.new
      page = agent.get('http://appft.uspto.gov/netahtml/PTO/search-bool.html')
      search_form = page.form
      search_form.TERM1 = "#{company_name}"
      search_form.TERM2 = "#{company_name}"
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

      File.open(File.expand_path("../../data/#{symbol}/#{symbol}_patents_#{$tag}.json", __FILE__), "w") do |f|
        f.write(JSON.pretty_generate(records))
      end
    end
  end
end
