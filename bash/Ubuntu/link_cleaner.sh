#!/bin/bash

# Cat the file
cat links.txt

# Copy the original file
cp links.txt sorted_links.txt

# Remove Chrome Tabs
sed -i 's/^chrome:.*$//g' sorted_links.txt
sed -i 's/^chrome-native:.*$//g' sorted_links.txt

# Remove Facebook Sites
sed -i 's/^.*facebook.*$//g' sorted_links.txt
# Remove Generic voat tabs
sed -i 's/^.*voat.co.$//g' sorted_links.txt
sed -i 's/^.*voat.co..page=.*$//g' sorted_links.txt
# Convert Mobile Youtube to Regular
sed -i 's/m\.youtube/www\.youtube/g' sorted_links.txt
# Convert Mobile Twitter to Regular
sed -i 's/mobile\.twitter/twitter/g' sorted_links.txt

# Convert most mobile to regular links
sed -i 's/\/\/m\./www\./g' sorted_links.txt
sed -i 's/\/\/mobile\./www\./g' sorted_links.txt

# Remove Empty Newlines
sed -i '/^ *$/d' sorted_links.txt

# Alphabetically sort and remove duplicates in sorted_links file.
sort -u -o sorted_links.txt sorted_links.txt

# Cat finished file
cat sorted_links.txt
