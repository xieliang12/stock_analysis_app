require 'pg'

con = PG.connect(host: 'localhost', :dbname => 'stock_analysis', :user => 'xieliang12' )

begin
  con.exec "CREATE TABLE IF NOT EXISTS yahoo_healthcare_daily (
    symbol CHAR(6) NOT NULL,
    date  DATE,
    open  DECIMAL(18,4),
    high  DECIMAL(18,4),
    low   DECIMAL(18,4),
    close DECIMAL(18,4),
    volume bigint,
    adj_close DECIMAL(18,4))"

  con.exec "CREATE UNIQUE INDEX symbol_date ON yahoo_healthcare_daily (
    symbol, date)"
rescue PG::Error => e
  puts e.message
end

begin
  con.exec "CREATE TABLE IF NOT EXISTS yahoo_healthcare_statistics (
  symbol CHAR(6) NOT NULL,
  p_e_ratio DECIMAL(18,4),
  peg_raio  DECIMAL(18,4),
  earnings_per_share DECIMAL(18,4),
  ebitda    DECIMAL(18,4),
  eps_estimate_current_year DECIMAL(18,4),
  eps_estimate_next_quarter DECIMAL(18,4),
  fifty_day_moving_average  DECIMAL(18,4),
  fifty_two_week_high       DECIMAL(18,4),
  fifty_two_week_low        DECIMAL(18,4),
  percent_change_from_200_day_moving_average DECIMAL(6,4),
  percent_change_from_50_day_moving_average DECIMAL(6,4),
  shares_owned  NUMERIC,
  short_ratio   DECIMAL(18,4),
  two_hundred_day_moving_average DECIMAL(18,4),
  volume        NUMERIC,
  market_cap    NUMERIC,
  price_to_sales_ttm  DECIMAL(18,4),
  price_to_book_mrq   DECIMAL(18,4),
  roa_ttm             DECIMAL(18,4),
  roe_ttm             DECIMAL(18,4),
  shares_outstanding  NUMERIC,
  pcnt_held_by_insiders DECIMAL(6,4),
  pcnt_held_by_institutions DECIMAL(6,4),
  pcnt_short_of_float DECIMAL(6,4),
  operating_cash_flow_ttm NUMERIC,
  levered_cash_flow_ttm NUMERIC,
  book_value_per_share_mrq DECIMAL(18,4),
  next_earnings_announcement_date text,
  sector CHAR(18),
  industry text,
  company_name text
  )"

rescue PG::Error => e
  puts e.message
end
con.close

cmd_copy_stat = "psql stock_analysis -c \"COPY yahoo_healthcare_statistics from '/Users/xieliang12/ruby/stock_analysis_app/data/yahoo/yahoo_healthcare_statistics_201605042250.csv' delimiter E'\t' NULL '-999' CSV HEADER;\""
system(cmd_copy_stat)
#cmd_copy_price = "psql stock_analysis -c \"COPY yahoo_healthcare_daily from '/Users/xieliang12/ruby/stock_analysis_app/data/yahoo/yahoo_healthcare_daily_201605040307.csv' delimiter ',' CSV HEADER;\""
#system(cmd_copy_price)
