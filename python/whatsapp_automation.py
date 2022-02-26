#!/usr/bin/python

import pywhatkit
import datetime
import sys
import getopt


def send_message(number, message):
    # Parameters: <Mobile Number with Country Code>, <Message>, <Hour>, <Minutes>
    pywhatkit.sendwhatmsg(number, message, datetime.datetime.now().hour, datetime.datetime.now().minute + 1)


def main(argv):
    number = "+1234567890"
    message = "Test"

    try:
        opts, args = getopt.getopt(argv, "hn:m:", ["help", "number=", "message="])
    except getopt.GetoptError:
        print('Usage:\npython3 whatsapp_automation.py -n "+1234567890" -m "Test message"')
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print('Usage:\npython3 whatsapp_automation.py -n "+1234567890" -m "Test message"')
            sys.exit()
        elif opt in ("-n", "--number"):
            number = arg
        elif opt in ("-m", "--message"):
            message = arg

    send_message(number, message)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Main Usage:\npython3 whatsapp_automation.py -n "+1234567890" -m "Test message"')
        sys.exit(2)
    main(sys.argv[1:])
