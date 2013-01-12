from __future__ import division
import datetime
import dateutil
from dateutil import tz
import numpy as np
import os

from geflight.transform import flighthistory
from geflight.transform import utilities
from geflight.transform import weather

#def create_day_data(input_path, df_flight_history, output_path, cutoff_time):
#    flighthistory.get_flight_list_and_write_flight_history(df_flight_history, output_path, cutoff_time)

def raw_data_to_training_days(raw_data_path, training_days_path, cutoff_times):
    #df_flight_history = flighthistory.get_df_flight_history_from_raw_format(os.path.join(raw_data_path, "FlightHistory", "flighthistory.csv"))
 
    print(os.path.join(raw_data_path, "FlightHistory", "flighthistory.csv"))

    days_flight_ids = flighthistory.process_flight_history_to_train_day_files(
        input_path = os.path.join(raw_data_path, "FlightHistory", "flighthistory.csv"),
        output_path = training_days_path,
        output_folder_name = "FlightHistory",
        output_file_name = "flighthistory.csv",
        cutoff_times = cutoff_times,
        start_hours_offset = -9)

    print("Flight History Events")
    utilities.split_file_based_on_times_filter_on_ids_streaming(
        os.path.join(raw_data_path, "FlightHistory", "flighthistoryevents.csv"),
        training_days_path,
        "FlightHistory",
        "flighthistoryevents.csv",
        "flight_history_id",
        days_flight_ids)
    
    print("ASDI Flight Plan")
    days_flight_plan_ids = utilities.split_file_based_on_times_filter_on_ids_streaming(os.path.join(raw_data_path, "ASDI", "asdiflightplan.csv"), training_days_path,
        "ASDI", "asdiflightplan.csv", "flighthistoryid", days_flight_ids, ids_to_track_column_name="asdiflightplanid")

    print("ASDI Position")
    utilities.split_file_based_on_times_filter_on_ids_streaming(os.path.join(raw_data_path, "ASDI", "asdiposition.csv"), training_days_path,
        "ASDI", "asdiposition.csv", "flighthistoryid", days_flight_ids)

    print("ASDI Airway")
    utilities.split_file_based_on_times_filter_on_ids_streaming(os.path.join(raw_data_path, "ASDI", "asdiairway.csv"), training_days_path,
        "ASDI", "asdiairway.csv", "asdiflightplanid", days_flight_plan_ids)

    print("ASDI FPFix")
    utilities.split_file_based_on_times_filter_on_ids_streaming(os.path.join(raw_data_path, "ASDI", "asdifpfix.csv"), training_days_path,
        "ASDI", "asdifpfix.csv", "asdiflightplanid", days_flight_plan_ids)

    print("ASDI FPCenter")
    utilities.split_file_based_on_times_filter_on_ids_streaming(os.path.join(raw_data_path, "ASDI", "asdifpcenter.csv"), training_days_path,
        "ASDI", "asdifpcenter.csv", "asdiflightplanid", days_flight_plan_ids)

    print("ASDI FPSector")
    utilities.split_file_based_on_times_filter_on_ids_streaming(os.path.join(raw_data_path, "ASDI", "asdifpsector.csv"), training_days_path,
        "ASDI", "asdifpsector.csv", "asdiflightplanid", days_flight_plan_ids)

    print("ASDI FPWaypoint")
    utilities.split_file_based_on_times_filter_on_ids_streaming(os.path.join(raw_data_path, "ASDI", "asdifpwaypoint.csv"), training_days_path,
        "ASDI", "asdifpwaypoint.csv", "asdiflightplanid", days_flight_plan_ids)

    for ct in cutoff_times:
        print ct
        day_output_path = os.path.join(output_path, utilities.get_day_str(ct, -9))
        day_beginning, day_end = utilities.get_day_boundaries(ct, -9)

        if not os.path.exists(day_output_path):
            os.makedirs(day_output_path)
        weather.process_one_day(raw_data_path, day_output_path, day_beginning, day_end, "train")

if __name__=="__main__":
    flight_data_path = os.path.join(os.environ["DataPath"], "GEFlight", "RawInitialRelease")
    output_path = os.path.join(os.environ["DataPath"], "GEFlight", "Playground", "Train")

    cutoff_times =[datetime.datetime(2012,11,cutoff_day,20,00, tzinfo=dateutil.tz.tzutc()) for cutoff_day in range(12,26)]

    raw_data_to_training_days(flight_data_path, output_path, cutoff_times)