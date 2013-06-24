CREATE TABLE flightstats_metarpresentconditions_combined (
    id                BIGINT PRIMARY KEY,
    metar_reports_id  BIGINT,
    present_condition CHARACTER VARYING);

CREATE TABLE flightstats_metarreports_combined (
    id                   BIGINT,
    weather_station_code CHARACTER VARYING,
    date_time_issued     TIMESTAMP WITH TIME ZONE,
    report_modifier      CHARACTER VARYING,
    is_wind_direction_variable CHARACTER VARYING,
    wind_direction DOUBLE PRECISION,
    wind_speed DOUBLE PRECISION,
    wind_gusts CHARACTER VARYING,
    variable_wind_direction CHARACTER VARYING,
    is_visibility_less_than CHARACTER VARYING,
    visibility DOUBLE PRECISION,
    temperature DOUBLE PRECISION,
    dewpoint DOUBLE PRECISION,
    altimeter DOUBLE PRECISION,
    remark CHARACTER VARYING,
    original_report CHARACTER VARYING,
    station_type CHARACTER VARYING,
    sea_level_pressure CHARACTER VARYING);

CREATE TABLE flightstats_metarrunwaygroups_combined (
    approach_direction CHARACTER VARYING,
    id DOUBLE PRECISION,
    is_varying CHARACTER VARYING,
    max_prefix CHARACTER VARYING,
    max_visible DOUBLE PRECISION,
    metar_reports_id DOUBLE PRECISION,
    min_prefix CHARACTER VARYING,
    min_visible DOUBLE PRECISION,
    runway DOUBLE PRECISION);

CREATE TABLE flightstats_metarskyconditions_combined (
    id BIGINT,
    metar_reports_id BIGINT,
    sky_condition CHARACTER VARYING);
