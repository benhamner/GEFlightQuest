-- =======================================================================
-- Query to correct for times not in UTC since there were ingested into a postgres server on PDT.
-- @Author: Joyce Noah-Vanhoucke
-- @Created: 14 October 2013

-- =======================================================================


-- -------------------------------------------------------------------------
-- ASDI Flight Plan: cols are 
--   original_departure_utc
--   estimated_departure_utc
--   original_arrival_utc
--   estimated_arrival_utc
-- -------------------------------------------------------------------------
update asdiflightplan
set estimated_departure_utc = estimated_departure_utc - (interval '-7 hours');
--where estimated_departure_utc is not null;

update asdiflightplan
set original_departure_utc = original_departure_utc - (interval '-7 hours');
--where original_departure_utc is not null;

update asdiflightplan
set original_arrival_utc = original_arrival_utc - (interval '-7 hours');
--where original_arrival_utc is not null;

update asdiflightplan
set estimated_arrival_utc = estimated_arrival_utc - (interval '-7 hours');
--where estimated_arrival_utc is not null;

-- -------------------------------------------------------------------------
-- ASDI Position: col is
-- received
-- -------------------------------------------------------------------------
update asdiposition
set received = received - (interval '-7 hours');
--where received is not null;

-- -------------------------------------------------------------------------
-- FD Wind Report: cols is
-- createdutc
-- -------------------------------------------------------------------------
update fdwindreport 
set createdutc = createdutc - (interval '-7 hours');
--where createdutc is not null;

-- -------------------------------------------------------------------------
-- Metar Report: cols is
-- date_time_issued
-- -------------------------------------------------------------------------
update metar_reports 
set date_time_issued = date_time_issued - (interval '-7 hours');
--where date_time_issued is not null;

-- -------------------------------------------------------------------------
-- Taf: cols are
-- bulletintimeutc
-- issuetimeutc
-- validtimefromutc
-- validtimetoutc
-- -------------------------------------------------------------------------
update taf 
set issuetimeutc = issuetimeutc - (interval '-7 hours');
--where issuetimeutc is not null;

update taf 
set bulletintimeutc = bulletintimeutc - (interval '-7 hours');
--where bulletintimeutc is not null;

update taf 
set validtimefromutc = validtimefromutc - (interval '-7 hours');
--where validtimefromutc is not null;

update taf 
set validtimetoutc = validtimetoutc - (interval '-7 hours');
--where validtimetoutc is not null;

-- -------------------------------------------------------------------------
-- Tafforecast: cols are
-- forecasttimefromutc
-- forecasttimetoutc
-- -------------------------------------------------------------------------
update tafforecast 
set forecasttimefromutc = forecasttimefromutc - (interval '-7 hours');
--where forecasttimefromutc is not null;

update tafforecast 
set forecasttimetoutc = forecasttimetoutc - (interval '-7 hours');
--where forecasttimetoutc is not null;

-- -------------------------------------------------------------------------
-- Taftemperature: cols are
-- validtimeutc
-- -------------------------------------------------------------------------
update taftemperature
set validtimeutc = validtimeutc - (interval '-7 hours');
--where validtimeutc is not null;
