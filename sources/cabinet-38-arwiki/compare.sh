#!/bin/bash

LABEL_RAW=$(mktemp)
LABEL_CSV=$(mktemp)
NAMED_CSV=$(mktemp)

cd $(dirname $0)

bundle exec ruby scraper.rb $(jq -r .source meta.json) > scraped-ar.csv

# Get English versions of member names
qsv select wdid scraped-ar.csv | qsv search Q | qsv dedup | qsv behead | xargs wd label > $LABEL_RAW
sed -e 's/  */,/' $LABEL_RAW | qsv rename -n xid,enname > $LABEL_CSV
qsv join --left wdid scraped-ar.csv xid $LABEL_CSV |
  qsv select wdid,enname,name,pid,position |
  qsv rename wdid,name,arname,pid,position > $NAMED_CSV

# Get English versions of positions
qsv select pid scraped-ar.csv | qsv search Q | qsv dedup | qsv behead | xargs wd label > $LABEL_RAW
sed -e 's/  */,/' $LABEL_RAW | qsv rename -n xid,enpos > $LABEL_CSV

qsv join --left pid $NAMED_CSV xid $LABEL_CSV |
  qsv select wdid,name,arname,pid,enpos,position |
  qsv rename wdid,name,arname,pid,position,arposition > scraped.csv

wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid > wikidata.csv
bundle exec ruby diff.rb | qsv sort -s wdid | tee diff.csv

cd ~-
