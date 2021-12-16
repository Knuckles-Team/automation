#!/bin/bash

#./shift_subtitle.sh "+3.0 seconds" < bmt.srt
#5
#00:01:05,323 --> 00:01:08,572
#New date
#Hello, my frieds!
#6

set -o errexit -o noclobber -o nounset -o pipefail

date_offset="$1"

shift_date() {
    date --date="$1 $date_offset" +%T,%N | cut -c 1-12
}

while read -r line
do
    if [[ $line =~ ^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]\ --\>\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$ ]]
    then
        read -r start_date separator end_date <<<"$line"
        new_start_date="$(shift_date "$start_date")"
        new_end_date="$(shift_date "$end_date")"
        printf "%s %s %s\n" "$new_start_date" "$separator" "$new_end_date"
        echo "New date"
    else
        printf "%s\n" "$line"
    fi
done