#!/usr/bin/python
import pathlib
import pyanime4k
import sys
import getopt
import glob
from contextlib import contextmanager,redirect_stderr,redirect_stdout
from os import devnull


@contextmanager
def suppress_stdout_stderr():
    """A context manager that redirects stdout and stderr to devnull"""
    with open(devnull, 'w') as fnull:
        with redirect_stderr(fnull) as err, redirect_stdout(fnull) as out:
            yield err, out


def upscale_videos(videos, output_directory):
    video_count = 0
    for video in videos:
        video_count = video_count + 1
        percentage = '%.3f' % ((video_count/len(videos))*100)
        print(f"Videos Processed: {video_count} | Percentage: {percentage}% | Total: {video_count}/{len(videos)}\n")
        with suppress_stdout_stderr():
            pyanime4k.upscale_videos(video, output_directory)


def main(argv):
    video_directory = "./"
    output_directory = "./output"
    videos = []

    try:
        opts, args = getopt.getopt(argv, "hv:o:", ["help", "video-directory=", "output-directory="])
    except getopt.GetoptError:
        print('Usage:\npython3 video_upscaler.py -v ./videos -o ./output')
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print('Usage:\npython3 video_upscaler.py -v ./videos -o ./output')
            sys.exit()
        elif opt in ("-v", "--video-directory"):
            video_directory = arg
        elif opt in ("-o", "--output-directory"):
            output_directory = arg

    videos_for_processing = glob.glob(f'{video_directory}/*.mp4')
    for video in videos_for_processing:
        videos.append(pathlib.Path(video))

    upscale_videos(videos, output_directory)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Main Usage:\npython3 video_upscaler.py -v ./videos -o ./output')
        sys.exit(2)
    main(sys.argv[1:])
