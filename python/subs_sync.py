import re
import codecs
import chardet
import math

subtitles = []
shift_time = 5
shift_operator = "+"

def pad_time(time):
    if float(time) >= 10:
        return str(time)
    else:
        return '0'+str(time)

def shift_sub_time(time, shift, shift_time):
    start_time, end_time = time.split(" --> ")
    start_hours, start_minutes, start_seconds = start_time.split(":")
    end_hours, end_minutes, end_seconds = end_time.split(":")
    start_seconds = re.sub(",", ".", start_seconds)
    end_seconds = re.sub(",", ".", end_seconds)
    #print(f"Old Start Hours: {start_hours} Start Minutes: {start_minutes} Start Seconds: {start_seconds}")
    #print(f"Old End Hours: {end_hours} End Minutes: {end_minutes} End Seconds: {end_seconds}")
    start_time_seconds = round(((int(start_hours) * 3600) + (int(start_minutes) * 60) + float(start_seconds)),3)
    end_time_seconds = round(((int(end_hours) * 3600) + (int(end_minutes) * 60) + float(end_seconds)),3)
    #print(f"Start Seconds: {start_time_seconds} End Seconds: {end_time_seconds}")
    if shift == "+":
        start_time_seconds = round(start_time_seconds + shift_time, 3)
        end_time_seconds = round(end_time_seconds + shift_time, 3)
    elif shift == "-":
        if start_time_seconds - shift_time < 0:
            shift_time = start_time_seconds
        start_time_seconds = round(start_time_seconds - shift_time, 3)
        end_time_seconds = round(end_time_seconds - shift_time, 3)
    #print(f"New Start Seconds: {start_time_seconds} New End Seconds: {end_time_seconds}")

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
    start_seconds = pad_time(start_seconds)
    end_hours = pad_time(end_hours)
    end_minutes = pad_time(end_minutes)
    end_seconds = pad_time(end_seconds)

    # Return the comma on seconds
    start_seconds = re.sub("\.", ",", start_seconds)
    end_seconds = re.sub("\.", ",", end_seconds)

    #print(f"New Start Hours: {start_hours} Start Minutes: {start_minutes} Start Seconds: {start_seconds}")
    #print(f"New End Hours: {end_hours} End Minutes: {end_minutes} End Seconds: {end_seconds}")
    time = f"{start_hours}:{start_minutes}:{start_seconds} --> {end_hours}:{end_minutes}:{end_seconds}"
    return time

def sync_time(filename):
    index = 0

    # Detect encoding of file
    with open(filename, 'rb') as f:
        rawdata = b''.join([f.readline() for _ in range(20)])
    encoding = chardet.detect(rawdata)['encoding']

    # Read full file with correct encoding
    with codecs.open(filename, encoding=encoding) as file:
        lines = [line.rstrip() for line in file.readlines() if line.strip()]
        f.truncate(0)

    # Iterate through all subtitle lines
    while index < 20:
    #while index < len(lines):
        #print(f"Checking line: {index}")
        if re.match(r"[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines[index]):
            sub_index = lines[index-1]
            #print(f"Sub Index: {lines[index-1]}")
            time = lines[index]
            #print(f"Time: {lines[index]}")
            if re.match(r"[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines[index+5]):
                text = f"{lines[index + 1]}\n{lines[index + 2]}\n{lines[index + 3]}"
                #print(f"Text: {lines[index + 1]}\n{lines[index + 2]}\n{lines[index + 3]}")
            elif re.match(r"[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]", lines[index+4]):
                text = f"{lines[index + 1]}\n{lines[index + 2]}"
                #print(f"Text: {lines[index + 1]}\n{lines[index + 2]}")
            else:
                text = f"{lines[index + 1]}"
                #print(f"Text: {lines[index + 1]}")

            time = shift_sub_time(time, shift_operator, shift_time)
            subtitles.append({"index": sub_index, "time": time, "text": text})

        index+=1

    for subtitle in subtitles:
        print(f"{subtitle['index']}\n{subtitle['time']}\n{subtitle['text']}\n")

    with codecs.open(filename, encoding=encoding) as file:
        for subtitle in subtitles:
            file_entry = f"{subtitle['index']}\n{subtitle['time']}\n{subtitle['text']}\n"
            print(f"{subtitle['index']}\n{subtitle['time']}\n{subtitle['text']}\n")
            file.writelines(file_entry)

sync_time("./manosteel.srt")
