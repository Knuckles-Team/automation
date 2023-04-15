import os
import shutil
from mutagen.easyid3 import EasyID3

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
    #audio = EasyID3("example.mp3")
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

        #audio.save()

