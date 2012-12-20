import copy
import csv
import datetime
import dateutil
from dateutil.tz import tzoffset, tzutc
import os
import pandas as pd
from pdb import set_trace

class HeaderCsvReader():
    
    def __init__(self, file_handle):
        self.reader = csv.reader(file_handle)
        self.header = self.reader.next()

    def __iter__(self):
        return self

    def next(self):
        return {col: val for col, val in zip(self.header, self.reader.next())}

    def get_header(self):
        return copy.deepcopy(self.header)

def parse_row(converters, row):
    """
    WARNING: this function mutates row
    """

    for col_name in converters:
        row[col_name] = converters[col_name](row[col_name])

def get_day_boundaries(cutoff_time, start_hours_offset=-9):
    """
    Returns datetimes representing the start and end of a given day in UTC
    """
    assert(cutoff_time.tzinfo.utcoffset(None)==dateutil.tz.tzutc().utcoffset(None))
    
    updated_time = cutoff_time + datetime.timedelta(0, start_hours_offset*3600)
    start_of_day_utc = datetime.datetime(updated_time.year, updated_time.month,
        updated_time.day, tzinfo=dateutil.tz.tzutc())
    start_time = start_of_day_utc + datetime.timedelta(0, -start_hours_offset * 3600)
    end_time = start_of_day_utc + datetime.timedelta(1, -start_hours_offset * 3600)
    return start_time, end_time

def get_day_str(cutoff_time, start_hours_offset=-9):
    return cutoff_time.astimezone(tzoffset(None, start_hours_offset*3600)).strftime("%Y_%m_%d")

def get_day_path(path, cutoff_time, start_hours_offset=-9):
    day_str = get_day_str(cutoff_time, start_hours_offset)
    day_path = os.path.join(path, day_str)
    if not os.path.exists(day_path):
        os.mkdir(day_path)
    return day_path

def get_full_output_path(output_path, output_folder_name, cutoff_time, start_hours_offset=-9):
    day_output_path = get_day_path(output_path, cutoff_time, start_hours_offset)
    full_output_path = os.path.join(day_output_path, output_folder_name)
    if not os.path.exists(full_output_path):
        os.mkdir(full_output_path)
    return full_output_path

def get_output_subdirectory(day_output_path, output_folder_name):
    output_subdirectory = os.path.join(day_output_path, output_folder_name)
    if not os.path.exists(output_subdirectory):
        os.mkdir(output_subdirectory)
    return output_subdirectory

class CsvDialect(csv.Dialect):
    def __init__(self):
        self.delimiter = ','
        self.doublequote = True
        self.escapechar = None
        self.lineterminator = "\n"
        self.quotechar = '"'
        self.quoting = csv.QUOTE_MINIMAL
        self.skipinitialspace = False
        self.strict = False

def split_file_based_on_times_filter_on_ids_streaming(
    input_path,
    output_path,
    output_folder_name,
    output_file_name,
    ids_column_name,
    ids_dict,
    ids_to_track_column_name = None,
    start_hours_offset = -9):
    """
    ids_dict has cutoff_times for its keys
    """

    file_started_for_day = {key: False for key in ids_dict}

    i=0
    cnt=0

    ids_to_cutoff_date = {}
    for cutoff_date in ids_dict:
        for my_id in ids_dict[cutoff_date]:
            ids_to_cutoff_date[my_id] = cutoff_date

    reader = csv.reader(open(input_path))
    header = reader.next()

    ids_column_loc = header.index(ids_column_name)

    if ids_to_track_column_name is not None:
        ids_tracked_dict = {key: set() for key in ids_dict}
        ids_to_track_column_loc = header.index(ids_to_track_column_name)
    else:
        ids_tracked_dict = None

    file_handles = {}
    writers = {}
    for cutoff_time in ids_dict:
        day_output_path = get_full_output_path(output_path, output_folder_name, cutoff_time, start_hours_offset)
        file_output_path = os.path.join(day_output_path, output_file_name)
        file_handles[cutoff_time] = open(file_output_path, "w")
        writers[cutoff_time] = csv.writer(file_handles[cutoff_time], dialect=CsvDialect())
        writers[cutoff_time].writerow(header)

    i_row_mod = 0
    buffer_dict = {cutoff_time: [] for cutoff_time in ids_dict}

    for row in reader:
        i_row_mod += 1
        if row[ids_column_loc] in ids_to_cutoff_date:
            cnt += 1
            buffer_dict[ids_to_cutoff_date[row[ids_column_loc]]].append(row)
            if ids_to_track_column_name is not None:
                ids_tracked_dict[ids_to_cutoff_date[row[ids_column_loc]]].add(row[ids_to_track_column_loc])
        if i_row_mod < 100000:
            continue
        i+=1
        print("%s: %d00k records processed, %d with relevant flight ids in this chunk" % (output_file_name, i, cnt))
        cnt=0
        for cutoff_time in ids_dict:
            writers[cutoff_time].writerows(buffer_dict[cutoff_time])
            file_handles[cutoff_time].flush()

        i_row_mod = 0
        buffer_dict = {cutoff_date: [] for cutoff_date in ids_dict}

    for cutoff_time in ids_dict:
        writers[cutoff_time].writerows(buffer_dict[cutoff_time])
        file_handles[cutoff_time].close()

    return ids_tracked_dict

def filter_file_based_on_cutoff_time(input_path,
                                     output_path,
                                     date_column_name,
                                     date_parser,
                                     cutoff_time,
                                     ids_to_track_column_name = None
                                    ):
    """
    Takes in one file, outputs one file
    """

    converters = {date_column_name: date_parser}
    df = pd.read_csv(input_path, converters=converters)
    original_length = len(df)
    df = df[df[date_column_name] <= cutoff_time]
    df.to_csv(output_path, index=False)
    new_length = len(df)

    print("%s, %s: %d lines remaining out of %d original lines" % (get_day_str(cutoff_time), os.path.split(input_path)[1], new_length, original_length))
    print(min(df[date_column_name]))
    print(max(df[date_column_name]))

    if ids_to_track_column_name is not None:
        ids_to_track = set(df[ids_to_track_column_name])
    else:
        ids_to_track = None
    return ids_to_track

def filter_file_based_on_cutoff_time_streaming(
    input_path,
    output_path,
    date_column_name,
    date_parser,
    cutoff_time,
    ids_to_track_column_name = None
    ):

    if ids_to_track_column_name is not None:
        ids_tracked = set()
    else:
        ids_tracked = None

    f_in = open(input_path)
    reader = HeaderCsvReader(f_in)
    f_out = open(output_path, "w")
    writer = csv.writer(f_out, dialect=CsvDialect())
    writer.writerow(reader.header)

    converters = {date_column_name: date_parser}

    i_total = 0
    i_keep = 0

    for row in reader:
        i_total += 1
        parse_row(converters, row)
        if row[date_column_name] > cutoff_time:
            continue
        if ids_to_track_column_name is not None:
            ids_tracked.add(row[ids_to_track_column_name])
        i_keep += 1
        row[date_column_name] = str(row[date_column_name])
        writer.writerow([row[col_name] for col_name in reader.header])

    print("%s, %s: %d lines remaining out of %d original lines" % (get_day_str(cutoff_time), os.path.split(input_path)[1], i_keep, i_total))

    f_out.close()
    return ids_tracked

def filter_file_based_on_ids_streaming(
    input_path,
    output_path,
    id_column_name,
    valid_ids):
    """
    Takes in one file, outputs one file
    """

    f_in = open(input_path)
    reader = HeaderCsvReader(f_in)
    f_out = open(output_path, "w")
    writer = csv.writer(f_out, dialect=CsvDialect())
    writer.writerow(reader.header)

    i_total = 0
    i_keep = 0

    for row in reader:
        i_total += 1
        if row[id_column_name] not in valid_ids:
            continue
        i_keep += 1
        writer.writerow([row[col_name] for col_name in reader.header])

    remainder, file_name = os.path.split(input_path)
    day_str = os.path.split(remainder)[1]
    print("%s, %s: %d lines remaining out of %d original lines" % (day_str, file_name, i_keep, i_total))

    f_out.close()

def parse_datetime_format1(datestr):
    """
    Doing this manually for efficiency

    Format: 2012-11-12 01:00:03-08
    Year-Month-Day Hour:Minute:Second-TimeZoneUTCOffsetInHours

    Converts into UTC
    """
    dt = datetime.datetime(int(datestr[:4]),
                           int(datestr[5:7]),
                           int(datestr[8:10]),
                           int(datestr[11:13]),
                           int(datestr[14:16]),
                           int(datestr[17:19]),
                           0,
                           tzoffset(None, int(datestr[19:22]) * 3600))
    dt = dt.astimezone(tzutc())
    return dt

def parse_datetime_format2(datestr):
    """
    Doing this manually for efficiency

    Format: 2012-11-13 02:55:32
    Year-Month-Day Hour:Minute:Second

    Assumed to be UTC
    """
    dt = datetime.datetime(int(datestr[:4]),
                           int(datestr[5:7]),
                           int(datestr[8:10]),
                           int(datestr[11:13]),
                           int(datestr[14:16]),
                           int(datestr[17:19]),
                           0,
                           tzutc())
    return dt

def parse_datetime_format3(datestr):
    """
    Doing this manually for efficiency

    Format: 2012-11-13 14:45:41.964-08
    Alternative: 2012-11-13 15:03:16.62-08
    Year-Month-Day Hour:Minute:Second.Milliseconds-TimeZoneUTCOffsetInHours

    Converts into UTC
    """
    microseconds = datestr[20:-3]
    if not microseconds:
        microseconds=0
    else:
        microseconds = int(microseconds) * (10**(6-len(microseconds)))
   
    dt = datetime.datetime(int(datestr[:4]),
                           int(datestr[5:7]),
                           int(datestr[8:10]),
                           int(datestr[11:13]),
                           int(datestr[14:16]),
                           int(datestr[17:19]),
                           microseconds,
                           tzoffset(None, int(datestr[-3:]) * 3600))

    return dt

def parse_datetime_format4(datestr, time_zone_offset_hours):
    """
    Doing this manually for efficiency

    Format: 2012-11-12 01:00:03
    Year-Month-Day Hour:Minute:Second

    Converts into UTC
    """
    dt = datetime.datetime(int(datestr[:4]),
                           int(datestr[5:7]),
                           int(datestr[8:10]),
                           int(datestr[11:13]),
                           int(datestr[14:16]),
                           int(datestr[17:19]),
                           0,
                           tzoffset(None, time_zone_offset_hours * 3600))
    dt = dt.astimezone(tzutc())
    return dt

def parse_datetime_format5(datestr, time_zone_offset_hours):
    """
    Doing this manually for efficiency

    Format: 2012-11-12 01:00:03
    Year-Month-Day Hour:Minute:Second

    Converts into UTC
    """
    dt = datetime.datetime(int(datestr[:4]),
                           int(datestr[5:7]),
                           int(datestr[8:10]),
                           int(datestr[11:13]),
                           int(datestr[14:16]),
                           0,
                           0,
                           tzoffset(None, time_zone_offset_hours * 3600))
    dt = dt.astimezone(tzutc())
    return dt

def minutes_difference(datetime1, datetime2):
    diff = datetime1 - datetime2
    return diff.days*24*60+diff.seconds/60