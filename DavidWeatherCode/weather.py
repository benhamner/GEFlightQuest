import os
import datetime
import pandas
from dateutil import parser
import pytz

#Need function for each weather data set. Arguments will be:
# cutoff_time (UTC) (optional)
# test_or_train 	
# start_time (for the day) (UTC)
# end_time (for the day, in UTC)
# path to data_in_top
# path to data_out

class Filter:
  def __init__(self, data_in_top, data_out, start_time, end_time, test_or_train, cutoff_time = None):
    self.data_in_top = data_in_top
    self.data_out = data_out
    self.start_time = start_time
    self.end_time = end_time
    self.test_or_train = test_or_train
    self.cutoff_time = cutoff_time
    print "hi"
    if test_or_train=="test":
    	self._cutoff_time = cutoff_time
    	print "it's test data"
    else: 
    	print "it's train data"
    	self._cutoff_time = end_time

  def set_subdir(self, subdir_in):
    self.subdir_in = subdir_in
    self.subdir_in_path = os.path.join(self.data_in_top, self.subdir_in)
    directory = os.path.join(self.data_out, self.subdir_in)
    if not os.path.exists(directory):
	    os.makedirs(directory)

  def set_file_in(self, file_in):
    self.file_in = file_in
    self.file_in_path = os.path.join(self.subdir_in_path, self.file_in)
    self.file_out_path = os.path.join(self.data_out, self.subdir_in, self.file_in)


  def compare_times(self, t):
    return self.start_time < t < self._cutoff_time

  def filter_on_date(self, field_name, date_fields=[], fields_to_remove = [], fields_to_blank_based_on_cutoff = [], additional_id_var = None):
    print "Filtering file " + self.file_in_path + " on date field " + field_name + " and outputting CSV to " + self.file_out_path
    print "additional_id_var is " + str(additional_id_var)
    df = pandas.read_csv(self.file_in_path, converters = get_date_converter(date_fields))
    keep =  map(self.compare_times, df[field_name])
    df_subset = df[keep]
    df_subset = self.blank_based_on_cutoff(df_subset, fields_to_blank_based_on_cutoff)
    df_subset = df_subset.drop([f for f in fields_to_remove if f in df_subset], axis=1)
    df_subset.to_csv(self.file_out_path, index=False)
    if additional_id_var:
    	return set(df_subset[additional_id_var])

  def set_file_in_and_filter_on_date(self, file_in, time_field_name, date_fields=[], fields_to_remove = [], fields_to_blank_based_on_cutoff = [], additional_id_var = None):
    self.set_file_in(file_in)
    return self.filter_on_date(time_field_name, date_fields = date_fields, fields_to_remove = fields_to_remove, fields_to_blank_based_on_cutoff = fields_to_blank_based_on_cutoff, additional_id_var = additional_id_var)

  def get_keep_ids(self, file_in, time_field_name, id_field_name, date_fields=[]):
    self.set_file_in(file_in)
    print "Getting " + id_field_name + "s to keep based on time field " + time_field_name + " in file " + file_in
    df = pandas.read_csv(self.file_in_path, converters = get_date_converter(date_fields))
    keep =  map(self.compare_times, df[time_field_name])
    df_subset = df[keep]
    return set(df_subset[id_field_name])

  def filter_on_ids(self, file_in, id_field_name, id_list, additional_id_var = None, date_fields = [], fields_to_remove = [], fields_to_blank_based_on_cutoff = []):
    self.set_file_in(file_in)
    print "Filtering file " + self.file_in_path + " on id .. " + id_field_name + " and outputting CSV to " + self.file_out_path
    df = pandas.read_csv(self.file_in_path, converters = get_date_converter(date_fields))
    keep =  map(lambda id: id in id_list, df[id_field_name])
    if len(df) > 0:
	  df_subset = df[keep]
    else:
      df_subset = df
    df_subset = self.blank_based_on_cutoff(df_subset, fields_to_blank_based_on_cutoff)
    df_subset = df_subset.drop([f for f in fields_to_remove if f in df_subset], axis=1)
    df_subset.to_csv(self.file_out_path, index=False)
    if additional_id_var:
    	print df_subset
    	return set(df_subset[additional_id_var])
  
  def blank_based_on_cutoff(self, df, fields_to_blank_based_on_cutoff):
  	if self.test_or_train == "train":
  		return df
  	def comparison_multi_type(t):
  		if type(t) == datetime.datetime:
  			if self.compare_times(t):
  				return t
  			else:
  				return 'HIDDEN'
  		else:
  			return 'MISSING'
  	if len(df) == 0:
  		return df
  	for col in fields_to_blank_based_on_cutoff:
  		print map(type, df[col])
  		df[col] = map(comparison_multi_type, df[col])
  	return df


def get_date_converter(date_columns):
	return {x : to_utc_date for x in date_columns}

def to_utc_date(myString):
	if not myString or myString=='MISSING':
		return "MISSING"
	t =  parser.parse(myString)
	if t.tzinfo == None:
		t = pytz.utc.localize(t)
	return t.astimezone(pytz.utc)




 #Done defining "Filter" class
 #Begin functions for doing filtering, one for each type of file:

def filter_atscc(filter):
	print "Performing filtering on atscc files"
	filter.set_subdir("ATSCC")
	
	filter.set_file_in_and_filter_on_date("flightstats_atsccadvisories.csv", "capture_time", date_fields = ["capture_time", "signature_time"])
	keep_advisory_message_ids =  filter.get_keep_ids("flightstats_atsccadvisories.csv", "capture_time", "advisory_message_id", date_fields = ["capture_time"])
		

#	filter.set_file_in_and_filter_on_date("flightstats_atsccclosures.csv", "capture_time")  (skipping, empty)
	filter.set_file_in_and_filter_on_date("flightstats_atsccdeicing.csv", "capture_time", date_fields = ["capture_time",
"start_time",
"end_time",	
"invalidated_time"],
fields_to_remove = ["ending_nas_status_id", "invalidating_airport_deicing_id"],
fields_to_blank_based_on_cutoff = ["end_time",	"invalidated_time"]
)

	filter.set_file_in_and_filter_on_date("flightstats_atsccdelay.csv", "capture_time", date_fields = ["capture_time",
"start_time",
"end_time",	
"invalidated_time"],
fields_to_remove = ["ending_nas_status_id", "invalidating_airport_delay_id"],
fields_to_blank_based_on_cutoff = ["end_time", "invalidated_time"]) 

	filter.set_file_in_and_filter_on_date("flightstats_atsccinvalidgs.csv", "capture_time", date_fields = ["capture_time", "signature_time"]) 
	
#	filter.set_file_in_and_filter_on_date("flightstats_atsccinvalafp.csv", "capture_time") #(skipping, empty)
#	filter.set_file_in_and_filter_on_date("flightstats_atsccinvalidgdp.csv", "capture_time") #(skipping, only one row)

	filter.set_file_in_and_filter_on_date("flightstats_atsccnasstatus.csv", "capture_time", date_fields = ["capture_time"]) 

	#(skipping, empty:)
	#filter.set_file_in_and_filter_on_date("flightstats_atsccflow.csv", "signature_time")  
	#keep_airspace_flow_program_ids = filter.get_keep_ids("flightstats_atsccflow.csv", "signature_time", "airspace_flow_program_id")
	#print keep_airspace_flow_program_ids
	#filter.filter_on_ids("atsccflowairports.csv", "airspace_flow_program_id", keep_airspace_flow_program_ids)
	
	keep_ground_delay_program_ids = filter.filter_on_ids("flightstats_atsccgrounddelay.csv", "original_advisory_message_id", keep_advisory_message_ids, 
		additional_id_var = "ground_delay_program_id",
		date_fields = ["signature_time",
"effective_start_time",	
"effective_end_time",
"invalidated_time"	,
"cancelled_time",	
"adl_time",
"arrivals_estimated_for_start_time",
"arrivals_estimated_for_end_time",],
	fields_to_remove = ["cancelling_advisory_message_id", "invalidating_ground_delay_program_id", "expired_notification_sent"],
	fields_to_blank_based_on_cutoff = ["invalidated_time", "cancelled_time"]
) 
	filter.filter_on_ids("flightstats_atsccgrounddelayairports.csv", "ground_delay_program_id", keep_ground_delay_program_ids)
	filter.filter_on_ids("flightstats_atsccgrounddelayartccs.csv", "ground_delay_program_id", keep_ground_delay_program_ids)

	#(skipping, empty:)
	#filter.set_file_in_and_filter_on_date("flightstats_atsccgroundstop.csv", "signature_time") 
	#keep_ground_stop_ids = filter.get_keep_ids("atsccgroundstop.csv", "signature_time", "ground_stop_id")
	#filter.filter_on_ids("atsccgroundstopairports.csv", "ground_stop_id", keep_ground_stop_ids)
	#filter.filter_on_ids("atsccgroundstopartccs.csv", "ground_stop_id", keep_ground_stop_ids)


def filter_metar(filter):
	filter.set_subdir("Metar")
	keep_metar_reports_ids = filter.set_file_in_and_filter_on_date("flightstats_metarreports_combined.csv", "date_time_issued", date_fields = ["date_time_issued"], additional_id_var = "metar_reports_id")
	filter.filter_on_ids("flightstats_metarpresentconditions_combined.csv", "metar_reports_id", keep_metar_reports_ids)
	filter.filter_on_ids("flightstats_metarrunwaygroups_combined.csv", "metar_reports_id", keep_metar_reports_ids)
	filter.filter_on_ids("flightstats_metarskyconditions_combined.csv", "metar_reports_id", keep_metar_reports_ids)


def filter_airsigmet(filter):
	filter.set_subdir("OtherWeather")
	filter.set_file_in_and_filter_on_date("flightstats_airsigmet.csv", "timevalidfromutc", date_fields = ["timevalidfromutc", "timevalidtoutc"])
	keep_airsigmet_ids = filter.get_keep_ids("flightstats_airsigmet.csv", "timevalidfromutc", "airsigmetid", date_fields = ["timevalidfromutc", "timevalidtoutc"])
	filter.filter_on_ids("flightstats_airsigmetarea.csv", "airsigmetid", keep_airsigmet_ids)

def filter_fb(filter):
	print "Performing filtering on fb files"
	filter.set_subdir("OtherWeather")
	filter.set_file_in_and_filter_on_date("flightstats_fbwindreport.csv", "createdutc", date_fields = ["createdutc"])
	keep_fbwindreportid = filter.get_keep_ids("flightstats_fbwindreport.csv", "createdutc", "fbwindreportid", date_fields = ["createdutc"])
	print len(keep_fbwindreportid)
	keep_fbwindairportids = filter.filter_on_ids("flightstats_fbwindairport.csv", "fbwindreportid", keep_fbwindreportid, additional_id_var = "fbwindairportid")
	filter.filter_on_ids("flightstats_fbwindaltitude.csv", "fbwindreportid", keep_fbwindreportid)
	print keep_fbwindairportids
	filter.filter_on_ids("flightstats_fbwindairport.csv", "fbwindairportid", keep_fbwindairportids)
	filter.filter_on_ids("flightstats_fbwind.csv", "fbwindairportid", keep_fbwindairportids)



def filter_taf(filter):
	print "Performing filtering on taf files"
	filter.set_subdir("OtherWeather")
	keep_tafids = filter.set_file_in_and_filter_on_date("flightstats_taf.csv", "bulletintimeutc", date_fields = ["bulletintimeutc",
"issuetimeutc",
"validtimefromutc",
"validtimetoutc"],
additional_id_var = "tafid"
)
	print len(keep_tafids)
	keep_tafforecastids = filter.filter_on_ids("flightstats_tafforecast.csv", "tafid", keep_tafids, 
		additional_id_var = "tafforecastid",
		date_fields = ["forecasttimefromutc", "forecasttimetoutc", "timebecomingutc"])
	print len(keep_tafforecastids)
	filter.filter_on_ids("flightstats_taficing.csv", "tafforecastid", keep_tafforecastids)
	filter.filter_on_ids("flightstats_tafsky.csv", "tafforecastid", keep_tafforecastids)
	filter.filter_on_ids("flightstats_taftemperature.csv", "tafforecastid", keep_tafforecastids)
	filter.filter_on_ids("flightstats_tafturbulence.csv", "tafforecastid", keep_tafforecastids)

def process_one_day(data_in_top, data_out, start_time, end_time, test_or_train, cutoff_time = None):
	filter = Filter(data_in_top, data_out, start_time, end_time, test_or_train, cutoff_time = cutoff_time)
	filter_atscc(filter)
	filter_airsigmet(filter)
	filter_fb(filter)
	filter_metar(filter)
	filter_taf(filter)

if __name__ == '__main__':
	filter = Filter(
		"C:\\Users\\david\\Dropbox\\GE\\nov26 data\\", 
		"C:\\Users\\david\\Dropbox\\GE\\competition_datasets\\test\\d14m11y2012\\",
		parser.parse("2012-11-24 01:00:00.00-09") ,
		parser.parse("2012-11-25 01:00:00.00-09") ,
		"test",
		cutoff_time = parser.parse("2012-11-24 20:00:00.00-09") ,	
		)
	print datetime.datetime.now()
	filter_atscc(filter)
	#filter_airsigmet(filter)
	#filter_fb(filter)
	#filter_metar(filter)
	#filter_taf(filter)
	print datetime.datetime.now()
