from __future__ import division
import copy
from datetime import datetime, timedelta
import dateutil
from dateutil import tz
import os

from geflight.transform import create_day_train_data

def main():
    flight_data_path = os.path.join(os.environ["DataPath"], "GEFlight", "RawAugmentedTrainingRelease1")
    output_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 3", "AugmentedTrainingSet1")

    start_day = datetime(2012,12,10,20,00, tzinfo=dateutil.tz.tzutc())
    cutoff_times = [start_day]
    for i in range(1,25):
        cutoff_times.append(start_day + timedelta(i, 0))

    for ct in cutoff_times:
        print ct

    create_day_train_data.raw_data_to_training_days(flight_data_path, output_path, cutoff_times)

if __name__=="__main__":
    main()