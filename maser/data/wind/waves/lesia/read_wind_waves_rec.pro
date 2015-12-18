FUNCTION read_wind_waves_rec, file, header, $
                              error=error, $ 
                              VERBOSE=VERBOSE

;+
; NAME:
;               read_wind_waves_rec
;
; PURPOSE:
; 		Read Wind Waves rad1/rad2 receiver background
;               values from an input binary file.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		read_wind_waves_rec, file, header
;
; INPUTS:
;               file - Pathname to the file to read.
;	
; OPTIONAL INPUTS:
;		None.
;
; KEYWORD PARAMETERS:
;		/VERBOSE    - Talkative mode.
;
; OUTPUTS:
;		data - Structure containing receiver backgrounds.
;
; OPTIONAL OUTPUTS:
;               header - Structure containing the header of the file. 
;		error  - Returns 1b if an error has occurred during processing, 0b otherwise.
;		
; COMMON BLOCKS:		
;		None.
;	
; SIDE EFFECTS:
;		None.
;		
; RESTRICTIONS/COMMENTS:
;		None. 
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
;               8-AUG-2012, X.Bonnin:   Added mode parameter in the
;               header. 			
;				
;-

error = 1b
if (n_params() lt 1) then begin
	message,/CONT,'Call is:'
	print,'read_wind_waves_rec, file, header, $'
	print,'                     error=error, /VERBOSE)'
	return,0
endif
VERBOSE = keyword_set(VERBOSE)

if not (file_test(file)) then begin
   message,/CONT,file+' does not exist!'
   return,0
endif

header = {irad:0, iunit:0, nfreq:0, ianten:intarr(2)}
openr,lun,file,/GET_LUN,/SWAP_IF_LITTLE_ENDIAN
readu,lun,header
fkhz = fltarr(header.nfreq)
s_bkgd = fltarr(2,header.nfreq)
sp_bkgd = fltarr(2,header.nfreq)
z_bkgd = fltarr(2,header.nfreq)
readu,lun,fkhz
readu,lun,s_bkgd
readu,lun,sp_bkgd
readu,lun,z_bkgd
close,lun
free_lun,lun

data = {freq:fkhz,s:s_bkgd,sp:sp_bkgd,z:z_bkgd}

error=0b
return,data
END
