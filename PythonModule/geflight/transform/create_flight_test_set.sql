-- Test set 1.
-- cutoffs: first 7 are public, last 7 are private
-- ['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
-- '2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
-- '2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00']


-- create base test flight history: remove extra cols, keep overall relevant time window
-- Total = 24 cols. Training has 26, remove actual_gate_arrival and actual_runway_arrival.
drop view basetest_flighthistory cascade;
CREATE OR REPLACE VIEW basetest_flighthistory AS SELECT 
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
        published_departure >= '2013-07-05 09:00:00+00'
        OR ( published_departure IS NULL AND scheduled_gate_departure >= '2013-07-05 09:00:00+00' )
        OR ( published_departure IS NULL AND scheduled_gate_departure IS NULL AND scheduled_runway_departure >= '2013-07-05 09:00:00+00' ) 
    )
    AND (departure_airport_icao_code LIKE 'K%' AND arrival_airport_icao_code LIKE 'K%');


select * from basetest_flighthistory limit 10

-- PUBLIC FLIGHT HISTORY
create or replace view test1_flighthistory as (
    select * from apply_time_cutoffs_flighthistory( 
            ARRAY['2013-07-05 21:56:00+00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
    '2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
    '2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
)
order by id;
copy (select * from test1_flighthistory) to '/mnt/out/test1_flighthistory.csv' delimiter ',' csv header;

select * from basetest_flighthistory limit 5
select * from test1_flighthistory where published_departure > '2013-07-09 22:30:00+00' and published_departure < '2013-07-09 23:30:00+00'
limit 50

-- PUBLIC flighthistoryevents
-- FLIGHTHISTORYEVENTS test
create or replace view test1_flighthistoryevents as (
    select * from apply_time_cutoffs_flighthistoryevents( 
            ARRAY['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
    '2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
    '2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
);
--order by flighthistory_id;
copy (select * from test1_flighthistoryevents) to '/mnt/out/test1_flighthistoryevents.csv' delimiter ',' csv header;

select * from test1_flighthistoryevents limit 5


create temp table temp_flighthistoryevents as (
    select * from apply_time_cutoffs_flighthistoryevents( 
            ARRAY['2013-07-05 21:56:00', '2013-07-07 22:29:00', '2013-07-09 23:01:00', '2013-07-11 23:33:00', '2013-07-14 00:06:00', 
    '2013-07-16 00:38:00', '2013-07-18 01:10:00', '2013-07-06 16:13:00', '2013-07-08 16:45:00', '2013-07-10 17:17:00', 
    '2013-07-12 17:49:00', '2013-07-14 18:22:00', '2013-07-16 18:54:00', '2013-07-18 19:26:00'])
);
--order by flighthistory_id;





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
            (published_departure >= set_start_time(cutoff) and published_departure < cutoff)
            or
            (published_departure is null and scheduled_gate_departure >= set_start_time(cutoff) and scheduled_gate_departure < cutoff)
            or 
            (published_departure is null and scheduled_gate_departure is null and 
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

