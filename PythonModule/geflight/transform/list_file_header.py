import csv
import os
import sys

def print_csv_header(file_path):
    reader = csv.reader(open(file_path))
    header = reader.next()
    for col in header:
        print(" - **%s**: " % col)

if __name__=="__main__":
    print_csv_header(sys.argv[1])