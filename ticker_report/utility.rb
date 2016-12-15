require 'yahoo-finance'
require 'fileutils'

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

    def check_file(symbol, file_type)
      match_files = Dir["/Users/xieliang12/ruby/stock_analysis_app/data/#{symbol}/*#{file_type}*"]
      if match_files.any?
        created = match_files[0].scan(/\d{8}/).join('').to_i
        if $tag.to_i > created
          match_files.each do |f|
            FileUtils.rm(f)
          end
        else
          exit
        end
      end
    end
  end
end
