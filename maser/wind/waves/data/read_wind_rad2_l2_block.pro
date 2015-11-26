PRO read_wind_rad2_l2_block,lun,header,data


;+
; NAME:
;       read_wind_rad2_l2_block
;
; PURPOSE:
; 	    Read a block of a Wind Waves rad2 level 2 binary data file.
;
; CATEGORY:
;	    I/O
;
; GROUP:
;	    None.
;
; CALLING SEQUENCE:
;	    read_wind_rad2_l2_block,lun,cycle_tnr,t_ur8,freq,dbagc,sdbv,dbagc2,sdbv2
;
; INPUTS:
;       lun - Logical unit number of the opened rad2 data file.
;	
; OPTIONAL INPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; OUTPUTS:
;	    header  - Structure containing the header of the current block.
;       data    - Structure containing the 
;
; OPTIONAL OUTPUTS:
;       None.
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
;	None.
;
; EXAMPLE:
;	None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;       Adapted from r_header_l2_v03.pro and lire_l2_v03.pro routines.
;
;-

if (n_params() lt 1) then begin
   message,/INFO,'Usage:'
   print,'read_wind_rad2_l2_block,lun,header,data'
   return
endif

t_CCSDS=lonarr(2) & tdeb_bloc=0d0 & tfin_bloc=0d0
int_time=0.
block_size=0l & agc_size=0l & stm_size=0l
nb=0l & ncycles=0l & nfreq=0l
count=0l & state=0l & mode=0l
antenna=0l & antenna_1=0l & antenna_2=0l

readu,lu,t_CCSDS,tdeb_bloc,tfin_bloc,int_time, $
         block_size,agc_size,stm_size,nb,ncycles, $
         nfreq,count,state,mode, $
         antenna,antenna_1,antenna_2,band

fixed_tune=state eq 1 & ABCDE=state eq 2 & ACE=state eq 3

tdeb_fin_ur8=[tdeb_bloc,tfin_bloc]	; intervalle de temps UR8
					; disponible dans le bloc
t_ur8=dblarr(ncycles)
case 1 of
 fixed_tune: begin
  nf=nfreq
  freq=4.*2.^(band+(2*indgen(nfreq)+1.)/nfreq)
  dbagc=fltarr(ncycles)
  sdbv=fltarr(ncycles,nfreq)
  if mode eq 4 then begin
   dbagc2=fltarr(ncycles)
   sdbv2=fltarr(ncycles,nfreq)
  endif
 end
 ACE: begin
  nf=3*nfreq
  freq=reform(4*2.^((2*indgen(nf)+1.)/nfreq),nfreq,3)
  dbagc=fltarr(ncycles,3)
  sdbv=fltarr(ncycles,nfreq,3)
  if mode eq 4 then begin
  dbagc2=fltarr(ncycles,3)
  sdbv2=fltarr(ncycles,nfreq,3)
  endif

 end

 ABCDE: begin
  nf=5*nfreq
  freq=fltarr(nfreq,5)
  nf_ace=3*nfreq & nf_bd=2*nfreq    
  freq(*,[0,2,4])=reform(4.*2^((2*indgen(nf_ace)+1.)/nfreq),nfreq,3)
  freq(*,[1,3])=reform(8.*2^((2*indgen(nf_bd)+1.)/nfreq),nfreq,2)
  dbagc=fltarr(ncycles,5)
  sdbv=fltarr(ncycles,nfreq,5)
  if mode eq 4 then begin
   dbagc2=fltarr(ncycles,5)
   sdbv2=fltarr(ncycles,nfreq,5)
  endif

 end
endcase
cycle_tnr={ $
	  tdeb_fin_ur8:tdeb_fin_ur8, $	; [ debut, fin] UR8
	  ncycles:ncycles,	$	; nombre de cycles du bloc
	  nb:nb, $			; nombre de bandes du cycle
	  nf:nf, $			; nombre de freuences du cycle
	  nfreq:nfreq, $		; nombre de freuences d'une bande
          state:state, $	        ; type de cycle : FT(1), ABCDE(2) ou ACE(3)
          mode:mode,	  $		; 0 ou 1 : TNR A ou TNR B, nfreq=16
					; 2 ou 3 : TNR A ou TNR B, nfreq=32
					;    4   : TNR A et TNR B, nfreq=16
	  antenna:antenna, $		; a n'utiliser qu'en mode 4
          antenna_1:antenna_1, $	; n° d'antenne disponible (sur TNR A 
					; en mode 4)
          antenna_2:antenna_2, $	; mode 4, n° d'antenne TNR B
          bande:band, $
          freq:freq $
	  }


if cycle_tnr.mode lt 4 then begin
   ; Reading time,spectra 1 and AGC 1 : TNR A or TNR B
   readu,lu,t_CCSDS,t_ur8,sdbv,dbagc
endif else begin
   ; Reading time,spectra 1 and AGC 1 : TNR A following by
   ; spectra 2 and AGC 2 : TNR B
   readu,lu,t_CCSDS,t_ur8,sdbv,dbagc,sdbv2,dbagc2
endelse

return
end
