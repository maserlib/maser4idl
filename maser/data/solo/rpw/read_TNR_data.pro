pro read_TNR_data,namefile,V,time,freq, $
        sensor=sensor,indstart=indstart,indend=indend, $ 
        tnr_sweep=tnr_sweep, tnr_sensor=tnr_sensor, $
        AS_IS=AS_IS, QUIET=QUIET
; +
; NAME:
;   read_TNR_data
;
; PURPOSE:
;   Read SolO/RPW TNR L2 data from input CDF file
;
; CALLING SEQUENCE:
;
;   read_TNR_data,namefile,V,time,freq
;
; INPUTS:
;   namefile - STRING OF THE FILENAME IN .CDF CONTAINING THE RPW TNR L2 DATA 
;
; OPTIONAL INPUTS:
;   sensor : TNR SENSOR TO BE READ
;             	1: V1
;             	2:V2
;				3:V3
;				4:V1-V2
;				5:V2-V3
;				6:V3-V1
;				7: B
;           If sensor is not passed, then try to retrieve all TNR sensor data, except magnetic measurements (B=7).
;
;   indstart: starting time index
;   
;   indend:  end time index. indend=-99 means the last point of the timeserie.
;
; KEYWORD PARAMETERS:
;   AS_IS     - If passed, then return data as vectors as written in the input CDF file. 
;   QUIET     - If passed, do not print any message (except errors)
;  
; OUTPUTS:
;    V: array (time,frequency) of the measured signals
;    time: time of each measurement in Julian days
;    freq: frequency in kHz
;
; OPTIONAL OUTPUTS:
;   tnr_sweep  - List of TNR sweep index
;   tnr_sensor - List of TNR sensor index
; 
;NOTES:
;  The script check if there are data from the two channel and put them together.
;  
; MODIFICATION HISTORY:
;   Written by A.VECCHIO (LESIA, CNRS - RRL Radboud University): February 2021
;
;   X.Bonnin, 21-JUN-2023:  sensor, indstart and indend become optional inputs
;                           sweepn_TNR becomes an optional output named tnr_sweep
;                           add tnr_sensor optional output
;                           Use CDF_TT2000 instead of CDF_EPOCH to convert Epoch values 
;                           add input checks at beginning
;                           add /AS_IS and /QUIET keywords
;                           use CDF ISTP FILLVAL values for missing data
;                           update header
;
; -


; Define missing data values (use CDF ISTP FILLVAL standards)
fillval_float = -1.0e31
fillval_uint1 = 255B
fillval_uint2 = 65535
fillval_uint4 = 4294967295

; Total number of TNR frequency channels
nfreq = 128

; Check if namefile input has been passed as an argument
if n_elements(namefile) eq 0 then begin
    message,/INFO,'Usage:'
    print,'read_TNR_data, namefile, V, time, freq, $
    print,'               sensor=sensor, indstart=indstart, indend=indend, $'
    print,'               tnr_sweep=tnr_sweep, tnr_sensor=tnr_sensor, $'
    print,'               /AS_IS, /QUIET'
    return
endif
; Initialize optional input values
AS_IS = keyword_set(AS_IS)
QUIET = keyword_set(QUIET)
if n_elements(indstart) eq 0 then indstart = 0L
if n_elements(indend) eq 0 then indend = -99L
n_sensor = n_elements(sensor)
if n_sensor eq 0 then sensor = [1, 2, 3, 4, 5, 6]
if n_sensor eq 1 then sensor = [sensor]
n_sensor = n_elements(sensor)


; If file exists, read it
if FILE_TEST(namefile) then begin
    if not QUIET then print,'Reading ' + namefile
    data_L2=rcdf(namefile) 
endif else message,/ERROR,namefile + ' not found!'

; Retrieve list of TNR frequencies for the 4 bands A, B, C and D
tnr_freq = transpose(data_L2.TNR_band_freq.data[*,*])
freq = [reform(tnr_freq[*, 0]),$
            reform(tnr_freq[*, 1]),$
            reform(tnr_freq[*, 2]),$
            reform(tnr_freq[*, 3])]/1000. ; freq in kHz
if n_elements(freq) ne nfreq then message,'Wrong number of TNR frequencies found in ' + namefile + $
    '! (found '+strtrim(n_elements(freq),2)+' instead of '+strtrim(nfreq,2)+')'

; indices of TNR band frequencies
tnr_freq_ind = intarr(32, 4)
for i=0,3 do tnr_freq_ind[*, i] = i*32 + indgen(32)

nn=n_elements(data_L2.epoch.data)
if indend eq -99 then indend=nn-1

; Filter data between indstart and indend
epochdata=data_L2.epoch.data[indstart:indend]
sensor_config=data_L2.sensor_config.data[*,indstart:indend]
auto1_data=data_L2.auto1.data[*,indstart:indend]
auto2_data=data_L2.auto2.data[*,indstart:indend]
mag1_data=data_L2.MAGNETIC_SPECTRAL_POWER1.data[*,indstart:indend]
mag2_data=data_L2.MAGNETIC_SPECTRAL_POWER2.data[*,indstart:indend]
sweep_numo=data_L2.sweep_num.data[indstart:indend]
tnr_band=data_L2.tnr_band.data[indstart:indend]

; Keep only data for front_end=1 (i.e. receiver connected to PREAMP)
puntical=where(data_L2.front_end.data[indstart:indend] eq 1, nrec)
epochdata=epochdata[puntical]
sensor_config=sensor_config[*,puntical]
auto1_data=auto1_data[*,puntical]
auto2_data=auto2_data[*,puntical]
sweep_num=sweep_numo[puntical]
tnr_band=tnr_band[puntical]

; Convert Epoch TT2000 times into Julian days
CDF_TT2000, epochdata , yr, mo, dy, hr, mn, sc, milli, /BREAK
timet = CDF_EPOCH_TOJULDAYS (epochdata);JULDAY(mo,dy,yr,hr,mn,sc)
;timetr=timet-timet[0]

; Make sure to have monotical increasing sweep index values
tnr_sweep = lonarr(nrec)
sweep_count = 1L
for i=0L, nrec-2L do begin
    tnr_sweep[i] = sweep_count
    if sweep_num[i+1L] ne sweep_num[i] then sweep_count = sweep_count + 1L
endfor
tnr_sweep[nrec-1L] = sweep_count

if AS_IS then begin
    ; If AS_IS, do no convert amplitudes into 2D array
    V = dblarr(4, 2, nrec)
    V[0, *, *] = auto1_data
    V[1, *, *] = auto2_data
    V[2, *, *] = mag1_data
    V[3, *, *] = mag2_data
    tnr_sensor = sensor_config
    time = timet
    return
endif

; Build outputs
V = dblarr(sweep_count, nfreq, 2) + fillval_float
time = dblarr(sweep_count) - fillval_float
tnr_sensor = uintarr(sweep_count, 2) + fillval_uint1

; Fill outputs 
for i=0L, nrec - 1 do begin
    ; Initialize valid flag
    is_valid = 0B

    ; Get index of time(x-axis)
    i_sweep = tnr_sweep[i] - 1L
    ; Get indices of frequencies (y-axis) for the current TNR band
    j_freq = tnr_freq_ind[*, tnr_band[i]] 

    where_sensor1 = where(sensor_config[0,i] eq sensor, n1)
    where_sensor2 = where(sensor_config[1,i] eq sensor, n2)
    ; If data samples have been found for expected sensor value(s) in channel 1
    ; Then fill V output
    if n1 gt 0 then begin
        if sensor_config[0,i] eq 7 then $
            V[i_sweep, j_freq, 0] = mag1_data[*, i] $
        else $
            V[i_sweep, j_freq, 0] = auto1_data[*, i] 
        is_valid = 1B
    endif
    ; If data samples have been found for expected sensor value(s) in channel 2
    ; Then fill V output
    if n2 gt 0 then begin
        if sensor_config[1,i] eq 7 then $
            V[i_sweep, j_freq, 1] = mag2_data[*, i] $
        else $
            V[i_sweep, j_freq, 1] = auto2_data[*, i] 
        is_valid = 1B
    endif   
    ; If valid data have been found for channel 1 or 2 for expected sensor value(s)
    ; then values for time and tnr_sensor
    if is_valid gt 0B then begin
        ; For time vector, make sure to store the first Epoch value of the current sweep
        time[i_sweep] = min([timet[i], time[i_sweep]])
        tnr_sensor[i_sweep, 0] = sensor_config[0,i] 
        tnr_sensor[i_sweep, 1] = sensor_config[1,i]
    endif 
endfor

where_valid = where(tnr_sensor[*, 0] ne 255B or tnr_sensor[*, 1] ne 255B, n)
if n gt 0 then begin
    V = V[where_valid, *, *]
    time = time[where_valid]
    tnr_sensor = tnr_sensor[where_valid, *]
    tnr_sweep = tnr_sweep[where_valid]
    if not QUIET then print, strtrim(n,2) + ' sweep(s) extracted from '+strtrim(namefile,2)
endif else message, /INFO, $
    'No valid TNR data samples found in '+strtrim(namefile,2)+' for expected sensor values ('+strjoin(strtrim(sensor, 2), ',')+')!'

END
