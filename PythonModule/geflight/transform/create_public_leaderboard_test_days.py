from __future__ import division
import datetime
import dateutil
from dateutil import tz
from dateutil.parser import parse
from geflight.transform import flighthistory, utilities
from geflight.transform import create_day_test_data
import os

if __name__=="__main__":
    training_days_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 2", "PublicLeaderboardTrainDays")
    test_days_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 2", "PublicLeaderboardSet")
    solution_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 2", "PublicLeaderboardSolution")

    reader = utilities.HeaderCsvReader(open(os.path.join(test_days_path, "days.csv")))
    cutoff_times = [parse(row["selected_cutoff_time"]) for row in reader]

    create_day_test_data.training_days_to_test_days(training_days_path, test_days_path, solution_path, cutoff_times)