
ALTER TABLE flighthistory ADD PRIMARY KEY (id);
CREATE INDEX ON flighthistory (departure_airport_icao_code);
CREATE INDEX ON flighthistory (arrival_airport_icao_code);
CREATE INDEX ON flighthistory (actual_runway_departure);
CREATE INDEX ON flighthistory (actual_runway_arrival);

ALTER TABLE flighthistoryevents ADD PRIMARY KEY (id);
ALTER TABLE flighthistoryevents
ADD CONSTRAINT flighthistoryevents_flighthistory_fk
FOREIGN KEY (flighthistory_id)
REFERENCES flighthistory (id) MATCH FULL;
CREATE INDEX ON flighthistoryevents (flighthistory_id);
CREATE INDEX ON flighthistoryevents (date_time_recorded);


ALTER TABLE asdiflightplan ADD PRIMARY KEY (id);
ALTER TABLE asdiflightplan
ADD CONSTRAINT asdiflightplan_flighthistory_fk
FOREIGN KEY (flighthistory_id)
REFERENCES flighthistory (id) MATCH FULL;
CREATE INDEX ON asdiflightplan (flighthistory_id);

ALTER TABLE asdiposition ADD PRIMARY KEY (id);
ALTER TABLE asdiposition
ADD CONSTRAINT asdiposition_flighthistory_fk
FOREIGN KEY (flighthistory_id)
REFERENCES flighthistory (id) MATCH FULL;
CREATE INDEX ON asdiposition (flighthistory_id);

ALTER TABLE metar_reports ADD PRIMARY KEY (id);