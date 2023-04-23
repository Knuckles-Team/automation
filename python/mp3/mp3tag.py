import os
import shutil
import mutagen
from mutagen.easyid3 import EasyID3
from urllib.request import urlopen
from mutagen.id3 import ID3, APIC, ID3NoHeaderError
import json

# Part 1 Get all metadata from music brains for music in specified directory
# Part 2 Rename File/Folder to Match Artist/Album/Track

"""/ws/2/area
 /ws/2/artist            recordings, releases, release-groups, works
 /ws/2/collection        user-collections (includes private collections, requires authentication)
 /ws/2/event
 /ws/2/genre
 /ws/2/instrument
 /ws/2/label             releases
 /ws/2/place
 /ws/2/recording         artists, releases, isrcs, url-rels
 /ws/2/release           artists, collections, labels, recordings, release-groups
 /ws/2/release-group     artists, releases
 /ws/2/series
 /ws/2/work
 /ws/2/url"""

# Search API https://musicbrainz.org/doc/MusicBrainz_API/Search
"https://musicbrainz.org/doc/MusicBrainz_API/Search"

# Get Artist Info:
"https://musicbrainz.org/ws/2/artist/fe39727a-3d21-4066-9345-3970cbd6cca4?inc=aliases+artist-rels+place-rels"

# Cover Art: https://musicbrainz.org/doc/Cover_Art_Archive/API
"https://musicbrainz.org/ws/2/release/{mbid}/"


def rename_audio_file(directory):
    # audio = EasyID3("example.mp3")
    files = os.listdir(directory)
    for file in files:
        current_parent_directory = os.path.dirname(file)
        current_file_name = os.path.basename(file)

        audio = EasyID3(file)
        # audio['title'] = u"Example Title"
        # audio['artist'] = u"Me"
        # audio['album'] = u"My album"
        # audio['composer'] = u""  # clear

        new_parent_directory = os.path.join(audio['artist'], audio['album'])
        new_file_name = f"{audio['artist']} - {audio['title']}"

        # Create New Parent dir if it does not exist. Move contents of current_parent_directory to new_parent_directory
        if new_parent_directory != current_parent_directory:
            if not os.path.exists(new_parent_directory):
                os.mkdir(new_parent_directory)

            # Move files
            file_names = os.listdir(current_parent_directory)
            for file_name in file_names:
                shutil.move(os.path.join(current_parent_directory, file_name), new_parent_directory)

        # Rename all the files if they do not already match the new naming proposed
        file_names = os.listdir(current_parent_directory)
        for file_name in file_names:
            if new_file_name != current_file_name:
                os.rename(
                    os.path.join(current_parent_directory, current_file_name),
                    os.path.join(current_parent_directory, new_file_name))

            shutil.move(os.path.join(current_parent_directory, file_name), new_parent_directory)

        # audio.save()


# result = musicbrainzngs.search_artists(artist="delegation")
# with open("result.json", "w") as outfile:
#     outfile.write(json.dumps(result, indent=4))
# # for artist in result['artist-list']:
# #     print(u"{id}: {name}".format(id=artist['id'], name=artist["name"]))
#
# test2 = musicbrainzngs.search_release_groups("oh honey - delegation")
# #print("TEST 2: ", test2)
# with open("test2.json", "w") as outfile:
#     outfile.write(json.dumps(test2, indent=4))


import sys
import music_tag
import asyncio
from shazamio import Shazam


song = {}
print("Starting")


async def main():
    shazam = Shazam()
    file = 'Holybrune - JoyRide [HlQCatfWBSk].m4a'
    song = await shazam.recognize_song(file)
    with open("shazam.json", "w") as outfile:
        outfile.write(json.dumps(song, indent=4))
    # print(song)
    audio = None
    try:
        audio = music_tag.load_file(file)
    except Exception as e:
        print(f"Unable to open file: {e}")

    if not audio:
        print("Audio file was not loaded")
        sys.exit(2)
    audio['title'] = song['track']['title']
    audio['subtitle'] = song['track']['subtitle']
    audio['artist'] = song['track']['subtitle']
    audio['album'] = song['track']['sections'][0]['metadata'][0]['text']
    audio['label'] = song['track']['sections'][0]['metadata'][1]['text']
    audio['year'] = song['track']['sections'][0]['metadata'][2]['text']
    audio['comments'] = song['track']['sections'][1]['text']
    audio['genre'] = song['track']['genres']['primary']
    audio['composer'] = song['track']['subtitle']
    audio['tag'] = song['track']['tagid']
    new_file = f"{song['track']['subtitle']} - {song['track']['title']}"
    print(f"Track: {audio['title']}\n"
          f"Artist:{audio['artist']}\n"
          f"Cover Art URL: {song['track']['images']['coverart']}\n"
          f"Album: {audio['album']}\n"
          f"Year: {audio['year']}\n"
          f"Comments: {audio['comments']}\n"
          f"Genre: {audio['genre']}")
    #audio.save(new_file)
    print("Saved Metadata\nOpening Album Art")
    #audio = ID3(new_file)

    albumart = urlopen(song['track']['images']['coverart'])

    audio['artwork'] = albumart.read()

    albumart.close()

    audio.first.thumbnail([64, 64])

    audio.save()

    # audio['APIC'] = APIC(
    #     encoding=3,
    #     mime='image/jpeg',
    #     type=3,
    #     desc=u'Cover',
    #     data=albumart.read()
    # )
    #
    # albumart.close()
    # audio.save()
    print("Set Album Art")

    # try:
    #     audio = EasyID3(file)
    # except ID3NoHeaderError:
    #     audio = mutagen.File(file, easy=True)
    #     audio.add_tags()
    # audio['title'] = song['track']['title']
    # audio['subtitle'] = song['track']['subtitle']
    # audio['artist'] = song['track']['subtitle']
    # audio['album'] = song['track']['sections'][0]['metadata'][0]['text']
    # audio['label'] = song['track']['sections'][0]['metadata'][1]['text']
    # audio['year'] = song['track']['sections'][0]['metadata'][2]['text']
    # audio['comments'] = song['track']['sections'][1]['text']
    # audio['genre'] = song['track']['genres']['primary']
    # audio['composer'] = song['track']['subtitle']
    # audio['tag'] = song['track']['tagid']
    # new_file = f"{song['track']['subtitle']} - {song['track']['title']}"
    # print(f"Track: {audio['title']}\n"
    #       f"Artist:{audio['artist']}\n"
    #       f"Cover Art URL: {song['track']['images']['coverart']}\n"
    #       f"Album: {audio['album']}\n"
    #       f"Year: {audio['year']}\n"
    #       f"Comments: {audio['comments']}\n"
    #       f"Genre: {audio['genre']}")
    # audio.save(new_file)
    # print("Saved Metadata\nOpening Album Art")
    # audio = ID3(new_file)
    # albumart = urlopen(song['track']['images']['coverart'])
    #
    # audio['APIC'] = APIC(
    #     encoding=3,
    #     mime='image/jpeg',
    #     type=3,
    #     desc=u'Cover',
    #     data=albumart.read()
    # )
    #
    # albumart.close()
    # audio.save()
    # print("Set Album Art")


loop = asyncio.get_event_loop()
loop.run_until_complete(main())

print("Done")
