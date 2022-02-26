#!/bin/bash

# This will store the old filetype, needs to be updated to remove the filetype.
for i in *.flv; do ffmpeg -i "${i}" "${i}".mp4; done