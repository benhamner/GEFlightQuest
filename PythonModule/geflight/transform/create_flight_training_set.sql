-- ==============================================================
-- create_flight_quest_training.sql
-- @Author: Joyce Noah-Vanhoucke
-- @Created: 15 August 2013
-- Assumes original Flight Stats data is in db form, assumes
-- combined METAR table
-- ==============================================================


-- ==============================================================
-- Flight history training set filters
--   1. Date/time 
--   2. Continental US (ICAO code LIKE 'K%'
--   3. Select columns, total 26
-- ==============================================================

CREATE OR REPLACE VIEW training1_flighthistory AS SELECT 
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
    actual_gate_arrival, 
    scheduled_runway_departure, 
    actual_runway_departure, 
    scheduled_runway_arrival, 
    actual_runway_arrival, 
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
        published_departure < '2013-07-05 09:00:00+00'
        OR ( published_departure IS NULL AND scheduled_gate_departure < '2013-07-05 09:00:00+00' )
        OR ( published_departure IS NULL AND scheduled_gate_departure IS NULL AND scheduled_runway_departure < '2013-07-05 09:00:00+00' ) 
    )
    AND (departure_airport_icao_code LIKE 'K%' AND arrival_airport_icao_code LIKE 'K%');

create table flighthistory_ids as select id from training1_flighthistory;
create or replace view training1_flighthistoryevents as
    select * from flighthistoryevents where 
        flighthistory_id in (select * from flighthistory_ids);

-- ASDI flight plan, uses flighthistory_id)
select * from asdiflightplan limit 20
create or replace view training1_asdiflightplan as
    select * from asdiflightplan where
        flighthistory_id in (select id from flighthistory_ids);

-- ASDI Flight Plan IDs
create table asdiflightplan_ids as select id from training1_asdiflightplan;

-- ASDI airway
create or replace view training1_asdiairway as
    select * from asdiairway where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Fix
create or replace view training1_asdifpfix as
    select * from asdifpfix where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Center
create or replace view training1_asdifpcenter as
    select * from asdifpcenter where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Sector
create or replace view training1_asdifpsector as
    select * from asdifpsector where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI Position (uses flighthistoryid)
create or replace view training1_asdiposition as
    select * from asdiposition where
        flighthistory_id in (select * from flighthistory_ids);
-- ASDI FP Waypoint
create or replace view training1_asdifpwaypoint as
    select * from asdifpwaypoint where
        asdiflightplan_id in (select * from asdiflightplan_ids);


-- Write to file
copy (select * from training1_flighthistoryevents) to '/mnt/out/training1_flighthistoryevents.csv' delimiter ',' csv header;
copy (select * from training1_asdiairway) to '/mnt/out/training1_asdiairway.csv' delimiter ',' csv header; 
copy (select * from training1_asdiflightplan) to '/mnt/out/training1_asdiflightplan.csv' delimiter ',' csv header; 
copy (select * from training1_asdifpcenter) to '/mnt/out/training1_asdifpcenter.csv' delimiter ',' csv header; 
copy (Select * from training1_asdifpfix) to '/mnt/out/training1_asdifpfix.csv' delimiter ',' csv header; 
copy (select * from training1_asdifpsector) to '/mnt/out/training1_asdifpsector.csv' delimiter ',' csv header; 
copy (select * from training1_asdifpwaypoint) to '/mnt/out/training1_asdifpwaypoint.csv' delimiter ',' csv header; 
copy (select * from training1_asdiposition) to '/mnt/out/training1_asdiposition.csv' delimiter ',' csv header;



-- ===============================================================
-- METAR
-- 1. Filter metar_reports for training period dates. Need ids
-- 2. Use metar_reports_id to filter in order:
--      * presentconditions, skyconditions, runwayconditions
-- ===============================================================
-- metar_reports: create view with training date constraints
create or replace view training1_metar_reports as ( 
    select * from metar_reports where
    date_time_issued >= '2013-06-07 09:00:00+00' and date_time_issued < '2013-07-05 09:00:00+00'
);

-- presentconditions
create or replace view training1_metar_presentconditions as (
    select * from metar_presentconditions
    where metar_reports_id in (select id from training1_metar_reports)
);
-- skyconditions
create or replace view training1_metar_skyconditions as (
    select * from metar_skyconditions
    where metar_reports_id in (select id from training1_metar_reports)
);

-- runwayconditions
create or replace view training1_metar_runwaygroups as (
    select * from metar_runwaygroups
    where metar_reports_id in (select id from training1_metar_reports)
);

copy (select * from training1_metar_reports) to '/mnt/out/training1_metar_reports.csv' delimiter ',' csv header;
copy (select * from training1_metar_presentconditions) to '/mnt/out/training1_metar_presentconditions.csv' delimiter ',' csv header;
copy (select * from training1_metar_skyconditions) to '/mnt/out/training1_metar_skyconditions.csv' delimiter ',' csv header;
copy (select * from training1_metar_runwaygroups) to '/mnt/out/training1_metar_runwaygroups.csv' delimiter ',' csv header;


-- ===============================================================
-- FDWIND
-- 1. Filter fdwindreport for training period dates. Need ids
-- 2. Use fbwindreportid to filter in order:
--     * fdwindairport, Need ids
--     * fdwindaltitude
-- 3. Use fbwindairportid to filter fdwind
-- 4. Note: Tables are called FDwind, ids are called FBwind.
--          This is because NOAA has changed the name of their product
--          to FDwind but did not change column headers
-- ===============================================================
create or replace view training1_fdwindreport as (
    select * from fdwindreport where
    createdutc >= '2013-06-07 09:00:00' and createdutc < '2013-07-05 09:00:00'
);
-- airport using report ids
create or replace view training1_fdwindairport as (
    select * from fdwindairport where fbwindreportid in 
        (select fbwindreportid from training1_fdwindreport)
);

-- altitude uses report ids
create or replace view training1_fdwindaltitude as (
    select * from fdwindaltitude where fbwindreportid in 
        (select fbwindreportid from training1_fdwindreport)
);
-- wind using airport ids
create or replace view training1_fdwind as (
    select * from fdwind where fbwindairportid in
        (SELECT fbwindairportid from training1_fdwindairport)
);

copy (select * from training1_fdwindreport) to '/mnt/out/training1_fdwindreport.csv' delimiter ',' csv header;
copy (select * from training1_fdwindairport) to '/mnt/out/training1_fdwindairport.csv' delimiter ',' csv header;
copy (select * from training1_fdwindaltitude) to '/mnt/out/training1_fdwindaltitude.csv' delimiter ',' csv header;
copy (select * from training1_fdwind) to '/mnt/out/training1_fdwind.csv' delimiter ',' csv header;

-- ===============================================================
-- TAF
-- 1. Filter taf for training period dates, Need ids
-- 2. Use tafid to filter in order:
--    * taf forecast, icing, sky, temp, turbulence
-- ===============================================================
create or replace view training1_taf as (
    select * from taf where 
    bulletintimeutc >= '2013-06-07 09:00:00' and bulletintimeutc < '2013-07-05 09:00:00'
);
-- taf forecast on taf ids
create or replace view training1_tafforecast as (
    select * from tafforecast where tafid in
        (select tafid from training1_taf)
);
-- taf icing, sky, temp, turbulence on tafforecastid
create or replace view training1_taficing as (
    select * from taficing where tafforecastid in
        (select tafforecastid from training1_tafforecast)
);
create or replace view training1_tafsky as (
    select * from tafsky where tafforecastid in
        (select tafforecastid from training1_tafforecast)
);
create or replace view training1_taftemperature as (
    select * from taftemperature where tafforecastid in
        (select tafforecastid from training1_tafforecast)
);
create or replace view training1_tafturbulence as (
    select * from tafturbulence where tafforecastid in
        (select tafforecastid from training1_tafforecast)
);

copy (select * from training1_taf) to '/mnt/out/training1_taf.csv' delimiter ',' csv header;
copy (select * from training1_tafforecast) to '/mnt/out/training1_tafforecast.csv' delimiter ',' csv header;
copy (select * from training1_taficing) to '/mnt/out/training1_taficing.csv' delimiter ',' csv header;
copy (select * from training1_tafsky) to '/mnt/out/training1_tafsky.csv' delimiter ',' csv header;
copy (select * from training1_taftemperature) to '/mnt/out/training1_taftemperature.csv' delimiter ',' csv header;
copy (select * from training1_tafturbulence) to '/mnt/out/training1_tafturbulence.csv' delimiter ',' csv header;

-- ===============================================================
-- AIRSIGMET
-- 1. Filter airsigmet on training dates, Need ids
-- 2. Filter airsigmetarea using airsigmet ids
-- ===============================================================
create or replace view training1_airsigmet as (
    select * from airsigmet where
    timevalidfromutc >= '2013-06-07 09:00:00' 
    and timevalidfromutc < '2013-07-05 09:00:00'
);
-- airsigmetarea
create or replace view training1_airsigmetarea as (
    select * from airsigmetarea where 
    airsigmetid in (select airsigmetid from training1_airsigmet)
);

copy (select * from training1_airsigmet) to '/mnt/out/training1_airsigmet.csv' delimiter ',' csv header;
copy (select * from training1_airsigmetarea) to '/mnt/out/training1_airsigmetarea.csv' delimiter ',' csv header;

 
