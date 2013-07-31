CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;

CREATE TABLE flighthistory (
    id                                BIGINT PRIMARY KEY,
    airline_code                      CHARACTER VARYING,
    airline_icao_code                 CHARACTER VARYING,
    flight_number                     BIGINT,
    departure_airport_code            CHARACTER VARYING,
    departure_airport_icao_code       CHARACTER VARYING,
    arrival_airport_code              CHARACTER VARYING,
    arrival_airport_icao_code         CHARACTER VARYING,
    published_departure               TIMESTAMP WITH TIME ZONE,
    published_arrival                 TIMESTAMP WITH TIME ZONE,
    scheduled_gate_departure          TIMESTAMP WITH TIME ZONE,
    actual_gate_departure             TIMESTAMP WITH TIME ZONE,
    scheduled_gate_arrival            TIMESTAMP WITH TIME ZONE,
    actual_gate_arrival               TIMESTAMP WITH TIME ZONE,
    scheduled_runway_departure        TIMESTAMP WITH TIME ZONE,
    actual_runway_departure           TIMESTAMP WITH TIME ZONE,
    scheduled_runway_arrival          TIMESTAMP WITH TIME ZONE,
    actual_runway_arrival             TIMESTAMP WITH TIME ZONE,
    creator_code                      CHARACTER VARYING,
    scheduled_air_time                BIGINT,
    scheduled_block_time              CHARACTER VARYING,
    departure_airport_timezone_offset BIGINT,
    arrival_airport_timezone_offset   BIGINT,
    scheduled_aircraft_type           CHARACTER VARYING,
    actual_aircraft_type              CHARACTER VARYING,
    icao_aircraft_type_actual         CHARACTER VARYING);
CREATE INDEX ON flighthistory (departure_airport_icao_code);
CREATE INDEX ON flighthistory (arrival_airport_icao_code);
CREATE INDEX ON flighthistory (actual_runway_departure);
CREATE INDEX ON flighthistory (actual_runway_arrival);

CREATE TABLE flighthistoryevents (
    id                 BIGSERIAL PRIMARY KEY,
    flighthistory_id   BIGINT REFERENCES flighthistory(id),
    date_time_recorded TIMESTAMP WITH TIME ZONE,
    event              CHARACTER VARYING,
    data_updated       CHARACTER VARYING);
CREATE INDEX ON flighthistoryevents (flighthistory_id);
CREATE INDEX ON flighthistoryevents (date_time_recorded);

CREATE TABLE asdiflightplan (
    id                      BIGINT PRIMARY KEY,
    update_time_utc         TIMESTAMP WITH TIME ZONE,
    flighthistory_id        BIGINT NOT NULL REFERENCES flighthistory(id),
    departure_airport       CHARACTER VARYING,
    arrival_airport         CHARACTER VARYING,
    aircraft_id             CHARACTER VARYING,
    legacy_route            CHARACTER VARYING,
    original_departure_utc  TIMESTAMP WITH TIME ZONE,
    estimated_departure_utc TIMESTAMP WITH TIME ZONE,
    original_arrival_utc    TIMESTAMP WITH TIME ZONE,
    estimated_arrival_utc   TIMESTAMP WITH TIME ZONE);
CREATE INDEX ON asdiflightplan (flighthistory_id);

CREATE TABLE asdiairway (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT NOT NULL REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    airway            CHARACTER VARYING);
CREATE INDEX ON asdiairway (asdiflightplan_id);

CREATE TABLE asdifpcenter (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT NOT NULL REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    center            CHARACTER VARYING);
CREATE INDEX ON asdifpcenter (asdiflightplan_id);

CREATE TABLE asdifpfix (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT NOT NULL REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    fix               CHARACTER VARYING);
CREATE INDEX ON asdifpfix (asdiflightplan_id);

CREATE TABLE asdifpsector (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT NOT NULL REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    sector            CHARACTER VARYING);
CREATE INDEX ON asdifpsector (asdiflightplan_id);

CREATE TABLE asdifpwaypoint (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT NOT NULL REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    latitude          DOUBLE PRECISION,
    longitude         DOUBLE PRECISION);
CREATE INDEX ON asdifpwaypoint (asdiflightplan_id);

CREATE TABLE asdiposition (
    id                BIGSERIAL PRIMARY KEY,
    received          TIMESTAMP WITH TIME ZONE,
    callsign          CHARACTER VARYING,
    altitude          BIGINT,
    ground_speed      BIGINT,
    latitude_degrees  DOUBLE PRECISION,
    longitude_degrees DOUBLE PRECISION,
    flighthistory_id  BIGINT NOT NULL REFERENCES flighthistory(id));
CREATE INDEX ON asdiposition (flighthistory_id);

CREATE TABLE metar_presentconditions (
    id                BIGINT PRIMARY KEY,
    metar_reports_id  BIGINT,
    present_condition CHARACTER VARYING);

CREATE TABLE metarreports (
    id                   BIGINT PRIMAY KEY,
    weather_station_code CHARACTER VARYING,
    date_time_issued     TIMESTAMP WITH TIME ZONE,
    report_modifier      CHARACTER VARYING,
    is_wind_direction_variable CHARACTER VARYING,
    wind_direction DOUBLE PRECISION,
    wind_speed DOUBLE PRECISION,
    wind_gusts DOUBLE PRECISION,
    variable_wind_direction CHARACTER VARYING,
    is_visibility_less_than CHARACTER VARYING,
    visibility DOUBLE PRECISION,
    temperature DOUBLE PRECISION,
    dewpoint DOUBLE PRECISION,
    altimeter DOUBLE PRECISION,
    remark CHARACTER VARYING,
    original_report CHARACTER VARYING,
    station_type CHARACTER VARYING,
    sea_level_pressure DOUBLE PRECISION);

CREATE TABLE metar_runwaygroups (
    approach_direction CHARACTER VARYING,
    id DOUBLE PRECISION,
    is_varying CHARACTER VARYING,
    max_prefix CHARACTER VARYING,
    max_visible DOUBLE PRECISION,
    metar_reports_id BIGINT,
    min_prefix CHARACTER VARYING,
    min_visible DOUBLE PRECISION,
    runway DOUBLE PRECISION);

CREATE TABLE metar_skyconditions (
    id BIGINT,
    metar_reports_id BIGINT PRIMARY KEY,
    sky_condition CHARACTER VARYING);

CREATE TABLE airsigmet (
    airsigmetid BIGINT PRIMARY KEY,
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

CREATE TABLE airsigmetarea (
    airsigmetid BIGINT PRIMARY KEY,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    ordinal BIGINT);

CREATE TABLE fbwind (
    fbwindairportid BIGINT PRIMARY KEY,
    ordinal BIGINT,
    bearing BIGINT,
    knots BIGINT,
    temperature CHARACTER VARYING);

CREATE TABLE fdwindairport (
    fbwindairportid BIGINT PRIMARY KEY,
    fbwindreportid BIGINT,
    airportcode CHARACTER VARYING);

CREATE TABLE fdwindaltitude (
    fbwindreportid BIGINT PRIMARY KEY,
    ordinal BIGINT,
    altitude BIGINT);

CREATE TABLE fdwindreport (
    fbwindreportid BIGINT PRIMARY KEY,
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

CREATE TABLE taf (
    tafid BIGINT PRIMARY KEY,
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

CREATE TABLE tafforecast (
    tafforecastid BIGINT PRIMARY KEY,
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
    windsheardirectiondegrees DOUBLE PRECISION,
    windshearheightfeet DOUBLE PRECISION,
    windshearspeedknots DOUBLE PRECISION,
    weatherstring CHARACTER VARYING,
    notdecoded CHARACTER VARYING);

CREATE TABLE taficing (
    tafforecastid BIGINT PRIMARY KEY,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet DOUBLE PRECISION,
    maximumaltitudefeet DOUBLE PRECISION);

CREATE TABLE tafsky (
    tafforecastid BIGINT PRIMARY KEY,
    cloudbasefeet DOUBLE PRECISION,
    cloudtype CHARACTER VARYING,
    cloudcover CHARACTER VARYING);

CREATE TABLE taftemperature (
    tafforecastid BIGINT PRIMARY KEY,
    validtimeutc TIMESTAMP WITH TIME ZONE,
    mintemperaturecelcius DOUBLE PRECISION,
    maxtemperaturecelcius DOUBLE PRECISION,
    surfacetemperaturecelcius DOUBLE PRECISION);

CREATE TABLE tafturbulence (
    tafforecastid BIGINT PRIMARY KEY,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet DOUBLE PRECISION,
    maximumaltitudefeet DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION distance_from_destination(asdiposition)
  RETURNS DOUBLE PRECISION STABLE LANGUAGE SQL AS
$BODY$
    SELECT distance_from_airport(fh.arrival_airport_icao_code, $1.latitude_degrees, $1.longitude_degrees)
    FROM   flighthistory fh
    WHERE  fh.id = $1.flighthistory_id;
$BODY$;

CREATE OR REPLACE FUNCTION distance_from_airport(airport_icao_code CHARACTER VARYING, latitude DOUBLE PRECISION, longitude DOUBLE PRECISION) 
RETURNS DOUBLE PRECISION
AS $$
select
    earth_distance(ll_to_earth(latitude_degrees, longitude_degrees), ll_to_earth($2, $3)) / 1609.344
from airports
WHERE airport_icao_code = $1
UNION ALL
select 0.0
WHERE NOT EXISTS (select * from airports where airport_icao_code = $1)
$$ LANGUAGE 'sql';
