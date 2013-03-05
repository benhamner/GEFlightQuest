from __future__ import division
import datetime
import dateutil
from dateutil import tz
from dateutil.parser import parse
from geflight.transform import flighthistory, utilities, stitch_files, weather
import numpy as np
import os

def training_days_to_test_days(training_days_path, test_days_path, solution_path, cutoff_times):
    for cutoff_time in cutoff_times:
        training_day_path = utilities.get_day_path(training_days_path, cutoff_time)
        test_day_path = utilities.get_day_path(test_days_path, cutoff_time)
        training_day_to_test_day(training_day_path, test_day_path, solution_path, cutoff_time)

    stitch_files.stitch_test_set(test_days_path)
    stitch_files.stitch_solution(solution_path)

def training_day_to_test_day(training_day_path, test_day_path, solution_path, cutoff_time): 
    flighthistory.write_flight_history_test_day_file(
        os.path.join(training_day_path, "FlightHistory", "flighthistory.csv"),
        os.path.join(utilities.get_output_subdirectory(test_day_path, "FlightHistory"), "flighthistory.csv"),
        cutoff_time)

    flighthistory.write_flight_history_test_day_and_solution_test_flights_only(
        os.path.join(training_day_path, "FlightHistory", "flighthistory.csv"),
        os.path.join(test_day_path, "test_flights.csv"),
        os.path.join(solution_path, utilities.get_day_str(cutoff_time) + "_solution.csv"),
        cutoff_time)

    utilities.filter_file_based_on_cutoff_time_streaming(os.path.join(training_day_path, "FlightHistory", "flighthistoryevents.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "FlightHistory"), "flighthistoryevents.csv"),
        "date_time_recorded",
        utilities.parse_datetime_format3,
        cutoff_time)

    utilities.filter_file_based_on_cutoff_time_streaming(os.path.join(training_day_path, "ASDI", "asdiposition.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "ASDI"), "asdiposition.csv"),
        "received",
        utilities.parse_datetime_format1,
        cutoff_time)

    flight_plan_ids = utilities.filter_file_based_on_cutoff_time_streaming(os.path.join(training_day_path, "ASDI", "asdiflightplan.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "ASDI"), "asdiflightplan.csv"),
        "updatetimeutc",
        utilities.parse_datetime_format2,
        cutoff_time,
        ids_to_track_column_name = "asdiflightplanid")

    utilities.filter_file_based_on_ids_streaming(os.path.join(training_day_path, "ASDI", "asdiairway.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "ASDI"), "asdiairway.csv"),
        "asdiflightplanid",
        flight_plan_ids)

    utilities.filter_file_based_on_ids_streaming(os.path.join(training_day_path, "ASDI", "asdifpfix.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "ASDI"), "asdifpfix.csv"),
        "asdiflightplanid",
        flight_plan_ids)

    utilities.filter_file_based_on_ids_streaming(os.path.join(training_day_path, "ASDI", "asdifpcenter.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "ASDI"), "asdifpcenter.csv"),
        "asdiflightplanid",
        flight_plan_ids)

    utilities.filter_file_based_on_ids_streaming(os.path.join(training_day_path, "ASDI", "asdifpsector.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "ASDI"), "asdifpsector.csv"),
        "asdiflightplanid",
        flight_plan_ids)

    utilities.filter_file_based_on_ids_streaming(os.path.join(training_day_path, "ASDI", "asdifpwaypoint.csv"), 
        os.path.join(utilities.get_output_subdirectory(test_day_path, "ASDI"), "asdifpwaypoint.csv"),
        "asdiflightplanid",
        flight_plan_ids)

    day_beginning, day_end = utilities.get_day_boundaries(cutoff_time)

    weather.process_one_day(
        training_day_path, 
        test_day_path, 
        day_beginning, 
        cutoff_time, 
        "test", 
        cutoff_time = cutoff_time)

if __name__=="__main__":
    training_days_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 1", "InitialTrainingSet_rev1")
    test_days_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 1", "SampleTestSet")
    solution_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 1", "SampleSolution")

    reader = utilities.HeaderCsvReader(open(os.path.join(test_days_path, "days.csv")))
    cutoff_times = [parse(row["selected_cutoff_time"]) for row in reader]

    training_days_to_test_days(training_days_path, test_days_path, solution_path, cutoff_times)
