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
    AND (departure_airport_icao_code LIKE 'K%' OR arrival_airport_icao_code LIKE 'K%')
;

-- Training: flighthistory
drop table if exists training3_flighthistory;
CREATE table training3_flighthistory as 
    select * from base_flighthistory WHERE 
        (
            published_departure < '2013-12-12 09:00:00+00'
            OR ( published_departure IS NULL AND scheduled_gate_departure < '2013-12-12 09:00:00+00' )
            OR ( published_departure IS NULL AND scheduled_gate_departure IS NULL AND scheduled_runway_departure < '2013-12-12 09:00:00+00' ) 
        );

 -- flighthistory ids
drop table if exists flighthistory_ids;
create table flighthistory_ids as select id from training3_flighthistory;


-- Training: flighthistoryevents
drop table if exists training3_flighthistoryevents;
create table training3_flighthistoryevents as
    select * from flighthistoryevents where 
        flighthistory_id in (select * from flighthistory_ids);


-- ASDI flight plan, uses flighthistory_id)
drop table if exists training3_asdiflightplan;
create table training3_asdiflightplan as
    select * from asdiflightplan where
        flighthistory_id in (select id from flighthistory_ids);


-- ASDI Flight Plan IDs
drop table if exists asdiflightplan_ids;
create table asdiflightplan_ids as select id from training3_asdiflightplan;

-- ASDI airway
drop table if exists training3_asdiairway;
create table training3_asdiairway as
    select * from asdiairway where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Fix
drop table if exists training3_asdifpfix;
create table training3_asdifpfix as
    select * from asdifpfix where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Center
drop table if exists training3_asdifpcenter;
create table training3_asdifpcenter as
    select * from asdifpcenter where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI FP Sector
drop table if exists training3_asdifpsector;
create table training3_asdifpsector as
    select * from asdifpsector where
        asdiflightplan_id in (select * from asdiflightplan_ids);
-- ASDI Position (uses flighthistoryid)
drop table if exists training3_asdiposition;
create table training3_asdiposition as
    select * from asdiposition where
        flighthistory_id in (select * from flighthistory_ids);
-- ASDI FP Waypoint
drop table if exists training3_asdifpwaypoint;
create table training3_asdifpwaypoint as
    select * from asdifpwaypoint where
        asdiflightplan_id in (select * from asdiflightplan_ids);


-- Write to file
copy (select * from training3_flighthistory) to 'E:/FQ2_Data/training3_flighthistory.csv' delimiter ',' csv header;
copy (select * from training3_flighthistoryevents) to 'E:/FQ2_Data/training3_flighthistoryevents.csv' delimiter ',' csv header;
copy (select * from training3_asdiairway) to 'E:/FQ2_Data/training3_asdiairway.csv' delimiter ',' csv header; 
copy (select * from training3_asdiflightplan) to 'E:/FQ2_Data/training3_asdiflightplan.csv' delimiter ',' csv header; 
copy (select * from training3_asdifpcenter) to 'E:/FQ2_Data//training3_asdifpcenter.csv' delimiter ',' csv header; 
copy (Select * from training3_asdifpfix) to 'E:/FQ2_Data//training3_asdifpfix.csv' delimiter ',' csv header; 
copy (select * from training3_asdifpsector) to 'E:/FQ2_Data/training3_asdifpsector.csv' delimiter ',' csv header; 
copy (select * from training3_asdifpwaypoint) to 'E:/FQ2_Data/training3_asdifpwaypoint.csv' delimiter ',' csv header; 
copy (select * from training3_asdiposition) to 'E:/FQ2_Data/training3_asdiposition.csv' delimiter ',' csv header;



-- ===============================================================
-- METAR
-- 1. Filter metar_reports for training period dates. Need ids
-- 2. Use metar_reports_id to filter in order:
--      * presentconditions, skyconditions, runwayconditions
-- ===============================================================
-- metar_reports: create view with training date constraints
drop table if exists training3_metar_reports;
create table training3_metar_reports as ( 
    select * from metar_reports where
    date_time_issued >= '2013-11-14 09:00:00+00' and date_time_issued < '2013-12-12 09:00:00+00'
);

-- presentconditions
drop table if exists training3_metar_presentconditions;
create table training3_metar_presentconditions as (
    select * from metar_presentconditions
    where metar_reports_id in (select id from training3_metar_reports)
);
-- skyconditions
drop table if exists training3_metar_skyconditions;
create table training3_metar_skyconditions as (
    select * from metar_skyconditions
    where metar_reports_id in (select id from training3_metar_reports)
);

-- runwayconditions
drop table if exists training3_metar_runwaygroups;
create table training3_metar_runwaygroups as (
    select * from metar_runwaygroups
    where metar_reports_id in (select id from training3_metar_reports)
);

copy (select * from training3_metar_reports) to 'E:/FQ2_Data/training3_metar_reports.csv' delimiter ',' csv header;
copy (select * from training3_metar_presentconditions) to 'E:/FQ2_Data/training3_metar_presentconditions.csv' delimiter ',' csv header;
copy (select * from training3_metar_skyconditions) to 'E:/FQ2_Data/training3_metar_skyconditions.csv' delimiter ',' csv header;
copy (select * from training3_metar_runwaygroups) to 'E:/FQ2_Data/training3_metar_runwaygroups.csv' delimiter ',' csv header;


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
drop table if exists training3_fdwindreport;
create table training3_fdwindreport as (
    select * from fdwindreport where
    createdutc >= '2013-11-14 09:00:00+00' and createdutc < '2013-12-12 09:00:00+00'
);
-- airport using report ids
drop table if exists training3_fdwindairport;
create table training3_fdwindairport as (
    select * from fdwindairport where fbwindreportid in 
        (select fbwindreportid from training3_fdwindreport)
);

-- altitude uses report ids
drop table if exists training3_fdwindaltitude;
create table training3_fdwindaltitude as (
    select * from fdwindaltitude where fbwindreportid in 
        (select fbwindreportid from training3_fdwindreport)
);
-- wind using airport ids
drop table if exists training3_fdwind;
create table training3_fdwind as (
    select * from fdwind where fbwindairportid in
        (SELECT fbwindairportid from training3_fdwindairport)
);

copy (select * from training3_fdwindreport) to 'E:/FQ2_Data/training3_fdwindreport.csv' delimiter ',' csv header;
copy (select * from training3_fdwindairport) to 'E:/FQ2_Data/training3_fdwindairport.csv' delimiter ',' csv header;
copy (select * from training3_fdwindaltitude) to 'E:/FQ2_Data/training3_fdwindaltitude.csv' delimiter ',' csv header;
copy (select * from training3_fdwind) to 'E:/FQ2_Data/training3_fdwind.csv' delimiter ',' csv header;

-- ===============================================================
-- TAF
-- 1. Filter taf for training period dates, Need ids
-- 2. Use tafid to filter in order:
--    * taf forecast, icing, sky, temp, turbulence
-- ===============================================================
drop table if exists training3_taf;
create table training3_taf as (
    select * from taf where 
    bulletintimeutc >= '2013-11-14 09:00:00+00' and bulletintimeutc < '2013-12-12 09:00:00+00'
);
-- taf forecast on taf ids
drop table if exists training3_tafforecast;
CREATE TABLE training3_tafforecast as (
    select * from tafforecast where tafid in
        (select tafid from training3_taf)
);
-- taf icing, sky, temp, turbulence on tafforecastid
drop table if exists training3_taficing;
CREATE TABLE training3_taficing as (
    select * from taficing where tafforecastid in
        (select tafforecastid from training3_tafforecast)
);
drop table if exists training3_tafsky;
CREATE TABLE training3_tafsky as (
    select * from tafsky where tafforecastid in
        (select tafforecastid from training3_tafforecast)
);
drop table if exists training3_taftemperature;
CREATE TABLE training3_taftemperature as (
    select * from taftemperature where tafforecastid in
        (select tafforecastid from training3_tafforecast)
);
drop table if exists training3_tafturbulence;
CREATE TABLE training3_tafturbulence as (
    select * from tafturbulence where tafforecastid in
        (select tafforecastid from training3_tafforecast)
);

copy (select * from training3_taf) to 'E:/FQ2_Data/training3_taf.csv' delimiter ',' csv header;
copy (select * from training3_tafforecast) to 'E:/FQ2_Data/training3_tafforecast.csv' delimiter ',' csv header;
copy (select * from training3_taficing) to 'E:/FQ2_Data/training3_taficing.csv' delimiter ',' csv header;
copy (select * from training3_tafsky) to 'E:/FQ2_Data/training3_tafsky.csv' delimiter ',' csv header;
copy (select * from training3_taftemperature) to 'E:/FQ2_Data/training3_taftemperature.csv' delimiter ',' csv header;
copy (select * from training3_tafturbulence) to 'E:/FQ2_Data/training3_tafturbulence.csv' delimiter ',' csv header;

-- ===============================================================
-- AIRSIGMET
-- 1. Filter airsigmet on training dates, Need ids
-- 2. Filter airsigmetarea using airsigmet ids
-- ===============================================================
drop table if exists training3_airsigmet;
CREATE TABLE training3_airsigmet as (
    select * from airsigmet where
    timevalidfromutc >= '2013-11-14 09:00:00+00'
    and timevalidfromutc < '2013-12-12 09:00:00+00'
);
-- airsigmetarea
drop table if exists training3_airsigmetarea;
CREATE TABLE training3_airsigmetarea as (
    select * from airsigmetarea where 
    airsigmetid in (select airsigmetid from training3_airsigmet)
);

copy (select * from training3_airsigmet) to 'E:/FQ2_Data/training3_airsigmet.csv' delimiter ',' csv header;
copy (select * from training3_airsigmetarea) to 'E:/FQ2_Data/training3_airsigmetarea.csv' delimiter ',' csv header;

 
