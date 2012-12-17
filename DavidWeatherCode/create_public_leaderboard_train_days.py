import os
import pandas
from datetime import datetime, timedelta
from dateutil import parser, tz
from geflight.transform import utilities
import pytz
import random

import weather

raw_data_path = os.path.join(os.environ["DataPath"], "GEFlight", "RawPublicLeaderboard")
output_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 2", "PublicLeaderboardTrainDays")

start_day = datetime(2012,11,26,20,00, tzinfo=tz.tzutc())
cutoff_times = [start_day]
for i in range(1,14):
    cutoff_times.append(start_day + timedelta(i, 0))

for ct in cutoff_times:
    print ct
    day_output_path = os.path.join(output_path, utilities.get_day_str(ct, -9))
    day_beginning, day_end = utilities.get_day_boundaries(ct, -9)

    if not os.path.exists(day_output_path):
        os.makedirs(day_output_path)
    weather.process_one_day(raw_data_path, day_output_path, day_beginning, day_end, "train")
