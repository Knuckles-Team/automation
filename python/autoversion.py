import semantic_version
import datetime
import re
import sys
import getopt


def usage():
    print('Usage:\npython autoversion.py -v "v2024.1.4"')


def main(argv):
    current_version = '0.0.0'
    new_version = '0.0.0'
    try:
        opts, args = getopt.getopt(argv, "hv:", ["help", "version="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-v", "--version"):
            current_version = arg

    current_version = re.sub("v", "", current_version)

    today = datetime.date.today()
    date = today.strftime("%Y.%m")
    if current_version == "":
        new_version = f'{date}.0'
    else:
        current_version = semantic_version.Version(current_version)
        s = semantic_version.SimpleSpec(f'<={date}.0')
        if s.match(current_version):
            new_version = f'{date}.0'

        s = semantic_version.SimpleSpec(f'<={date}.{current_version.patch}')
        if s.match(current_version):
            current_version.next_patch()
            new_version = f'{date}.{current_version.patch}'
    print(f"{new_version}")
    return new_version


if __name__ == "__main__":
    if len(sys.argv) < 2:
        usage()
        sys.exit(2)
    main(sys.argv[1:])
