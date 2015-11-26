PRO get_waves_cal,receiver_code, date, cal, $
                  time=time, sweep=sweep, $
                  starttime=starttime, $
                  endtime=endtime, $
                  VERBOSE=VERBOSE


;+
; NAME:
;               get_waves_cal
;
; PURPOSE:
; 		get Wind/Waves instrument internal calibration spectra
;               for a given receiver and date.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		get_waves_cal, receiver_code, date, cal, time
;
; INPUTS:
;               receiver_code - Waves receiver id (RAD1=1, RAD2=2, TNR=0).
;		date          - Scalar of string type providing the 
;		                date for which calibrations must returned.
;                               Format of date must be 'YYYYMMDD', where:
;                                     YYYY = year
;                                     MM   = month
;                                     DD   = day of the month
;	
; OPTIONAL INPUTS:
;               starttime - Scalar of double type providing the 
;                           firt time (in long integer format) to return.
;                           Default is 000000.
;               endtime   - Scalar of double type providing the last
;                           time (in long integer format) to return.
;                           Default is 235959.
;
; KEYWORD PARAMETERS:
;		/VERBOSE - Talkative mode.
;
; OUTPUTS:
;		cal  - Vector of byte type containing the calibration
;                      status for the n sweepings: 
;                         1b = internal calibration
;                         0b = no calibration.
;
; OPTIONAL OUTPUTS:
;               time - Vector of double type containing the n corresponding
;                      sweeping start times (in decimal hours).
;		sweep - Vector containing the sweeping number.
;		
; COMMON BLOCKS:		
;		None.
;	
; SIDE EFFECTS:
;		None.
;		
; RESTRICTIONS/COMMENTS:
;	        WINDLib IDL routines
;               must be callable. 
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

time=0.0 & cal=-1 & sweep=-1
if (n_params() lt 2) then begin
   message,/INFO,'Call is:'
   print,'get_waves_cal,receiver_code, date, cal, $'
   print,'              time=time, sweep=sweep, $'
   print,'              starttime=starttime,endtime=endtime, $'
   print,'              /VERBOSE'
   return
endif
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
      return
   end
endcase

; Generate filename of wind/waves lz data file to read
filename = 'wi_lz_wav_'+date+'*.dat'

; Compute corresponding ur8_start and ur8_stop
ur8_start=double(0) & ur8_stop=double(0)
ok = w_ur8_from_ymd_i(ur8_start,long(date),starttime)
ok = w_ur8_from_ymd_i(ur8_stop,long(date),endtime)

; Open Waves lz data file for the current date
if (VERBOSE) then print,'Fetching '+filename
ch=0l & ret_size=0l & ok=0l
lun = w_channel_open(ch,filename)
if (lun ne 1) then begin
   if (VERBOSE) then message,/CONT,'Fetching file has failed!'
   ok=w_channel_close(ch)
   return     
endif
if not (VERBOSE) then ok = w_messages_off(ch) else $
   ok = w_messages_on(ch)
filepath = ''
ok = w_channel_filename(ch,filepath)
if (VERBOSE) then print,'Reading '+filepath		
ok = w_channel_position(ch,ur8_start)

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

   ; Calibration flag (0 = Normal, 1 = Cal)
   cal_flag_i = 0l
   ok=w_item_i4(ch,'CAL_FLAG',cal_flag_i,1,ret_size)
   if (ok ne 1) then continue

   time=[time,float(event_scet_i - fix(event_scet_i))*24.0]
   cal=[cal,byte(cal_flag_i)]
   sweep=[sweep,i]
   i++
endwhile
ok=w_channel_close(ch)
close,lun
free_lun,lun

if (n_elements(cal) eq 1) then return
cal=cal[1:*] & time=time[1:*] & sweep=sweep[1:*]

END 
