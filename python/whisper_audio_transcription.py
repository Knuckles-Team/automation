# https://colab.research.google.com/drive/1vJj6EW0nKi3olLb5nOccA4ypkKx-x4Hr#scrollTo=gmaEWTbLWigj
# https://www.youtube.com/watch?v=Wc4bQxuypo0&list=PL08h2eci_GQsimNShqQ3SOB_sBrkuv69q&index=31&t=102s
# pip install git+https://github.com/openai/whisper.git -q
# pip install pytube -q
import whisper
from pytube import YouTube

model = whisper.load_model('base')

youtube_video_url = "https://www.youtube.com/watch?v=NT2H9iyd-ms"
youtube_video = YouTube(youtube_video_url)

print(youtube_video.title)

print(dir(youtube_video))

for stream in youtube_video.streams:
  print(stream)

streams = youtube_video.streams.filter(only_audio=True)
stream = streams.first()

stream.download(filename='fed_meeting.mp4')

# ffmpeg -ss 378 -i fed_meeting.mp4 -t 2715 fed_meeting_trimmed.mp4

import datetime

# save a timestamp before transcription
t1 = datetime.datetime.now()
print(f"started at {t1}")

# do the transcription
output = model.transcribe("fed_meeting_trimmed.mp4")

# show time elapsed after transcription is complete.
t2 = datetime.datetime.now()
print(f"ended at {t2}")
print(f"time elapsed: {t2 - t1}")

print(f"Output: {output}")

for segment in output['segments']:
  print(segment)
  second = int(segment['start'])
  second = second - (second % 5)
  print(second)

