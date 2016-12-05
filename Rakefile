require './finviz.rb'
require './get_yahoo_finance.rb'
directory "data/finviz"
file_path = Rake.application.original_dir

$sector = ""
$stat_file = ""
$price_file = ""

namespace :screen do
  task :finviz_screen => "data/finviz" do
    $sector = ARGV.last
    sh "ruby finviz.rb #{$sector}"
  end

  task :scraping => [:finviz_screen, "data/yahoo"] do
    sh "ruby get_yahoo_finance.rb #{$sector}"
  end

  task :all => [:finviz_screen, :scraping]
end

namespace :pop_data do
  task :daily_stat_file => ["screen:all"] do
    $sector = ARGV.last
    $stat_file = file_path+"/"+Dir["data/yahoo/*.csv"].grep(/#{$sector}_statistics/).join("")
    $price_file = file_path+"/"+Dir["data/yahoo/*.csv"].grep(/#{$sector}_daily/).join("")
  end

  task :create_insert => :daily_stat_file do
    sh "./psql_run.sh #{$sector} #{$price_file} #{$stat_file}"
  end

  task :all => [:daily_stat_file, :create_insert]
end

desc "all my job"
task :populate => ["screen:all", "pop_data:all"]
Rake::Task["populate"].invoke
