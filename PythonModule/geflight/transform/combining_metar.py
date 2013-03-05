import pandas
import os

folder = os.path.join(os.environ["DataPath"], "GEFlight", "RawFinalEvaluationSet", "Metar", "flightstats_metar")

def combine_metars(base_name):
	print base_name
	base = pandas.read_csv(folder + base_name + ".csv")
	archive = pandas.read_csv(folder + base_name + "archive.csv")
	base['metar_reports_id'] = map(lambda x: -x, base['metar_reports_id'])
	print archive.columns
	if 'metar_reports_id' in archive.columns:
		print 'dropping metar_reports_id'
		archive = archive.drop(['metar_reports_id'], axis=1)
	print "columns:"
	print archive.columns
	archive = archive.rename(columns = {'metar_reports_archive_id' : 'metar_reports_id'})
	combined = base.append(archive, ignore_index = True)
	combined.to_csv(folder + base_name + "_combined.csv", index=False)

combine_metars("presentconditions")
combine_metars("reports")
combine_metars("runwaygroups")
combine_metars("skyconditions")