#!/bin/bash
sed -i 's/ [0-9][0-9]* /\n\n&\n/g' sub.srt
sed -i 's/^ //g' sub.srt
sed -i 's/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9] /&\n/g' sub.srt
sed -i 's/^.*FILIMO.*$/./g' sub.srt
sed -i 's/^.*Supervisor of Translators:.*$/./g' sub.srt
ffmpeg -i movie.mp4 -ss 9 -vcodec copy -acodec copy output.mp4
ffmpeg -i "output.mp4" -f srt -i "sub.srt" -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language=eng "output-tr.mp4"
