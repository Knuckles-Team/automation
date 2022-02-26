#!/bin/bash

for i in *.flv; do ffmpeg -i "${i}" "${i}".mp4; done