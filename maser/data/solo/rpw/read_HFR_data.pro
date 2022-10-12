pro read_HFR_data,namefile,sensor,V,time,freq_hfr,sweepn_HFR,indstart,indend
; +
; NAME:
;   read_HFR_data
;
; PURPOSE:
;   READ L2 data from HFR
;
; CALLING SEQUENCE:
;
;   read_HFR_data,namefile,sensor,V,time,freq_hfr
;
; INPUTS:
;   namefile - STRING OF THE FILENAME IN .CDF CONTAINING THE L2 DATA
;
;   sensor : HFR SENSOR TO BE READ
;				9:V1-V2
;				10:V2-V3
;				11:V3-V1
;
;   indstart: starting time index
;
;   indend:  end time index. indend=-99 means the last point of the timeserie.
;
;
; OPTIONAL INPUTS:
;   None.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;    V: array (time,frequency) of the measured signals
;    time: time of each measurement in Julian days
;    freq_hfr:frequency in kHz
;
; OPTIONAL OUTPUTS:
;   None.
;
;NOTES:
;  The script check if there are data from the two channel and put them together.
;  Since the number of frequency steps for HFR is not known a priori an array of 321 frequency points is considered.
;  Values are filled with -99 where there are no data points
;
; MODIFICATION HISTORY:
;   Written by A.VECCHIO (LESIA, CNRS - RRL Radboud University): February 2020
;
; -

data_L2=rcdf(namefile)
frequency=reform(data_L2.frequency.data) ; frequency in kHz

nn=n_elements(data_L2.epoch.data)
if indend eq -99 then indend=nn-1

frequency=frequency(indstart:indend)
epochdata=data_L2.epoch.data[indstart:indend]
sensor_config=data_L2.sensor_config.data[*,indstart:indend]
agc1_data=data_L2.agc1.data[indstart:indend]
agc2_data=data_L2.agc2.data[indstart:indend]
sweep_numo=data_L2.sweep_num.data[indstart:indend]

puntical=where(data_L2.front_end.data[indstart:indend] eq 1)
epochdata=epochdata[puntical]
frequency=frequency[puntical]
sensor_config=sensor_config[*,puntical]
agc1_data=agc1_data[puntical]
agc2_data=agc2_data[puntical]
sweep_numo=sweep_numo[puntical]
sweep_num=sweep_numo
deltasw=abs(double(sweep_numo[1:*])-double(sweep_numo[0:n_elements(sweep_numo)-2] ))
xdeltasw=where(deltasw gt 100,xdsw)
if xdsw gt 0 then begin
    xdeltasw=[xdeltasw,n_elements(sweep_numo)-1]
    nxdeltasw=n_elements(xdeltasw)
	for inswn=0,nxdeltasw-2 do begin	;sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]=sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]+sweep_numo[xdeltasw[inswn]]
	sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]=sweep_num[xdeltasw[inswn]+1:xdeltasw[inswn+1]]+sweep_num[xdeltasw[inswn]]
    endfor
endif
CDF_EPOCH, epochdata , yr, mo, dy, hr, mn, sc, milli, /BREAK
timet = CDF_EPOCH_TOJULDAYS (epochdata);JULDAY(mo,dy,yr,hr,mn,sc)
timetr=timet-timet[0]
sens0=where(sensor_config[0,*] eq sensor,psens0)
sens1=where(sensor_config[1,*] eq sensor,psens1)
if (sens0[0] ne -1L and sens1[0] ne -1L) then begin
	agc=[agc1_data[sens0],agc2_data[sens1]]
	frequency=[frequency[sens0],frequency[sens1]]
    sens=[sens0,sens1]
    ;timet_ici=[timet[sens0],timet[sens1]]
    timet_ici=timet[sens]
endif else begin
    if (sens0[0] ne -1L) then begin
        agc=agc1_data[sens0]
	    frequency=frequency[sens0]
	    sens=sens0
    	timet_ici=timet[sens0]
    endif
    if (sens1[0] ne -1L) then begin
		agc=agc2_data[sens1]
		frequency=frequency[sens1]
		sens=sens1
		timet_ici=timet[sens1]
    endif
    if (sens0[0] eq -1L and sens1[0] eq -1L) then begin
        V=dblarr(321)
        V[0:*]=-99.
        time=-99.
        print,'no data at all ?!?
        return
   	  endif
endelse


ord_time=sort(timet_ici)
timerr=timet_ici[ord_time]
sens=sens[ord_time]
agc=agc[ord_time]
frequency=frequency[ord_time]

maxsweep=max(sweep_num[sens])
minsweep=min(sweep_num[sens])
sweep_num=sweep_num[sens]


V1=dblarr(321)-99
V=dblarr(321)
freq_hfr1=dblarr(321)-99
freq_hfr=dblarr(321)
time=0.0
sweepn_HFR=0.0
;ind_freq=[(frequency-375.)/50.]-436.; dati airbus test
ind_freq=[(frequency-375.)/50.]
for ind_sweep=long(minsweep),long(maxsweep) do begin
    ppunt=where(sweep_num eq ind_sweep,xm)
    if xm gt 0 then begin
    	V1[ind_freq[ppunt]]=agc[ppunt]
    	freq_hfr1[ind_freq[ppunt]]=frequency[ppunt]
    endif
    if max(V1) gt 0.0 then begin
    	V=[[V],[V1]]
    	freq_hfr=[[freq_hfr],[freq_hfr1]]
    	;sweepn_HFR=[sweepn_HFR,sweep_num[sens[ppunt[0]]]]
    	sweepn_HFR=[sweepn_HFR,sweep_num[ppunt[0]]]
    endif
    V1=dblarr(321)-99
    freq_hfr1=dblarr(321)
    if xm gt 0 then time=[time,timerr[min(ppunt)]]
    ;if n_elements(V(0,*)) eq 2987 then stop
endfor
V=transpose(V[*,1:*])
time=time[1:*]
freq_hfr=transpose(freq_hfr[*,1:*])
sweepn_HFR=sweepn_HFR[1:*]
end
