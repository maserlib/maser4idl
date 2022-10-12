FUNCTION read_wind_waves_gp,file,header, $
                            irecord_offset=irecord_offset, $
                            isweep_offset=isweep_offset, $
                            VERBOSE=VERBOSE,NDATA=NDATA, $
                            NSWEEP=NSWEEP

;+
; NAME:
;       read_wind_waves_gp
;
; PURPOSE:
; 	Read a Wind Waves rad1 l3 goniopolarimetry data
;	file.
;
; CATEGORY:
;	I/O
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	data = read_wind_waves_gp( file, header)
;
; INPUTS:
;       file - Scalar of string type containing
;              the full path to the Wind Waves
;              data file to read.
;	
; OPTIONAL INPUTS:
;	irecord_offset - Add an offset value to data indices.
;                        Default is 0l.
;       isweep_offset  - Add an offset value to sweep indices.
;                        Default is 0l.
;
; KEYWORD PARAMETERS: 
;       /SI_UNITS   - Return flux density in W/m^2/Hz.
;       /NDATA      - Return the number of data only.
;       /NSWEEP     - Return the number of sweep only.
;       /VERBOSE    - Talkative mode.
;
; OUTPUTS:
;       data - Structure containing data read in the file.
;
; OPTIONAL OUTPUTS:
;       header - Structure containing the file's header.
;	error  - Returns 1 if an error has occurred during processing, 0 otherwise.
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
;	calend_date__define
;       ccsds_date__define
;       data_wind_waves_gp__define
;       header_wind_waves_gp__define
;
; EXAMPLE:
;	None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).		
;				
;-

if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'data = read_wind_waves_gp(file,header, $'
   print,'                          irecord_offset=irecord_offset, $'
   print,'                          isweep_offset=isweep_offset, $'
   print,'                          /NDATA, /NSWEEP, $'
   print,'                          /SI_UNITS, /VERBOSE'
   return,0
endif
NDATA = keyword_set(NDATA)
NSWEEP = keyword_set(NSWEEP)
VERBOSE = keyword_set(VERBOSE)
SI_UNITS = keyword_set(SI_UNITS)
if not (file_test(file)) then begin
   message,/CONT,file+' does not exist!'
   return,0
endif

if (SI_UNITS) then begin 
  if verbose then message,/info,'Intensity output in W/M^2/Hz (SI units)'
  factor=1.e-22
endif else begin
  if verbose then message,/info,'Intensity output in Solar Flux Units (SFU)'
  factor=1.
endelse

if (keyword_set(irecord_offset)) then irecord_offset = long(irecord_offset) $
else irecord_offset = 0l
if (VERBOSE) then message,/info,'irecord offset ='+string(irecord_offset)

if (keyword_set(isweep_offset)) then isweep_offset = long(isweep_offset) $
else isweep_offset = 0l
if (VERBOSE) then message,/info,'isweep offset = '+string(isweep_offset)

; temporary header format (used for date reading):
ccsds_date = {P_FIELD:0b, julian_day_b1:0b, julian_day_b2:0b, julian_day_b3:0b, msec_of_day:0L}

header_tmp = {ccsds_date:ccsds_date,     $
              receiver_code:0,           $
              julian_sec:0l,             $
              calend_date:{calend_date}, $
              julian_sec_frac:0.0,       $
              isweep:0l,                 $
              iunit:0,                   $
              ianten:0,                  $
              Nfreq:0,                   $
              Npalif:0,                  $
              Isyst:0,                   $
              spacecraft_coord:{spacecraft_coord_gse}}

n_sweep = 0l
n_data  = 0l
rec_lng1 = 0l
rec_lng2 = 0l

; File overview (getting number of data samples)

openr,lun,file,/get_lun,/swap_if_little_endian

n=0l
yyyy=-1 & mm=-1 & dd=-1
repeat begin
  readu,lun,rec_lng1
  point_lun,-lun,lun_ptr
  readu,lun,header_tmp
  yyyy = [yyyy,header_tmp.calend_date.year]
  mm = [mm,header_tmp.calend_date.month]
  dd = [dd,header_tmp.calend_date.day]
  n_sweep ++
  n_data += header_tmp.Npalif
  point_lun,lun,lun_ptr+rec_lng1
  readu,lun,rec_lng2
  n=n+rec_lng1 +8l
  if rec_lng1 ne rec_lng2 then stop
endrep until eof(lun)
close,lun
free_lun,lun

if (VERBOSE) then message,file+':',/info
if (VERBOSE) then message,string(format='(I6," sweeps, ",I6," data samples.")', $
                                 n_sweep,n_data),/info
header=header_tmp
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
julian_sec0=(julday(mm,dd,yyyy,0,0,0) - julday50)*86400.0d

data = replicate({data_wind_waves_gp},n_data)
header = replicate({header_wind_waves_gp},n_sweep)

data.irecord = lindgen(n_data)+irecord_offset

warning = 0l
openr,lun,file,/get_lun,/swap_if_little_endian
ipos=0l
for i=0l,n_sweep-1l do begin 
   readu,lun,rec_lng1
   readu,lun,header_tmp

   if (VERBOSE) then message, string(format='("sweep #",I4.4," [",I6," bytes]")',i,rec_lng1),/info
   
   header(i).ccsds_date.P_field = header_tmp.ccsds_date.P_Field
   
   julian_day = long(header_tmp.ccsds_date.julian_day_b1)*2l^16l+long(header_tmp.ccsds_date.julian_day_b2)*2l^8l+long(header_tmp.ccsds_date.julian_day_b3)
   julian_sec = julian_day*86400l + header_tmp.ccsds_date.msec_of_day/1000l
   
   if julian_sec ne header_tmp.julian_sec then begin
      warning ++
      if (VERBOSE) then message,'/!\ Warning: date check did not pass /!\',/info
   endif
   
   caldat,julian_day+julday(01,01,1950,0,0,0),month,day,year

   header(i).ccsds_date.T_field.year        = year
   header(i).ccsds_date.T_field.month       = month
   header(i).ccsds_date.T_field.day         = day
   header(i).ccsds_date.T_field.hour        = header_tmp.ccsds_date.msec_of_day/1000l/3600l
   header(i).ccsds_date.T_field.minute      = (header_tmp.ccsds_date.msec_of_day/1000l mod 3600l)/60l
   header(i).ccsds_date.T_field.second      = (header_tmp.ccsds_date.msec_of_day/1000l mod 60l)
   header(i).ccsds_date.T_field.second_10_2 = (header_tmp.ccsds_date.msec_of_day mod 1000l)/10l
   header(i).ccsds_date.T_field.second_10_4 = (header_tmp.ccsds_date.msec_of_day mod 10l)*10l
   header(i).receiver_code                  = header_tmp.receiver_code
   header(i).julian_sec                     = header_tmp.julian_sec
   header(i).calend_date                    = header_tmp.calend_date
   header(i).julian_sec_frac                = header_tmp.julian_sec_frac
   header(i).isweep                         = header_tmp.isweep
   header(i).ianten                         = header_tmp.ianten
   header(i).iunit                          = header_tmp.iunit
   header(i).nfreq                          = header_tmp.nfreq
   header(i).npalif                         = header_tmp.npalif
   header(i).Isyst                          = header_tmp.Isyst
   header(i).spacecraft_coord               = header_tmp.spacecraft_coord  
   
   Ndata_i = header(i).npalif
  
   data(ipos:ipos+Ndata_i-1l).irecord = max(data.irecord) + 1l + lindgen(Ndata_i) 
   ; Save sweep index
   data(ipos:ipos+Ndata_i-1l).isweep   = header_tmp.isweep + irecord_offset
   ; Save ianten (antenna config)
   data(ipos:ipos+Ndata_i-1l).ianten = header_tmp.ianten
   
   ; Save frequencies
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).freq = tmp

   julsec_offset=double(header_tmp.julian_sec) + double(header_tmp.julian_sec_frac) - $
                 julian_sec0
   ; Save Time
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).sec = reform(tmp,Ndata_i) + julsec_offset
  
   ; Save intensities
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).intensity = tmp*factor 
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.intensity = tmp*factor

   ; Save modulation rate
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).taumod = tmp 
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.taumod = tmp

   ; Save angular radius
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).rayang = tmp
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.rayang = tmp 

   ; Save azimuth angle
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).azimut = tmp
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.azimut = tmp

   ; Save elevation angle
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).elevat = tmp
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.elevat = tmp

   ; Save V Stokes parameter
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).V = tmp
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.V = tmp

   ; Save Q Stokes parameter
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).Q = tmp
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.Q = tmp

   ; Save U Stokes parameter
   tmp = fltarr(Ndata_i)
   readu,lun,tmp  
   data(ipos:ipos+Ndata_i-1l).U = tmp
   tmp = fltarr(Ndata_i)
   readu,lun,tmp
   data(ipos:ipos+Ndata_i-1l).sigma.U = tmp
   
   readu,lun,rec_lng2
   if rec_lng2 ne rec_lng1 then message,'ERROR: Number of bytes read is incorrect!'
   ipos = ipos + Ndata_i
endfor
close,lun
free_lun,lun

if (VERBOSE) then message,'Returning data.',/info
return,data
end
