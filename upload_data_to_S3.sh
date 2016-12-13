#/bin/sh

FILES="/Users/xieliang12/ruby/stock_analysis_app/data/$1"
for f in $FILES; do
 aws s3 sync $f s3://mystocks/reports/$1/ --region us-west-2
done
