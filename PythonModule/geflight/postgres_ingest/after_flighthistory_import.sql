-- flighthistory contains dates in the wrong time zone. This corrects it

UPDATE flighthistory
SET published_departure = published_departure - ((departure_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE published_departure IS NOT NULL;

UPDATE flighthistory
SET scheduled_gate_departure = scheduled_gate_departure - ((departure_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE scheduled_gate_departure IS NOT NULL;

UPDATE flighthistory
SET estimated_gate_departure = estimated_gate_departure - ((departure_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE estimated_gate_departure IS NOT NULL;

UPDATE flighthistory
SET actual_gate_departure = actual_gate_departure - ((departure_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE actual_gate_departure IS NOT NULL;

UPDATE flighthistory
SET scheduled_runway_departure = scheduled_runway_departure - ((departure_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE scheduled_runway_departure IS NOT NULL;

UPDATE flighthistory
SET estimated_runway_departure = estimated_runway_departure - ((departure_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE estimated_runway_departure IS NOT NULL;

UPDATE flighthistory
SET actual_runway_departure = actual_runway_departure - ((departure_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE actual_runway_departure IS NOT NULL;

UPDATE flighthistory
SET departure_date = departure_date - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE departure_date IS NOT NULL;

UPDATE flighthistory
SET published_arrival = published_arrival - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE published_arrival IS NOT NULL;

UPDATE flighthistory
SET scheduled_gate_arrival = scheduled_gate_arrival - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE scheduled_gate_arrival IS NOT NULL;

UPDATE flighthistory
SET estimated_gate_arrival = estimated_gate_arrival - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE estimated_gate_arrival IS NOT NULL;

UPDATE flighthistory
SET actual_gate_arrival = actual_gate_arrival - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE actual_gate_arrival IS NOT NULL;

UPDATE flighthistory
SET scheduled_runway_arrival = scheduled_runway_arrival - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE scheduled_runway_arrival IS NOT NULL;

UPDATE flighthistory
SET estimated_runway_arrival = estimated_runway_arrival - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE estimated_runway_arrival IS NOT NULL;

UPDATE flighthistory
SET actual_runway_arrival = actual_runway_arrival - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE actual_runway_arrival IS NOT NULL;

UPDATE flighthistory
SET arrival_date = arrival_date - ((arrival_airport_timezone_offset * interval '1 hour') - interval '-7 hours')
WHERE arrival_date IS NOT NULL;
