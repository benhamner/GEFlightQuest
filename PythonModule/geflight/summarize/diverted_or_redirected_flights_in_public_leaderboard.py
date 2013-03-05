import csv
import os
import pandas as pd 

flight_path = os.path.join(os.environ["DataPath"], "GEFlight")
public_solution_path = os.path.join(flight_path, "Release 6", "FinalEvaluationSolution", "solution_combined.csv")
raw_public_leaderboard_flight_history_path = os.path.join(flight_path, "RawFinalEvaluationSet", "FlightHistory")
flight_history_path = os.path.join(raw_public_leaderboard_flight_history_path, "flighthistory.csv")
flight_history_events_path = os.path.join(raw_public_leaderboard_flight_history_path, "flighthistoryevents.csv")
redirected_or_diverted_flights_solution_path = os.path.join(flight_path, "Release 6", "redirected_or_diverted_flights_solution.csv")

df_public_solution = pd.read_csv(public_solution_path)

flight_ids_in_public_leaderboard = set(df_public_solution["flight_history_id"])

print(len(flight_ids_in_public_leaderboard))

df_flight_history = pd.read_csv(flight_history_path)

diverted_flight_ids = set(df_flight_history[[type(code)==str for code in df_flight_history["diverted_airport_icao_code"]]]["flight_history_id"])

print(len(diverted_flight_ids))
print(flight_ids_in_public_leaderboard.intersection(diverted_flight_ids))

diverted_flight_ids = set()
redirected_flight_ids = set()

reader = csv.reader(open(flight_history_events_path))
reader.next()

for row in reader:
    if "STATUS-Diverted" in row[2]:
        diverted_flight_ids.add(int(row[0]))
    if "STATUS-Redirected" in row[2]:
        redirected_flight_ids.add(int(row[0]))

print("Number diverted flights: %d" % len(diverted_flight_ids))
print("Number redirected flights: %d" % len(redirected_flight_ids))

diverted_or_redirected_flight_ids = diverted_flight_ids.union(redirected_flight_ids)

print("Number diverted or redirected flights: %d" % len(diverted_or_redirected_flight_ids))

bad_flights_in_public_leaderboard = flight_ids_in_public_leaderboard.intersection(diverted_or_redirected_flight_ids)
print("Number diverted or redirected flights in public leaderboard: %d" % len(bad_flights_in_public_leaderboard))
print(bad_flights_in_public_leaderboard)

df_bad_flights_solution = df_public_solution[[x in bad_flights_in_public_leaderboard for x in df_public_solution["flight_history_id"]]]
df_bad_flights_solution.to_csv(redirected_or_diverted_flights_solution_path, index=False)

print(bad_flights_in_public_leaderboard)