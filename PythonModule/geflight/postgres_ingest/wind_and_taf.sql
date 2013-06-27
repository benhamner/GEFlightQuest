CREATE TABLE flightstats_fbwind (
    fbwindairportid BIGINT,
    ordinal BIGINT,
    bearing BIGINT,
    knots BIGINT,
    temperature CHARACTER VARYING);

CREATE TABLE flightstats_fbwindairport (
    fbwindairportid BIGINT,
    fbwindreportid BIGINT,
    airportcode CHARACTER VARYING);

CREATE TABLE flightstats_fbwindaltitude (
    fbwindreportid BIGINT,
    ordinal BIGINT,
    altitude BIGINT);

CREATE TABLE flightstats_fbwindreport (
    fbwindreportid BIGINT,
    createdutc TIMESTAMP WITH TIME ZONE,
    reporttype1 CHARACTER VARYING,
    reporttype2 CHARACTER VARYING,
    reporttype3 CHARACTER VARYING,
    generated BIGINT,
    basedon CHARACTER VARYING,
    valid CHARACTER VARYING,
    forusestart BIGINT,
    foruseend BIGINT,
    negativeabove BIGINT,
    altitudescale CHARACTER VARYING,
    altitudeunits CHARACTER VARYING);

CREATE TABLE flightstats_taf (
    tafid BIGINT,
    station CHARACTER VARYING,
    airport CHARACTER VARYING,
    rawtext CHARACTER VARYING,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    elevationmeters BIGINT,
    remarks CHARACTER VARYING,
    bulletintimeutc TIMESTAMP WITH TIME ZONE,
    issuetimeutc TIMESTAMP WITH TIME ZONE,
    validtimefromutc TIMESTAMP WITH TIME ZONE,
    validtimetoutc TIMESTAMP WITH TIME ZONE);

CREATE TABLE flightstats_tafforecast (
    tafforecastid BIGINT,
    tafid BIGINT,
    altimiter CHARACTER VARYING,
    changeindicator CHARACTER VARYING,
    forecasttimefromutc TIMESTAMP WITH TIME ZONE,
    forecasttimetoutc TIMESTAMP WITH TIME ZONE,
    probability CHARACTER VARYING,
    timebecomingutc CHARACTER VARYING,
    verticalvisibility CHARACTER VARYING,
    visibilitystatutemiles DOUBLE PRECISION,
    windspeedknots DOUBLE PRECISION,
    winddirectiondegrees DOUBLE PRECISION,
    windgustspeedknots DOUBLE PRECISION,
    windsheardirectiondegrees CHARACTER VARYING,
    windshearheightfeet CHARACTER VARYING,
    windshearspeedknots CHARACTER VARYING,
    weatherstring CHARACTER VARYING,
    notdecoded CHARACTER VARYING);

CREATE TABLE flightstats_taficing (
    tafforecastid BIGINT,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet CHARACTER VARYING,
    maximumaltitudefeet DOUBLE PRECISION);

CREATE TABLE flightstats_tafsky (
    tafforecastid BIGINT,
    cloudbasefeet DOUBLE PRECISION,
    cloudtype CHARACTER VARYING,
    cloudcover CHARACTER VARYING);

CREATE TABLE flightstats_taftemperature (
    tafforecastid BIGINT,
    validtimeutc TIMESTAMP WITH TIME ZONE,
    mintemperaturecelcius CHARACTER VARYING,
    maxtemperaturecelcius DOUBLE PRECISION,
    surfacetemperaturecelcius CHARACTER VARYING);

CREATE TABLE flightstats_tafturbulence (
    tafforecastid BIGINT,
    intensity DOUBLE PRECISION,
    minimumaltitudefeet DOUBLE PRECISION,
    maximumaltitudefeet DOUBLE PRECISION);