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