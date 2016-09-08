require 'nokogiri'

#unless ARGV[0]
#  puts "Usage: ruby json_to_xml.rb json_filename"
#  puts "Example: ruby json_to_xml.rb patent.json"
#end

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

data = [
  {
    "patent_id": "20150328238",
    "inventor": "WALIGORA; Frank W.; et al.",
    "report_date": "November 19, 2015",
    "title": "SYNTHESIS AND FORMULATIONS OF SALTS OF ISOPHOSPHORAMIDE MUSTARD AND ANALOGS THEREOF",
    "abstract": "Disclosed herein are formulations and methods of manufacture of compounds of formula (E): ##STR00001## wherein X and Y independently represent leaving groups; and A.sup.+ is an ammonium cation.",
    "link": "http://appft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-bool.html&r=1&f=G&l=50&co1=OR&d=PG01&s1=%22ZIOPHARM+Oncology%22.AS.&s2=%22ZIOPHARM+Oncology%22.AANM.&OS=AN/%22ZIOPHARM+Oncology%22+OR+AANM/%22ZIOPHARM+Oncology%22&RS=AN/%22ZIOPHARM+Oncology%22+OR+AANM/%22ZIOPHARM+Oncology%22"
  },
  {
    "patent_id": "20150152125",
    "inventor": "MORGAN; Lee R.",
    "report_date": "June 4, 2015",
    "title": "SALTS OF ISOPHOSPHORAMIDE MUSTARD AND ANALOGS THEREOF AS ANTI-TUMOR AGENTS",
    "abstract": "The present disclosure relates to salts and compositions of isophosphoramide mustard and isophosphoramide mustard analogs. In one embodiment the salts can be represented by the formula I: (I) wherein A.sup.+ represents an ammonium species selected from the protonated (conjugate acid) or quaternary forms of aliphatic amines and aromatic amines, including basic amino acids, heterocyclic amines, substituted and unsubstituted pyridines, guanidines and amidines; and X and Y independently represent leaving groups. Also disclosed herein are methods for making such compounds and formulating pharmaceutical compositions thereof. Methods for administering the disclosed compounds to subjects, particularly to treat hyper-proliferative disorders, also are disclosed. ##STR00001##",
    "link": "http://appft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-bool.html&r=2&f=G&l=50&co1=OR&d=PG01&s1=%22ZIOPHARM+Oncology%22.AS.&s2=%22ZIOPHARM+Oncology%22.AANM.&OS=AN/%22ZIOPHARM+Oncology%22+OR+AANM/%22ZIOPHARM+Oncology%22&RS=AN/%22ZIOPHARM+Oncology%22+OR+AANM/%22ZIOPHARM+Oncology%22"
  },
  {
    "patent_id": "20140378704",
    "inventor": "WALIGORA; Frank W.; et al.",
    "report_date": "December 25, 2014",
    "title": "SYNTHESIS AND FORMULATIONS OF SALTS OF ISOPHOSPHORAMIDE MUSTARD AND ANALOGS THEREOF",
    "abstract": "Disclosed herein are formulations and methods of manufacture of compounds of formula (E): ##STR00001## wherein X and Y independently represent leaving groups; and A.sup.+ is an ammonium cation.",
    "link": "http://appft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-bool.html&r=3&f=G&l=50&co1=OR&d=PG01&s1=%22ZIOPHARM+Oncology%22.AS.&s2=%22ZIOPHARM+Oncology%22.AANM.&OS=AN/%22ZIOPHARM+Oncology%22+OR+AANM/%22ZIOPHARM+Oncology%22&RS=AN/%22ZIOPHARM+Oncology%22+OR+AANM/%22ZIOPHARM+Oncology%22"
  }, 
]
  
#json_file = ARGV[0].chomp
#content = JSON.parse(File.read(json_file))

#File.open("test.xml",'w') do |f|
#  f.writes(content.to_xml(:root => 'patent'))
#end

builder = Nokogiri::XML::Builder.new do |xml|
  xml.root do
    process_array('category',data,xml)
  end
end

puts builder.to_xml
