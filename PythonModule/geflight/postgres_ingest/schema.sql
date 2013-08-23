CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;

CREATE TABLE airports (
    airport_icao_code CHARACTER VARYING PRIMARY KEY,
    latitude_degrees DOUBLE PRECISION,
    longitude_degrees DOUBLE PRECISION,
    altitude_feet DOUBLE PRECISION);

CREATE TABLE flighthistory (
    id                                BIGINT NOT NULL,
    airline_code                      CHARACTER VARYING,
    airline_icao_code                 CHARACTER VARYING,
    flight_number                     CHARACTER VARYING,
    tail_number                       CHARACTER VARYING,
    departure_airport_code            CHARACTER VARYING,
    departure_airport_icao_code       CHARACTER VARYING,
    arrival_airport_code              CHARACTER VARYING,
    arrival_airport_icao_code         CHARACTER VARYING,
    diverted_airport_code             CHARACTER VARYING,
    diverted_airport_icao_code        CHARACTER VARYING,
    published_departure               TIMESTAMP WITH TIME ZONE,
    published_arrival                 TIMESTAMP WITH TIME ZONE,
    scheduled_gate_departure          TIMESTAMP WITH TIME ZONE,
    estimated_gate_departure          TIMESTAMP WITH TIME ZONE,
    actual_gate_departure             TIMESTAMP WITH TIME ZONE,
    scheduled_gate_arrival            TIMESTAMP WITH TIME ZONE,
    estimated_gate_arrival            TIMESTAMP WITH TIME ZONE,
    actual_gate_arrival               TIMESTAMP WITH TIME ZONE,
    scheduled_runway_departure        TIMESTAMP WITH TIME ZONE,
    estimated_runway_departure        TIMESTAMP WITH TIME ZONE,
    actual_runway_departure           TIMESTAMP WITH TIME ZONE,
    scheduled_runway_arrival          TIMESTAMP WITH TIME ZONE,
    estimated_runway_arrival          TIMESTAMP WITH TIME ZONE,
    actual_runway_arrival             TIMESTAMP WITH TIME ZONE,
    creator_code                      CHARACTER VARYING,
    flight_history_status_code        CHARACTER VARYING,
    scheduled_air_time                BIGINT,
    actual_air_time                   BIGINT,
    scheduled_block_time              BIGINT,
    actual_block_time                 BIGINT,
    departure_airport_timezone_offset BIGINT,
    arrival_airport_timezone_offset   BIGINT,
    diverted_airport_timezone_offset  BIGINT,
    task_scheduled                    CHARACTER VARYING,
    departure_date                    TIMESTAMP WITH TIME ZONE,
    arrival_date                      TIMESTAMP WITH TIME ZONE,
    scheduled_aircraft_type           CHARACTER VARYING,
    actual_aircraft_type              CHARACTER VARYING,
    departure_gate                    CHARACTER VARYING,
    departure_terminal                CHARACTER VARYING,
    arrival_gate                      CHARACTER VARYING,
    arrival_terminal                  CHARACTER VARYING,
    baggage_claim                     CHARACTER VARYING,
    task_status                       CHARACTER VARYING,
    departure_date_date_only          TIMESTAMP WITH TIME ZONE,
    arrival_date_date_only            TIMESTAMP WITH TIME ZONE,
    last_updated                      TIMESTAMP WITH TIME ZONE,
    icao_aircraft_type_actual         CHARACTER VARYING);

CREATE TABLE flighthistory_release (
    id                                BIGINT NOT NULL,
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

CREATE TABLE flighthistoryevents (
    id                 BIGSERIAL,
    flighthistory_id   BIGINT NOT NULL,
    date_time_recorded TIMESTAMP WITH TIME ZONE,
    event              CHARACTER VARYING,
    data_updated       CHARACTER VARYING);

CREATE TABLE asdiflightplan (
    id                      BIGINT NOT NULL,
    update_time_utc         TIMESTAMP WITH TIME ZONE,
    flighthistory_id        BIGINT NOT NULL,
    departure_airport       CHARACTER VARYING,
    arrival_airport         CHARACTER VARYING,
    aircraft_id             CHARACTER VARYING,
    legacy_route            CHARACTER VARYING,
    original_departure_utc  TIMESTAMP WITH TIME ZONE,
    estimated_departure_utc TIMESTAMP WITH TIME ZONE,
    original_arrival_utc    TIMESTAMP WITH TIME ZONE,
    estimated_arrival_utc   TIMESTAMP WITH TIME ZONE);

CREATE TABLE asdiairway (
    id                BIGSERIAL,
    asdiflightplan_id BIGINT NOT NULL,
    ordinal           BIGINT,
    airway            CHARACTER VARYING);

CREATE TABLE asdifpcenter (
    id                BIGSERIAL,
    asdiflightplan_id BIGINT NOT NULL,
    ordinal           BIGINT,
    center            CHARACTER VARYING);

CREATE TABLE asdifpfix (
    id                BIGSERIAL,
    asdiflightplan_id BIGINT NOT NULL,
    ordinal           BIGINT,
    fix               CHARACTER VARYING);

CREATE TABLE asdifpsector (
    id                BIGSERIAL,
    asdiflightplan_id BIGINT NOT NULL,
    ordinal           BIGINT,
    sector            CHARACTER VARYING);

CREATE TABLE asdifpwaypoint (
    id                BIGSERIAL,
    asdiflightplan_id BIGINT,
    ordinal           BIGINT,
    latitude          DOUBLE PRECISION,
    longitude         DOUBLE PRECISION);

CREATE TABLE asdiposition (
    id                BIGSERIAL,
    received          TIMESTAMP WITH TIME ZONE,
    callsign          CHARACTER VARYING,
    altitude          BIGINT,
    ground_speed      BIGINT,
    latitude_degrees  DOUBLE PRECISION,
    longitude_degrees DOUBLE PRECISION,
    flighthistory_id  BIGINT);

CREATE TABLE metar_presentconditions (
    id                BIGINT,
    metar_reports_id  BIGINT,
    present_condition CHARACTER VARYING);

CREATE TABLE metar_reports (
    altimeter DOUBLE PRECISION,
    date_time_issued     TIMESTAMP WITH TIME ZONE,
    dewpoint DOUBLE PRECISION,
    is_visibility_less_than CHARACTER VARYING,
    is_wind_direction_variable CHARACTER VARYING,
    id                   BIGINT,
    original_report CHARACTER VARYING,
    remark CHARACTER VARYING,
    report_modifier      CHARACTER VARYING,
    sea_level_pressure DOUBLE PRECISION,
    station_type CHARACTER VARYING,
    temperature DOUBLE PRECISION,
    variable_wind_direction CHARACTER VARYING,
    visibility DOUBLE PRECISION,
    weather_station_code CHARACTER VARYING,
    wind_direction DOUBLE PRECISION,
    wind_gusts DOUBLE PRECISION,
    wind_speed DOUBLE PRECISION);

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
    metar_reports_id BIGINT,
    sky_condition CHARACTER VARYING);

CREATE TABLE airsigmet (
    airsigmetid BIGINT NOT NULL,
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
    airsigmetid BIGINT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    ordinal BIGINT);

CREATE TABLE fdwind (
    fbwindairportid BIGINT,
    ordinal BIGINT,
    bearing BIGINT,
    knots BIGINT,
    temperature CHARACTER VARYING);

CREATE TABLE fdwindairport (
    fbwindairportid BIGINT,
    fbwindreportid BIGINT,
    airportcode CHARACTER VARYING);

CREATE TABLE fdwindaltitude (
    fbwindreportid BIGINT NOT NULL,
    ordinal BIGINT,
    altitude BIGINT);

CREATE TABLE fdwindreport (
    fbwindreportid BIGINT NOT NULL,
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
    tafforecastid BIGINT,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet DOUBLE PRECISION,
    maximumaltitudefeet DOUBLE PRECISION);

CREATE TABLE tafsky (
    tafforecastid BIGINT,
    cloudbasefeet DOUBLE PRECISION,
    cloudtype CHARACTER VARYING,
    cloudcover CHARACTER VARYING);

CREATE TABLE taftemperature (
    tafforecastid BIGINT,
    validtimeutc TIMESTAMP WITH TIME ZONE,
    mintemperaturecelcius DOUBLE PRECISION,
    maxtemperaturecelcius DOUBLE PRECISION,
    surfacetemperaturecelcius DOUBLE PRECISION);

CREATE TABLE tafturbulence (
    tafforecastid BIGINT,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet DOUBLE PRECISION,
    maximumaltitudefeet DOUBLE PRECISION);

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

CREATE OR REPLACE FUNCTION distance_from_destination(asdiposition)
  RETURNS DOUBLE PRECISION STABLE LANGUAGE SQL AS
$BODY$
    SELECT distance_from_airport(fh.arrival_airport_icao_code, $1.latitude_degrees, $1.longitude_degrees)
    FROM   flighthistory fh
    WHERE  fh.id = $1.flighthistory_id;
$BODY$;


CREATE OR REPLACE FUNCTION testFlightIds(cutoffTime TIMESTAMP WITH TIME ZONE)
    RETURNS TABLE(flighthistory_id BIGINT, last_asdiposition_id BIGINT)
    AS $$ 
        WITH flights (id) AS (
            SELECT id
            FROM flighthistory fh
            WHERE actual_runway_departure    IS NOT NULL
              AND actual_runway_arrival      IS NOT NULL
              AND scheduled_runway_arrival   IS NOT NULL
              AND scheduled_gate_arrival     IS NOT NULL
              AND scheduled_gate_departure   IS NOT NULL
              AND actual_gate_departure      IS NOT NULL
              AND diverted_airport_icao_code IS NULL
              AND actual_runway_departure    < $1
              AND actual_runway_arrival      > $1)
        SELECT f.id,
               max(p.id)
        FROM flights f
        LEFT OUTER JOIN asdiposition p ON f.id=p.flighthistory_id
        WHERE extract(epoch FROM ($1 - p.received))>0
          AND extract(epoch FROM ($1 - p.received))<120
          AND p.altitude >= 18000
        GROUP BY f.id
        HAVING COUNT(p.id)>0
    $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION testFlightInformation(cutoffTime TIMESTAMP WITH TIME ZONE)
    RETURNS TABLE(flighthistory_id            BIGINT,
                  departure_airport_icao_code CHARACTER VARYING,
                  arrival_airport_icao_code   CHARACTER VARYING,
                  scheduled_runway_arrival    TIMESTAMP WITH TIME ZONE,
                  scheduled_gate_arrival      TIMESTAMP WITH TIME ZONE,
		  scheduled_gate_departure    TIMESTAMP WITH TIME ZONE,
		  actual_gate_departure       TIMESTAMP WITH TIME ZONE,
                  latitude_degrees            DOUBLE PRECISION,
                  longitude_degrees           DOUBLE PRECISION,
                  altitude                    BIGINT,
                  ground_speed                BIGINT)
    AS $$
        SELECT fh.id,
               departure_airport_icao_code,
               arrival_airport_icao_code,
               scheduled_runway_arrival,
               scheduled_gate_arrival,
               scheduled_gate_departure,
               actual_gate_departure,
               latitude_degrees,
               longitude_degrees,
               altitude,
               ground_speed
        FROM testFlightIds($1) f
        INNER JOIN asdiposition p on f.last_asdiposition_id=p.id
        INNER JOIN flighthistory fh on f.flighthistory_id=fh.id;
    $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION actuallandingcounts(IN tsbegin timestamp with time zone, IN tsend timestamp with time zone)
  RETURNS TABLE(airport_code character varying, runway_arrival timestamp with time zone, count bigint) AS
$BODY$
select
	arrival_airport_icao_code as airport_code,
	actual_runway_arrival as runway_arrival,
	count(*) as count
from flighthistory fh
where
	fh.arrival_airport_icao_code in ('KBOS', 'KJFK', 'KLGA', 'KEWR', 'KPHL', 'KBWI', 'KIAD', 'KDCA', 'KBNA', 'KMEM', 'KATL', 'KRDU', 'KCLT', 'KMCO', 'KMIA', 'KFLL', 'KTPA', 'KRSW', 'KPBI', 'KORD', 'KMDW', 'KDTW', 'KCLE', 'KCMH', 'KCVG', 'KIND', 'KMKE', 'KMSP', 'KSDF', 'KDSM', 'KCID', 'KDFW', 'KDAL', 'KIAH', 'KHOU', 'KMSY', 'KSTL', 'KMCI', 'KABQ', 'KELP', 'KOKC', 'KTUL', 'KLIT', 'KXNA', 'KSEA', 'KPDX', 'KDEN', 'KCOS', 'KSLC', 'KSFO', 'KSJC', 'KOAK', 'KLAX', 'KLGB', 'KSNA', 'KONT', 'KBUR', 'KPSP', 'KSAN', 'KFAT', 'KSMF', 'KPHX', 'KTUS')
	and fh.actual_runway_arrival > $1
	and fh.actual_runway_arrival < $2
group by
	fh.actual_runway_arrival,
	fh.arrival_airport_icao_code
order by 	
	fh.actual_runway_arrival
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION actuallandingcounts(timestamp with time zone, timestamp with time zone)
  OWNER TO postgres;

-- Function: groundconditionsbetween(timestamp with time zone, timestamp with time zone)

-- DROP FUNCTION groundconditionsbetween(timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION groundconditionsbetween(IN tsbegin timestamp with time zone, IN tsend timestamp with time zone)
  RETURNS TABLE(weather_station_code character varying, date_time_issued timestamp with time zone, dewpoint double precision, wind_speed double precision, visibility double precision, wind_gusts double precision, temperature double precision) AS
$BODY$
select
	weather_station_code,
	date_time_issued,
	dewpoint,
	wind_speed,
	visibility,
	COALESCE(wind_gusts::double precision,0) as wind_gusts, 
	temperature
from metar_reports fmc
where
	fmc.date_time_issued > $1
	AND fmc.date_time_issued < $2
	AND fmc.weather_station_code in ('KBOS', 'KJFK', 'KLGA', 'KEWR', 'KPHL', 'KBWI', 'KIAD', 'KDCA', 'KBNA', 'KMEM', 'KATL', 'KRDU', 'KCLT', 'KMCO', 'KMIA', 'KFLL', 'KTPA', 'KRSW', 'KPBI', 'KORD', 'KMDW', 'KDTW', 'KCLE', 'KCMH', 'KCVG', 'KIND', 'KMKE', 'KMSP', 'KSDF', 'KDSM', 'KCID', 'KDFW', 'KDAL', 'KIAH', 'KHOU', 'KMSY', 'KSTL', 'KMCI', 'KABQ', 'KELP', 'KOKC', 'KTUL', 'KLIT', 'KXNA', 'KSEA', 'KPDX', 'KDEN', 'KCOS', 'KSLC', 'KSFO', 'KSJC', 'KOAK', 'KLAX', 'KLGB', 'KSNA', 'KONT', 'KBUR', 'KPSP', 'KSAN', 'KFAT', 'KSMF', 'KPHX', 'KTUS')	
	AND fmc.wind_direction is not null
	AND fmc.wind_speed is not null
	AND fmc.visibility is not null
	AND fmc.temperature is not null
	AND fmc.dewpoint is not null
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION groundconditionsbetween(timestamp with time zone, timestamp with time zone)
  OWNER TO postgres;

-- Function: landingsinminutesbetween(character varying, timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION landingsinminutesbetween(character varying, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION landingsinminutesbetween(airport character varying, tslower timestamp without time zone, tshigher timestamp without time zone)
  RETURNS bigint AS
$BODY$
 SELECT count(*) 
	FROM public.flighthistory fh2
	WHERE
		fh2.arrival_airport_code = $1
		AND fh2.actual_runway_arrival is NOT NULL
		AND $2  < fh2.actual_runway_arrival::TIMESTAMP
		AND $3  > fh2.actual_runway_arrival::TIMESTAMP
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION landingsinminutesbetween(character varying, timestamp without time zone, timestamp without time zone)
  OWNER TO postgres;

-- Function: scheduledlandingcounts(timestamp with time zone, timestamp with time zone)

-- DROP FUNCTION scheduledlandingcounts(timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION scheduledlandingcounts(IN tsbegin timestamp with time zone, IN tsend timestamp with time zone)
  RETURNS TABLE(airport_code character varying, runway_arrival timestamp with time zone, count bigint) AS
$BODY$
select
	arrival_airport_icao_code as airport_code,
	scheduled_runway_arrival as runway_arrival,
	count(*) as count
from flighthistory fh
where
	fh.arrival_airport_icao_code in ('KBOS', 'KJFK', 'KLGA', 'KEWR', 'KPHL', 'KBWI', 'KIAD', 'KDCA', 'KBNA', 'KMEM', 'KATL', 'KRDU', 'KCLT', 'KMCO', 'KMIA', 'KFLL', 'KTPA', 'KRSW', 'KPBI', 'KORD', 'KMDW', 'KDTW', 'KCLE', 'KCMH', 'KCVG', 'KIND', 'KMKE', 'KMSP', 'KSDF', 'KDSM', 'KCID', 'KDFW', 'KDAL', 'KIAH', 'KHOU', 'KMSY', 'KSTL', 'KMCI', 'KABQ', 'KELP', 'KOKC', 'KTUL', 'KLIT', 'KXNA', 'KSEA', 'KPDX', 'KDEN', 'KCOS', 'KSLC', 'KSFO', 'KSJC', 'KOAK', 'KLAX', 'KLGB', 'KSNA', 'KONT', 'KBUR', 'KPSP', 'KSAN', 'KFAT', 'KSMF', 'KPHX', 'KTUS')
	and fh.scheduled_runway_arrival > $1
	and fh.scheduled_runway_arrival < $2
group by
	fh.scheduled_runway_arrival,
	fh.arrival_airport_icao_code
order by 	
	fh.scheduled_runway_arrival
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION scheduledlandingcounts(timestamp with time zone, timestamp with time zone)
  OWNER TO postgres;

-- Function: testflightids(timestamp with time zone)

-- DROP FUNCTION testflightids(timestamp with time zone);


CREATE OR REPLACE FUNCTION dewpoint(airport character varying, ts timestamp with time zone)
  RETURNS DOUBLE PRECISION STABLE LANGUAGE SQL AS
$BODY$
  SELECT dewpoint
  FROM metar_reports
  WHERE date_time_issued <= $2
    AND weather_station_code = $1
    AND dewpoint IS NOT NULL
  ORDER BY date_time_issued DESC
  LIMIT 1;
$BODY$;

CREATE OR REPLACE FUNCTION wind_speed(airport character varying, ts timestamp with time zone)
  RETURNS DOUBLE PRECISION STABLE LANGUAGE SQL AS
$BODY$
  SELECT wind_speed
  FROM metar_reports
  WHERE date_time_issued <= $2
    AND weather_station_code = $1
    AND wind_speed IS NOT NULL
  ORDER BY date_time_issued DESC
  LIMIT 1;
$BODY$;

CREATE OR REPLACE FUNCTION visibility(airport character varying, ts timestamp with time zone)
  RETURNS DOUBLE PRECISION STABLE LANGUAGE SQL AS
$BODY$
  WITH vis AS (
  SELECT visibility
  FROM metar_reports
  WHERE date_time_issued <= $2
    AND weather_station_code = $1
    AND visibility IS NOT NULL
  ORDER BY date_time_issued DESC
  LIMIT 1)
  SELECT visibility from vis
  UNION
  SELECT 0.0 WHERE NOT EXISTS (SELECT visibility from vis)
  LIMIT 1;
$BODY$;

CREATE OR REPLACE FUNCTION wind_gusts(airport character varying, ts timestamp with time zone)
  RETURNS DOUBLE PRECISION STABLE LANGUAGE SQL AS
$BODY$
  WITH gusts AS (
  SELECT wind_gusts
  FROM metar_reports
  WHERE date_time_issued <= $2
    AND weather_station_code = $1
    AND wind_gusts IS NOT NULL
  ORDER BY date_time_issued DESC
  LIMIT 1)
  SELECT wind_gusts from gusts
  UNION
  SELECT 0.0 WHERE NOT EXISTS (SELECT wind_gusts from gusts)
  LIMIT 1;
$BODY$;

CREATE OR REPLACE FUNCTION temperature(airport character varying, ts timestamp with time zone)
  RETURNS DOUBLE PRECISION STABLE LANGUAGE SQL AS
$BODY$
  SELECT temperature
  FROM metar_reports
  WHERE date_time_issued <= $2
    AND weather_station_code = $1
    AND temperature IS NOT NULL
  ORDER BY date_time_issued DESC
  LIMIT 1;
$BODY$;
