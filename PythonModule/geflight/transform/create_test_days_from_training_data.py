import datetime
from dateutil import tz
from geflight.transform import create_day_test_data
import os

if __name__=="__main__":
    training_days_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 1", "InitialTrainingSet_rev1")
    test_days_path = os.path.join(os.environ["DataPath"], "GEFlight", "Playground", "SampleTest")
    solution_path = os.path.join(os.environ["DataPath"], "GEFlight", "Playground", "SampleSolution")
    cutoff_times = [datetime.datetime(2012,11, 20, 18, tzinfo = tz.tzutc())]

    create_day_test_data.training_days_to_test_days(training_days_path, test_days_path, solution_path, cutoff_times)