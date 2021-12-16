#!/bin/bash

#./shifter.sh "+3.0 seconds" < bmt.srt
sub_title_file="subtitle.srt"
video_file="movie.mp4"

sed -i 's/ [0-9][0-9]* /\n\n&\n/g' "${sub_title_file}"
sed -i 's/^ //g' "${sub_title_file}"
sed -i 's/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9] /&\n/g' "${sub_title_file}"
sed -i 's/^.*FILIMO.*$/./g' "${sub_title_file}"
sed -i 's/^.*Supervisor of Translators:.*$/./g' "${sub_title_file}"
ffmpeg -i "${video_file}" -ss 9 -vcodec copy -acodec copy "output.mp4"
ffmpeg -i "output.mp4" -f srt -i "${sub_title_file}" -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language=eng "output-tr.mp4"
cp "${video_file}" "backup-${video_file}"
mv "output-tr.mp4" "${video_file}"


