"""
This file contains I/O and other utilities for the GE Flight Quest benchmarks.
"""

def get_other_arrival_type(arrival_type):
    if arrival_type == "runway":
        return "gate"
    return "runway"

def get_scheduled_arrival(row, arrival_type, cutoff_time):
    if row["scheduled_%s_arrival" % arrival_type] != "MISSING":
        return row["scheduled_%s_arrival" % arrival_type]
    if row["scheduled_%s_arrival" % get_other_arrival_type(arrival_type)] != "MISSING":
        return row["scheduled_%s_arrival" % get_other_arrival_type(arrival_type)]
    if row["published_arrival"] != "MISSING":
        return row["published_arrival"]
    return cutoff_time 

def get_estimated_arrival_time(row, arrival_type, cutoff_time):
    if row["estimated_%s_arrival" % arrival_type] != "MISSING":
        return row["estimated_%s_arrival" % arrival_type]
    if row["estimated_%s_arrival" % get_other_arrival_type(arrival_type)] != "MISSING":
        return row["estimated_%s_arrival" % get_other_arrival_type(arrival_type)]
    return get_scheduled_arrival(row, arrival_type, cutoff_time)