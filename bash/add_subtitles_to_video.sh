#!/bin/bash
# For language codes, use ISO 639-2
ffmpeg -i infile.mp4 -f srt -i infile.srt -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language=eng outfile.mp4
