#!/bin/bash

matched_file=`find data/yahoo -type f -iname "*_health_*\.csv"`
# matched_price=`find data/yahoo -type f -iname "*healhcare_daily_*\.csv"`

temp_file="data/yahoo/temp.csv"

awk -F'\t' -v OFS='\t' '{for(i=NF+1;i<=32;i++)$i="Not Available"}1' $matched_file > $temp_file

mv $temp_file $matched_file

psql -d stock_analysis -f create_stock_analysis.sql 
