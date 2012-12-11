import csv
from dateutil import tz
from dateutil.parser import parse

def get_min_max_field(file_path, column_number):
    reader = csv.reader(open(file_path))

    #ignore header
    reader.next()

    row = reader.next()
    min_val = parse(row[column_number])
    max_val = parse(row[column_number])

    for row in reader:
    	if not row[column_number]:
    		continue
    	min_val = min(min_val, parse(row[column_number]))
    	max_val = max(max_val, parse(row[column_number]))

    print(min_val.astimezone(tz.tzutc()))
    print(max_val.astimezone(tz.tzutc()))

if __name__=="__main__":
    import sys
    
    file_path = sys.argv[1]
    column_number = int(sys.argv[2])

    get_min_max_field(file_path, column_number)