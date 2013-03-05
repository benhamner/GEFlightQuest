import csv
import datetime
from dateutil import tz
import os
import pandas as pd
from pdb import set_trace
from geflight.transform import utilities

def to_utc_date(myString):
    if not myString or myString=="MISSING":
        return "MISSING"
    if myString=="HIDDEN":
        return "HIDDEN"
    return utilities.parse_datetime_format1(myString).astimezone(tz.tzutc())

def get_flight_history_date_columns():
    flight_history_date_columns = [
        "published_departure",
        "published_arrival",
        "scheduled_gate_departure",
        "scheduled_gate_arrival",
        "actual_gate_departure",
        "actual_gate_arrival",
        "scheduled_runway_departure",
        "scheduled_runway_arrival",
        "actual_runway_departure",
        "actual_runway_arrival",
    ]

    return flight_history_date_columns

def get_flight_history_date_converter():
    return {col : to_utc_date for col in get_flight_history_date_columns()}

def get_flight_history_departure_date_columns():
    departure_date_columns = [
        "published_departure",
        "scheduled_gate_departure",
        "actual_gate_departure",
        "scheduled_runway_departure",
        "actual_runway_departure",
    ]

    return departure_date_columns

def get_flight_history_arrival_date_columns():
    arrival_date_columns = [
        "published_arrival",
        "scheduled_gate_arrival",
        "actual_gate_arrival",
        "scheduled_runway_arrival",
        "actual_runway_arrival",
    ]

    return arrival_date_columns

def get_flight_history_date_columns_to_hide():
    """
    Returns a list of date columns with values that should be hidden based on the cutoff time.
    """
    flight_history_date_columns_to_hide = [
        "actual_gate_departure",
        "actual_gate_arrival",
        "actual_runway_departure",
        "actual_runway_arrival",
    ]

    return flight_history_date_columns_to_hide

def get_flight_history_columns_to_delete():
    """
    Returns a list of columns to delete from flighthistory.csv
    """

    return [ "last_updated"
           , "departure_date"
           , "departure_date_date_only"
           , "arrival_date"
           , "arrival_date_date_only"
           , "task_scheduled"
           , "task_status"
           , "baggage_claim"
           , "actual_block_time"
           , "actual_air_time"
           , "estimated_gate_departure"
           , "estimated_runway_departure"
           , "estimated_runway_arrival"
           , "estimated_gate_arrival"
           , "departure_gate"
           , "departure_terminal"
           , "arrival_gate"
           , "arrival_terminal"
           , "flight_history_status_code"
           , "diverted_airport_timezone_offset"
           , "diverted_airport_code"
           , "diverted_airport_icao_code"
           , "tail_number"]

    def get_flight_history_date_converter():
        return {x : to_utc_date for x in get_flight_history_date_columns()}

def get_df_flight_history_from_raw_format(flighthistory_path):
    df = pd.read_csv(flighthistory_path, 
                     converters = get_flight_history_date_converter(),
                     keep_default_na = False)

    for col in get_flight_history_columns_to_delete():
    	del df[col]
    return df 

def get_df_flight_history_from_train_format(flighthistory_path):
    df = pd.read_csv(flighthistory_path, 
                     converters = get_flight_history_date_converter(),
                     keep_default_na = False)
    return df

def summarize_flight_history(flighthistory_path):
    df = pd.read_csv(flighthistory_path, converters = get_flight_history_date_converter())
    for col in get_flight_history_date_columns():
        print("%s: %0.1f" % (col, len(df[df[col]!="MISSING"])/len(df)*100 ))
    
    codes_file = os.path.join(os.environ["DataPath"], "GEFlight", "Reference", "usairporticaocodes.txt")
    us_icao_codes = get_us_airport_icao_codes(codes_file)
    
    df_departs_from_us = df.select(lambda i: df["departure_airport_icao_code"][i] in us_icao_codes)
    df_arrives_in_us = df.select(lambda i: df["arrival_airport_icao_code"][i] in us_icao_codes)
    df_us = df.select(lambda i: df["departure_airport_icao_code"][i] in us_icao_codes
                            and df["arrival_airport_icao_code"][i] in us_icao_codes)

    print("%s: %d" % ("NumberDepartsFromUS", len(df_departs_from_us)))
    print("%s: %0.1f" % ("PercentDepartsFromUS", len(df_departs_from_us)/len(df)*100 ))
    print("%s: %d" % ("NumberArrivesInUS", len(df_arrives_in_us)))
    print("%s: %0.1f" % ("PercentArrivesInUS", len(df_arrives_in_us)/len(df)*100 ))
    print("%s: %d" % ("NumberBothInUS", len(df_us)))
    print("%s: %0.1f" % ("PercentBothInUS", len(df_us)/len(df)*100 ))

    print("")
    print("---US Only Stats---")
    print("")
    for col in get_flight_history_date_columns():
        print("%s: %0.1f" % (col, len(df_us[df_us[col]!="MISSING"])/len(df_us)*100 ))

def get_departure_time(row):
    if row["published_departure"] != "MISSING":
        return row["published_departure"]
    if row["scheduled_gate_departure"] != "MISSING":
        return row["scheduled_gate_departure"]
    if row["scheduled_runway_departure"] != "MISSING":
        return row["scheduled_runway_departure"]
    return "MISSING"

def is_flight_in_or_out_of_us(row, us_icao_codes):
    if ((row["arrival_airport_icao_code"] not in us_icao_codes) or
        (row["departure_airport_icao_code"] not in us_icao_codes)):
        return False
    return True

def get_departure_day_str(row, start_hours_offset):
    """
    Returns the date_str for the specific day that a flighthistory row belongs to
    based on the departure date for the flight

    Sample return value: "2012_11_15"
    """
    departure_time = get_departure_time(row)
    if departure_time=="MISSING":
        return ""
    return utilities.get_day_str(departure_time, start_hours_offset)

def parse_flight_history_dates(row, departure_date_columns, arrival_date_columns):
    """
    Row is a dict. This changes date strings in row to datetimes
    - it is NOT an immutable operation
    """
    
    departure_timezone_offset = int(row["departure_airport_timezone_offset"])
    arrival_timezone_offset = int(row["arrival_airport_timezone_offset"])

    for col in departure_date_columns:
        if row[col]:
            row[col] = utilities.parse_datetime_format4(row[col], departure_timezone_offset)
        else:
            row[col] = "MISSING"
    for col in arrival_date_columns:
        if row[col]:
            row[col] = utilities.parse_datetime_format4(row[col], arrival_timezone_offset)
        else:
            row[col] = "MISSING"

def process_flight_history_to_train_day_files(
    input_path,
    output_path,
    output_folder_name,
    output_file_name,
    cutoff_times,
    start_hours_offset = -9):
    """
    
    """

    file_started_for_day = {cutoff_time: False for cutoff_time in cutoff_times}

    i=0
    cnt=0

    departure_date_columns = get_flight_history_departure_date_columns()
    arrival_date_columns = get_flight_history_arrival_date_columns()

    reader = utilities.HeaderCsvReader(open(input_path))
    header_out = reader.get_header()
    for col in get_flight_history_columns_to_delete():
        header_out.remove(col)

    day_flight_history_ids = {cutoff_time:set() for cutoff_time in cutoff_times}
    day_str_to_cutoff_time = {}
    file_handles = {}
    writers = {}
    for cutoff_time in cutoff_times:
        day_output_path = utilities.get_full_output_path(output_path, output_folder_name, cutoff_time)
        file_output_path = os.path.join(day_output_path, output_file_name)
        file_handles[cutoff_time] = open(file_output_path, "w")
        writers[cutoff_time] = csv.writer(file_handles[cutoff_time], dialect=utilities.CsvDialect())
        writers[cutoff_time].writerow(header_out)
        day_str_to_cutoff_time[utilities.get_day_str(cutoff_time)] = cutoff_time

    i_row_mod = 0
    buffer_dict = {cutoff_time: [] for cutoff_time in cutoff_times}

    start_time, end_time = utilities.get_day_boundaries(cutoff_time, start_hours_offset)

    codes_file = os.path.join(os.environ["DataPath"], "GEFlight", "Reference", "usairporticaocodes.txt")
    us_icao_codes = get_us_airport_icao_codes(codes_file)

    for row in reader:
        i_row_mod += 1
        if not is_flight_in_or_out_of_us(row, us_icao_codes):
            continue
        parse_flight_history_dates(row, departure_date_columns, arrival_date_columns)
        row_day_str = get_departure_day_str(row, start_hours_offset)
        if row_day_str not in day_str_to_cutoff_time:
            continue
        cutoff_time = day_str_to_cutoff_time[row_day_str]
        cnt += 1
        buffer_dict[cutoff_time].append([row[col] for col in header_out])
        day_flight_history_ids[cutoff_time].add(row["flight_history_id"])
        if i_row_mod < 100000:
            continue
        i+=1
        print("%s: %d00k records processed, %d with relevant flights in this chunk" % (output_file_name, i, cnt))
        cnt=0
        for cutoff_time in cutoff_times:
            writers[cutoff_time].writerows(buffer_dict[cutoff_time])
            file_handles[cutoff_time].flush()

        i_row_mod = 0
        buffer_dict = {cutoff_time: [] for cutoff_time in cutoff_times}

    for cutoff_time in cutoff_times:
        writers[cutoff_time].writerows(buffer_dict[cutoff_time])
        file_handles[cutoff_time].close()

    return day_flight_history_ids

def get_us_airport_icao_codes(codes_file):
    df = pd.read_csv(codes_file)
    return set(df["icao_code"])

def write_flight_history_test_day_file(input_path, output_path, cutoff_time):    
    df = get_df_flight_history_from_train_format(input_path)

    cols_to_mask = get_flight_history_date_columns_to_hide()
    rows_modified = 0

    for i in range(len(df)):
        row_modified = False
        for col in cols_to_mask:
            if df[col][i] == "MISSING":
                continue
            if df[col][i] <= cutoff_time:
                continue
            df[col][i] = "HIDDEN"
            row_modified = True
        if row_modified:
            rows_modified += 1

    df.to_csv(output_path, index=False)

    print("%s, %s: %d rows modified out of %d original lines" % (utilities.get_day_str(cutoff_time), "flighthistory.csv", rows_modified, len(df)))

def flight_history_row_in_test_set(row, cutoff_time, us_icao_codes, diverted_or_redirected_flight_ids):
    """
    This function returns True if the flight is in the air and it
    meets the other requirements to be a test row (continental US flight)
    """
    
    departure_time = get_departure_time(row)
    if departure_time > cutoff_time:
        return False
    if row["actual_gate_departure"] == "MISSING":
        return False
    if row["actual_runway_departure"] == "MISSING":
        return False
    if row["actual_runway_departure"] > cutoff_time:
        return False
    if row["actual_runway_arrival"] == "MISSING":
        return False
    if row["actual_runway_arrival"] <= cutoff_time:
        return False
    if row["actual_gate_arrival"] == "MISSING":
        return False
    if row["actual_gate_arrival"] < row["actual_runway_arrival"]:
        return False   
    if row["actual_runway_departure"] < row["actual_gate_departure"]:
        return False 
    if row["arrival_airport_icao_code"] not in us_icao_codes:
        return False
    if row["departure_airport_icao_code"] not in us_icao_codes:
        return False
    if row["flight_history_id"] in diverted_or_redirected_flight_ids:
        return False
    return True

def get_diverted_or_redirected_flights(flight_history_path):
    base_path, fh_filename = os.path.split(flight_history_path)
    flight_history_events_path = os.path.join(base_path, "flighthistoryevents.csv")
    diverted_or_redirected_flight_ids = set()
    
    reader = csv.reader(open(flight_history_events_path))
    reader.next()

    for row in reader:
        if "STATUS-Diverted" in row[2]:
            diverted_or_redirected_flight_ids.add(int(row[0]))
        if "STATUS-Redirected" in row[2]:
            diverted_or_redirected_flight_ids.add(int(row[0]))

    return diverted_or_redirected_flight_ids

def write_flight_history_test_day_and_solution_test_flights_only(input_path, test_output_path, solution_path, cutoff_time):
    diverted_or_redirected_flight_ids = get_diverted_or_redirected_flights(input_path)

    codes_file = os.path.join(os.environ["DataPath"], "GEFlight", "Reference", "usairporticaocodes.txt")
    us_icao_codes = get_us_airport_icao_codes(codes_file)
    midnight_time = datetime.datetime(cutoff_time.year, cutoff_time.month, cutoff_time.day, tzinfo=tz.tzutc())

    df = get_df_flight_history_from_train_format(input_path)
    
    original_length = len(df)

    df = df.select(lambda i: flight_history_row_in_test_set(df.irow(i), cutoff_time, us_icao_codes, diverted_or_redirected_flight_ids))

    df_test = df[["flight_history_id"
                , "departure_airport_code"
                , "arrival_airport_code"
                , "published_departure"
                , "published_arrival"
                , "scheduled_gate_departure"
                , "scheduled_gate_arrival"
                , "scheduled_runway_departure"
                , "scheduled_runway_arrival"]]        

    df_test.to_csv(test_output_path, index=False)
    
    df_solution = df[["flight_history_id"
                    , "actual_runway_arrival"
                    , "actual_gate_arrival"]]

    for i in df_solution.index:
        df_solution["actual_runway_arrival"][i] = utilities.minutes_difference(df_solution["actual_runway_arrival"][i], midnight_time)
        df_solution["actual_gate_arrival"][i] = utilities.minutes_difference(df_solution["actual_gate_arrival"][i], midnight_time)

    df_solution.to_csv(solution_path, index=False)

    print("%s, %s: %d rows kept out of %d original lines" % (utilities.get_day_str(cutoff_time), "test_flights.csv", len(df_test), original_length))

    return df_test, df_solution