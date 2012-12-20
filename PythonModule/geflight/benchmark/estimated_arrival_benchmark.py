from dateutil.parser import parse
from geflight.transform import flighthistoryevents, utilities as tu
from geflight.benchmark import utilities as bu
from geflight.benchmark import process_test_set_scaffold
import os
import pandas as pd

def process_day(day):

    day.df_test_flight_history["estimated_runway_arrival"] = "MISSING"
    day.df_test_flight_history["estimated_gate_arrival"] = "MISSING"

    df_fhe = pd.read_csv(os.path.join(day.test_day_path, "FlightHistory", 
        "flighthistoryevents.csv"), 
        converters={"date_time_recorded": tu.parse_datetime_format6})
    df_fhe = df_fhe.sort("date_time_recorded")

    for i, row in df_fhe.iterrows():
        f_id = row["flight_history_id"]
        if f_id not in day.df_test_flight_history.index:
            continue
        if type(row["data_updated"]) != str:
            continue
        offset = day.df_test_flight_history["arrival_airport_timezone_offset"][f_id]
        if offset>0:
            offset_str = "+" + str(offset)
        else:
            offset_str = str(offset)
        gate_str = flighthistoryevents.get_estimated_gate_arrival_string(row["data_updated"])
        if gate_str:
            day.df_test_flight_history["estimated_gate_arrival"][f_id] = parse(gate_str+offset_str)
        runway_str = flighthistoryevents.get_estimated_runway_arrival_string(row["data_updated"])
        if runway_str:
            day.df_test_flight_history["estimated_runway_arrival"][f_id] = parse(runway_str+offset_str)

    for i, row in day.df_test_flight_history.iterrows():
        day.df_predictions["actual_runway_arrival"][i] = bu.get_estimated_arrival(row, "runway", day.cutoff_time)
        day.df_predictions["actual_gate_arrival"][i] = bu.get_estimated_arrival(row, "gate", day.cutoff_time)

    return day.df_predictions

if __name__=="__main__":
    process_test_set_scaffold.process_test_set(process_day, 
        "estimated_arrival_benchmark.csv")
