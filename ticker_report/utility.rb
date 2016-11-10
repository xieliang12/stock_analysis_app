require 'yahoo-finance'

module StockReport
  module Utility
    def create_directory(dirname)
      unless Dir.exists?(dirname)
        Dir.mkdir(dirname)
      end
    end

    def get_company(symbol, separator)
      data = YahooFinance::Client.new.quotes(["#{symbol}"], [:name])
      name = data[0].name
      first_part = name.split(",")[0] unless name == nil
      if first_part.scan(/\w+/).size >= 2
        search_name = first_part.split(" ")[0..1].join(separator)
      else search_name = first_part.scan(/\w+/).join("")
        end
      return search_name
    end
  end
end
