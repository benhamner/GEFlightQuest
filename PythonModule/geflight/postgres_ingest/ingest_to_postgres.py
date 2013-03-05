import csv
from csvjazz import csv_to_postgres
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

def replace_missing(row):
    for i, el in enumerate(row):
        if el=="MISSING":
            row[i]=""

def create_temp_file(original_folder, original_file, temp_file):
    converters = {"flighthistory.csv": replace_missing}

    reader = csv.reader(open(os.path.join(original_folder, original_file)))
    f_out = open(temp_file, "w")
    writer = csv.writer(f_out, dialect=CsvDialect())
    writer.writerow(reader.next())

    for row in reader:
        if original_file in converters:
            converters[original_file](row)
        writer.writerow(row)
    f_out.close()

def main():
    conn = psycopg2.connect("dbname=geflight user=postgres password=Postgres1234")
    cur = conn.cursor()

    temp_file = "C:\\Users\\Public\\Temp\\temp.csv"
    data_path = os.path.join(os.environ["DataPath"],
                             "GEFlight",
                             "Release 2",
                             "PublicLeaderboardTrainDays",
                             "2012_12_05")

    for root, dirs, files in os.walk(data_path):
        if "atscc" in root: continue
        for file_name in files:
            if not file_name.endswith(".csv"): continue
            create_temp_file(root, file_name, temp_file)
            table_name = file_name[:-4]

            ingest_command = csv_to_postgres.make_postgres_ingest(temp_file, table_name)
            cur.execute(ingest_command)
            conn.commit()

if __name__=="__main__":
    main()