pro read_HFR_data,namefile,V,time,freq, $
        sensor=sensor,indstart=indstart,indend=indend, $ 
        hfr_sweep=hfr_sweep, hfr_sensor=hfr_sensor, $
        AS_IS=AS_IS, QUIET=QUIET

; +
; NAME:
;   read_HFR_data
;
; PURPOSE:
;   Read SolO/RPW HFR L2 data from input CDF file
;
; CALLING SEQUENCE:
;   read_HFR_data,namefile,V,time,freq
;
; INPUTS:
;   namefile - STRING OF THE FILENAME IN .CDF CONTAINING THE RPW HFR L2 DATA
;
; OPTIONAL INPUTS:
;   sensor   - Vector containing the HFR sensor(s) to read. 
;              Possible values are:
;				    9:V1-V2
;				    10:V2-V3
;				    11:V3-V1
;               If sensor is not passed, then try to retrieve all HFR sensor data (i.e., sensor=[9,10, 11]).               
;
;   indstart - starting time index. Default is 0L.
;
;   indend   - end time index. indend<0 means the last point of the timeserie.
;
; KEYWORD PARAMETERS:
;   AS_IS     - If passed, then return data as vectors as written in the input CDF file. 
;   QUIET     - If passed, do not print any message (except errors)
;
; OUTPUTS:
;    V        - array (time,frequency) of the measured AGC signals
;    time     - time of first measurement in sweep in Julian days
;    freq     - List of 321 HFR frequencies in kHz
;
; OPTIONAL OUTPUTS:
;   hfr_sweep  - List of HFR sweep index
;   hfr_sensor - List of HFR sensor index
;
;NOTES:
;  The script check if there are data from the two channel and put them together.
;  Since the number of frequency steps for HFR is not known a priori an array of 321 frequency points is considered.
;  Values are filled with -1.0e31 where there are no data point
;
; MODIFICATION HISTORY:
;   Written by A.VECCHIO (LESIA, CNRS - RRL Radboud University): February 2020
;
;   X.Bonnin, 25-MAY-2023:  sensor, indstart and indend become optional inputs
;                           sweepn_HFR becomes an optional output named hfr_sweep
;                           add hfr_sensor optional output
;                           Use CDF_TT2000 instead of CDF_EPOCH to convert Epoch values 
;                           add input checks at beginning
;                           add /AS_IS and /QUIET keywords
;                           use CDF ISTP FILLVAL values for missing data
;                           update header
;
; -

; Define missing data values (use CDF ISTP FILLVAL standards)
fillval_float = -1.0e31
fillval_uint1 = 255
fillval_uint2 = 65535
fillval_uint4 = 4294967295

; Total number of HFR frequency channels
nfreq = 321
; Values of HFR frequencies in kHz
freq = 50 * indgen(nfreq) + 375

; Check if namefile input has been passed as an argument
if n_elements(namefile) eq 0 then begin
    message,/INFO,'Usage:'
    print,'read_HFR_data, namefile, V, time, freq, $
    print,'               sensor=sensor, indstart=indstart, indend=indend, $'
    print,'               hfr_sweep=hfr_sweep, hfr_sensor=hfr_sensor, $'
    print,'               /AS_IS, /QUIET'
    return
endif
; Initialize optional input values
AS_IS = keyword_set(AS_IS)
QUIET = keyword_set(QUIET)
if n_elements(indstart) eq 0 then indstart = 0L
if n_elements(indend) eq 0 then indend = -99L
n_sensor = n_elements(sensor)
if n_sensor eq 0 then sensor = [9, 10, 11]
if n_sensor eq 1 then sensor = [sensor]
n_sensor = n_elements(sensor)

; If file exists, read it
if FILE_TEST(namefile) then begin
    if not QUIET then print,'Reading ' + namefile
    data_L2=rcdf(namefile) 
endif else message,/ERROR,namefile + ' not found!'

; Get frequency in kHz
freq_data=reform(data_L2.frequency.data) 

; Get number of records in the file
nn=n_elements(data_L2.epoch.data)
if indend lt 0 then indend=nn-1L

; Filter data between indstart and indend
freq_data=freq_data[indstart:indend]
epochdata=data_L2.epoch.data[indstart:indend]
sensor_config=data_L2.sensor_config.data[*,indstart:indend]
agc1_data=data_L2.agc1.data[indstart:indend]
agc2_data=data_L2.agc2.data[indstart:indend]
sweep_numo=data_L2.sweep_num.data[indstart:indend]

; Keep only data for front_end=1 (i.e. receiver connected to PREAMP)
puntical=where(data_L2.front_end.data[indstart:indend] eq 1)
epochdata=epochdata[puntical]
freq_data=freq_data[puntical]
sensor_config=sensor_config[*,puntical]
agc1_data=agc1_data[puntical]
agc2_data=agc2_data[puntical]
sweep_numo=sweep_numo[puntical]

; Convert Epoch TT2000 values into Julian days
CDF_TT2000, epochdata , yr, mo, dy, hr, mn, sc, milli, /BREAK
timet = CDF_EPOCH_TOJULDAYS (epochdata);JULDAY(mo,dy,yr,hr,mn,sc)
timetr=timet-timet[0]

; Filter data using sensor index
; First initialize output variables and counter
nsample_max = 2 * nn
agc = dblarr(nsample_max) + fillval_float
frequency = uintarr(nsample_max) + fillval_uint2
timet_ici = dblarr(nsample_max) + fillval_float
sens = bytarr(nsample_max) + fillval_uint1
sweeps = ulonarr(nsample_max) + fillval_uint4
counter = 0L

; Then start loops on sensor vector
for i=0, n_sensor-1 do begin
    sens0=where(sensor_config[0,*] eq sensor[i],psens0)
    sens1=where(sensor_config[1,*] eq sensor[i],psens1)
    nsamp_i = psens0 + psens1
    if (sens0[0] ne -1L and sens1[0] ne -1L) then begin
        agc[counter:counter+nsamp_i-1L]=[agc1_data[sens0],agc2_data[sens1]]
        frequency[counter:counter+nsamp_i-1L]=[freq_data[sens0],freq_data[sens1]]
        sens[counter:counter+nsamp_i-1L]= bytarr(nsamp_i) + sensor[i] 
        ;timet_ici=[timet[sens0],timet[sens1]]
        timet_ici[counter:counter+nsamp_i-1L]=timet[[sens0,sens1]]
        sweeps[counter:counter+nsamp_i-1L] = sweep_numo[[sens0,sens1]]
    endif else begin
        if (sens0[0] ne -1L) then begin
            agc[counter:counter+nsamp_i-1L]=agc1_data[sens0]
            frequency[counter:counter+nsamp_i-1L]=freq_data[sens0]
            sens[counter:counter+nsamp_i-1L]= bytarr(nsamp_i) + sensor[i]
            timet_ici[counter:counter+nsamp_i-1L]=timet[sens0]
            sweeps[counter:counter+nsamp_i-1L] = sweep_numo[sens0]
        endif
        if (sens1[0] ne -1L) then begin
            agc[counter:counter+nsamp_i-1L]=agc2_data[sens1]
            frequency[counter:counter+nsamp_i-1L]=freq_data[sens1]
            sens[counter:counter+nsamp_i-1L]= bytarr(nsamp_i) + sensor[i]
            timet_ici[counter:counter+nsamp_i-1L]=timet[sens1]
            sweeps[counter:counter+nsamp_i-1L] = sweep_numo[sens1]
        endif
        if (sens0[0] eq -1L and sens1[0] eq -1L) then $
            if not QUIET then print, 'No HFR data found for sensor=' + strtrim(sensor[i],2) + ' in ' + strtrim(namefile, 2)
    endelse
    counter = counter + nsamp_i
    ;print, i, sensor[i], psens0, psens1, nsamp_i, counter
endfor

if not QUIET then print, strtrim(counter, 2) + ' HFR data samples extracted from ' + strtrim(namefile, 2)
; If no data sample extract, exit
if counter eq 0 then return
; else remove trailing empty data 
agc = agc[0L:counter-1L]
frequency = frequency[0L:counter-1L]
timet_ici = timet_ici[0L:counter-1L]
sens = sens[0L:counter-1L]
sweeps = sweeps[0L:counter-1L]

; Sort data by increasing time values
ord_time=sort(timet_ici)
timerr=timet_ici[ord_time]
sens=sens[ord_time]
agc=agc[ord_time]
frequency=frequency[ord_time]
sweeps = sweeps[ord_time]

; Make sure to have monotical increasing sweep index values
ord_sweep = lonarr(counter)
sweep_count = 1L
for i=0L, counter-2L do begin
    ord_sweep[i] = sweep_count
    if sweeps[i + 1L] ne sweeps[i] then sweep_count = sweep_count + 1L
endfor
ord_sweep[counter - 1L] = sweep_count

; if /AS_IS keyword is passed, stop here and return data "as is"
; Otherwise continue and return AGC as 2D array (time, freq)
if AS_IS then begin
    V = agc
    time = timerr
    freq = frequency
    hfr_sweep = ord_sweep
    hfr_sensor = sens
    return
endif else if not QUIET then $
    print, 'Returning AGC as a 2D array (ntime='+strtrim(sweep_count,2)+',nfreq='+strtrim(nfreq,2)+')'

; Initialize outputs
n_sweep = sweep_count
V = dblarr(n_sweep, nfreq) + fillval_float
time = dblarr(n_sweep) + fillval_float
hfr_sensor = uintarr(n_sweep) + fillval_uint1
hfr_sweep = lindgen(n_sweep) + 1L

; Get indices of the input frequencies
ind_freq=[(frequency-375.)/50.]

; Loops over sweeps to fill outputs
for i=0L, n_sweep - 1L do begin 
    k = where(ord_sweep eq i+1L, nk)
    if nk gt 0 then begin
        j = ind_freq[k]
        V[i, j] = agc[k]
        ;print,i, min(agc[k]), max(agc[k]), min(frequency[k]), max(frequency[k])
        time[i] = timerr[k[0]] ; Take first time of the sweep
        hfr_sensor[i] = sens[k[0]]
    endif else message, /INFO, 'No data returned for sweep #' + strtrim(i+1L,2)
endfor

end
