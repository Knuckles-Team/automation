import re
import codecs
import chardet
import math
import sys
import getopt


def usage():
    print(f"Usage: "
          f"-f | --file [Subtitle File]"
          f"-m | --mode [\"+\"/\"-\"]"
          f"-t | --time [Time in seconds to shift]"
          f"\n"
          f"python3 subsync.py --file Engrish.srt --mode + --time 5")


def pad_time(time, seconds=False):
    padded_time = time
    if seconds:
        padded_time = '{0:.3f}'.format(float(padded_time))
    if float(padded_time) >= 10:
        padded_time = str(padded_time)
    else:
        padded_time = '0' + str(padded_time)
    return padded_time


def shift_sub_time(time, shift_time=5, shift_operator="+"):
    # Parse time fields
    start_time, end_time = time.split(" --> ")
    start_hours, start_minutes, start_seconds = start_time.split(":")
    end_hours, end_minutes, end_seconds = end_time.split(":")
    start_seconds = re.sub(",", ".", start_seconds)
    end_seconds = re.sub(",", ".", end_seconds)

    # Calculate total time in seconds
    start_time_seconds = round(((int(start_hours) * 3600) + (int(start_minutes) * 60) + float(start_seconds)), 3)
    end_time_seconds = round(((int(end_hours) * 3600) + (int(end_minutes) * 60) + float(end_seconds)), 3)

    # Either add or subtract based off of operator
    if shift_operator == "+":
        start_time_seconds = round(start_time_seconds + int(shift_time), 3)
        end_time_seconds = round(end_time_seconds + int(shift_time), 3)
    elif shift_operator == "-":
        if start_time_seconds - int(shift_time) < 0:
            shift_time = start_time_seconds
        start_time_seconds = round(start_time_seconds - int(shift_time), 3)
        end_time_seconds = round(end_time_seconds - int(shift_time), 3)

    # Convert back to hours, minutes, seconds
    start_hours = math.floor(start_time_seconds / 3600)
    start_minutes = math.floor((start_time_seconds - start_hours * 3600) / 60)
    start_seconds = round(start_time_seconds - start_hours * 3600 - start_minutes * 60, 3)
    end_hours = math.floor(end_time_seconds / 3600)
    end_minutes = math.floor((end_time_seconds - end_hours * 3600) / 60)
    end_seconds = round(end_time_seconds - end_hours * 3600 - end_minutes * 60, 3)

    # Padded time
    start_hours = pad_time(start_hours)
    start_minutes = pad_time(start_minutes)
    start_seconds = pad_time(start_seconds, seconds=True)
    end_hours = pad_time(end_hours)
    end_minutes = pad_time(end_minutes)
    end_seconds = pad_time(end_seconds, seconds=True)

    # Return the comma on seconds
    start_seconds = re.sub("\.", ",", start_seconds)
    end_seconds = re.sub("\.", ",", end_seconds)

    # Reconstruct time fileline
    time = f"{start_hours}:{start_minutes}:{start_seconds} --> {end_hours}:{end_minutes}:{end_seconds}"
    return time


def sync_time(subtitle_file, shift_time, shift_operator):
    subtitles = []
    index = 0

    # Detect encoding of file
    with open(subtitle_file, 'rb') as f:
        rawdata = b''.join([f.readline() for _ in range(0, len(f.readlines()))])
    encoding = chardet.detect(rawdata)['encoding']

    # Read full file with correct encoding
    with codecs.open(subtitle_file, encoding=encoding) as file:
        lines = [line.rstrip() for line in file.readlines() if line.strip()]

    # Iterate through all subtitle lines
    while index < len(lines):
        if re.match(r"[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines[index]):
            sub_index = lines[index - 1]
            time = lines[index]
            try:
                if re.match(r"[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines[index + 5]):
                    text = f"{lines[index + 1]}\n{lines[index + 2]}\n{lines[index + 3]}"
                elif re.match(r"[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines[index + 4]):
                    text = f"{lines[index + 1]}\n{lines[index + 2]}"
                else:
                    text = f"{lines[index + 1]}"
            except IndexError:
                try:
                    if re.match(r"[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines[index + 4]):
                        text = f"{lines[index + 1]}\n{lines[index + 2]}"
                    else:
                        text = f"{lines[index + 1]}"
                except IndexError:
                    try:
                        text = f"{lines[index + 1]}\n{lines[index + 2]}\n{lines[index + 3]}"
                    except IndexError:
                        try:
                            text = f"{lines[index + 1]}\n{lines[index + 2]}"
                        except IndexError:
                            text = f"{lines[index + 1]}"

            # Acquire new time fileline
            time = shift_sub_time(time, shift_time, shift_operator)
            # Append to list of subtitle dictionaries
            subtitles.append({"index": sub_index, "time": time, "text": text})
        index += 1

    # Rewrite back to the same subtitle file and same encoding
    with codecs.open(subtitle_file, "w", encoding=encoding) as file:
        for subtitle in subtitles:
            file_entry = f"{subtitle['index']}\n{subtitle['time']}\n{subtitle['text']}\n\n"
            file.writelines(file_entry)


def main(argv):
    file = ""
    mode = "+"
    time = 5

    # Parse args
    try:
        opts, args = getopt.getopt(argv, "hf:m:t:", ["help", "file=", "mode=", "time="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-f", "--file"):
            file = arg
        elif opt in ("-m", "--mode"):
            mode = arg
            if str(mode) != "+" and str(mode) != "-":
                usage()
                sys.exit(2)
        elif opt in ("-t", "--time"):
            time = arg
    sync_time(subtitle_file=file, shift_time=time, shift_operator=mode)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        usage()
        sys.exit(2)
    main(sys.argv[1:])
