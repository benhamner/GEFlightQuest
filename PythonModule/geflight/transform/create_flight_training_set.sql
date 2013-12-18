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


-- create base flight history with only 26 columns, in the proper date
-- range and for only US airports.
drop table if exists base_flighthistory;
CREATE table base_flighthistory AS 
SELECT 
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
where
    (
    published_departure >= '2013-11-14 09:00:00+00'
    OR ( published_departure IS NULL AND scheduled_gate_departure >= '2013-11-14 09:00:00+00' )
    OR ( published_departure IS NULL AND scheduled_gate_departure IS NULL AND scheduled_runway_departure >= '2013-11-14 09:00:00+00' ) 
    )
    AND (departure_airport_icao_code LIKE 'K%' AND arrival_airport_icao_code LIKE 'K%')
;

-- Training: flighthistory
drop table if exists training2_flighthistory;
CREATE table training2_flighthistory as 
    select * from base_flighthistory WHERE 
        (
            published_departure < '2013-12-12 09:00:00+00'
            OR ( published_departure IS NULL AND scheduled_gate_departure < '2013-12-12 09:00:00+00' )
            OR ( published_departure IS NULL AND scheduled_gate_departure IS NULL AND scheduled_runway_departure < '2013-12-12 09:00:00+00' ) 
        );

 -- flighthistory ids
drop table if exists flighthistory_ids;
create table flighthistory_ids as select id from training2_flighthistory;


-- Training: flighthistoryevents
drop table if exists training2_flighthistoryevents;
create table training2_flighthistoryevents as
    select * from flighthistoryevents where 
        flighthistory_id in (select * from flighthistory_ids);


-- ASDI flight plan, uses flighthistory_id)
drop table if exists training2_asdiflightplan;
create table training2_asdiflightplan as
    select * from asdiflightplan where
        flighthistory_id in (select id from flighthistory_ids);


-- ASDI Flight Plan IDs
drop table if exists asdiflightplan_ids;
create table asdiflightplan_ids as select id from training2_asdiflightplan;

-- ASDI airway
drop table if exists training2_asdiairway;
create table training2_asdiairway as
    select * from asdiairway where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Fix
drop table if exists training2_asdifpfix;
create table training2_asdifpfix as
    select * from asdifpfix where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Center
drop table if exists training2_asdifpcenter;
create table training2_asdifpcenter as
    select * from asdifpcenter where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Sector
drop table if exists training2_asdifpsector;
create table training2_asdifpsector as
    select * from asdifpsector where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI Position (uses flighthistoryid)
drop table if exists training2_asdiposition;
create table training2_asdiposition as
    select * from asdiposition where
        flighthistory_id in (select * from flighthistory_ids);
-- ASDI FP Waypoint
drop table if exists training2_asdifpwaypoint;
create table training2_asdifpwaypoint as
    select * from asdifpwaypoint where
        asdiflightplan_id in (select * from asdiflightplan_ids);


-- Write to file
copy (select * from training2_flighthistory) to 'C:/FQ2DataRelease2/training2_flighthistory.csv' delimiter ',' csv header;
copy (select * from training2_flighthistoryevents) to 'C:/FQ2DataRelease2/training2_flighthistoryevents.csv' delimiter ',' csv header;
copy (select * from training2_asdiairway) to 'C:/FQ2DataRelease2/training2_asdiairway.csv' delimiter ',' csv header; 
copy (select * from training2_asdiflightplan) to 'C:/FQ2DataRelease2/training2_asdiflightplan.csv' delimiter ',' csv header; 
copy (select * from training2_asdifpcenter) to 'C:/FQ2DataRelease2/training2_asdifpcenter.csv' delimiter ',' csv header; 
copy (Select * from training2_asdifpfix) to 'C:/FQ2DataRelease2/training2_asdifpfix.csv' delimiter ',' csv header; 
copy (select * from training2_asdifpsector) to 'C:/FQ2DataRelease2/training2_asdifpsector.csv' delimiter ',' csv header; 
copy (select * from training2_asdifpwaypoint) to 'C:/FQ2DataRelease2/training2_asdifpwaypoint.csv' delimiter ',' csv header; 
copy (select * from training2_asdiposition) to 'C:/FQ2DataRelease2/training2_asdiposition.csv' delimiter ',' csv header;



-- ===============================================================
-- METAR
-- 1. Filter metar_reports for training period dates. Need ids
-- 2. Use metar_reports_id to filter in order:
--      * presentconditions, skyconditions, runwayconditions
-- ===============================================================
-- metar_reports: create view with training date constraints
drop table if exists training2_metar_reports;
create table training2_metar_reports as ( 
    select * from metar_reports where
    date_time_issued >= '2013-11-14 09:00:00+00' and date_time_issued < '2013-12-12 09:00:00+00'
);

-- presentconditions
drop table if exists training2_metar_presentconditions;
create table training2_metar_presentconditions as (
    select * from metar_presentconditions
    where metar_reports_id in (select id from training2_metar_reports)
);
-- skyconditions
drop table if exists training2_metar_skyconditions;
create table training2_metar_skyconditions as (
    select * from metar_skyconditions
    where metar_reports_id in (select id from training2_metar_reports)
);

-- runwayconditions
drop table if exists training2_metar_runwaygroups;
create table training2_metar_runwaygroups as (
    select * from metar_runwaygroups
    where metar_reports_id in (select id from training2_metar_reports)
);

copy (select * from training2_metar_reports) to 'C:/FQ2DataRelease2/training2_metar_reports.csv' delimiter ',' csv header;
copy (select * from training2_metar_presentconditions) to 'C:/FQ2DataRelease2/training2_metar_presentconditions.csv' delimiter ',' csv header;
copy (select * from training2_metar_skyconditions) to 'C:/FQ2DataRelease2/training2_metar_skyconditions.csv' delimiter ',' csv header;
copy (select * from training2_metar_runwaygroups) to 'C:/FQ2DataRelease2/training2_metar_runwaygroups.csv' delimiter ',' csv header;


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
drop table if exists training2_fdwindreport;
create table training2_fdwindreport as (
    select * from fdwindreport where
    createdutc >= '2013-11-14 09:00:00+00' and createdutc < '2013-12-12 09:00:00+00'
);
-- airport using report ids
drop table if exists training2_fdwindairport;
create table training2_fdwindairport as (
    select * from fdwindairport where fbwindreportid in 
        (select fbwindreportid from training2_fdwindreport)
);

-- altitude uses report ids
drop table if exists training2_fdwindaltitude;
create table training2_fdwindaltitude as (
    select * from fdwindaltitude where fbwindreportid in 
        (select fbwindreportid from training2_fdwindreport)
);
-- wind using airport ids
drop table if exists training2_fdwind;
create table training2_fdwind as (
    select * from fdwind where fbwindairportid in
        (SELECT fbwindairportid from training2_fdwindairport)
);

copy (select * from training2_fdwindreport) to 'C:/FQ2DataRelease2/training2_fdwindreport.csv' delimiter ',' csv header;
copy (select * from training2_fdwindairport) to 'C:/FQ2DataRelease2/training2_fdwindairport.csv' delimiter ',' csv header;
copy (select * from training2_fdwindaltitude) to 'C:/FQ2DataRelease2/training2_fdwindaltitude.csv' delimiter ',' csv header;
copy (select * from training2_fdwind) to 'C:/FQ2DataRelease2/training2_fdwind.csv' delimiter ',' csv header;

-- ===============================================================
-- TAF
-- 1. Filter taf for training period dates, Need ids
-- 2. Use tafid to filter in order:
--    * taf forecast, icing, sky, temp, turbulence
-- ===============================================================
drop table if exists training2_taf;
create table training2_taf as (
    select * from taf where 
    bulletintimeutc >= '2013-11-14 09:00:00+00' and bulletintimeutc < '2013-12-12 09:00:00+00'
);
-- taf forecast on taf ids
drop table if exists training2_tafforecast;
CREATE TABLE training2_tafforecast as (
    select * from tafforecast where tafid in
        (select tafid from training2_taf)
);
-- taf icing, sky, temp, turbulence on tafforecastid
drop table if exists training2_taficing;
CREATE TABLE training2_taficing as (
    select * from taficing where tafforecastid in
        (select tafforecastid from training2_tafforecast)
);
drop table if exists training2_tafsky;
CREATE TABLE training2_tafsky as (
    select * from tafsky where tafforecastid in
        (select tafforecastid from training2_tafforecast)
);
drop table if exists training2_taftemperature;
CREATE TABLE training2_taftemperature as (
    select * from taftemperature where tafforecastid in
        (select tafforecastid from training2_tafforecast)
);
drop table if exists training2_tafturbulence;
CREATE TABLE training2_tafturbulence as (
    select * from tafturbulence where tafforecastid in
        (select tafforecastid from training2_tafforecast)
);

copy (select * from training2_taf) to 'C:/FQ2DataRelease2/training2_taf.csv' delimiter ',' csv header;
copy (select * from training2_tafforecast) to 'C:/FQ2DataRelease2/training2_tafforecast.csv' delimiter ',' csv header;
copy (select * from training2_taficing) to 'C:/FQ2DataRelease2/training2_taficing.csv' delimiter ',' csv header;
copy (select * from training2_tafsky) to 'C:/FQ2DataRelease2/training2_tafsky.csv' delimiter ',' csv header;
copy (select * from training2_taftemperature) to 'C:/FQ2DataRelease2/training2_taftemperature.csv' delimiter ',' csv header;
copy (select * from training2_tafturbulence) to 'C:/FQ2DataRelease2/training2_tafturbulence.csv' delimiter ',' csv header;

-- ===============================================================
-- AIRSIGMET
-- 1. Filter airsigmet on training dates, Need ids
-- 2. Filter airsigmetarea using airsigmet ids
-- ===============================================================
drop table if exists training2_airsigmet;
CREATE TABLE training2_airsigmet as (
    select * from airsigmet where
    timevalidfromutc >= '2013-11-14 09:00:00+00'
    and timevalidfromutc < '2013-12-12 09:00:00+00'
);
-- airsigmetarea
drop table if exists training2_airsigmetarea;
CREATE TABLE training2_airsigmetarea as (
    select * from airsigmetarea where 
    airsigmetid in (select airsigmetid from training2_airsigmet)
);

copy (select * from training2_airsigmet) to 'C:/FQ2DataRelease2/training2_airsigmet.csv' delimiter ',' csv header;
copy (select * from training2_airsigmetarea) to 'C:/FQ2DataRelease2/training2_airsigmetarea.csv' delimiter ',' csv header;

 
