#!/bin/bash

if [ $# -lt 1 ]
then
    echo "usage: $(basename $0) urlfile" >&2
    exit 1
fi

file_list=$1
while read url
do
    curl -d"{\"url\":\"$url\"}" -H'content-type: application/json' http://findcareers.herokuapp.com/companies/scrape_website
done < "$file_list"
