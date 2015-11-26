FUNCTION get_w_item_i4,receiver_code, item, $
                       date=date, lz_filename=lz_filename, $
                       dsize=dsize, nan_value=nan_value, $
                       time=time, sweep=sweep, $
                       starttime=starttime, $
                       endtime=endtime, $
                       VERBOSE=VERBOSE


;+
; NAME:
;               get_w_item_i4
;
; PURPOSE:
; 		get Wind/Waves 4b integer item values reading the WindLib
;               for a given receiver and for given date or lz file.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		values = get_w_item_i4(receiver_code, item, date=date)
;            or 
;               values = get_w_item_i4(receiver_code, item, lz_filename=lz_filename)
; INPUTS:
;               receiver_code - Waves receiver id (RAD1=1, RAD2=2, TNR=0).
;               item          - Name of the item for which values must
;                               be returned.
;	
; OPTIONAL INPUTS:
;		date        - Scalar of string type providing the 
;		              date for which calibrations must returned.
;                             Format of date must be 'YYYYMMDD', where:
;                                     YYYY = year
;                                     MM   = month
;                                     DD   = day of the month
;               lz_filename - Name of the Waves lz file to read.
;               dsize       - Data size of the item to provide to the
;                             windlib. Default is 1l.
;               nan_value   - Value to give to item if it is not found
;                             for a given event.
;                             Default is !values.f_nan.
;               starttime   - Scalar of double type providing the 
;                             firt time (in long integer format) to return.
;                             Default is 000000.
;               endtime     - Scalar of double type providing the last
;                             time (in long integer format) to return.
;                             Default is 235959.
;
; KEYWORD PARAMETERS:
;		/VERBOSE - Talkative mode.
;
; OUTPUTS:
;		values  - Vector of byte type containing the item values 
;                         for the n sweepings.
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
;	        WINDLib IDL environment must be set. 
;			
; CALL:
;		open_w_lz
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by X.Bonnin (LESIA).			
;				
;-

time=0.0 & values=-1 & sweep=-1 & ret_size=1l
date_flag = keyword_set(date) & lz_flag = keyword_set(lz_filename)
if (n_params() lt 2) or (date_flag+lz_flag eq 0) then begin
   message,/INFO,'Call is:'
   print,'values = get_w_item_i4(receiver_code, item, $'
   print,'                       date=date, lz_filename=lz_filename, $'
   print,'                       dsize=dsize, nan_value=nan_value, $'
   print,'                       time=time, sweep=sweep, $'
   print,'                       starttime=starttime,endtime=endtime, $'
   print,'                       /VERBOSE)'
   return,!values.f_nan
endif
VERBOSE=keyword_set(VERBOSE)

if not (keyword_set(starttime)) then starttime=000000
if not (keyword_set(endtime)) then endtime=235959
if not (keyword_set(dsize)) then dsize=1l
if not (keyword_set(nan_value)) then nan_value = !values.f_nan

irad = fix(receiver_code[0])
case irad of
   0:recname='TNR'
   1:recname='RAD1'
   2:recname='RAD2'
   else:begin
      message,/CONT,'Unknown receiver code!'
      return,nan_value
   end
endcase

; Generate filename of wind/waves lz data file to read
if (lz_flag) then begin
   filename = file_basename(lz_filename) 
   date = (strsplit(filename,'_',/EXTRACT))[3]
endif else filename = 'wi_lz_wav_'+date+'*.dat'

; Compute corresponding ur8_start and ur8_stop
ur8_start=double(0) & ur8_stop=double(0)
ok = w_ur8_from_ymd_i(ur8_start,long(date),starttime)
ok = w_ur8_from_ymd_i(ur8_stop,long(date),endtime)

; Open Waves lz data file for the current date
ch = open_w_lz(filename,lun=lun,VERBOSE=VERBOSE,MESSAGES_ON=VERBOSE)
if (ch eq -1) then return,nan_value
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
   ok=w_item_r8(ch,'EVENT_SCET_R8',event_scet_i,1l,ret_size)
   if (ok ne 1) then event_scet_i = !values.f_nan $
   else event_scet_i = float(event_scet_i - fix(event_scet_i))*24.0

   ;Get item's value for the current event
   value_i = intarr(dsize)
   ok=w_item_i4(ch,item,value_i,dsize,ret_size)
   if (ok ne 1) then value_i[*] = nan_value

   time=[time,,event_scet_i]
   values=[values,fix(value_i)]
   sweep=[sweep,i]
   i++
endwhile
ok=w_channel_close(ch)
close,lun
free_lun,lun

if (n_elements(values) eq 1) then return,nan_value
values=values[1:*] & time=time[1:*] & sweep=sweep[1:*]

return, values
END 
