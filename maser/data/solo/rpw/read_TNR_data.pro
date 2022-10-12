pro read_TNR_data,namefile,sensor,V,time,freq_tnr,sweepn_TNR,indstart,indend
; +
; NAME:
;   read_TNR_data
;
; PURPOSE:
;   READ L2 data from TNR
;
; CALLING SEQUENCE:
;
;   read_TNR_data,namefile,sensor,V,time,freq_tnr,sweepn_TNR,indstart,indend
;
; INPUTS:
;   namefile - STRING OF THE FILENAME IN .CDF CONTAINING THE L2 DATA 
;
;   sensor : TNR SENSOR TO BE READ
;             	1: V1
;             	2:V2
;				3:V3
;				4:V1-V2
;				5:V2-V3
;				6:V3-V1
;				7: B
;
;   indstart: starting time index
;   
;   indend:  end time index. indend=-99 means the last point of the timeserie.
;
; OPTIONAL INPUTS:
;   None.
;
; KEYWORD PARAMETERS:
;  
; OUTPUTS:
;    V: array (time,frequency) of the measured signals
;    time: time of each measurement in Julian days
;    freq_tnr: frequency in kHz
;
; OPTIONAL OUTPUTS:
;   None.
; 
;NOTES:
;  The script check if there are data from the two channel and put them together.
;  
; MODIFICATION HISTORY:
;   Written by A.VECCHIO (LESIA, CNRS - RRL Radboud University): February 2021
;
; -


data_L2=rcdf(namefile)
freq_tnr=[reform(data_L2.TNR_band_freq.data[0,*]),reform(data_L2.TNR_band_freq.data[1,*]),reform(data_L2.TNR_band_freq.data[2,*]),reform(data_L2.TNR_band_freq.data[3,*])]/1000. ; freq in kHz

nn=n_elements(data_L2.epoch.data)
if indend eq -99 then indend=nn-1

epochdata=data_L2.epoch.data[indstart:indend]
sensor_config=data_L2.sensor_config.data[*,indstart:indend]
auto1_data=data_L2.auto1.data[*,indstart:indend]
auto2_data=data_L2.auto2.data[*,indstart:indend]
sweep_numo=data_L2.sweep_num.data[indstart:indend]
bande=data_L2.tnr_band.data[indstart:indend]
if sensor eq 7 then begin
	auto1_data=data_L2.MAGNETIC_SPECTRAL_POWER1.data[*,indstart:indend];
	auto2_data=data_L2.MAGNETIC_SPECTRAL_POWER2.data[*,indstart:indend]
endif
puntical=where(data_L2.front_end.data[indstart:indend] eq 1)
epochdata=epochdata[puntical]
sensor_config=sensor_config[*,puntical]
auto1_data=auto1_data[*,puntical]
auto2_data=auto2_data[*,puntical]
sweep_numo=sweep_numo[puntical]
bande=bande[puntical]
sweep_num=sweep_numo
;sweep0=0

deltasw=abs(double(sweep_numo[1:*])-double(sweep_numo[0:n_elements(sweep_numo)-2] ))
xdeltasw=where(deltasw gt 100,xdsw) 
if xdsw gt 0 then begin
    xdeltasw=[xdeltasw,n_elements(sweep_numo)-1]
    nxdeltasw=n_elements(xdeltasw)
	for inswn=0,nxdeltasw-2 do begin	sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]=sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]+sweep_num[xdeltasw[inswn]]  
	;sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]=sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]+sweep_numo[xdeltasw[inswn]] VERSIONE PER PYTHON 
    endfor
endif
;for indsw=1,n_elements(sweep_num)-1 do begin;;
;        sweep_num[indsw]=sweep0
;	    if sweep_numo[indsw] lt sweep_num[indsw-1]  then begin
;	    	sweep0=sweep0+1
;	    	sweep_num[indsw]=sweep0
;		endif 
;endfor
CDF_EPOCH, epochdata , yr, mo, dy, hr, mn, sc, milli, /BREAK
timet = CDF_EPOCH_TOJULDAYS (epochdata);JULDAY(mo,dy,yr,hr,mn,sc)
timetr=timet-timet[0]
sens0=where(sensor_config[0,*] eq sensor,psens0)
sens1=where(sensor_config[1,*] eq sensor,psens1)
if (sens0[0] ne -1L and sens1[0] ne -1L) then begin
	auto_calib=[[auto1_data[*,sens0]],[auto2_data[*,sens1]]]
    sens=[sens0,sens1]
    timet_ici=[timet[sens0],timet[sens1]]
endif else begin
    if (sens0[0] ne -1L) then begin
        auto_calib=auto1_data[*,sens0]
		sens=sens0
    	timet_ici=timet[sens0]   
    endif
    if (sens1[0] ne -1L) then begin
		auto_calib=auto2_data[*,sens1]
		sens=sens1
    	timet_ici=timet[sens1]   
      endif
      if (sens0[0] eq -1L and sens1[0] eq -1L) then begin
        V=fltarr(128)
        V[0:*]=-99.
        time=-99.
        print,'no data at all ?!?
        return
   	  endif
endelse
ord_time=sort(timet_ici) 
timerr=timet_ici[ord_time]
sens=sens[ord_time]
auto_calib=auto_calib[*,ord_time]
bandee=bande[sens]
maxsweep=max(sweep_num[sens])
minsweep=min(sweep_num[sens])
sweep_num=sweep_num[sens]


V1=dblarr(128)
V=fltarr(128)
time=0.0
sweepn_TNR=0.0
    ;if xm gt 3 then V1[96:*]=auto_calib[*,[ppunt[3]]]
	;if xm gt 2 then V1[64:95]=auto_calib[*,[ppunt[2]]]
   ; if xm gt 1 then V1[32:63]=auto_calib[*,[ppunt[1]]]
    ;if xm gt 0 then V1[0:31]=auto_calib[*,[ppunt[0]]]  
for ind_sweep=minsweep,maxsweep do begin
    ppunt=where(sweep_num eq ind_sweep,xm)
    ;if ind_sweep ge 13868.0 then stop
    if xm gt 0 then begin 
    	for indband=0,xm-1 do begin
    	     ;   print,ind_sweep,bandee[ppunt[indband]]
    		V1[32*bandee[ppunt[indband]]:32*bandee[ppunt[indband]]+31]=auto_calib[*,[ppunt[indband]]]
    		;if ind_sweep eq 922 then stop
    	endfor
    endif
  ;if ind_sweep ge 13868.0 then stop
   ; if xm gt 3 then begin 
   ; 	V1[96:*]=auto_calib[*,[ppunt[3]]]
   ; 	V1[64:95]=auto_calib[*,[ppunt[2]]]
   ; 	V1[32:63]=auto_calib[*,[ppunt[1]]]
   ; 	V1[0:31]=auto_calib[*,[ppunt[0]]] 
   ; endif
   ; if xm eq 1 then begin
   ;  	V1[32:63]=auto_calib[*,[ppunt[0]]]  
   ; endif
   if total(V1) gt 0.0 then begin
    	punt0=where(V1 eq 0.0, xp0)
    		if xp0 gt 0 then V1[punt0]=1e-30
   		V=[[V],[V1]]
    	sweepn_TNR=[sweepn_TNR,sweep_num[ppunt[0]]]
    endif
    V1=dblarr(128)
    if xm gt 0 then time=[time,timerr[min(ppunt)]]
endfor
V=transpose(V[*,1:*])
time=time[1:*]
sweepn_TNR=sweepn_TNR[1:*]
end