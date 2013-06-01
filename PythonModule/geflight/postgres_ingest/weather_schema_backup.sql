# This file contains the SQL to create the weather tables (currently unused)

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

CREATE TABLE flightstats_airsigmet (
    airsigmetid BIGINT,
    timevalidfromutc TIMESTAMP WITH TIME ZONE,
    timevalidtoutc TIMESTAMP WITH TIME ZONE,
    movementdirdegrees CHARACTER VARYING,
    movementspeedknots CHARACTER VARYING,
    hazardtype CHARACTER VARYING,
    hazardseverity CHARACTER VARYING,
    airsigmettype CHARACTER VARYING,
    altitudeminft DOUBLE PRECISION,
    altitudemaxft DOUBLE PRECISION,
    rawtext CHARACTER VARYING);

CREATE TABLE flightstats_airsigmetarea (
    airsigmetid BIGINT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    ordinal BIGINT);

CREATE TABLE flightstats_fbwind (
    fbwindairportid BIGINT,
    ordinal BIGINT,
    bearing BIGINT,
    knots BIGINT,
    temperature CHARACTER VARYING);

CREATE TABLE flightstats_fbwindairport (
    fbwindairportid BIGINT,
    fbwindreportid BIGINT,
    airportcode CHARACTER VARYING);

CREATE TABLE flightstats_fbwindaltitude (
    fbwindreportid BIGINT,
    ordinal BIGINT,
    altitude BIGINT);

CREATE TABLE flightstats_fbwindreport (
    fbwindreportid BIGINT,
    createdutc TIMESTAMP WITH TIME ZONE,
    reporttype1 CHARACTER VARYING,
    reporttype2 CHARACTER VARYING,
    reporttype3 CHARACTER VARYING,
    generated BIGINT,
    basedon CHARACTER VARYING,
    valid CHARACTER VARYING,
    forusestart BIGINT,
    foruseend BIGINT,
    negativeabove BIGINT,
    altitudescale CHARACTER VARYING,
    altitudeunits CHARACTER VARYING);

CREATE TABLE flightstats_taf (
    tafid BIGINT,
    station CHARACTER VARYING,
    airport CHARACTER VARYING,
    rawtext CHARACTER VARYING,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    elevationmeters BIGINT,
    remarks CHARACTER VARYING,
    bulletintimeutc TIMESTAMP WITH TIME ZONE,
    issuetimeutc TIMESTAMP WITH TIME ZONE,
    validtimefromutc TIMESTAMP WITH TIME ZONE,
    validtimetoutc TIMESTAMP WITH TIME ZONE);

CREATE TABLE flightstats_tafforecast (
    tafforecastid BIGINT,
    tafid BIGINT,
    altimiter CHARACTER VARYING,
    changeindicator CHARACTER VARYING,
    forecasttimefromutc TIMESTAMP WITH TIME ZONE,
    forecasttimetoutc TIMESTAMP WITH TIME ZONE,
    probability CHARACTER VARYING,
    timebecomingutc CHARACTER VARYING,
    verticalvisibility CHARACTER VARYING,
    visibilitystatutemiles DOUBLE PRECISION,
    windspeedknots DOUBLE PRECISION,
    winddirectiondegrees DOUBLE PRECISION,
    windgustspeedknots DOUBLE PRECISION,
    windsheardirectiondegrees CHARACTER VARYING,
    windshearheightfeet CHARACTER VARYING,
    windshearspeedknots CHARACTER VARYING,
    weatherstring CHARACTER VARYING,
    notdecoded CHARACTER VARYING);

CREATE TABLE flightstats_taficing (
    tafforecastid BIGINT,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet CHARACTER VARYING,
    maximumaltitudefeet DOUBLE PRECISION);

CREATE TABLE flightstats_tafsky (
    tafforecastid BIGINT,
    cloudbasefeet DOUBLE PRECISION,
    cloudtype CHARACTER VARYING,
    cloudcover CHARACTER VARYING);

CREATE TABLE flightstats_taftemperature (
    tafforecastid BIGINT,
    validtimeutc TIMESTAMP WITH TIME ZONE,
    mintemperaturecelcius CHARACTER VARYING,
    maxtemperaturecelcius DOUBLE PRECISION,
    surfacetemperaturecelcius CHARACTER VARYING);

CREATE TABLE flightstats_tafturbulence (
    tafforecastid BIGINT,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet DOUBLE PRECISION,
    maximumaltitudefeet DOUBLE PRECISION);