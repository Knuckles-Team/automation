#!/usr/bin/env python
# coding: utf-8

"""
A command-line tool for fetching EPG data from HDHomeRun and generating XMLTV files for Jellyfin.
"""

import argparse
import logging
import sys
import datetime
import time
import requests
import concurrent.futures
from xml.etree import ElementTree as ET
from typing import List, Dict, Any


def setup_logging(debug: str = "on"):
    logger = logging.getLogger("HDHomeRunEPG")
    logger.setLevel(logging.DEBUG)  # Logger processes all levels

    # Clear any existing handlers to avoid duplicate logs
    logger.handlers.clear()

    handler = logging.StreamHandler(sys.stdout)
    if debug == "full":
        handler.setLevel(logging.DEBUG)
    elif debug == "on":
        handler.setLevel(logging.INFO)
    else:
        handler.setLevel(logging.ERROR)

    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger


class HDHomeRunEPG:
    """A class to handle fetching EPG data from HDHomeRun and generating XMLTV files."""

    def __init__(
            self,
            host: str = "hdhomerun.local",
            filename: str = "epg.xml",
            days: int = 7,
            chunk_hours: int = 3,
            threads: int = 12,
            debug: str = "on",
    ):
        """Initialize the HDHomeRunEPG class with settings."""
        self.logger = setup_logging(debug=debug)
        self.host = host
        self.filename = filename
        self.days = days
        self.chunk_hours = chunk_hours
        self.threads = threads
        self.maximum_threads = 36
        if threads > self.maximum_threads:
            self.logger.warning(f"Threads exceed maximum, setting to {self.maximum_threads}")
            self.threads = self.maximum_threads
        self.debug = debug
        self.device_auth = self.get_device_auth()
        self.channels = self.get_channels()
        self.language = self.determine_language()  # Investigated and set based on device info

    def get_device_auth(self) -> str:
        """Fetch the DeviceAuth from the HDHomeRun device."""
        url = f"http://{self.host}/discover.json"
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()
            if "DeviceAuth" in data:
                self.logger.info("Successfully fetched DeviceAuth.")
                return data["DeviceAuth"]
            else:
                raise ValueError("DeviceAuth not found in discover.json")
        except Exception as e:
            self.logger.error(f"Failed to fetch DeviceAuth: {str(e)}")
            sys.exit(1)

    def get_channels(self) -> List[Dict]:
        """Fetch the channel lineup from the HDHomeRun device."""
        url = f"http://{self.host}/lineup.json"
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            channels = response.json()
            self.logger.info(f"Fetched {len(channels)} channels.")
            return channels
        except Exception as e:
            self.logger.error(f"Failed to fetch channels: {str(e)}")
            sys.exit(1)

    def determine_language(self) -> str:
        """Determine the language based on device information."""
        # Investigation: Checked discover.json and lineup.json for language info.
        # No explicit language field found. ModelNumber might indicate region (e.g., 'US' for English).
        # For simplicity, default to 'en'. If needed, can be extended based on ModelNumber.
        url = f"http://{self.host}/discover.json"
        try:
            response = requests.get(url, timeout=10)
            data = response.json()
            if "ModelNumber" in data and "US" in data["ModelNumber"]:
                self.logger.info("Device model suggests US region, using 'en' language.")
            else:
                self.logger.info("No specific region detected, defaulting to 'en' language.")
        except Exception:
            self.logger.warning("Could not determine language from device, defaulting to 'en'.")
        return "en"

    def get_guide_chunk(self, start_time: float) -> List[Dict]:
        """Fetch a chunk of guide data for a given start time."""
        url = f"https://api.hdhomerun.com/api/guide?DeviceAuth={self.device_auth}&Start={int(start_time)}&Duration={self.chunk_hours}"
        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            data = response.json()
            self.logger.debug(f"Fetched guide chunk starting at {datetime.datetime.fromtimestamp(start_time)}")
            return data
        except Exception as e:
            self.logger.error(f"Failed to fetch guide chunk: {str(e)}")
            return []

    def fetch_guide_in_parallel(self) -> Dict[str, List[Dict]]:
        """Fetch guide data in parallel chunks."""
        programs: Dict[str, List[Dict]] = {ch["GuideNumber"]: [] for ch in self.channels}
        start = time.time()
        end = start + self.days * 86400
        start_times = []
        current = start
        while current < end:
            start_times.append(current)
            current += self.chunk_hours * 3600

        try:
            with concurrent.futures.ThreadPoolExecutor(max_workers=self.threads) as executor:
                chunks = list(executor.map(self.get_guide_chunk, start_times))
            for chunk in chunks:
                for entry in chunk:
                    guide_number = entry.get("GuideNumber")
                    if guide_number in programs:
                        programs[guide_number].extend(entry.get("Airings", []))
            # Sort programs by start time
            for gn in programs:
                programs[gn] = sorted(programs[gn], key=lambda x: x.get("StartTime", 0))
            self.logger.info("Successfully fetched and processed guide data.")
            return programs
        except Exception as e:
            self.logger.error(f"Parallel guide fetching failed: {str(e)}")
            sys.exit(1)

    def build_xml(self, programs: Dict[str, List[Dict]]) -> None:
        """Build the XMLTV file adhering to DTD element ordering."""
        tv = ET.Element(
            "tv",
            attrib={
                "date": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds") + " +0000",
                "source-info-name": "HDHomeRun",
                "generator-info-name": "HDHomeRunEPG Script",
            },
        )

        # Add channels
        for ch in self.channels:
            channel = ET.SubElement(tv, "channel", id=str(ch["GuideNumber"]))
            display_name = ET.SubElement(channel, "display-name", lang=self.language)
            display_name.text = ch.get("GuideName", "Unknown")
            if "URL" in ch:
                url = ET.SubElement(channel, "url")
                url.text = ch["URL"]

        # Add programmes
        for guide_number, airings in programs.items():
            for airing in airings:
                start_dt = datetime.datetime.fromtimestamp(airing.get("StartTime", 0), tz=datetime.timezone.utc)
                end_dt = datetime.datetime.fromtimestamp(airing.get("EndTime", 0), tz=datetime.timezone.utc)
                programme = ET.SubElement(
                    tv,
                    "programme",
                    start=start_dt.isoformat(timespec="seconds") + " +0000",
                    stop=end_dt.isoformat(timespec="seconds") + " +0000",
                    channel=str(guide_number),
                )

                # Add elements in DTD order
                title = ET.SubElement(programme, "title", lang=self.language)
                title.text = airing.get("Title")

                if "EpisodeTitle" in airing:
                    sub_title = ET.SubElement(programme, "sub-title", lang=self.language)
                    sub_title.text = airing["EpisodeTitle"]

                if "Synopsis" in airing:
                    desc = ET.SubElement(programme, "desc", lang=self.language)
                    desc.text = airing["Synopsis"]

                # credits (if available, e.g., from airing data)
                if "Credits" in airing:  # Assuming possible structure
                    credits = ET.SubElement(programme, "credits")
                    for role, name in airing["Credits"].items():
                        sub = ET.SubElement(credits, role)
                        sub.text = name

                if "OriginalAirdate" in airing:
                    date = ET.SubElement(programme, "date")
                    date.text = datetime.datetime.fromtimestamp(airing["OriginalAirdate"]).strftime("%Y%m%d")

                if "Filter" in airing or "Categories" in airing:
                    categories = airing.get("Filter", []) or airing.get("Categories", [])
                    for cat in categories:
                        category = ET.SubElement(programme, "category", lang=self.language)
                        category.text = cat

                if "Keywords" in airing:
                    for kw in airing["Keywords"]:
                        keyword = ET.SubElement(programme, "keyword", lang=self.language)
                        keyword.text = kw

                if "Language" in airing:
                    lang = ET.SubElement(programme, "language")
                    lang.text = airing["Language"]

                if "OrigLanguage" in airing:
                    orig_lang = ET.SubElement(programme, "orig-language")
                    orig_lang.text = airing["OrigLanguage"]

                if "EndTime" in airing and "StartTime" in airing:
                    length = ET.SubElement(programme, "length", units="seconds")
                    length.text = str(airing["EndTime"] - airing["StartTime"])

                if "ImageURL" in airing:
                    icon = ET.SubElement(programme, "icon", src=airing["ImageURL"])

                if "SeriesID" in airing:
                    url = ET.SubElement(programme, "url")
                    url.text = f"https://www.themoviedb.org/tv/{airing['SeriesID']}"  # Example

                if "Country" in airing:
                    country = ET.SubElement(programme, "country")
                    country.text = airing["Country"]

                if "SeasonNumber" in airing and "EpisodeNumber" in airing:
                    episode_num = ET.SubElement(programme, "episode-num", system="xmltv_ns")
                    episode_num.text = f"{int(airing['SeasonNumber']) - 1} . {int(airing['EpisodeNumber']) - 1} ."

                if "Video" in airing:  # Assuming possible
                    video = ET.SubElement(programme, "video")
                    # Add subelements as needed

                if "Audio" in airing:
                    audio = ET.SubElement(programme, "audio")
                    # Add subelements

                if "OriginalAirdate" in airing and airing["OriginalAirdate"] < airing["StartTime"]:
                    previously_shown = ET.SubElement(programme, "previously-shown")

                if "IsPremiere" in airing:
                    premiere = ET.SubElement(programme, "premiere")

                # last-chance not typically available

                if "OriginalAirdate" in airing and airing["OriginalAirdate"] == airing["StartTime"]:
                    new = ET.SubElement(programme, "new")

                if "Subtitles" in airing:
                    subtitles = ET.SubElement(programme, "subtitles")
                    # Add language if available

                if "Ratings" in airing:
                    for r in airing["Ratings"]:
                        rating = ET.SubElement(programme, "rating", system=r.get("body", "Unknown"))
                        value = ET.SubElement(rating, "value")
                        value.text = r.get("code")

                if "StarRating" in airing:
                    star_rating = ET.SubElement(programme, "star-rating")
                    value = ET.SubElement(star_rating, "value")
                    value.text = airing["StarRating"]

                # review not typically available

                if "Images" in airing:
                    for img in airing["Images"]:
                        image = ET.SubElement(programme, "image", type=img.get("type", "poster"))
                        image.text = img["url"]

        # Write to file
        tree = ET.ElementTree(tv)
        ET.indent(tree, space="  ", level=0)
        with open(self.filename, "wb") as f:
            f.write(b'<?xml version="1.0" encoding="UTF-8"?>\n')
            f.write(b'<!DOCTYPE tv SYSTEM "xmltv.dtd">\n')
            tree.write(f, encoding="utf-8", xml_declaration=False)

        self.logger.info(f"XMLTV file generated: {self.filename}")


def main():
    parser = argparse.ArgumentParser(description="HDHomeRun EPG to XMLTV Generator")
    parser.add_argument("--host", type=str, default="hdhomerun.local", help="HDHomeRun host (default: hdhomerun.local)")
    parser.add_argument("--filename", type=str, default="epg.xml", help="Output XMLTV filename (default: epg.xml)")
    parser.add_argument("--days", type=int, default=7, help="Number of days to fetch (default: 7)")
    parser.add_argument("--hours", type=int, default=3, help="Guide chunk hours (default: 3)")
    parser.add_argument("--threads", type=int, default=12, help="Number of threads (default: 12, max: 36)")
    parser.add_argument("--debug", type=str, default="on", choices=["on", "full", "off"], help="Debug level (default: on)")

    args = parser.parse_args()

    epg = HDHomeRunEPG(
        host=args.host,
        filename=args.filename,
        days=args.days,
        chunk_hours=args.hours,
        threads=args.threads,
        debug=args.debug,
    )
    programs = epg.fetch_guide_in_parallel()
    epg.build_xml(programs)


if __name__ == "__main__":
    main()