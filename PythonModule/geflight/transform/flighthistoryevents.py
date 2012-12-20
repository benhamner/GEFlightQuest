"""
This file contains code to handle flighthistoryevents
"""

import re

def get_estimated_runway_arrival_string(data_str):
    if "ERA" not in data_str:
        return None
    matches = re.findall(r"ERA- New=(\d\d/\d\d/\d\d \d\d:\d\d)", data_str)
    if matches:
        return matches[0]

    matches = re.findall(r"ERA- Old=\d\d/\d\d/\d\d \d\d:\d\d New=(\d\d/\d\d/\d\d \d\d:\d\d)", data_str)
    if not matches:
        print data_str
        return None
    else:
        return matches[0]


def get_estimated_gate_arrival_string(data_str):
    if "EGA" not in data_str:
        return None
    matches = re.findall(r"EGA- New=(\d\d/\d\d/\d\d \d\d:\d\d)", data_str)
    if matches:
        return matches[0]

    matches = re.findall(r"EGA- Old=\d\d/\d\d/\d\d \d\d:\d\d New=(\d\d/\d\d/\d\d \d\d:\d\d)", data_str)
    if not matches:
        print data_str
        return None
    else:
        return matches[0]