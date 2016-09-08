-- check if the database stock_analysis exist or not, create it if not exist
CREATE OR REPLACE FUNCTION create_db()
  RETURNS VOID AS
$$
BEGIN

IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'stockfargo_dev') THEN
  RAISE NOTICE 'Database already exists';
ELSE
  PERFORM dblink_exec('dbname' || current_database(),
    'CREATE DATABASE stock_analysis');
END IF;
END
$$ LANGUAGE plpgsql;

SELECT create_db();

\c stockfargo_dev

-- create table temp_price if not exist
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

-- copy daily price data to table temp_price, the daily price file is inputed from command line parameter
COPY temp_price from :v2 delimiter ',' CSV HEADER;

-- a function for creating daily price table, the table name is dynamic and based on sector name
CREATE OR REPLACE FUNCTION create_table_daily(sector text)
  RETURNS VOID as
$$

BEGIN
EXECUTE format('
  CREATE TABLE IF NOT EXISTS %I (like temp_price)',
  'yahoo_' || sector || '_daily');

EXECUTE format('
  CREATE UNIQUE INDEX sector ON %I (symbol, date)', 'yahoo_' || sector || '_daily');

EXECUTE format('
  INSERT INTO %I SELECT * FROM temp_price ON CONFLICT (symbol, date) DO NOTHING', 'yahoo_' || sector || '_daily');

END
$$ LANGUAGE plpgsql;

-- create a table based on sector name inputed from command input
SELECT create_table_daily(:v1);

DROP TABLE temp_price;

CREATE TABLE IF NOT EXISTS temp_stat (
  symbol CHAR(6) PRIMARY key NOT NULL,
  p_e_ratio DECIMAL(18,4),
  peg_ratio  DECIMAL(18,4),
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
  previous_close NUMERIC,
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

COPY temp_stat from :v3 delimiter E'\t' NULL '-999' CSV HEADER;

CREATE OR REPLACE FUNCTION create_stat_table(sector text)
  RETURNS VOID AS
$$
BEGIN
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I (like temp_stat)', 'yahoo_' || sector || '_stat');

  EXECUTE format('
    INSERT INTO %I SELECT * from temp_stat', 'yahoo_' || sector || '_stat');
END
$$ LANGUAGE plpgsql;

SELECT create_stat_table(:v1);

DROP TABLE temp_stat;
