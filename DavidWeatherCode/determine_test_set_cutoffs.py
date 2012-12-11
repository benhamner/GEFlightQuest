import datetime
from dateutil import parser
import pytz
import random

#days begin at 1am PST /  9am UTC
#intervals by default begin at 9am EST / 17:00 UTC

def write_csv_with_cutoffs(outfile, first_day, num_days, interval_beginning_hours_after_midnight_UTC = 14, interval_length = 12):
	with open(outfile, "w") as outdays:
		outdays.write("day_beginning,selected_cutoff_time,folder_name\n")
		first_day = pytz.utc.localize(first_day)
		for day in range(num_days):
			day_beginning = first_day + datetime.timedelta(days = day, hours=9)
			interval_beginning = first_day + datetime.timedelta(days = day, hours=interval_beginning_hours_after_midnight_UTC)
			selected_cutoff_time = interval_beginning + datetime.timedelta(hours = random.uniform(0, interval_length))
			print day_beginning
			print selected_cutoff_time
			print day_beginning.day
			folder_name = str(day_beginning.year) + "_" + str(day_beginning.month) + "_" + str(day_beginning.day)
			print folder_name
			outdays.write(str(day_beginning) + ", " + str(selected_cutoff_time) + "," + folder_name + "\n")


if __name__ == '__main__':
	random.seed(487487)
	write_csv_with_cutoffs("C:\Users\david\Dropbox\GEFlight\Release 1\SampleTestSet\days.csv", parser.parse("11-19-2012"), 7)
	