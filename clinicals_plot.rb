require './ticker_report/clinicaltrails'
require './ticker_report/utility'
require 'rinruby'
include StockReport::Clinical 

unless ARGV[0]
  puts "Usage: ruby clinicals_data_clean.rb <stock_symbol>"
  exit
end

$tag = Time.now.strftime("%Y%m%d")
symbol = ARGV[0].chomp
check_file(stock_symbols[i], "clinical")
get_clinicals(symbol)

$path = File.expand_path("../data/#{symbol}/", __FILE__)
$filename = Dir.glob("#{$path}/#{symbol}_clinical*.zip")[0]
$basename = File.basename($filename).split(".")[0]
unzipped = $path+"/"+$basename+".csv"
$cleaned = $path+"/"+$basename+"_cleaned.csv" 
$filtered = []
$header = []

unzip_file($filename, unzipped)
if File.exists?(unzipped)
  data_clean(unzipped, $cleaned)
end

R.eval <<EOF
  if (file.exists("#{$cleaned}")) {
    packages <- c("timelineS","stringr", "ggplot2")
    if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
        install.packages(setdiff(packages, rownames(installed.packages())))
    }
    library(timelineS)
    library(stringr)
    setwd("/Users/xieliang12/ruby/stock_analysis_app")
    clinicals <- read.table("#{$cleaned}",
                            sep=",", header=TRUE, stringsAsFactors = FALSE)

    clinicals[,c("Start.Date", "Completion.Date","Last.Updated", "Primary.Completion.Date")] <- 
        lapply(clinicals[,c("Start.Date", "Completion.Date","Last.Updated", "Primary.Completion.Date")], function(x) as.Date(x, "%Y-%m-%d"))
    clinicals$Phases <- ifelse(clinicals$Phases == "", "preclinical", clinicals$Phases)
    #clinicals[, c("Phases")] <- clinicals[,c("Phases")]
    clinicals$Title <- str_wrap(clinicals$Title, width = 40)
    clinicals$Progress <- ""
    for (i in 1:nrow(clinicals)) {
        if (!is.na(clinicals$Completion.Date[i])) {
            clinicals$Progress[i] <- ifelse(clinicals$Completion.Date[i] > as.Date(Sys.time()), "ongoing", "completed")
        } else
            clinicals$Progress[i] <- ifelse(clinicals$Primary.Completion.Date[i] > as.Date(Sys.time()), "ongoing", "completed")
    }
    png(filename="#{$path}/#{$basename}.png", width=900, height=600)
    timelineG(df=clinicals, start="Start.Date", end="Last.Updated", names="Title",
              group1="Phases", group2="Progress", color="blue", width=5)
    dev.off()
  }
EOF
