from geflight.summarize import utilities as s_utilities

def summarize_day(base_day_path, test_day_path=None):
    summarize_flight_history_day(base_day_path, test_day_path)
    summarize_asdi_day(base_day_path, test_day_path)
    summarize_atscc_day(base_day_path, test_day_path)
    summarize_metar_day(base_day_path, test_day_path)
    summarize_otherweather_day(base_day_path, test_day_path)

if __name__=="__main__":
    pass