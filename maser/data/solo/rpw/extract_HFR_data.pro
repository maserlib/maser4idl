pro extract_HFR_data, V, Vf,pp
; +
; NAME:
;   extract_HFR_data
;
; PURPOSE:
;   Extract significant data (not equal to -99) from a HFR spectrogram 
;
; CALLING SEQUENCE:
;
;  extract_HFR_data, V, Vf,pp
;
; INPUTS:
;   V - raw HFR spectrogram as obtained from read_HFR_data
;
; OPTIONAL INPUTS:
;   None.
;
; KEYWORD PARAMETERS:
;  
; OUTPUTS:
;    Vf: array (time,frequency) of the measured signals with only significant informations
;    pp: frequency index where significant signal are detected
;
; OPTIONAL OUTPUTS:
;   None.
;
;  NOTES:
;  There is a "stop" while the program is running. Choose the channel as ch=1 or ch=2 then type .c
;  Since the number of frequency step for HFR is not known a priori an array of 321 frequency points is considered.
;  Values are filled with -99 where there are no data points
;
; MODIFICATION HISTORY:
;   Written by A.VECCHIO (LESIA, CNRS - RRL Radboud University): March 2020
;
; -

nv=n_elements(V[*,0])
punt_freq=intarr(nv)
for j=0,nv-1 do begin
 	pp=where(V(j,*) gt 0,xn)
 	punt_freq[j]=xn
endfor
jmax=max(punt_freq,xjmax)
pp=where(V(xjmax,*) gt 0, xn)
;pp=where(V(10,*) gt 0, xn)
Vf=fltarr(nv,xn)
for i=0,nv-1 do begin
		pp1=where(V(i,*) gt 0, xxn)
       if xn gt 0 then Vf(i,0:xxn-1)=reform(V(i,pp1))
endfor

end

