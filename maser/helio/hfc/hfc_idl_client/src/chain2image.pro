FUNCTION chain2image, chain, position_init,$
                      CLOCKWISE=CLOCKWISE

;+
; NAME:
;		chain2image
;
; PURPOSE:
; 		Generate contours from the input chaincode.
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		IDL>Result = chain2image(chain,pos)
;
; INPUTS:
;		chain	- string containing the chaincode.
;		pos     - position [X,Y] of the first pixel.
;	
; OPTIONAL INPUTS:
;		flag - Specify if the chain code follows clockwise or counter clockwise
;              convention:
;
; KEYWORD PARAMETERS:
;		/CLOCKWISE - If set the chain code follows clockwise
;                            convention, otherwise use counter clockwise.
;
; OUTPUTS:
;		structure - array which contains the pixels' coordinates
;                   of the contours defined by the chaincode. 		
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
; RESTRICTIONS:
;		None.
;
; CALL:
;		None.	
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by: Morgan Fouesneau, Maud Galametz, François Gonon, Antonin Maire, 01-JUN-2006.
;
;		10-JUN-2010,    X.Bonnin:    Increased the character number readable in chain parameter by 
;					     the procedure reads (300->strlen(chain)).
;					     Added a test on the chain parameter size.
;		23-JUN-2010,    X.Bonnin:    Removed taille input parameter. 
;			                     The chain length is directly computed from strlen(chain)
;		07-JUN-2011,    X.Bonnin:    create_structure was renamed to chain2image
;		
;-

if (n_params() lt 2) then begin
   message,/INFO,'Call is:'
   print,'Results = chain2image(chain,position_init,/CLOCKWISE)'
   return,0.
endif
if (keyword_set(CLOCKWISE)) then factor=-1 $
else factor=1

T = lonarr(8,2)
T[0,*] = [-1,0]
T[1,*] = [-1,-1]
T[2,*] = [0,-1]
T[3,*] = [1,-1]
T[4,*] = [1,0]
T[5,*] = [1,1]
T[6,*] = [0,1]
T[7,*] = [-1,1]

T[*,0]=factor*T[*,0]

;Get the chain parameter size
taille = strlen(strtrim(chain,2))

; reading the chaincode into an array
chain_array=bytarr(taille)		; begin from 0 to taille-1 
reads, chain, chain_array, format='('+strtrim(taille,2)+'(I1))'

; transcription chaincode to coord. in an array
structure=fltarr(2,taille+1)
structure(*,0)=position_init
for i=0,taille-1 do begin
   structure[*,i+1]=structure[*,i]+T[chain_array[i],*]
endfor

return, structure
END
