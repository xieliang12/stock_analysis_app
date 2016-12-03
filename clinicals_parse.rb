require 'date'
require 'csv'
cut_off = (Time.now.strftime("%Y").to_i-5).to_s+Time.now.strftime("%m%d")

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

filtered = []
header = []
column_index = [0,1,2,3,4,5,6,7,8,9,10,16,17,18,22,24]
File.foreach("./data/NVAX/NVAX_clinical_20161130.csv").with_index do |line, lineno|
  header << line.split("\",\"").values_at(*(column_index.map { |x| x+1 })) if lineno == 0
  items = line.split("\",\"").values_at(*column_index) if lineno > 0
  if !items.nil?
    items[0].gsub!(/\d{1,}\,\"/, '')
    items[1].gsub!(/\"/, '')
    items[3].gsub!(/No Results Available/, 'NA')
    items[8].gsub!(/   /, ' ')
    items[9].gsub!(/Phase/, 'P')
    temp = items[11..14].map {|x| date_parse(x)}
    items[11..14] = temp
    items[15].gsub!("\"\r\n",'')
#   items.map! {|x| x.gsub(/   /, ' ')}
    filtered << items if Date.parse(items[11]) > Date.parse(cut_off)
  end
end

header[0].last.gsub!("\"\r\n",'')
header.flatten!.map! {|x| x.gsub("\"", '')}
CSV.open("test.txt", 'w', {:col_sep => ","}) do |csv|
  csv << header
  filtered.each do |row|
    csv << row
  end
end
