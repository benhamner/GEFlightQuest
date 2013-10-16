--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Redo Training ASDI Position
drop table if exists training2_asdiposition;
create table training2_asdiposition as
    select * from asdiposition where
        flighthistory_id in (select * from flighthistory_ids);
copy (select * from training2_asdiposition) to 'C:/FQ2DataRelease2/training2_asdiposition.csv' delimiter ',' csv header;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Redo Training METAR
drop table if exists training2_metar_reports;
create table training2_metar_reports as ( 
    select * from metar_reports where
    date_time_issued >= '2013-08-14 09:00:00+00' and date_time_issued < '2013-09-11 09:00:00+00'
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

--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- Redo Test ASDI Position
drop table if exists test2_asdiposition;
create table test2_asdiposition as (
    select * from apply_time_cutoffs_asdiposition(
        ARRAY['2013-09-11 18:24:19', '2013-09-12 21:31:59', '2013-09-13 16:11:56','2013-09-14 23:49:31', 
            '2013-09-15 19:10:16', '2013-09-16 15:47:50', '2013-09-17 14:22:31', '2013-09-18 14:12:58',
            '2013-09-19 19:21:39', '2013-09-20 15:14:26', '2013-09-21 21:16:19', '2013-09-22 14:19:51', 
            '2013-09-23 15:09:29', '2013-09-24 18:22:23']);
copy (select * from test2_asdiposition) to 'C:/FQ2DataRelease2/test2_asdiposition.csv' delimiter ',' csv header;
            

--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- Redo Test METAR

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
