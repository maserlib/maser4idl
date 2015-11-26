FUNCTION get_waves_scet,receiver_code, $
                        date=date, lz_filename=lz_filename, $
                        sweep=sweep, $
                        starttime=starttime, $
                        endtime=endtime, $
                        HOURS=HOURS, STRING=STRING, $
                        VERBOSE=VERBOSE


;+
; NAME:
;               get_waves_cal
;
; PURPOSE:
; 		get Wind/Waves instrument internal calibration spectra
;               for a given receiver and a given date or given lz file.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		scet = get_waves_scet(receiver_code, date=date)
;            or 
;               scet = get_waves_scet(receiver_code, lz_filename=lz_filename)
;
; INPUTS:
;               receiver_code - Waves receiver id (RAD1=1, RAD2=2, TNR=0).
;	
; OPTIONAL INPUTS:
;		date        - Scalar of string type providing the 
;		              date for which calibrations must returned.
;                             Format of date must be 'YYYYMMDD', where:
;                                     YYYY = year
;                                     MM   = month
;                                     DD   = day of the month
;               lz_filename - Name of the Waves lz file to read.
;               starttime   - Scalar of double type providing the 
;                             firt time (in long integer format) to return.
;                             Default is 000000.
;               endtime     - Scalar of double type providing the last
;                             time (in long integer format) to return.
;                             Default is 235959.
;
; KEYWORD PARAMETERS:
;               /HOURS   - Returns scet in decimal hours of the day.
;               /STRING  - Returns scet in a string format.
;		/VERBOSE - Talkative mode.
;
; OUTPUTS:
;		scet  - Vector of byte type containing the scet
;                       for the n sweepings: 
;
; OPTIONAL OUTPUTS:
;		sweep - Vector containing the sweeping number.
;		
; COMMON BLOCKS:		
;		None.
;	
; SIDE EFFECTS:
;		None.
;		
; RESTRICTIONS/COMMENTS:
;	        WINDLib IDL environment must be set. 
;			
; CALL:
;		None.
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by X.Bonnin (LESIA).			
;				
;-

sweep=-1 & ret_size=0l
date_flag = keyword_set(date) & lz_flag = keyword_set(lz_filename)
if (n_params() lt 1) or (date_flag+lz_flag eq 0) then begin
   message,/INFO,'Call is:'
   print,'scet = get_waves_scet(receiver_code, date=date, lz_filename=lz_filename, $'
   print,'                      sweep=sweep, $'
   print,'                      starttime=starttime,endtime=endtime, $'
   print,'                      /STRING,/HOURS,/VERBOSE'
   return,!values.f_nan
endif
STRING = keyword_set(STRING)
HOURS=keyword_set(HOURS)
VERBOSE=keyword_set(VERBOSE)

if not (keyword_set(starttime)) then starttime=000000
if not (keyword_set(endtime)) then endtime=235959

irad = fix(receiver_code[0])
case irad of
   0:recname='TNR'
   1:recname='RAD1'
   2:recname='RAD2'
   else:begin
      message,/CONT,'Unknown receiver code!'
      return,!values.f_nan
   end
endcase

; Generate filename of wind/waves lz data file to read
if (lz_flag) then begin
   filename = basename(lz_filename) 
   date = (strsplit(filename,'_',/EXTRACT))[3]
endif else filename = 'wi_lz_wav_'+date+'*.dat'

; Compute corresponding ur8_start and ur8_stop
ur8_start=double(0) & ur8_stop=double(0)
ok = w_ur8_from_ymd_i(ur8_start,long(date),starttime)
ok = w_ur8_from_ymd_i(ur8_stop,long(date),endtime)

; Open Waves lz data file for the current date
ch = open_w_lz(filename,lun=lun,VERBOSE=VERBOSE,MESSAGES_ON=VERBOSE)
if (ch eq -1) then return,!values.f_nan
filepath = ''
ok = w_channel_filename(ch,filepath)
if (VERBOSE) then print,'Reading '+filepath

if not (VERBOSE) then ok = w_messages_off(ch) else $
   ok = w_messages_on(ch)

scet=-1.0
if (STRING) then scet=''

ur8_time = ur8_start & i=1l
while (ur8_time le ur8_stop) do begin

   iev = w_event(ch,recname)
   if (iev eq 82) then begin
      if (VERBOSE) then print,'End of file reached.'
      break
   endif

   ; Get event scet
   event_scet_i = double(0)
   ok=w_item_r8(ch,'EVENT_SCET_R8',event_scet_i,1,ret_size)

   if (ok ne 1) then continue

   if (HOURS) then begin
      scet_i=float(event_scet_i - fix(event_scet_i))*24.0
   endif else if (STRING) then begin
      yyyymmdd=0l & hhnnss=0l
      ok = w_ur8_to_ymd_i(event_scet_i,yyyymmdd,hhnnss)
      yyyymmdd = string(yyyymmdd,format='(i8.8)') 
      hhnnss = string(hhnnss,format='(i6.6)')
      yyyy = strmid(yyyymmdd,0,4) & mm = strmid(yyyymmdd,4,2)
      dd = strmid(yyyymmdd,6,2) & hh = strmid(hhnnss,0,2)
      nn = strmid(hhnnss,2,2) & ss = strmid(hhnnss,4,2)
      scet_i = yyyy+'-'+mm+'-'+dd+'T'+hh+':'+nn+':'+ss
   endif

   scet=[scet,scet_i]
   sweep=[sweep,i]
   i++
endwhile
ok=w_channel_close(ch)
close,lun
free_lun,lun

if (n_elements(scet) eq 1) then return,!values.f_nan
scet=scet[1:*] & sweep=sweep[1:*]

return,scet
END 
