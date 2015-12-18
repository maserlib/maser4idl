FUNCTION read_wind_waves_gain,file,header,$
                              NDATA=NDATA, $
                              VERBOSE=VERBOSE

;+
; NAME:
;       read_wind_waves_gain
;
; PURPOSE:
; 	Read a binary file containing the
;       Wind Waves rad1 or rad2 total system gain 
;       G=G0*Z0 deducing from the Galaxy background.
;
;       See Manning and Fainberg, Space Sci. Inst., (1980) for 
;       a definition of G, and Dulk et al., AA, 2001 for the calibration
;       method.
;
; CATEGORY:
;	I/O
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	data = read_wind_waves_gain( file, header)
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
;       /NDATA      - If set, returns number of data samples. 
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
   print,'data = read_wind_waves_gain(file,header,/VERBOSE,/NDATA)'
   return,0
endif
VERBOSE=keyword_set(VERBOSE)
NDATA=keyword_set(NDATA)

if not (file_test(file)) then begin
   message,/CONT,file+' does not exist!'
   return,0
endif

header = {irad:0, $
          Cay:0.0, Cby:0.0, Ly:0.0, $
          Caz:0.0, Cbz:0.0, Lz:0.0, $
          nfreq:0,missing_value:0.}
openr,lun,file,/GET_LUN,/SWAP_IF_LITTLE_ENDIAN
readu,lun,header
nfreq = header.nfreq
if (NDATA) then return,nfreq
freq = fltarr(nfreq)
gain_s = fltarr(2,nfreq)
gain_sp = fltarr(2,nfreq)
gain_z = fltarr(2,nfreq)
readu,lun,freq
readu,lun,gain_s,gain_sp,gain_z
close,lun
free_lun,lun

s = {gain:[0.0,0.0]}
sp = {gain:[0.0,0.0]}
z = {gain:[0.0,0.0]}
data = {freq:0.0,s:s,sp:sp,z:z}
data = replicate(data,nfreq)

for i=0l,nfreq-1l do begin
   data[i].freq = freq[i]
   data[i].s.gain = gain_s[*,i]  
   data[i].sp.gain = gain_sp[*,i] 
   data[i].z.gain = gain_z[*,i]
endfor

error=0b
return,data
END
