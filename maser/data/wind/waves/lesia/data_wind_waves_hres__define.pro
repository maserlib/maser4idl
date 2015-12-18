PRO data_wind_waves_hres__define

tmp = {data_WIND_Waves_hres, $
       receiver_code:0b,          $  ; receiver index (Rad1=1, Rad2=2)
       irecord:0l,                $  ; record index
       isweep:0l,                 $  ; sweep index
       ical:0b,                   $  ; calibration flag (1=cal, 0=no cal)
       ianten:0b,                 $  ; antenna mode index (=1 -> SUM MODE, =0 -> SEP MODE)
       freq:0.,                   $  ; Frequency in kHz
       seconds:dblarr(3),         $  ; Seconds since beginning of current day (UTC) for S, SP, and Z 
       intensity:fltarr(3)}          ; Intensity in microVolts^2/Hz for S, SP, and Z

end
