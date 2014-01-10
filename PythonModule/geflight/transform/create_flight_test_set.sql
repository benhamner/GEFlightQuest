-- ============================================================
-- create_flight_test_set.sql
-- @Author: Joyce Noah-Vanhoucke
-- @Created 15 August 2013
-- Creates test set
-- ============================================================

-- Data Release 1
-- cutoffs: first 7 are public, last 7 are private
-- ['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
-- '2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
-- '2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00']

-- Data Release 2: Aug 14 to Sep 24 (Train is Aug 14 to Sep 10; Test is Sep 11-24)
-- cutoffs: first 7 are public, last 7 are private
-- Public: ['2013-09-11 18:24:19', '2013-09-15 19:10:16',' 2013-09-17 14:22:31', '2013-09-19 19:21:39', '2013-09-20 15:14:26',
-- '2013-09-21 21:16:19', '2013-09-23 15:09:29']
-- Private: ['2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', '2013-09-16 15:47:50', 
-- '2013-09-18 14:12:58','2013-09-22 14:19:51', '2013-09-24 18:22:23']

-- ============================================================


-- FLIGHT HISTORY
-- create base test flight history: remove extra cols, keep overall relevant time window
-- Total = 24 cols. Training has 26, remove actual_gate_arrival and actual_runway_arrival.
drop table if exists basetest_flighthistory;
CREATE TABLE basetest_flighthistory AS SELECT 
    id,
    airline_code, 
    airline_icao_code, 
    flight_number, 
    departure_airport_code, 
    departure_airport_icao_code, 
    arrival_airport_code, 
    arrival_airport_icao_code, 
    published_departure, 
    published_arrival, 
    scheduled_gate_departure, 
    actual_gate_departure, 
    scheduled_gate_arrival, 
    scheduled_runway_departure, 
    actual_runway_departure, 
    scheduled_runway_arrival, 
    creator_code, 
    scheduled_air_time, 
    scheduled_block_time, 
    departure_airport_timezone_offset, 
    arrival_airport_timezone_offset, 
    scheduled_aircraft_type, 
    actual_aircraft_type, 
    icao_aircraft_type_actual
FROM flighthistory 
WHERE 
    (
        published_departure >= '2013-09-11 09:00:00+00'
        OR ( published_departure IS NULL AND scheduled_gate_departure >= '2013-09-11 09:00:00+00' )
        OR ( published_departure IS NULL AND scheduled_gate_departure IS NULL AND scheduled_runway_departure >= '2013-09-11 09:00:00+00' ) 
    )
    AND (departure_airport_icao_code LIKE 'K%' OR arrival_airport_icao_code LIKE 'K%');


-- FLIGHT HISTORY test
drop table if exists test2_flighthistory;
CREATE TABLE test2_flighthistory as (
    select * from apply_time_cutoffs_flighthistory( 
            ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
);
drop table if exists test_flighthistory_ids;
create table test_flighthistory_ids as select id from test2_flighthistory;

-- FLIGHTHISTORYEVENTS test
drop table if exists test2_flighthistoryevents;
CREATE TABLE test2_flighthistoryevents as (
    select * from apply_time_cutoffs_flighthistoryevents( 
            ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
    where flighthistory_id in (select * from test_flighthistory_ids)
);
copy (select * from test2_flighthistory) to 'C:/FQ2DataRelease2/test2_flighthistory.csv' delimiter ',' csv header;
copy (select * from test2_flighthistoryevents) to 'C:/FQ2DataRelease2/test2_flighthistoryevents.csv' delimiter ',' csv header;

-------------------------------------------------------------------------------
-- ASDI

-- asdiposition
drop table if exists test2_asdiposition;
create table test2_asdiposition as (
    select * from apply_time_cutoffs_asdiposition(
        ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
);

drop table if exists test2_asdiflightplan;
create table test2_asdiflightplan as (
    select * from apply_time_cutoffs_asdiflightplan(
        ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
);

drop table if exists test_asdiflightplan_ids;
create table test_asdiflightplan_ids as
    (SELECT id from test2_asdiflightplan);

    
drop table if exists test2_asdiairway;
create table test2_asdiairway as (
    select * from asdiairway where asdiflightplan_id in
        (select * from test_asdiflightplan_ids)
    );

drop table if exists test2_asdifpfix;
create table test2_asdifpfix as (
    select * from asdiairway where asdiflightplan_id in
        (SELECT * from test_asdiflightplan_ids)
    );

drop table if exists test2_asdifpcenter;
create table test2_asdifpcenter as (
    select * from asdifpcenter where asdiflightplan_id in
        (select * from test_asdiflightplan_ids)
    );

drop table if exists test2_asdifpsector;
create table test2_asdifpsector as (
    select * from asdifpsector where asdiflightplan_id in
        (select * from test_asdiflightplan_ids)
    );
    
drop table if exists test2_asdifpwaypoint;
create table test2_asdifpwaypoint as (
    select * from asdifpwaypoint where asdiflightplan_id in
        (select * from test_asdiflightplan_ids)
    );

copy (select * from test2_asdiposition) to 'C:/FQ2DataRelease2/test2_asdiposition.csv' delimiter ',' csv header;
copy (select * from test2_asdiflightplan) to 'C:/FQ2DataRelease2/test2_asdiflightplan.csv' delimiter ',' csv header;
copy (select * from test2_asdiairway) to 'C:/FQ2DataRelease2/test2_asdiairway.csv' delimiter ',' csv header;
copy (select * from test2_asdifpfix) to 'C:/FQ2DataRelease2/test2_asdifpfix.csv' delimiter ',' csv header;
copy (select * from test2_asdifpcenter) to 'C:/FQ2DataRelease2/test2_asdifpcenter.csv' delimiter ',' csv header;
copy (select * from test2_asdifpsector) to 'C:/FQ2DataRelease2/test2_asdifpsector.csv' delimiter ',' csv header;
copy (select * from test2_asdifpwaypoint) to 'C:/FQ2DataRelease2/test2_asdifpwaypoint.csv' delimiter ',' csv header;

    
-------------------------------------------------------------------------------
-- METAR test
drop table if exists test2_metar_reports;
CREATE TABLE test2_metar_reports as (
    select * from apply_time_cutoffs_metar(
        ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
);
-- presentconditions
drop table if exists test2_metar_presentconditions;
CREATE TABLE test2_metar_presentconditions as (
    select * from metar_presentconditions
    where metar_reports_id in (select id from test2_metar_reports)
);
-- skyconditions
drop table if exists test2_metar_skyconditions;
CREATE TABLE test2_metar_skyconditions as (
    select * from metar_skyconditions
    where metar_reports_id in (select id from test2_metar_reports)
);
-- runwayconditions
drop table if exists test2_metar_runwaygroups;
CREATE TABLE test2_metar_runwaygroups as (
    select * from metar_runwaygroups
    where metar_reports_id in (select id from test2_metar_reports)
);


copy (select * from test2_metar_reports) to 'C:/FQ2DataRelease2/test2_metar_reports.csv' delimiter ',' csv header;
copy (select * from test2_metar_presentconditions) to 'C:/FQ2DataRelease2/test2_metar_presentconditions.csv' delimiter ',' csv header;
copy (select * from test2_metar_skyconditions) to 'C:/FQ2DataRelease2/test2_metar_skyconditions.csv' delimiter ',' csv header;
copy (select * from test2_metar_runwaygroups) to 'C:/FQ2DataRelease2/test2_metar_runwaygroups.csv' delimiter ',' csv header;


-------------------------------------------------------------------------------
-- FDWIND test
drop table if exists test2_fdwindreport;
CREATE TABLE test2_fdwindreport as (
    select * from apply_time_cutoffs_fdwind(
        ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
);
-- airport using report ids
drop table if exists test2_fdwindairport;
CREATE TABLE test2_fdwindairport as (
    select * from fdwindairport where 
        fbwindreportid in (select fbwindreportid from test2_fdwindreport)
);
-- altitude uses report ids
drop table if exists test2_fdwindaltitude;
CREATE TABLE test2_fdwindaltitude as (
    select * from fdwindaltitude where 
        fbwindreportid in (select fbwindreportid from test2_fdwindreport)
);
-- wind using airport ids
drop table if exists test2_fdwind;
CREATE TABLE test2_fdwind as (
    select * from fdwind where 
        fbwindairportid in (SELECT fbwindairportid from test2_fdwindairport)
);

copy (select * from test2_fdwindreport) to 'C:/FQ2DataRelease2/test2_fdwindreport.csv' delimiter ',' csv header;
copy (select * from test2_fdwindairport) to 'C:/FQ2DataRelease2/test2_fdwindairport.csv' delimiter ',' csv header;
copy (select * from test2_fdwindaltitude) to 'C:/FQ2DataRelease2/test2_fdwindaltitude.csv' delimiter ',' csv header;
copy (select * from test2_fdwind) to 'C:/FQ2DataRelease2/test2_fdwind.csv' delimiter ',' csv header;


-------------------------------------------------------------------------------
-- AIRSIGMET test
drop table if exists test2_airsigmet;
CREATE TABLE test2_airsigmet as (
    select * from apply_time_cutoffs_airsigmet(
        ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
);
-- airsigmetarea
drop table if exists test2_airsigmetarea;
CREATE TABLE test2_airsigmetarea as (
    select * from airsigmetarea where 
    airsigmetid in (select airsigmetid from test2_airsigmet)
);
copy (select * from test2_airsigmet) to 'C:/FQ2DataRelease2/test2_airsigmet.csv' delimiter ',' csv header;
copy (select * from test2_airsigmetarea) to 'C:/FQ2DataRelease2/test2_airsigmetarea.csv' delimiter ',' csv header;


-------------------------------------------------------------------------------
-- TAF test
drop table if exists test2_taf;
CREATE TABLE test2_taf as ( 
    select * from apply_time_cutoffs_taf(
        ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
);
drop table if exists test2_tafforecast;
CREATE TABLE test2_tafforecast as (
    select * from apply_time_cutoffs_tafforecast(
            ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23'])
    where tafid in (select tafid from test2_taf) 
);

copy (select * from test2_taf) to 'C:/FQ2DataRelease2/test2_taf.csv' delimiter ',' csv header;
copy (select * from test2_tafforecast) to 'C:/FQ2DataRelease2/test2_tafforecast.csv' delimiter ',' csv header;


-- taf icing, sky, temp, turbulence on tafforecastid
drop table if exists test2_taficing;
CREATE TABLE test2_taficing as (
    select * from taficing where tafforecastid in
        (select tafforecastid from test2_tafforecast)
);
drop table if exists test2_tafsky;
CREATE TABLE test2_tafsky as (
    select * from tafsky where tafforecastid in
        (select tafforecastid from test2_tafforecast)
);
drop table if exists test2_taftemperature;
CREATE TABLE test2_taftemperature as (
    select * from taftemperature where tafforecastid in
        (select tafforecastid from test2_tafforecast)
);
drop table if exists test2_tafturbulence;
CREATE TABLE test2_tafturbulence as (
    select * from tafturbulence where tafforecastid in
        (select tafforecastid from test2_tafforecast)
);
copy (select * from test2_taficing) to 'C:/FQ2DataRelease2/test2_taficing.csv' delimiter ',' csv header;
copy (select * from test2_tafsky) to 'C:/FQ2DataRelease2/test2_tafsky.csv' delimiter ',' csv header;
copy (select * from test2_taftemperature) to 'C:/FQ2DataRelease2/test2_taftemperature.csv' delimiter ',' csv header;
copy (select * from test2_tafturbulence) to 'C:/FQ2DataRelease2/test2_tafturbulence.csv' delimiter ',' csv header;



-- =================================================================================
-- Helper functions
-- =================================================================================

-- =======================================================================
-- set_start_time()
-- Given a string cutoff time, returns the start of that UTC day.
-- Expected Usage:
-- select * from set_start_time('2013-07-08 13:30:00') -- should return 2013-07-08 09:00:00
-- select * from set_start_time('2013-07-08 03:30:00') -- should return 2013-07-07 09:00:00
-- =======================================================================
CREATE OR REPLACE FUNCTION set_start_time(cutofftime timestamp with time zone)
  RETURNS timestamp with time zone AS
$BODY$
declare
begin
	if date_part('hour', $1) < 9 THEN
		return (date($1) - interval '1 day' + time '09:00:00')::timestamptz(0);
	else
		return (date($1) + time '09:00:00')::timestamptz(0); 
	end if;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION set_start_time(timestamp witH time zone)
  OWNER TO postgres;

-- FLIGHT HISTORY
create or replace function apply_time_cutoffs_flighthistory(text[]) returns setof basetest_flighthistory as $$
declare
    val text;
    cutoff timestamp with time zone;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from basetest_flighthistory where 
            (actual_gate_departure >= set_start_time(cutoff) and actual_gate_departure < cutoff)
            or
            (actual_gate_departure is null and scheduled_gate_departure >= set_start_time(cutoff) and scheduled_gate_departure < cutoff)
            or
            (actual_gate_departure is null and  scheduled_gate_departure is null and 
                published_departure >= set_start_time(cutoff) and published_departure < cutoff)
            or
            (actual_gate_departure is null and scheduled_gate_departure is null and published_departure is null and
                scheduled_runway_departure >= set_start_time(cutoff) and scheduled_runway_departure < cutoff);
    end loop;
end;
$$ language plpgsql;


-- FLIGHT HISTORY EVENTS
create or replace function apply_time_cutoffs_flighthistoryevents(text[]) returns setof flighthistoryevents as $$
declare
    val text;
    cutoff timestamp with time zone;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from flighthistoryevents where 
            (date_time_recorded >= set_start_time(cutoff) and date_time_recorded < cutoff);
    end loop;
end;
$$ language plpgsql;


-- asdi position
create or replace function apply_time_cutoffs_asdiposition(text[]) returns setof asdiposition as $$
declare
    val text;
    cutoff timestamp with time zone;
    rec record;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from asdiposition
            where received >= set_start_time(cutoff) and received < cutoff;
    end loop;
end;
$$ language plpgsql;


--- asdi flightplan
create or replace function apply_time_cutoffs_asdiflightplan(text[]) returns setof asdiflightplan as $$
declare
    val text;
    cutoff timestamp with time zone;
    rec record;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from asdiflightplan
            where update_time_utc >= set_start_time(cutoff) and update_time_utc < cutoff;
    end loop;
end;
$$ language plpgsql;



-- metar_reports
create or replace function apply_time_cutoffs_metar(text[]) returns setof metar_reports as $$
declare
    val text;
    cutoff timestamp with time zone;
    rec record;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from metar_reports
            where date_time_issued >= set_start_time(cutoff) and date_time_issued < cutoff;
    end loop;
end;
$$ language plpgsql;

-- table fdwindreport, relevant column is createdutc
create or replace function apply_time_cutoffs_fdwind(text[]) returns setof fdwindreport as $$
declare
    val text;
    cutoff timestamp with time zone;
    rec record;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from fdwindreport
            where createdutc >= set_start_time(cutoff) and createdutc < cutoff;
    end loop;
end;
$$ language plpgsql;


-- table airsigmet, relevant column is 'timevalidfromutc'
create or replace function apply_time_cutoffs_airsigmet(text[]) returns setof airsigmet  as $$
declare
    val text;
    cutoff timestamp with time zone;
    rec record;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from airsigmet
            where timevalidfromutc >= set_start_time(cutoff) and timevalidfromutc < cutoff;
    end loop;
end;
$$ language plpgsql;


-- table taf, relevant columns are bulletintimeutc, forecasttimefromutc, forecasttimetoutc
create or replace function apply_time_cutoffs_taf(text[]) returns setof taf as $$
declare
    val text;
    cutoff timestamp with time zone;
    rec record;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from taf
            where bulletintimeutc >= set_start_time(cutoff) and bulletintimeutc < cutoff;
    end loop;
end;
$$ language plpgsql;


-- table tafforecast, filter on tafids and columns forecasttimefromutc, forecasttimetoutc
create or replace function apply_time_cutoffs_tafforecast(text[]) returns setof tafforecast as $$
declare
    val text;
    cutoff timestamp with time zone;
begin
    set time zone 'UTC';
    FOREACH val in array $1
    Loop
        cutoff = val::timestamptz(0);
        return query
        select * from tafforecast where
            forecasttimefromutc >= set_start_time(cutoff) and forecasttimefromutc < cutoff
            and
            forecasttimetoutc >= set_start_time(cutoff) and forecasttimetoutc < cutoff;
    end loop;
end;
$$ language plpgsql;

