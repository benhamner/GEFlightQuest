import weather
from dateutil import parser
import pandas
import os

release_path = os.path.join(os.environ["DataPath"], "GEFlight", "Release 2")


days = pandas.read_csv(os.path.join(release_path, "PublicLeaderboardSet", "days.csv"))

day = days.ix[1]
print day
print day['day_beginning']

for row in days.iterrows():
	day = row[1]
	print "DAY IS " + str(day)
	weather.process_one_day(
		os.path.join(release_path, "PublicLeaderboardTrainDays", day['folder_name']), 
		os.path.join(release_path, "PublicLeaderboardSet", day['folder_name']), 
		parser.parse(day['day_beginning']), 
		parser.parse(day['selected_cutoff_time']), 
		"test", 
		cutoff_time = parser.parse(day['selected_cutoff_time'])
	)
