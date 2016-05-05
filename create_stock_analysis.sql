-- Database "stock_analysis"
-- DROP DATABASE "Stock_analysis"

CREATE DATABASE stock_analysis
  with OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;

-- SHOW DATESTYLE;
-- SET DATESTYLE TO POSTGRES, MDY;
-- now datestyle=Postgres, MDY;

-- create a temp table for daily price
CREATE TABLE IF NOT EXISTS temp_price (
  symbol CHAR(6) NOT NULL,
  date  DATE,
  open  DECIMAL(18,4),
  high  DECIMAL(18,4),
  low   DECIMAL(18,4),
  close DECIMAL(18,4),
  volume bigint,
  adj_close DECIMAL(18,4)
);

COPY temp_price from '/Users/xieliang12/ruby/stock_analysis_app/data/yahoo/yahoo_healthcare_daily_201605040307.csv' delimiter ',' CSV HEADER;

CREATE TABLE yahoo_healthcare_price as SELECT * FROM temp_price where 1=2;

CREATE UNIQUE INDEX symbol_date_uq ON
  TABLE yahoo_healthcare_price (symbol, date);

INSERT INTO yahoo_healthcare_price as SELECT * FROM temp_price
  ON CONFLICT (symbol, date) DO NOTHING;

DROP TABLE temp_price;

CREATE TABLE IF NOT EXISTS temp_stat (
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
);

COPY temp_stat from '/Users/xieliang12/ruby/stock_analysis_app/data/yahoo/yahoo_healthcare_statistics_201605042250.csv' delimiter E'\t' NULL '-999' CSV HEADER;

CREATE TABLE yahoo_healthcare_statistics as SELECT * FROM temp_stat where 1=2; 

CREATE UNIQUE INDEX symbol_uq ON
  TABLE yahoo_healthcare_statistics (symbol);

INSERT INTO yahoo_healthcare_statistics as SELECT * from temp_stat
  ON CONFLICT (symbol) DO NOTHING;

DROP TABLE temp_price;
