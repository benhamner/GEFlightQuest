"""
This script contains code to stitch files together
"""

import pandas as pd
import os

def combine_dataframes(dataframes_list):
    df = dataframes_list[0]
    for df_next in dataframes_list[1:]:
        df = df.append(df_next, ignore_index=True)
    return df

def stitch_files(files_list, output_path, sort_column=None):
    dataframes_list = [pd.read_csv(file_path) for file_path in files_list]
    df = combine_dataframes(dataframes_list)
    if sort_column:
        df = df.sort(sort_column)
    df.to_csv(output_path, index=False)

def get_csv_files_list(directory):
    return [os.path.join(directory, file_name)
                for file_name in os.listdir(directory)
                if file_name[-4:]==".csv"]

def get_test_files_list(test_directory):
    return [os.path.join(test_directory, folder, "test_flights.csv")
                for folder in os.listdir(test_directory)
                if "." not in folder]

def stitch_solution(solution_path):
    output_path = os.path.join(solution_path, "solution_combined.csv")

    files_list = get_csv_files_list(solution_path)
    stitch_files(files_list, output_path, "flight_history_id")

def stitch_test_set(test_path):
    output_path = os.path.join(test_path, "test_flights_combined.csv")

    files_list = get_test_files_list(test_path)
    stitch_files(files_list, output_path, "flight_history_id")

if __name__=="__main__":
    stitch_solution(solution_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 2", "PublicLeaderboardSolution"))
    stitch_test_set(test_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 2", "PublicLeaderboardSet"))