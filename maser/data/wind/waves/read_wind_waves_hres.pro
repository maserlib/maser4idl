FUNCTION read_wind_waves_hres,file,header, $
                              mode=mode, idipxy=idipxy, $
                              irecord_offset=irecord_offset, $
                              isweep_offset=isweep_offset, $
                              receiver_code=receiver_code, $
                              jd_base = jd_base, $
                              SWEEP_SECONDS=SWEEP_SECONDS, $
                              VERBOSE=VERBOSE,NDATA=NDATA, $
                              SI_UNITS=SI_UNITS,NSWEEP=NSWEEP, $
                              SKIP_CAL=SKIP_CAL,DEBUG=DEBUG, $
                              GET_DATE=GET_DATE

;+
; NAME:
;       read_wind_waves_hres
;
; PURPOSE:
; 	Read a Wind Waves rad1 or rad2 level 2 high resolution data
;	file (with intensity calibrated in microVolt^2/Hz).
;
; CATEGORY:
;	I/O
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	data = read_wind_waves_hres( file, header)
;
; INPUTS:
;       file - Scalar of string type containing
;              the full path to the Wind Waves
;              l2 binary file to read.
;
; OPTIONAL INPUTS:
;       idipxy         - Integer providing the equatorial dipole
;                        configuration index for which data must be returned.
;                        By default all of the data are returned.
;       mode           - Integer indicating the receiver mode
;                        for which data must be returned.
;                        By default all of the mode are returned.
;	irecord_offset - Add an offset value to data indices.
;                        Default is 0l.
;       isweep_offset  - Add an offset value to sweep indices.
;                        Default is 0l.
;
; KEYWORD PARAMETERS:
;       /SI_UNITS      - Return the voltage spectral density in V^2/Hz (SI
;                        units) instead of microV^2/Hz.
;       /NDATA         - Return the number of data only.
;       /NSWEEP        - Return the number of sweep only.
;       /SWEEP_SECONDS - Return seconds since beginning of each sweep
;                        for S, SP, and Z.
;	/VERBOSE       - Talkative mode.
;       /SKIP_CAL      - Skip internal calibration sweep/event.
;       /GET_DATE    - Return the date 'YYYY-MM-DD' of the data writen into the file.
;       /DEBUG         - Debug mode.
;
; OUTPUTS:
;	data - Structure containing data read in the file.
;
; OPTIONAL OUTPUTS:
;       receiver_code - Index of the waves receiver (RAD1=1, RAD2=2, TNR=0)
;       header     - Structure containing the file's header.
;       jd_base   - Contains the time origin of julian days in the header.
;	  error         - Returns 1 if an error has occurred during processing, 0 otherwise.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS/COMMENTS:
;	None.
;
; CALL:
;	 calend_date__define
;       ccsds_date__define
;       data_wind_waves_hres__define
;       header_wind_waves_hres__define
;
; EXAMPLE:
;	None.
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;       (Adapted from read_wind_waves_60s.pro.)
;
;       08-AUG-2012, X.Bonnin - Added mode optional input.
;       02-JAN-2012, X.Bonnin - Added /SKIP_CAL and /DEBUG keywords.
;       30-OCT-2013, X.Bonnin - Added /SWEEP_SECONDS keyword.
;                               Major output data structure modifications.
;       16-APR-2014, X.Bonnin - Data time in input file starts at 00:00:00 UT
;                               on 1 January 1982 instead of 1950.
;        08-APR-2015, X.Bonnin - Added /GET_DATE and jd_base.
;
;-

if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'data = read_wind_waves_hres(file,header, $'
   print,'                            mode=mode, idipxy=idipxy, $'
   print,'                            irecord_offset=irecord_offset, $'
   print,'                            isweep_offset=isweep_offset, $'
   print,'                            receiver_code=receiver_code, $'
   print,'                            jd_base=jd_base, $'
   print,'                            /NDATA, /NSWEEP, /SWEEP_SECONDS, $'
   print,'                            /SI_UNITS, /VERBOSE, /SKIP_CAL'
   print,'                            /DEBUG, /GET_DATE'
   return,0
endif
NDATA = keyword_set(NDATA)
NSWEEP = keyword_set(NSWEEP)
SWEEP_SECONDS=keyword_set(SWEEP_SECONDS)
DEBUG = keyword_set(DEBUG)
VERBOSE = keyword_set(VERBOSE) or DEBUG
SI_UNITS = keyword_set(SI_UNITS)
SKIP_CAL = keyword_set(SKIP_CAL)
GET_DATE = keyword_set(GET_DATE)
if not (keyword_set(mode)) then mode=0
if not (keyword_set(idipxy)) then idipxy=0

if not (file_test(file)) then begin
   message,/CONT,file+' does not exist!'
   return,0
endif

if (SI_UNITS) then begin
  if verbose then message,/info,'Intensity output in V^2/Hz (SI units)'
  factor=1.e-12
endif else begin
  if verbose then message,/info,'Intensity output in microV^2/Hz'
  factor=1.
endelse

if (keyword_set(irecord_offset)) then irecord_offset = long(irecord_offset) $
else irecord_offset = 0l
if (VERBOSE) then message,/info,'irecord offset ='+string(irecord_offset)

if (keyword_set(isweep_offset)) then isweep_offset = long(isweep_offset) $
else isweep_offset = 0l
if (VERBOSE) then message,/info,'isweep offset = '+string(isweep_offset)

julday0=julday(01,01,1982,0,0,0)
julsec0=long64(julday0*24.0d*3600.0d)

; temporary header format (used for date reading):
ccsds_date = {P_FIELD:0b, julian_day_b1:0b, julian_day_b2:0b, julian_day_b3:0b, msec_of_day:0L}

header_tmp = {ccsds_date:ccsds_date,     $
              receiver_code:0,           $
              julian_sec:0l,             $
              calend_date:{calend_date}, $
              Julian_sec_frac:0.0,       $
              isweep:0l,                 $
              iunit:0,                   $
              nbps:0,                    $
              sun_angle:0.0,             $
              spin_rate:0.0,             $
              Kspin:0,                   $
              mode:0,                    $
              listfr:0,                  $
              nfreq:0,                   $
              ical:0,                    $
              ianten:0,                  $
              ipola:0,                   $
              idipxy:0,                  $
              Sdurcy:0.0,                $
              Sdurpa:0.0,                $
              Npalcy:0,                  $
              Nfrpal:0,                  $
              Npalif:0,                  $
              NSpalf:0,                  $
              NZpalf:0}

n_sweep = 0l
n_data  = 0l
rec_lng1 = 0l
rec_lng2 = 0l

; File overview (getting number of data samples)

if (file_test(file,/ZERO_LENGTH)) then begin
   message,/CONT,file+' is empty (0b)!'
   return,0
endif

openr,lun,file,/get_lun,/swap_if_little_endian

yyyy=-1 & mm=-1 & dd=-1 & i_data=0l
repeat begin
   readu,lun,rec_lng1
   point_lun,-lun,lun_ptr
   readu,lun,header_tmp
   receiver_code = header_tmp.receiver_code
   yyyy = [yyyy,header_tmp.calend_date.year]
   mm = [mm,header_tmp.calend_date.month]
   dd = [dd,header_tmp.calend_date.day]
   point_lun,lun,lun_ptr+rec_lng1
   readu,lun,rec_lng2
   n_sweep ++
   i_data = [i_data,header_tmp.Npalif*(header_tmp.NZpalf)]

   if rec_lng1 ne rec_lng2 then begin
      message,/CONT,'Wrong number of bytes!'
      if (DEBUG) then stop else return,0
   endif
endrep until eof(lun)
close,lun
free_lun,lun

n_data=total(i_data)
if (VERBOSE) then begin
   message,file+':',/info
   message,string(format='(I6," sweeps, ",I10," data samples.")', $
                  n_sweep,n_data),/info
endif

if (n_sweep eq 0l) then begin
   message,/CONT,'Empty data file!'
   return,0
endif
yyyy=yyyy[1:*] & mm=mm[1:*] & dd=dd[1:*]


if (NDATA) then begin
   if (VERBOSE) then message,'Returning number of data samples.',/info
   if(NSWEEP) and (VERBOSE) then message,'Ignoring /nsweep keyword.',/info
   return,n_data
endif else if(NSWEEP) then begin
   if (VERBOSE) then message,'Returning number of sweeps.',/info
   return,n_sweep
endif

if (VERBOSE) then message,'Loading data.',/info

; Define beginning of the current day in julian sec
yyyy = yyyy[n_sweep/2]
mm = mm[n_sweep/2]
dd = dd[n_sweep/2]
julian_sec0=(julday(mm,dd,yyyy,0,0,0) - julday0)*86400.0d

jd_base = julday0

if (GET_DATE) then return, string(yyyy, format='(i4.4)') + '-' + $
  string(mm, format='(i2.2)') + '-' + string(dd, format='(i2.2)')

data = replicate({data_wind_waves_hres},n_data)
header = replicate({header_wind_waves_hres},n_sweep)

warning = 0l

openr,lun,file,/get_lun,/swap_if_little_endian
ipos=0l & ihead=0l & irec_i=0l
for i=0l,n_sweep-1l do begin
   irec_i=irec_i+i_data[i]+ 1l + irecord_offset

   readu,lun,rec_lng1
   point_lun,-lun,lun_ptr
   readu,lun,header_tmp

   if (VERBOSE) then message, string(format='("sweep #",I4.4," [",I6," bytes]")',i,rec_lng1),/info

   if (mode gt 0) and (header_tmp.mode ne mode) then begin
      if (VERBOSE) then message, /info, 'Incorrect receiver mode, skipping sweep'
      point_lun,lun,lun_ptr+rec_lng1
      readu,lun,rec_lng2
      continue
   endif

   if (idipxy gt 0) and (header_tmp.idipxy ne idipxy) then begin
      if (VERBOSE) then message, /info, 'Incorrect equatorial dipole index, skipping sweep'
      point_lun,lun,lun_ptr+rec_lng1
      readu,lun,rec_lng2
      continue
   endif

   if (SKIP_CAL) and (header_tmp.ical eq 1) then begin
      if (VERBOSE) then message,/INFO,'Internal calibration, skipping sweep'
      point_lun,lun,lun_ptr+rec_lng1
      readu,lun,rec_lng2
      continue
   endif

   header(ihead).ccsds_date.P_field             = header_tmp.ccsds_date.P_Field

   julian_day = long(header_tmp.ccsds_date.julian_day_b1)*2l^16l+long(header_tmp.ccsds_date.julian_day_b2)*2l^8l+long(header_tmp.ccsds_date.julian_day_b3)
   julian_sec = julian_day*86400l + header_tmp.ccsds_date.msec_of_day/1000l

   if julian_sec ne header_tmp.julian_sec then begin
      warning ++
      if (VERBOSE) then message,'/!\ Warning: date check did not pass /!\',/info
   endif

   caldat,julian_day+julday0,month,day,year

   header(ihead).ccsds_date.T_field.year        = year
   header(ihead).ccsds_date.T_field.month       = month
   header(ihead).ccsds_date.T_field.day         = day
   header(ihead).ccsds_date.T_field.hour        = header_tmp.ccsds_date.msec_of_day/1000l/3600l
   header(ihead).ccsds_date.T_field.minute      = (header_tmp.ccsds_date.msec_of_day/1000l mod 3600l)/60l
   header(ihead).ccsds_date.T_field.second      = (header_tmp.ccsds_date.msec_of_day/1000l mod 60l)
   header(ihead).ccsds_date.T_field.second_10_2 = (header_tmp.ccsds_date.msec_of_day mod 1000l)/10l
   header(ihead).ccsds_date.T_field.second_10_4 = (header_tmp.ccsds_date.msec_of_day mod 10l)*10l
   header(ihead).receiver_code                  = header_tmp.receiver_code
   header(ihead).julian_sec                     = header_tmp.julian_sec
   header(ihead).calend_date                    = header_tmp.calend_date
   header(ihead).julian_sec_frac                = header_tmp.julian_sec_frac
   header(ihead).iunit                          = header_tmp.iunit
   header(ihead).isweep                         = header_tmp.isweep
   header(ihead).nbps                           = header_tmp.nbps
   header(ihead).sun_angle                      = header_tmp.sun_angle
   header(ihead).spin_rate                      = header_tmp.spin_rate
   header(ihead).Kspin                          = header_tmp.Kspin
   header(ihead).mode                           = header_tmp.mode
   header(ihead).listfr                         = header_tmp.listfr
   header(ihead).nfreq                          = header_tmp.nfreq
   header(ihead).ical                           = header_tmp.ical
   header(ihead).ianten                         = header_tmp.ianten
   header(ihead).ipola                          = header_tmp.ipola
   header(ihead).idipxy                         = header_tmp.idipxy
   header(ihead).Sdurcy                         = header_tmp.Sdurcy
   header(ihead).Sdurpa                         = header_tmp.Sdurpa
   header(ihead).Npalcy                         = header_tmp.Npalcy
   header(ihead).Nfrpal                         = header_tmp.Nfrpal
   header(ihead).Npalif                         = header_tmp.Npalif
   header(ihead).NSpalf                         = header_tmp.NSpalf
   header(ihead).NZpalf                         = header_tmp.NZpalf

   NSpalf = header(ihead).NSpalf & NZpalf = header(ihead).NZpalf
   Nf = header(ihead).Npalif

   NSdata = Nf*NSpalf
   NZdata = Nf*NZpalf

   if (SWEEP_SECONDS) then julsec_offset=0.0d else $
      julsec_offset=double(header_tmp.julian_sec) + double(header_tmp.julian_sec_frac) $
                    - julian_sec0

   data(ipos:ipos+NZdata-1l).receiver_code = header_tmp.receiver_code
   data(ipos:ipos+NZdata-1l).irecord = irec_i + lindgen(NZdata)
   data(ipos:ipos+NZdata-1l).isweep = header_tmp.isweep + isweep_offset
   data(ipos:ipos+NZdata-1l).ianten = byte(header_tmp.ianten)
   data(ipos:ipos+NZdata-1l).ical = byte(header_tmp.ical)

   ; Save frequencies
   tmp = fltarr(Nf)
   readu,lun,tmp
   data(ipos:ipos+NZdata-1l).freq = reform(transpose(rebin(tmp,Nf,NZpalf)),NZdata)

   ; Save S and SP data
   tmp = fltarr(NSpalf, Nf)
   readu,lun,tmp
   is=2l*lindgen(NSpalf/2) & isp=2l*lindgen(NSpalf/2) + 1l

   data(ipos:ipos+NZdata-1l).intensity[0] = reform(tmp[is,*]*factor,NZdata)
   data(ipos:ipos+NZdata-1l).intensity[1] = reform(tmp[isp,*]*factor,NZdata)

  ; Save corresponding times
   tmp = fltarr(NSpalf, Nf)
   readu,lun,tmp
   data(ipos:ipos+NZdata-1l).seconds[0] = reform(tmp[is,*],NZdata) + julsec_offset
   data(ipos:ipos+NZdata-1l).seconds[1] = reform(tmp[isp,*],NZdata) + julsec_offset

  ; Save Z data
   tmp = fltarr(NZpalf, Nf)
   readu,lun,tmp
   data(ipos:ipos+NZdata-1l).intensity[2] = reform(tmp*factor,NZdata)
   tmp = fltarr(NZpalf, Nf)
   readu,lun,tmp
   data(ipos:ipos+NZdata-1l).seconds[2] = reform(tmp,Nzdata) + julsec_offset

   readu,lun,rec_lng2

   if rec_lng2 ne rec_lng1 then begin
      message,/CONT,'Wrong number of bytes!'
      if (DEBUG) then stop else return,0
   endif
   ipos = ipos + NZdata
   ihead++
endfor
if (ihead eq 0l) then return,0
data = data[0l:ipos-1l]
header = header[0l:ihead-1l]
close,lun
free_lun,lun


if (VERBOSE) then message,string(format='("Returning ",I10," data samples for ",I4.4," sweeps.")',ipos,ihead),/info
return,data
end
