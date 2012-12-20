from geflight.benchmark import process_test_set_scaffold

def process_day(day):
    for i in day.df_predictions.index:
        day.df_predictions["actual_runway_arrival"] = day.cutoff_time
        day.df_predictions["actual_gate_arrival"] = day.cutoff_time

    return day.df_predictions

if __name__=="__main__":
    process_test_set_scaffold.process_test_set(process_day, 
        "cutoff_benchmark.csv")