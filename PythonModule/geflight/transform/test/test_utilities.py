#! /usr/bin/env python2.7

import csv
from datetime import datetime, tzinfo
from dateutil.tz import tzoffset, tzutc
from geflight.transform import utilities
import io
import itertools
import os
import unittest

class TestUtilities(unittest.TestCase):

    def test_header_csv_reader(self):
        r = utilities.HeaderCsvReader(io.StringIO(u"a,b,c\n1,2,3\n4,5,6\n"))
        self.assertEqual("2", r.next()["b"])
        self.assertEqual("6", r.next()["c"])
        self.assertEqual(["a", "b", "c"], r.get_header())

        r = utilities.HeaderCsvReader(io.StringIO(u"a,b\r\n1,2\r\ne,ffff"))
        self.assertEqual([{"a":"1", "b":"2"}, {"a":"e", "b":"ffff"}], [x for x in r])

    def test_parse_row(self):
        row = {"a": "ben", "b": "1", "c": 2.5, "name": "Stella"}
        converters = {"b": int, "c": float}
        utilities.parse_row(converters, row)
        self.assertEqual(row["b"], 1)
        self.assertEqual(row["c"], 2.5)

    def test_get_day_boundaries(self):
        self.assertRaises(AssertionError, utilities.get_day_boundaries, datetime(2012, 10, 15, tzinfo=tzoffset(None, 3600)))
        
        start_time, end_time = utilities.get_day_boundaries(datetime(2012, 10, 5, 12, 00, tzinfo=tzutc()), -9)
        self.assertEqual(start_time, datetime(2012, 10, 5, 9, 00, tzinfo=tzutc()))
        self.assertEqual(end_time, datetime(2012, 10, 6, 9, 00, tzinfo=tzutc()))

        start_time, end_time = utilities.get_day_boundaries(datetime(2012, 10, 5, 01, 00, tzinfo=tzutc()), -9)
        self.assertEqual(start_time, datetime(2012, 10, 4, 9, 00, tzinfo=tzutc()))
        self.assertEqual(end_time, datetime(2012, 10, 5, 9, 00, tzinfo=tzutc()))

        start_time, end_time = utilities.get_day_boundaries(datetime(2012, 10, 6, 5, 00, tzinfo=tzutc()), -9)
        self.assertEqual(start_time, datetime(2012, 10, 5, 9, 00, tzinfo=tzutc()))
        self.assertEqual(end_time, datetime(2012, 10, 6, 9, 00, tzinfo=tzutc()))

    def test_get_day_str(self):
        cutoff_time = datetime(2012, 10, 25, 8, 00, tzinfo = tzutc())
        self.assertEqual("2012_10_24", utilities.get_day_str(cutoff_time))

        cutoff_time = datetime(2012, 10, 25, 8, 00, tzinfo = tzutc())
        self.assertEqual("2012_10_25", utilities.get_day_str(cutoff_time, 0))

    def test_get_day_path(self):
        original_path = os.tempnam()
        os.mkdir(original_path)

        cutoff_time = datetime(2012, 10, 25, 8, 00, tzinfo = tzutc())
        day_path = utilities.get_day_path(original_path, cutoff_time, 0)
        self.assertEqual(os.path.join(original_path, "2012_10_25"), day_path)
        self.assertTrue(os.path.exists(day_path))
        os.rmdir(day_path)
        os.rmdir(original_path)

    def test_get_full_output_path(self):
        original_path = os.tempnam()
        os.mkdir(original_path)

        cutoff_time = datetime(2012, 10, 25, 8, 00, tzinfo = tzutc())
        output_path = utilities.get_full_output_path(original_path, "FlightHistory", cutoff_time, 0)
        self.assertEqual(os.path.join(original_path, "2012_10_25", "FlightHistory"), output_path)
        self.assertTrue(os.path.exists(output_path))
        os.rmdir(output_path)
        os.rmdir(os.path.join(original_path, "2012_10_25"))
        os.rmdir(original_path)

    def test_get_output_subdirectory(self):
        original_path = os.tempnam()
        os.mkdir(original_path)

        output_subdir = utilities.get_output_subdirectory(original_path, "FlightHistory")
        self.assertEqual(os.path.join(original_path, "FlightHistory"), output_subdir)
        self.assertTrue(os.path.exists(output_subdir))
        os.rmdir(output_subdir)
        os.rmdir(original_path)

    def split_file_based_on_times_filter_on_ids_streaming(self):
        input_dir = os.tempnam()
        os.mkdir(input_dir)
        input_file = os.path.join(input_dir, "raw.csv")
        data = [(str(x), str(y), z) for x,y,z in zip(range(200010),
            itertools.cycle(range(5)),
            itertools.cycle(["Andrew", "Ben", "Chris", "David", "Anthony"]))]
        f = open(input_file, "w")
        w = csv.writer(f)
        w.writerow(["id1", "id2", "name"])
        w.writerows(data)
        f.close()

        ct1 = datetime(2012, 10, 25, 15, 00, tzinfo = tzutc())
        ct2 = datetime(2012, 10, 26, 15, 00, tzinfo = tzutc()) 

        cutoff_times = [ct1, ct2]
        ids_dict = {x:y for x,y in zip(cutoff_times, [set(["1", "3", "200005"]), set(["2", "100001", "200006"])])}
        output_path = os.tempnam()
        os.mkdir(output_path)
        ids_back = utilities.split_file_based_on_times_filter_on_ids_streaming(
            input_file,
            output_path,
            "MyTestFolder",
            "test_output.csv",
            "id1",
            ids_dict,
            ids_to_track_column_name = "id2",
            start_hours_offset = -9)
        self.assertEqual(set(["1", "3", "0"]), ids_back[ct1])
        self.assertEqual(set(["2", "1", "1"]), ids_back[ct2])

        f1path = os.path.join(output_path, "2012_10_25", "MyTestFolder", "test_output.csv")
        f2path = os.path.join(output_path, "2012_10_26", "MyTestFolder", "test_output.csv")

        f1 = open(f1path)
        f2 = open(f2path)

        f1data = [x for x in csv.reader(f1)]
        f2data = [x for x in csv.reader(f2)]

        self.assertEqual([["id1", "id2", "name"],
                          ["1", "1", "Ben"], 
                          ["3", "3", "David"],
                          ["200005", "0", "Andrew"]], f1data)

        self.assertEqual([["id1", "id2", "name"],
                          ["2", "2", "Chris"], 
                          ["100001", "1", "Ben"],
                          ["200006", "1", "Ben"]], f2data)

        # Clean up
        f1.close()
        f2.close()

        os.remove(f1path)
        os.remove(f2path)
        os.remove(input_file)
        for x in [os.path.join(output_path, "2012_10_25", "MyTestFolder"),
                  os.path.join(output_path, "2012_10_26", "MyTestFolder"),
                  os.path.join(output_path, "2012_10_25"),
                  os.path.join(output_path, "2012_10_26"),
                  output_path, input_dir]:
            os.rmdir(x)

    def test_filter_file_based_on_cutoff_time_streaming(self):
        start_path = os.tempnam()
        os.mkdir(start_path)
        input_path = os.path.join(start_path, "input.csv")
        f = open(input_path, "w")
        f.write("".join(["id,name,time\n",
            "1,Ben,2012-11-12 01:00:03+00\n",
            "2,David,2012-11-12 05:00:03+00\n",
            "3,Andrew,2012-11-12 10:00:03+00"]))
        f.close()

        output_path = os.path.join(start_path, "output.csv")
        ids = utilities.filter_file_based_on_cutoff_time_streaming(
            input_path = input_path,
            output_path = output_path,
            date_column_name = "time",
            date_parser = utilities.parse_datetime_format1,
            cutoff_time = datetime(2012, 11, 12, 8, 00, tzinfo=tzutc()),
            ids_to_track_column_name = "id")
        
        expected_data = "".join(["id,name,time\n",
            "1,Ben,2012-11-12 01:00:03+00:00\n",
            "2,David,2012-11-12 05:00:03+00:00\n"])
        
        f = open(output_path)
        actual_data = f.read()
        f.close()
        self.assertEqual(actual_data, expected_data)
        self.assertEqual(ids, set(["1","2"]))

        ids = utilities.filter_file_based_on_cutoff_time_streaming(
            input_path = input_path,
            output_path = output_path,
            date_column_name = "time",
            date_parser = utilities.parse_datetime_format1,
            cutoff_time = datetime(2012, 11, 12, 5, 0, 3, tzinfo=tzutc()))

        f = open(output_path)
        actual_data = f.read()
        f.close()
        self.assertEqual(actual_data, expected_data)
        self.assertIsNone(ids)

        os.remove(input_path)
        os.remove(output_path)
        os.rmdir(start_path)

    def test_filter_file_based_on_ids_streaming(self):
        start_path = os.tempnam()
        os.mkdir(start_path)
        input_path = os.path.join(start_path, "input.csv")
        f = open(input_path, "w")
        f.write("".join(["id,name,time\n",
            "1,Ben,2012-11-12 01:00:03+00\n",
            "2,David,2012-11-12 05:00:03+00\n",
            "3,Andrew,2012-11-12 10:00:03+00"]))
        f.close()

        output_path = os.path.join(start_path, "output.csv")
        utilities.filter_file_based_on_ids_streaming(
            input_path = input_path,
            output_path = output_path,
            id_column_name = "id",
            valid_ids = set(["1","2"]))
        
        expected_data = "".join(["id,name,time\n",
            "1,Ben,2012-11-12 01:00:03+00\n",
            "2,David,2012-11-12 05:00:03+00\n"])
        
        f = open(output_path)
        actual_data = f.read()
        f.close()
        self.assertEqual(actual_data, expected_data)

        os.remove(input_path)
        os.remove(output_path)
        os.rmdir(start_path)

    def test_parse_datetime_format1(self):
        self.assertEqual(utilities.parse_datetime_format1("2012-11-12 01:00:03-08"),
                         datetime(2012, 11, 12, 9, 0, 3, tzinfo=tzutc()))
        
        self.assertEqual(utilities.parse_datetime_format1("2012-12-12 23:00:03-05"),
                         datetime(2012, 12, 13, 4, 0, 3, tzinfo=tzutc()))

        self.assertEqual(utilities.parse_datetime_format1("2012-12-12 23:00:03-00"),
                         datetime(2012, 12, 12, 23, 0, 3, tzinfo=tzutc()))

    def test_parse_datetime_format2(self):
        self.assertEqual(utilities.parse_datetime_format2("2012-11-12 01:00:03"),
                         datetime(2012, 11, 12, 1, 0, 3, tzinfo=tzutc()))
        
        self.assertEqual(utilities.parse_datetime_format2("2012-12-12 23:00:03"),
                         datetime(2012, 12, 12, 23, 0, 3, tzinfo=tzutc()))

        self.assertEqual(utilities.parse_datetime_format2("2013-01-08 11:15:32"),
                         datetime(2013, 1, 8, 11, 15, 32, tzinfo=tzutc()))

    def test_parse_datetime_format3(self):
        self.assertEqual(utilities.parse_datetime_format3("2012-11-12 01:00:03-08"),
                         datetime(2012, 11, 12, 9, 0, 3, tzinfo=tzutc()))
        
        self.assertEqual(utilities.parse_datetime_format3("2012-12-12 23:00:03.23-05"),
                         datetime(2012, 12, 13, 4, 0, 3, 230000, tzinfo=tzutc()))

        self.assertEqual(utilities.parse_datetime_format3("2013-01-08 11:15:32.1234+00"),
                         datetime(2013, 1, 8, 11, 15, 32, 123400, tzinfo=tzutc()))

    def test_parse_datetime_format4(self):
        self.assertEqual(utilities.parse_datetime_format4("2012-11-12 01:00:03", -8),
                         datetime(2012, 11, 12, 9, 0, 3, tzinfo=tzutc()))
        
        self.assertEqual(utilities.parse_datetime_format4("2012-12-12 23:00:03", -5),
                         datetime(2012, 12, 13, 4, 0, 3, tzinfo=tzutc()))

        self.assertEqual(utilities.parse_datetime_format4("2012-12-12 23:00:03", 0),
                         datetime(2012, 12, 12, 23, 0, 3, tzinfo=tzutc()))

    def test_parse_datetime_format5(self):
        self.assertEqual(utilities.parse_datetime_format5("2012-11-12 01:00", -8),
                         datetime(2012, 11, 12, 9, 0, 0, tzinfo=tzutc()))
        
        self.assertEqual(utilities.parse_datetime_format5("2012-12-12 23:00", -5),
                         datetime(2012, 12, 13, 4, 0, 0, tzinfo=tzutc()))

        self.assertEqual(utilities.parse_datetime_format5("2012-12-12 23:00", 0),
                         datetime(2012, 12, 12, 23, 0, 0, tzinfo=tzutc()))

    def test_parse_datetime_format6(self):
        self.assertEqual(utilities.parse_datetime_format6("2012-11-12 01:00:03-08:00"),
                         datetime(2012, 11, 12, 9, 0, 3, tzinfo=tzutc()))
        
        self.assertEqual(utilities.parse_datetime_format6("2012-12-12 23:00:03.23-05:00"),
                         datetime(2012, 12, 13, 4, 0, 3, 230000, tzinfo=tzutc()))

        self.assertEqual(utilities.parse_datetime_format6("2013-01-08 11:15:32.1234+00:00"),
                         datetime(2013, 1, 8, 11, 15, 32, 123400, tzinfo=tzutc()))

    def test_minutes_difference(self):
        dt1 = datetime(2012, 10, 12, tzinfo=tzutc())
        dt2 = datetime(2012, 10, 12, 1, tzinfo=tzutc())
        self.assertEqual(utilities.minutes_difference(dt2, dt1), 60)

        dt3 = datetime(2012, 10, 13, 0, tzinfo=tzutc())
        self.assertEqual(utilities.minutes_difference(dt3, dt1), 24*60)

        dt4 = datetime(2012, 10, 13, 0, 1, tzinfo=tzutc())
        self.assertEqual(utilities.minutes_difference(dt4, dt1), 24*60+1)

if __name__ == '__main__':
    unittest.main()
