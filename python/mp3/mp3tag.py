import json
import sys
import music_tag
import asyncio
from shazamio import Shazam
from urllib.request import urlopen


async def main():
    song = {}
    shazam = Shazam()
    print("Starting")
    file = 'Snakehips - All My Friends (Official Video) ft. Tinashe, Chance the Rapper [I3mrYxPLSH4].m4a'
    song = await shazam.recognize_song(file)
    with open("shazam.json", "w") as outfile:
        outfile.write(json.dumps(song, indent=4))
    audio = None
    try:
        audio = music_tag.load_file(file)
    except Exception as e:
        print(f"Unable to open file: {e}")
    print("Opened Audio")
    if not audio:
        print("Audio file was not loaded")
        sys.exit(2)
    print("Reading Metadata...")
    audio['tracktitle'] = song['track']['title']
    audio['albumartist'] = song['track']['subtitle']
    audio['artist'] = song['track']['subtitle']
    audio['album'] = song['track']['sections'][0]['metadata'][0]['text']
    audio['year'] = song['track']['sections'][0]['metadata'][2]['text']
    try:
        audio['lyrics'] = song['track']['sections'][1]['text']
        audio['comment'] = song['track']['sections'][1]['text']
    except KeyError:
        print("No Lyrics found")

    try:
        audio['genre'] = song['track']['genres']['primary']
    except KeyError:
        print("No Genre found")

    try:
        audio['composer'] = song['track']['sections'][0]['metadata'][1]['text']
    except KeyError:
        print("No Composer found")

    new_file = f"{song['track']['subtitle']} - {song['track']['title']}"
    print(f"Track: {audio['title']}\n"
          f"Artist:{audio['artist']}\n"
          f"Cover Art URL: {song['track']['images']['coverart']}\n"
          f"Album: {audio['album']}\n"
          f"Year: {audio['year']}\n"
          f"Comments: {audio['comment']}\n"
          f"Genre: {audio['genre']}")
    print("Saved Metadata\nOpening Album Art")

    albumart = urlopen(song['track']['images']['coverart'])

    audio['artwork'] = albumart.read()
    albumart.close()
    audio['artwork'].first.thumbnail([64, 64])
    audio.save()
    print("Set Album Art")


loop = asyncio.get_event_loop()
loop.run_until_complete(main())

print("Done")
