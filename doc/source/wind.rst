The *data/wind* module
====================================

The *data/wind* module directory provides routines to read the
Wind spacecraft data.

The *waves* directory
-------------------------------------------

The *waves* directory concerns Wind / Waves experiment data.

The *lesia* routines
````````````````````````````
Here are routines that can be used to read Waves data files produced by the LESIA:

- read_wind_waves_hres      read the Wind/Waves L2 high resolution data (big endian binary format)
- read_wind_waves_60s       read the Wind/Waves L2 60 sec. averaged data (big endian binary format)

