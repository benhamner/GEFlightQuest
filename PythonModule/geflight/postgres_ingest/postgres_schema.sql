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
    flighthistory_id        BIGINT REFERENCES flighthistory(id),
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
    asdiflightplan_id BIGINT REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    airway            CHARACTER VARYING);
CREATE INDEX ON asdiairway (asdiflightplan_id);

CREATE TABLE asdifpcenter (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    center            CHARACTER VARYING);
CREATE INDEX ON asdifpcenter (asdiflightplan_id);

CREATE TABLE asdifpfix (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    fix               CHARACTER VARYING);
CREATE INDEX ON asdifpfix (asdiflightplan_id);

CREATE TABLE asdifpsector (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT REFERENCES asdiflightplan(id),
    ordinal           BIGINT,
    sector            CHARACTER VARYING);
CREATE INDEX ON asdifpsector (asdiflightplan_id);

CREATE TABLE asdifpwaypoint (
    id                BIGSERIAL PRIMARY KEY,
    asdiflightplan_id BIGINT REFERENCES asdiflightplan(id),
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
CREATE INDEX ON asdiposition (latitude_degrees);
CREATE INDEX ON asdiposition (longitude_degrees);
