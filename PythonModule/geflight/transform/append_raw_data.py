"""
This script takes the latest raw data we receive from FlightStats and appends
it to the existing set of raw data.
"""

import os

ge_flight_path = os.path.join(os.environ["DataPath"], "GEFlight")
raw_combined_path = os.path.join(ge_flight_path, "RawCombined")

def append_data(new_data_path):
    for cur_dir, dir_names, file_names in os.walk(raw_combined_path):
        for f_name in file_names:
            combined_file = os.path.join(cur_dir, f_name)
            print(combined_file)
            f_combined = open(combined_file, "a")
            new_data_file = os.path.join(new_data_path,
                cur_dir[len(raw_combined_path)+1:], f_name)
            f_new = open(new_data_file)
            # ignore header on new file
            f_new.next()
            for line in f_new:
                f_combined.write(line)
            f_combined.close()
            f_new.close()

def append_public_leaderboard_data():
    public_leaderboard_path = os.path.join(ge_flight_path, 
        "RawPublicLeaderboard")
    append_data(public_leaderboard_path)

if __name__=="__main__":
    append_public_leaderboard_data()
