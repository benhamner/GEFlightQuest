import pandas
import os
import utilities

def summarize_flight_history_day(base_day_path, test_day_path = None):
	path = os.path.join(base_day_path, "FlightHistory", "flighthistory.csv")
	flighthistory = pandas.read_csv(path)
	print "In file %s:" % path
	print "Number of flight_history_ids: %d, Number unique: %d" % (len(flighthistory.flight_history_id), len(set(flighthistory.flight_history_id)))
	date_fields = [
	'published_departure',
	'published_arrival',
	'scheduled_gate_departure',
	'actual_gate_departure',
	'scheduled_gate_arrival',
	'actual_gate_arrival',
	'scheduled_runway_departure',
	'actual_runway_departure',
	'scheduled_runway_arrival',
	'actual_runway_arrival',
	]
	map(lambda field: utilities.summarize_date_field(flighthistory, field), date_fields)

	path = os.path.join(base_day_path, "FlightHistory", "flighthistoryevents.csv")
	flighthistoryevents = pandas.read_csv(path)
	print "Now looking at FlightHistoryEvents"
	print path
	print "%d rows" % len(flighthistoryevents.date_time_recorded)
	utilities.summarize_date_field(flighthistoryevents, "date_time_recorded")


	if test_day_path:
		print "\n"
		summarize_flight_history_day(test_day_path)
	else:
		print "\n\n"



def summarize_asdi_day(base_day_path, test_day_path = None):
	asdi_path = os.path.join(base_day_path, "ASDI")
	flightplan = pandas.read_csv(os.path.join(asdi_path, "asdiflightplan.csv"))
	print "%d flightplans, %d unique flightplanids, %d distinct flights" % (len(flightplan.asdiflightplanid), len(set(flightplan.asdiflightplanid)), len(set(flightplan.flighthistoryid)))
	utilities.summarize_date_field(flightplan, "updatetimeutc")
	if test_day_path:
		print "\n"
		summarize_asdi_day(test_day_path)
	else:
		print "\n\n"


if __name__=="__main__":
	summarize_flight_history_day('''C:\Users\david\Dropbox\GEFlight\Release 1\InitialTrainingSet_rev1\\2012_11_19''', 
		'''C:\Users\david\Dropbox\GEFlight\Release 1\SampleTestSet\\2012_11_19''')
	summarize_asdi_day('''C:\Users\david\Dropbox\GEFlight\Release 1\InitialTrainingSet_rev1\\2012_11_19''', 
		'''C:\Users\david\Dropbox\GEFlight\Release 1\SampleTestSet\\2012_11_19''')
