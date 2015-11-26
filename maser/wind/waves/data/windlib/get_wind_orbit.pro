PRO get_wind_orbit,date, wind_pos, time, $
                   starttime=starttime, $
                   endtime=endtime, $
                   GCI=GCI, GSM=GSM, $
                   JULIAN=JULIAN, $
                   VERBOSE=VERBOSE


;+
; NAME:
;               get_wind_orbit
;
; PURPOSE:
; 		get Wind spacecraft positions (in km) in GSE coordinates
; 		system for a give date.
;
;
; CATEGORY:
;		I/O
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		get_wind_orbit, date, wind_pos, time
;
; INPUTS:
;		date          - Scalar of string type providing the 
;		                date for which Wind orbit must returned.
;                               Format of date must be 'YYYYMMDD', where:
;                                     YYYY = year
;                                     MM   = month
;                                     DD   = day of the month
;	
; OPTIONAL INPUTS:
;               starttime - Scalar of double type providing the 
;                           firt time (in decimal hours) to return.
;                           Default is 0.0d.
;               endtime   - Scalar of double type providing the last
;                           time (in decimal hours) to return.
;                           Default is 24.0d
;
; KEYWORD PARAMETERS:
;               /GCI     - If set, return Wind spacecraft position
;                          in the GCI coordinates system.
;               /GSM     - If set, return Wind spacecraft position
;                          in the GSM coordinates system.
;               /JULIAN  - If set, return times in julian days.
;		/VERBOSE - Talkative mode.
;
; OUTPUTS:
;		wind_orbit - [3,n] Array of double type containing the
;                            n times [X,Y,Z] GSE coordinates of the Wind
;                            spacecraft.
;               time       - Vector of double type containing the n corresponding
;                            times (in decimal hours).
;
; OPTIONAL OUTPUTS:
;		None.
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

wind_pos=0 & time=0
if not (keyword_set(date)) then begin
   message,/INFO,'Call is:'
   print,'get_wind_orbit,date, wind_pos, time, $'
   print,'               starttime=starttime,endtime=endtime, $'
   print,'               /GCI, GSM, /JULIAN, /VERBOSE'
   return
endif
GCI=keyword_set(GCI)
GSM=keyword_set(GSM)
JULIAN=keyword_set(JULIAN)
VERBOSE=keyword_set(VERBOSE)

if not (keyword_set(starttime)) then starttime=0.0d
if not (keyword_set(endtime)) then endtime=24.0d

if (GCI) then begin
   cs='GCI'
endif else if (GSM) then begin
   cs='GSM'
endif else cs='GSE'

; Generate filename of wind/waves lz data file to read
filename = 'wi_lz_wav_'+date+'*.dat'

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

if not (VERBOSE) then ok = w_messages_off(ch) else $
   ok = w_messages_on(ch)

nrec=144
scet=dblarr(nrec) 
pos_x=dblarr(nrec) 
pos_y=dblarr(nrec)
pos_z=dblarr(nrec)
iev = w_event(ch,'CDF')
ok1=w_item_R8(ch, 'WIND_ORBIT_SCET_R8',scet,nrec,ret_size)
ok2=w_item_R8(ch, 'WIND_ORBIT_X('+cs+')_R8',pos_x,nrec,ret_size)
ok3=w_item_R8(ch, 'WIND_ORBIT_Y('+cs+')_R8',pos_y,nrec,ret_size)
ok4=w_item_R8(ch, 'WIND_ORBIT_Z('+cs+')_R8',pos_z,nrec,ret_size)
ok=w_channel_close(ch)
close,lun
free_lun,lun
if (ok1+ok2+ok3+ok4 ne 4) then return

wind_pos=dblarr(3,nrec)
wind_pos[0,*] = pos_x
wind_pos[1,*] = pos_y
wind_pos[2,*] = pos_z

time=(scet - fix(scet))*24.0d

where_trange=where(time ge starttime and time le endtime)
if (where_trange[0] ne -1) then time=time[where_trange]

if (JULIAN) then begin
   yyyy=strmid(date,0,4)
   mm=strmid(date,4,2)
   dd=strmid(date,6,2)
   hh = fix(time)
   nn = 60.0*(time - hh)
   ss = fix(60.0*(nn - fix(nn)))
   nn = fix(nn)
   time=julday(mm,dd,yyyy,hh,nn,ss)
endif


END 
