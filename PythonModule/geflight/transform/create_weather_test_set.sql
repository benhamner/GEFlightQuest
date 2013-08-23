-- =======================================================================
-- create_weather_test_set.sql
-- Script for creating weather test set with random time cutoffs.
-- Helper functions are at the bottom of this script.

-- Joyce Noah-Vanhoucke
-- 23 August 2013
-- =======================================================================

-- Test set 1.
-- cutoffs: first 7 are public, last 7 are private
-- ['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
-- '2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
-- '2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00']


-- ============================================================================
-- File processing
-- ============================================================================

-----------------------------------------------------------------------------
-- METAR test
create or replace view test1_metar_reports as (
    select * from apply_time_cutoffs_metar(
        ARRAY['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
'2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
'2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
)
order by id;
copy (select * from test1_metar_reports) to '/mnt/out/test1_metar_reports.csv' delimiter ',' csv header;

-- presentconditions
create or replace view test1_metar_presentconditions as (
    select * from metar_presentconditions
    where metar_reports_id in (select id from test1_metar_reports)
) order by metar_reports_id;
copy (select * from test1_metar_presentconditions) to '/mnt/out/test1_metar_presentconditions.csv' delimiter ',' csv header;

-- skyconditions
create or replace view test1_metar_skyconditions as (
    select * from metar_skyconditions
    where metar_reports_id in (select id from test1_metar_reports)
) order by metar_reports_id;
copy (select * from test1_metar_skyconditions) to '/mnt/out/test1_metar_skyconditions.csv' delimiter ',' csv header;

-- runwayconditions
create or replace view test1_metar_runwaygroups as (
    select * from metar_runwaygroups
    where metar_reports_id in (select id from test1_metar_reports)
) order by metar_reports_id;
copy (select * from test1_metar_runwaygroups) to '/mnt/out/test1_metar_runwaygroups.csv' delimiter ',' csv header;


-------------------------------------------------------------------------------
-- FDWIND test
create or replace view test1_fdwindreport as (
    select * from apply_time_cutoffs_fdwind(
        ARRAY['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
'2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
'2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
)
order by fbwindreportid;
copy (select * from test1_fdwindreport) to '/mnt/out/test1_fdwindreport.csv' delimiter ',' csv header;

-- airport using report ids
create or replace view test1_fdwindairport as (
    select * from fdwindairport where 
        fbwindreportid in (select fbwindreportid from test1_fdwindreport)
) order by fbwindreportid;
copy (select * from test1_fdwindairport) to '/mnt/out/test1_fdwindairport.csv' delimiter ',' csv header;

-- altitude uses report ids
create or replace view test1_fdwindaltitude as (
    select * from fdwindaltitude where 
        fbwindreportid in (select fbwindreportid from test1_fdwindreport)
) order by fbwindreportid;
copy (select * from test1_fdwindaltitude) to '/mnt/out/test1_fdwindaltitude.csv' delimiter ',' csv header;

-- wind using airport ids
create or replace view test1_fdwind as (
    select * from fdwind where 
        fbwindairportid in (SELECT fbwindairportid from test1_public_fdwindairport)
) order by fbwindairportid;
copy (select * from test1_fdwind) to '/mnt/out/test1_fdwind.csv' delimiter ',' csv header;

-------------------------------------------------------------------------------
-- AIRSIGMET test
create or replace view test1_airsigmet as (
    select * from apply_time_cutoffs_airsigmet(
        ARRAY['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
'2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
'2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
) order by airsigmetid;
copy (select * from test1_airsigmet) to '/mnt/out/test1_airsigmet.csv' delimiter ',' csv header;

-- airsigmetarea
create or replace view test1_airsigmetarea as (
    select * from airsigmetarea where 
    airsigmetid in (select airsigmetid from test1_airsigmet)
);
copy (select * from test1_airsigmetarea) to '/mnt/out/test1_airsigmetarea.csv' delimiter ',' csv header;

-------------------------------------------------------------------------------
-- TAF test
create or replace view test1_taf as ( 
    select * from apply_time_cutoffs_taf(
        ARRAY['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
'2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
'2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
)
order by tafid;
copy (select * from test1_taf) to '/mnt/out/test1_taf.csv' delimiter ',' csv header;

create or replace view test1_tafforecast as (
    select * from apply_time_cutoffs_tafforecast(
            ARRAY['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
    '2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
    '2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
    where tafid in (select tafid from test1_taf) )
order by tafid;
copy (select * from test1_tafforecast) to '/mnt/out/test1_tafforecast.csv' delimiter ',' csv header;

-- taf icing, sky, temp, turbulence on tafforecastid
create or replace view test1_taficing as (
    select * from taficing where tafforecastid in
        (select tafforecastid from test1_tafforecast)
);
copy (select * from test1_taficing) to '/mnt/out/test1_taficing.csv' delimiter ',' csv header;

create or replace view test1_tafsky as (
    select * from tafsky where tafforecastid in
        (select tafforecastid from test1_tafforecast)
);
copy (select * from test1_tafsky) to '/mnt/out/test1_tafsky.csv' delimiter ',' csv header;

create or replace view test1_taftemperature as (
    select * from taftemperature where tafforecastid in
        (select tafforecastid from test1_tafforecast)
);
copy (select * from test1_taftemperature) to '/mnt/out/test1_taftemperature.csv' delimiter ',' csv header;

create or replace view test1_tafturbulence as (
    select * from tafturbulence where tafforecastid in
        (select tafforecastid from test1_tafforecast)
);
copy (select * from test1_tafturbulence) to '/mnt/out/test1_tafturbulence.csv' delimiter ',' csv header;


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


-- =======================================================================
-- apply_time_cutoffs_XXX()
-- Given an array of cutoff times, filters each of the weather tables.
-- A version of this function is needed for each type of weather table:
--   * metar, airsigmet, fdwind, taf
-- usage: select * from apply_time_cutoffs('2013-12-12 10:30:0+00')
-- =======================================================================

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

