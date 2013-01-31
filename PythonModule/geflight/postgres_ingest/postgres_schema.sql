CREATE TABLE asdiairway (
    asdiflightplanid BIGINT,
    ordinal BIGINT,
    airway CHARACTER VARYING);

CREATE TABLE asdiflightplan (
    asdiflightplanid BIGINT,
    updatetimeutc TIMESTAMP WITH TIME ZONE,
    flighthistoryid BIGINT,
    departureairport CHARACTER VARYING,
    arrivalairport CHARACTER VARYING,
    aircraftid CHARACTER VARYING,
    legacyroute CHARACTER VARYING,
    originaldepartureutc TIMESTAMP WITH TIME ZONE,
    estimateddepartureutc TIMESTAMP WITH TIME ZONE,
    originalarrivalutc TIMESTAMP WITH TIME ZONE,
    estimatedarrivalutc TIMESTAMP WITH TIME ZONE);

CREATE TABLE asdifpcenter (
    asdiflightplanid BIGINT,
    ordinal BIGINT,
    center CHARACTER VARYING);

CREATE TABLE asdifpfix (
    asdiflightplanid BIGINT,
    ordinal BIGINT,
    fix CHARACTER VARYING);

CREATE TABLE asdifpsector (
    asdiflightplanid BIGINT,
    ordinal BIGINT,
    sector CHARACTER VARYING);

CREATE TABLE asdifpwaypoint (
    asdiflightplanid BIGINT,
    ordinal BIGINT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION);

CREATE TABLE asdiposition (
    received TIMESTAMP WITH TIME ZONE,
    callsign CHARACTER VARYING,
    altitude BIGINT,
    groundspeed BIGINT,
    latitudedegrees DOUBLE PRECISION,
    longitudedegrees DOUBLE PRECISION,
    flighthistoryid BIGINT);

CREATE TABLE flighthistory (
    flight_history_id BIGINT,
    airline_code CHARACTER VARYING,
    airline_icao_code CHARACTER VARYING,
    flight_number BIGINT,
    departure_airport_code CHARACTER VARYING,
    departure_airport_icao_code CHARACTER VARYING,
    arrival_airport_code CHARACTER VARYING,
    arrival_airport_icao_code CHARACTER VARYING,
    published_departure CHARACTER VARYING,
    published_arrival CHARACTER VARYING,
    scheduled_gate_departure CHARACTER VARYING,
    actual_gate_departure CHARACTER VARYING,
    scheduled_gate_arrival CHARACTER VARYING,
    actual_gate_arrival CHARACTER VARYING,
    scheduled_runway_departure TIMESTAMP WITH TIME ZONE,
    actual_runway_departure CHARACTER VARYING,
    scheduled_runway_arrival TIMESTAMP WITH TIME ZONE,
    actual_runway_arrival CHARACTER VARYING,
    creator_code CHARACTER VARYING,
    scheduled_air_time BIGINT,
    scheduled_block_time CHARACTER VARYING,
    departure_airport_timezone_offset BIGINT,
    arrival_airport_timezone_offset BIGINT,
    scheduled_aircraft_type CHARACTER VARYING,
    actual_aircraft_type CHARACTER VARYING,
    icao_aircraft_type_actual CHARACTER VARYING);

CREATE TABLE flighthistoryevents (
    flight_history_id BIGINT,
    date_time_recorded TIMESTAMP WITH TIME ZONE,
    event CHARACTER VARYING,
    data_updated CHARACTER VARYING);

CREATE TABLE flightstats_metarpresentconditions_combined (
    id BIGINT,
    metar_reports_id BIGINT,
    present_condition CHARACTER VARYING);

CREATE TABLE flightstats_metarreports_combined (
    metar_reports_id BIGINT,
    weather_station_code CHARACTER VARYING,
    date_time_issued TIMESTAMP WITH TIME ZONE,
    report_modifier CHARACTER VARYING,
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