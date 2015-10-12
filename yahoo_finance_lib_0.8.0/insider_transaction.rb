require 'open-uri'
require 'nokogiri'

module YahooFinance
  module InsiderTransaction
    AVL_KEY_STATS = {
      :insider_transaction_history => ["", 'Insider Transactions Reported (last two years']
    }
    def InsiderTransaction.key_events_available 
      return AVL_KEY_STATS.keys;
    end

    class InsiderTransactionPage
      attr_accessor :symbol
    
      def initialize symbol=nil
        @symbol = symbol
      end
      
      def fetch
        url = "http://finance.yahoo.com/q/it?s=#{@symbol}"
        open(url) do |stream|
          @doc = Nokogiri::HTML(stream)
        end
      end
       
      def value_for key_stat
        begin
          if key_stat == :insider_transaction_history
            ret = []
            tbl = @doc.xpath("//strong[text() = 'Insider Transactions Reported - Last Two Years']")[0].parent.parent.parent.parent.children[1].xpath("tr")
            rows = tbl.xpath(".//td//table//tr")
            for i in 1..(rows.size-1) do
              r = {}
              r[:date] = YahooFinance.parse_yahoo_field(rows[i].children[0].text)
              r[:insider] = rows[i].children[1].children[0].text
              r[:position] = rows[i].children[1].children[1].text
              r[:shares] = rows[i].children[2].text
              r[:type] = rows[i].children[3].text
              r[:transaction]  = rows[i].children[4].text
              r[:value] = rows[i].children[5].text
              ret << r
            end
            return ret
          end
          if [:insider_transaction_history].include?(key_stat) == false
            value = @doc.xpath("//td[text() = '#{AVL_KEY_STATS[key_stat][0]}']")[0].parent.children[1].text
            return YahooFinance.parse_yahoo_field(value)
          end
        rescue
        end
        return nil
      end  
    end
  end
end
