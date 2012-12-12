README
------

## combining_metar.py

Each type of METAR file came to us split into two files. For your convenience, they are combined into one. This script flips the sign of the ID on one type of file, to avoid ID collisions.

## create_cutoffs_csv.py

This top-level script calls functions in weather.py and create_sample_test_set.py. It transforms original data into training data (split by day), and the call to create_sample_test_set.py (badly styled as an import statement at the end) creates test data from there.

## create_sample_test_set.py

This script creates test data from training data. The actual test data (both public leaderboard and final) will be created by a similar process).

## determine_test_set_cutoffs.py

This script creates random cutoff times for the (sample) test set, outputting them to a CSV. The cutoff times for the real test sets will be created similarly.

## weather.py

The functions in this file do most of the work. They split the original files by day, remove certain columns that could cause leakage or would be useless. These functions are also used in turning training-type data into test-type data and filter rows and some individual values ("fields to blank") by the appropriate cutoff time.