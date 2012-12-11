import weather
from dateutil import parser
import pandas
import os

test_folder = '''C:\Users\david\Dropbox\GEFlight\Release 1\SampleTestSet\\'''

days = pandas.read_csv(test_folder + "days.csv")

day = days.ix[1]
print day
print day['day_beginning']
release_path = '''C:\Users\david\Dropbox\GEFlight\Release 1\\'''

for row in days.iterrows():
	day = row[1]
	print "DAY IS " + str(day)
	weather.process_one_day(
		os.path.join(release_path, "InitialTrainingSet_rev1", day['folder_name']), 
		os.path.join(release_path, "SampleTestSet\\", day['folder_name']), 
		parser.parse(day['day_beginning']), 
		parser.parse(day['selected_cutoff_time']), 
		"test", 
		cutoff_time = parser.parse(day['selected_cutoff_time'])
	)