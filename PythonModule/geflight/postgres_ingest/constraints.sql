
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

ALTER TABLE asdiairway ADD PRIMARY KEY (id);

ALTER TABLE asdiflightplan ADD PRIMARY KEY (id);
ALTER TABLE asdiflightplan
ADD CONSTRAINT asdiflightplan_flighthistory_fk
FOREIGN KEY (flighthistory_id)
REFERENCES flighthistory (id) MATCH FULL;
CREATE INDEX ON asdiflightplan (flighthistory_id);

ALTER TABLE asdiairway ADD PRIMARY KEY (id);
ALTER TABLE asdiairway
ADD CONSTRAINT asdiairway_asdiflightplan_fk
FOREIGN KEY (asdiflightplan_id)
REFERENCES asdiflightplan (id) MATCH FULL;
CREATE INDEX ON asdiairway (asdiflightplan_id);

ALTER TABLE asdifpcenter ADD PRIMARY KEY (id);
ALTER TABLE asdifpcenter
ADD CONSTRAINT asdifpcenter_asdiflightplan_fk
FOREIGN KEY (asdiflightplan_id)
REFERENCES asdiflightplan (id) MATCH FULL;
CREATE INDEX ON asdifpcenter (asdiflightplan_id);

ALTER TABLE asdifpfix ADD PRIMARY KEY (id);
ALTER TABLE asdifpfix
ADD CONSTRAINT asdifpfix_asdiflightplan_fk
FOREIGN KEY (asdiflightplan_id)
REFERENCES asdiflightplan (id) MATCH FULL;
CREATE INDEX ON asdifpfix (asdiflightplan_id);

ALTER TABLE asdifpsector ADD PRIMARY KEY (id);
ALTER TABLE asdifpsector
ADD CONSTRAINT asdifpsector_asdiflightplan_fk
FOREIGN KEY (asdiflightplan_id)
REFERENCES asdiflightplan (id) MATCH FULL;
CREATE INDEX ON asdifpsector (asdiflightplan_id);

ALTER TABLE asdifpwaypoint ADD PRIMARY KEY (id);
ALTER TABLE asdifpwaypoint
ADD CONSTRAINT asdifpwaypoint_asdiflightplan_fk
FOREIGN KEY (asdiflightplan_id)
REFERENCES asdifpwaypoint (id) MATCH FULL;
CREATE INDEX ON asdifpwaypoint (asdiflightplan_id);

ALTER TABLE asdiposition ADD PRIMARY KEY (id);
ALTER TABLE asdiposition
ADD CONSTRAINT asdiposition_flighthistory_fk
FOREIGN KEY (flighthistory_id)
REFERENCES flighthistory (id) MATCH FULL;
CREATE INDEX ON asdiposition (flighthistory_id);

ALTER TABLE metar_reports ADD PRIMARY KEY (id);

ALTER TABLE airsigmet ADD PRIMARY KEY (airsigmetid);

ALTER TABLE fdwindreport ADD PRIMARY KEY (fbwindreportid);