from mutagen.easyid3 import EasyID3

audio = EasyID3("example.mp3")
audio['title'] = u"Example Title"
audio['artist'] = u"Me"
audio['album'] = u"My album"
audio['composer'] = u"" # clear
audio.save()

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