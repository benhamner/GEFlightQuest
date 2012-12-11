import numpy as np
import pandas as pd
import parser
from dateutil import parser
import datetime

def summarize_date_field(df, date_field):
	dates = (map(parse_date_with_missing, df[date_field]))
	print "Date field %s has: \n  %d missing, \n  %d hidden, \n  %s earliest date, \n  %s latest date" % (
		date_field,
		len([d for d in dates if d=='MISSING']),
		len([d for d in dates if d=='HIDDEN']),
		min([d for d in dates if type(d) == datetime.datetime]),
		max([d for d in dates if type(d) == datetime.datetime]),
		)

def parse_date_with_missing(date_string):
	if date_string in ['MISSING', 'HIDDEN']:
		return date_string
	else:
		return parser.parse(date_string)


