import csv
from geflight.transform import flighthistory
from geflight.transform import utilities
import gzip
import os
import pandas as pd

def get_us_airport_icao_codes(codes_file):
    df = pd.read_csv(codes_file)
    return set(df["icao_code"])

def is_flight_in_or_out_of_us(row, us_icao_codes):
    if ((row["arrival_airport_icao_code"] not in us_icao_codes) or
        (row["departure_airport_icao_code"] not in us_icao_codes)):
        return False
    return True

def filter_flight_history(input_path, output_path):
    codes_file = os.path.join(os.environ["DataPath"], "GEFlight", "Reference", "usairporticaocodes.txt")
    us_icao_codes = get_us_airport_icao_codes(codes_file)

    reader = utilities.HeaderCsvReader(gzip.open(input_path, 'rb'))
    out_handle = gzip.open(output_path, 'wb')
    writer = csv.writer(out_handle, dialect=utilities.CsvDialect())

    header_out = reader.get_header()
    for col in flighthistory.get_flight_history_columns_to_delete():
        header_out.remove(col)
    writer.writerow(header_out)

    row_buffer = []
    flight_history_ids = set()
    i_row_mod = 0
    cnt = 0
    i = 0

    for row in reader:
        i_row_mod += 1
        if not is_flight_in_or_out_of_us(row, us_icao_codes):
            continue
        cnt += 1

        row_buffer.append([row[col] for col in header_out])

        flight_history_ids.add(row["flight_history_id"])

        if i_row_mod < 100000:
            continue

        i += 1
        print("%s: %d00k records processed, %d with relevant flights in this chunk" % ("flighthistory", i, cnt))
        cnt = 0
        i_row_mod = 0

        writer.writerows(row_buffer)
        out_handle.flush()
        row_buffer = []

    out_handle.close()
    return flight_history_ids

def get_input_path(input_dir, table):
	return os.path.join(input_dir, "flightstats_%s.csv.gz" % table)

def get_output_path(output_dir, table):
	return os.path.join(output_dir, "%s.csv.gz" % table)

def filter_file_based_on_ids_streaming(
    input_dir,
    output_dir,
    table,
    id_column_name,
    valid_ids):
    """
    Takes in one file, outputs one file
    """

    input_path = get_input_path(input_dir, table)
    output_path = get_output_path(output_dir, table)

    f_in = gzip.open(input_path, "rb")
    reader = utilities.HeaderCsvReader(f_in)
    f_out = gzip.open(output_path, "wb")
    writer = csv.writer(f_out, dialect=utilities.CsvDialect())
    writer.writerow(reader.header)

    i_total = 0
    i_keep = 0

    for row in reader:
        i_total += 1
        if row[id_column_name] not in valid_ids:
            continue
        i_keep += 1
        writer.writerow([row[col_name] for col_name in reader.header])
        if i_total % 100000 == 0:
        	print("%s, %d00k lines processed, %d00k lines kept" % (table, int(i_total/1000), int(i_keep/1000)))
  
    remainder, file_name = os.path.split(input_path)
    day_str = os.path.split(remainder)[1]
    print("%s, %s: %d lines remaining out of %d original lines" % (day_str, file_name, i_keep, i_total))

    f_out.close()

def main(input_dir, output_dir):
	tables = [ "asdiposition"
	         , "flighthistory"
	         ]

	flight_history_ids = filter_flight_history(get_input_path(input_dir, "flighthistory"), get_output_path(output_dir, "flighthistory"))
	filter_file_based_on_ids_streaming(input_dir, output_dir, "asdiposition", "flighthistoryid", flight_history_ids)

if __name__=="__main__":
	input_dir  = os.path.join(os.environ["DataPath"], "GEFlight2", "DataSet1", "Raw")
	output_dir = os.path.join(os.environ["DataPath"], "GEFlight2", "DataSet1", "Filtered")
	main(input_dir, output_dir)