import csv
import os
import pandas as pd

from datetime import datetime
from dateutil.tz import tzutc
from dateutil.parser import parse

from geflight.transform import flighthistory
from geflight.transform import utilities as tu

def get_test_flight_ids(test_day_path):
    reader = csv.reader(open(os.path.join(test_day_path, "test_flights.csv")))
    # ignore header
    reader.next()
    return [int(row[0]) for row in reader]

def get_test_days(test_days_path):
    return os.walk(test_day_path).next()[1]

def get_df_test_days(test_days_path):
    return pd.read_csv(os.path.join(test_days_path, "days.csv"),
        converters={"selected_cutoff_time": parse})

class DayInfo:
    def __init__(self, test_day_path, cutoff_time):
        self.test_day_path = test_day_path
        self.cutoff_time = cutoff_time
        self.midnight_time = datetime(cutoff_time.year, cutoff_time.month, cutoff_time.day, tzinfo=tzutc())
        self.test_flights_list = get_test_flight_ids(test_day_path)
        self.test_flights_set = set(self.test_flights_list)
        self.df_flight_history = flighthistory.get_df_flight_history_from_train_format(
            os.path.join(test_day_path, "FlightHistory", "flighthistory.csv"))
        self.df_flight_history.index = self.df_flight_history["flight_history_id"]
        
        test_flights_index = pd.Index(data=self.test_flights_list,
            name="flight_history_id")
        self.df_test_flights_empty = pd.DataFrame(None,
            index=test_flights_index)

        self.df_test_flight_history = self.df_test_flights_empty.join(
            self.df_flight_history)

        cutoff_time_list = [cutoff_time for i in range(len(test_flights_index))]
        self.df_predictions = self.df_test_flights_empty.join(pd.DataFrame(
            {"flight_history_id": self.test_flights_list,
             "actual_runway_arrival": cutoff_time_list,
             "actual_gate_arrival" : cutoff_time_list}, 
            index = test_flights_index,
            columns = ["flight_history_id", "actual_runway_arrival",
                       "actual_gate_arrival"]))

def convert_df_predictions_from_datetimes_to_minutes(df_predictions,
    midnight_time):
    """
    For each day we 
    """

    for i in df_predictions.index:
        df_predictions["actual_runway_arrival"][i] = tu.minutes_difference(
            df_predictions["actual_runway_arrival"][i], midnight_time)
        df_predictions["actual_gate_arrival"][i] = tu.minutes_difference(
            df_predictions["actual_gate_arrival"][i], midnight_time)

    return df_predictions

def process_test_set(process_day, output_file_name, output_file_path=None, 
    test_data_path=None):

    if output_file_path is None:
        output_file_path = os.path.join(os.environ["DataPath"], "GEFlight",
            "BenchmarkSubmissions")
    if test_data_path is None:
        test_data_path = os.path.join(os.environ["DataPath"],
            "GEFlight", "Release 2", "PublicLeaderboardSet")

    df_test_days = get_df_test_days(test_data_path)
    df_predictions = []

    for i, row in df_test_days.iterrows():
        print(row["folder_name"])
        day_info = DayInfo(
            os.path.join(test_data_path, row["folder_name"]),
            row["selected_cutoff_time"])
        df_day = process_day(day_info)
        df_day = convert_df_predictions_from_datetimes_to_minutes(df_day,
            day_info.midnight_time)
        df_predictions.append(df_day)

    df_out = df_predictions[0]
    for df in df_predictions[1:]:
        df_out = df_out.append(df, ignore_index=True)
    df_out = df_out.sort("flight_history_id")
    df_out.to_csv(os.path.join(output_file_path, output_file_name),
        index=False)