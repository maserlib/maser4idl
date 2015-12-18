PRO data_wind_waves_gp__define

sigma = {data_WIND_Waves_gp_sigma, $
         intensity:0.0, taumod:0.0, $
         rayang:0.0, azimut:0.0, elevat:0.0, $
         V:0.0, Q:0.0, U:0.0}

tmp = {data_WIND_Waves_gp, $
       receiver_code:0b,   $ ; receiver index (Rad1=1, Rad2=2)
       irecord:0l,         $ ; record index
       isweep:0l,          $ ; sweep index
       ianten:0,           $ ; antenna mode index (=1 -> SUM MODE, =0 -> SEP MODE) 
       freq:0.0,           $ ; frequency in kHz
       sec:0.0d,           $ ; seconds since the beginning of the day (i.e., at 00:00:00 UTC)
       intensity:0.0,      $ ; intensity in SFU
       taumod:0.0,         $ ; modulation rate
       rayang:0.0,         $ ; angular radius in degrees
       azimut:0.0,         $ ; azimuth angle in degrees
       elevat:0.0,         $ ; elevation angle in degrees
       V:0.0,              $ ; V Stokes parameter
       Q:0.0,              $ ; Q Stokes parameter
       U:0.0,              $ ; U Stokes parameter
       sigma:{data_wind_waves_gp_sigma}} ; 1-sigma uncertainties on the goniopolarimetry paramaters

END
