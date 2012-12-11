GE Flight Quest
===============

This repo contains code for the [GE Flight Quest](http://www.gequest.com/c/flight). It contains the code to split the original FlightStats data files (not released publicly) into training days. It also contains code to take a training day and a cutoff time and then create a sample test day from it.

The code for doing this is split between two folders: 

**PythonModule** - a python module named geflight that handles:

   - FlightHistory files
   - ASDI files

**DavidWeatherCode** - python scripts for handling the following sets of files:

   - METAR files
   - ATSCC files
   - OtherWeather files

If time permits, the code to split up the weather files will be modified appropriately and rolled into the geflight Python module.

Authors
-------

 - **Ben Hamner** [@benhamner](https://twitter.com/benhamner)
 - **David Chudzicki**