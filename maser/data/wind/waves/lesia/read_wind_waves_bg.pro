FUNCTION read_wind_waves_bg,file,header,$
                            NDATA=NDATA, CDP=CDP, $
                            VERBOSE=VERBOSE

;+
; NAME:
;       read_wind_waves_bg
;
; PURPOSE:
; 	Read a binary file containing
;       Wind Waves rad1 or rad2 background values
;       from l2 data files.
;
; CATEGORY:
;	I/O
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	data = read_wind_waves_bg( file, header)
;
; INPUTS:
;       file - Scalar of string type containing
;              the full path to the Wind Waves
;              binary file to read.
;	
; OPTIONAL INPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /NDATA      - Returns number of data samples.
;	/VERBOSE    - Talkative mode.
;
; OUTPUTS:
;	data - Structure containing data read in the file.
;
; OPTIONAL OUTPUTS:
;       header - Structure containing the file's header.
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
   print,'data = read_wind_waves_bg(file,header,/NDATA,/VERBOSE)'
   return,0
endif
NDATA=keyword_set(NDATA)
VERBOSE=keyword_set(VERBOSE)

if not (file_test(file)) then begin
   message,/CONT,file+' does not exist!'
   return,0
endif

; Read file header
header = {irad:0,idipxy:0, $
          starttime:{calend_date}, $ 
          endtime:{calend_date}, $
	  nfreq:0,quantile:0.0,nbins:0l,interp:0}
openr,lun,file,/GET_LUN,/SWAP_IF_LITTLE_ENDIAN
readu,lun,header

if (NDATA) then begin
   close,lun
   free_lun,lun
   return,header.nfreq
endif

; Read frequency values
freq = fltarr(header.nfreq)
readu,lun,freq

nrec_s = lonarr(2,header.nfreq)
nrec_sp = lonarr(2,header.nfreq)
nrec_z = lonarr(2,header.nfreq)
Bs = fltarr(2,header.nfreq)     ; Background values computed for the sep and sum config
Bsp = fltarr(2,header.nfreq)
Bz = fltarr(2,header.nfreq)

readu,lun,nrec_s,nrec_sp,nrec_z
readu,lun,Bs,Bsp,Bz

s = {background:[0.0,0.0],nsample:[0L,0L]}
sp = {background:[0.0,0.0],nsample:[0L,0L]}
z = {background:[0.0,0.0],nsample:[0L,0L]}
data = {freq:0.0,s:s,sp:sp,z:z}
data = replicate(data,header.nfreq)

for i=0l,header.nfreq-1l do begin
   data[i].freq = freq[i]
   data[i].s.background = Bs[*,i] & data[i].s.nsample = nrec_s[*,i] 
   data[i].sp.background = Bsp[*,i] & data[i].sp.nsample = nrec_sp[*,i]
   data[i].z.background = Bz[*,i] & data[i].z.nsample = nrec_z[*,i]
endfor
close,lun
free_lun,lun

error=0b
return,data
END
