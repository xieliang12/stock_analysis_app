require 'open-uri'
require 'date'
require 'csv'
require_relative 'utility'
include StockReport::Utility

module StockReport
  module Clinical
    def get_clinicals(ticker) 
      company = get_company(ticker, "+")
      clinicals = open("https://www.clinicaltrials.gov/ct2/results/download?down_stds=all&down_typ=fields&down_flds=all&down_fmt=csv&term="+company+"&show_down=Y")
      IO.copy_stream(clinicals, File.expand_path("../../data/#{ticker}/#{ticker}_clinical_#{$tag}.zip", __FILE__))
    end

    def unzip_file(zipfile, unzipped)
      if File.exists?(zipfile)
      # unzipfile_name = path+"/"+File.basename(zipfile).split(".")[0]+".csv"
        system "unzip -p #{zipfile} > #{unzipped}"
      else
        puts "There is an error occurred during decompression:\n #{e}"
      end
    end

    def data_clean(unzipped_file, cleaned_file)
      def date_parse(date_string)
        date_arr = date_string.split(/[\s,]/) if !date_string.nil?
        elements = date_arr.reject { |c| c.empty? }
        month = Date::MONTHNAMES.index(elements[0]).to_s
        if elements.length < 3
          date = elements[1]+ "-" + month + "-01"
        else
          date = elements[2] + "-" + month + "-" + elements[1]
        end
        return date
      end
      cut_off = (Time.now.strftime("%Y").to_i-5).to_s+Time.now.strftime("%m%d")
      column_index = [0,1,2,3,4,5,6,7,8,9,10,16,17,18,22,24]
      File.foreach("#{unzipped_file}").with_index do |line, lineno|
        $header << line.split("\",\"").values_at(*(column_index.map { |x| x+1 })) if lineno == 0
        items = line.split("\",\"").values_at(*column_index) if lineno > 0
        if !items.nil?
          items[0].gsub!(/\d{1,}\,\"/, '')
          items[1].gsub!(/\"/, '')
          items[3].gsub!(/No Results Available/, 'NA')
          items[8].gsub!(/   /, ' ')
          items[9].gsub!(/Phase/, 'P')
          items[9].gsub!(/ /, '') if items[9] =~ /\|/
          temp = items[11..14].map {|x| date_parse(x)}
          items[11..14] = temp
          items[15].gsub!("\"\r\n",'')
          #items.map! {|x| x.gsub(/   /, ' ')}
          $filtered << items if Date.parse(items[11]) > Date.parse(cut_off)
        end
      end

      $header[0].last.gsub!("\"\r\n",'')
      $header.flatten!.map! {|x| x.gsub("\"", '')}
      CSV.open("#{cleaned_file}", 'w', {:col_sep => ","}) do |csv|
        csv << $header
        $filtered.each do |row|
          csv << row
        end
      end
    end
  end
end
