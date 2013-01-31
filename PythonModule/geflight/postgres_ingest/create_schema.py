from csvjazz import csv_to_postgres
import os

def main():
    data_path = os.path.join(os.environ["DataPath"],
                             "GEFlight",
                             "Release 1",
                             "InitialTrainingSet_rev1",
                             "2012_11_12")

    schema = []

    for root, dirs, files in os.walk(data_path):
        if "atscc" in root: continue
        for file_name in files:
            if not file_name.endswith(".csv"):
                continue
            csv_path = os.path.join(root, file_name)
            schema.append(csv_to_postgres.make_postgres_schema(csv_path, file_name[:-4]))

    f = open("postgres_schema.sql", "w")
    f.write("\n\n".join(schema))

if __name__=="__main__":
    main()