
from geflight.benchmark import utilities as bu
from geflight.benchmark import process_test_set_scaffold

def process_day(day):
    for i, row in day.df_test_flight_history.iterrows():
        day.df_predictions["actual_runway_arrival"][i] = bu.get_scheduled_arrival(row, "runway", day.cutoff_time)
        day.df_predictions["actual_gate_arrival"][i] = bu.get_scheduled_arrival(row, "gate", day.cutoff_time)

    return day.df_predictions

if __name__=="__main__":
    process_test_set_scaffold.process_test_set(process_day, 
        "scheduled_arrival_benchmark.csv")
