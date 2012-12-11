
import os
import datetime
import pandas
from dateutil import parser
import pytz
import random

import weather

month = 11
days = range(12,26)
day = 12

for day in days:
	day_beginning = parser.parse("2012-" + str(month) + "-" + str(day) + " 01:00:00.00-08")
	day_end = parser.parse("2012-" + str(month) + "-" + str(day+1) + " 01:00:00.00-08")
	print day_beginning
	print day_end

	data_out = "C:\\Users\\david\\Dropbox\\GEFlight\\InitialTrainingSet_rev1\\2012_" + str(month) + "_" + str(day) + "\\"
	print data_out
	if not os.path.exists(data_out):
		os.makedirs(data_out)
	weather.process_one_day("C:\\Users\\david\\Dropbox\\GE\\nov26 data\\", data_out, day_beginning, day_end, "train")

#cutoff_beginning_range = parser.parse("2012-" + str(month) + "-" + str(day) + " 09:00:00.00-09")
#random_range_num_hours = 12

#hours_to_add = random.uniform(0, random_range_num_hours)

import create_sample_test_set
