import pandas
import os
import csv
from utilities import HeaderCsvReader


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


def metar(base_name, offset=None):
    """ Process metar files line by line instead of using Pandas data frames.
    Note that some metar tables have the columns in a different order from the base file to the
    archive file.
    This script relists columns in alphabetical order and then outputs result.
    """ 
    
    with open(folder + '_' + base_name + ".csv", 'wb') as w:
        with open(folder + base_name + ".csv") as b:
            base = HeaderCsvReader(b)
            headerdict = dict(zip(base.header, xrange(len(base.header))))
            targetheader = sorted(base.header)
            
            out = csv.writer(w)
            out.writerow(targetheader)
            
            for row in base.reader:
                row[headerdict['metar_reports_id']] = int(row[headerdict['metar_reports_id']]) + offset
                newrow = []
                for item in targetheader:
                    newrow.append(row[headerdict[item]])
                out.writerow(newrow)
                    
        with open(folder + base_name + "archive.csv") as a:
            archive = HeaderCsvReader(a)
            headerdict = dict(zip(archive.header, xrange(len(archive.header))))
            headerdict['metar_reports_id'] = headerdict['metar_reports_archive_id']
            
            for row in archive.reader:
                newrow = []
                for item in targetheader:
                    newrow.append(row[headerdict[item]])
                out.writerow(newrow)



if __name__ == "__main__":

    # to find max metar_reports_archive_id: cat file | cut -d, -f1 | sort -nr | head -1
    metar('presentconditions', offset=233709460)
    metar('runwaygroups', offset=233709460)
    metar('skyconditions', offset=233709460)
    metar('reports', offset=233709460)
