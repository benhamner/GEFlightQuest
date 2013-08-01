import csv
from csvjazz import csv_to_postgres
from itertools import islice
import psycopg2
import os

class CsvDialect(csv.Dialect):
    def __init__(self):
        self.delimiter = ','
        self.doublequote = True
        self.escapechar = None
        self.lineterminator = "\n"
        self.quotechar = '"'
        self.quoting = csv.QUOTE_MINIMAL
        self.skipinitialspace = False
        self.strict = False

def write_temp_file(temp_file, header, lines):
    f = open(temp_file, "w")
    f.write(header)
    f.writelines(lines)
    f.close()

def import_table(root, file_name, temp_file, cur, conn):
    print("%s/%s" % (root, file_name))

    table_name = file_name[:-4]
    if "flightstats_" in file_name:
        table_name = table_name[12:]
    
    f = open(os.path.join(root, file_name))
    header = f.readline()
    i = 0
    
    while True:
        next_lines = list(islice(f, 100000))
        if not next_lines:
            break
        write_temp_file(temp_file, header, next_lines)
        i += 1
        ingest_command = csv_to_postgres.make_postgres_ingest_with_defaults(temp_file, table_name, cur)
        if i==1:
            print(ingest_command)
        print("%s: %d lines processed" % (table_name, (i-1)*100000+len(next_lines)))
        cur.execute(ingest_command)
        conn.commit()

def main():
    import sys
    if len(sys.argv)>1:
        password = sys.argv[1]
        temp_file = sys.argv[2]
        data_path = sys.argv[3]
    else:
        password = "Postgres1234"
        temp_file = "C:\\Users\\Public\\Temp\\temp.csv"
        data_path = os.path.join(os.environ["DataPath"],
                                 "GEFlight",
                                 "Release 2",
                                 "PublicLeaderboardTrainDays",
                                 "2012_12_05")
       
    conn = psycopg2.connect("dbname=geflight user=postgres password=%s" % password)
    cur = conn.cursor()

    paths = [(root, file_name) for root, dirs, files in os.walk(data_path) for file_name in files]

    for root, file_name in [(root, file_name) for root, file_name in paths if file_name=="flighthistory.csv"]:
        import_table(root, file_name, temp_file, cur, conn)

    valid_file_names = ["flightstats_metar_reports.csv",
                        "flightstats_fdwind.csv",
                        "flightstats_fdwindairport.csv",
                        "flightstats_fdwindaltitude.csv",
                        "flightstats_fdwindreport.csv",
                        "flightstats_taf.csv",
                        "flightstats_tafforecast.csv",
                        "flightstats_taficing.csv",
                        "flightstats_tafsky.csv",
                        "flightstats_taftemperature.csv",
                        "flightstats_tafturbulence.csv",
                        "flightstats_metar_presentconditions.csv",
                        "flightstats_metar_runwaygroups.csv",
                        "flightstats_metar_skyconditions.csv",
                        "flightstats_airsigmet.csv",
                        "flightstats_airsigmetarea.csv"]
    
    for root, file_name in [(root, file_name) for root, file_name in paths if file_name in valid_file_names]:
        import_table(root, file_name, temp_file, cur, conn)

    for root, file_name in [(root, file_name) for root, file_name in paths if file_name=="asdiposition.csv"]:
        import_table(root, file_name, temp_file, cur, conn)

if __name__=="__main__":
    main()
