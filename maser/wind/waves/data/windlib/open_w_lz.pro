FUNCTION open_w_lz,filename, $
                   lun=lun, $
                   MESSAGES_ON=MESSAGES_ON, $
                   VERBOSE=VERBOSE


;+
; NAME:
;               open_w_lz
;
; PURPOSE:
; 		open a wind/waves lz file using the WindLib. 
;
; CATEGORY:
;		I/O
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		ch = open_w_lz(filename)
;
; INPUTS:
;               filename - Name of the lz file to open.       
;	
; OPTIONAL INPUTS:
;		None.
;
; KEYWORD PARAMETERS:
;               /MESSAGES_ON - Set Windlib message displaying to on.
;		/VERBOSE     - Talkative mode.
;
; OUTPUTS:
;		ch - File's channel opened.
;
; OPTIONAL OUTPUTS:
;               lun - Contains the logical unit number of the open file.
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

ch=0l & ok=0l
if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,' ch = open_w_lz(filename, $'
   print,'                lun=lun, $'
   print,'                /MESSAGES_ON, $'
   print,'                /VERBOSE'
   return,-1
endif
VERBOSE = keyword_set(VERBOSE)
MESSAGE = keyword_set(MESSAGES_ON)

if (VERBOSE) then print,'Fetching '+filename

lun = w_channel_open(ch,filename)
if (lun ne 1) then begin
   message,/CONT,'Fetching file has failed!'
   Return,-1
endif
if not (MESSAGE) then ok = w_messages_off(ch) $
else ok = w_messages_on(ch) 

return,ch
END
