require './finviz.rb'
require './get_yahoo_finance.rb'
directory "data/finviz"
file_path = Rake.application.original_dir

namespace :screen do
  task :finviz_screen, [:sec] => "data/finviz" do |t, args|
    $sector = args.sec
    sh "ruby finviz.rb #{$sector}"
  end

  task :scraping => [:finviz_screen, "data/yahoo"] do
    sh "ruby get_yahoo_finance.rb #{$sector}"
  end

  task :all => ["screen:finviz_screen", "screen:scraping"]
end

desc "screen and scaping data from yahoo finance"
task :finviz_yahoo => ["screen:all"]
 
namespace :pop_data do
  task :daily_stat_file => :finviz_yahoo do
    $stat_file = Dir["data/yahoo/*.csv"].grep(/#{sector}_statistics/).join("")
    $price_file = Dir["data/yahoo/*.csv"].grep(/#{sector}_daily/).join("")
  end

  $stat_file = file_path+"/"+$stat_file
  $price_file = file_path+"/"+$price_file

  task :create_insert => :stat_daily_file do
    sh 'psql -X -q -a -1 -v v1="#{$sector}" -v v2="#{$price_file}" -v v3="#{$stat_file}" --pset pager=off -d mydb -f create_stock_analysis.sql'
  end

  task :all => ["create_insert:stat_daily_file", "create_insert:db_pop"]
end

desc "create table and insert data into postgresql"
task :insert => ["create_insert:all"]

desc "all my job"
task :default => [:finviz_yahoo, :insert]
