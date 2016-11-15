require 'open-uri'
include StockReport::Utility

module StockReport
  module Clinical
    company = get_company(stock_symbols[i], "+")
    clinicals = open("https://www.clinicaltrials.gov/ct2/results/download?down_stds=all&down_typ=fields&down_flds=all&down_fmt=csv&term="+company+"&show_down=Y")
    IO.copy_stream(clinicals, File.expand_path("../data/#{stock_symbols[i]}/#{stock_symbols[i]}_clinical_#{$tag}.zip", __FILE__))
  end
end
