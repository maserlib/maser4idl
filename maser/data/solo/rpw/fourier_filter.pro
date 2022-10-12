pro fourier_filter, V, Vf, Vf0
; +
; NAME:
;   fourier_filter
;
; PURPOSE:
;   Produces a Fourier passband filtered TNR spectrogram
;
; CALLING SEQUENCE:
;
;   fft_filter,x1,xf,xfnull,tlow,tup
;
; INPUTS:
;   V - INPUT DYNAMICAL SPECTRUM (from read_tnr_data.pro)
;
; OPTIONAL INPUTS:
;   None.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;    Vf - OUTPUT FILTERED DYNAMICAL SPECTRUM
;    VF0 - OUTPUT AVERAGE  DYNAMICAL SPECTRUM (OBTAINED BY TAKING THE FFT MODE 0 ONLY)
;
; OPTIONAL OUTPUTS:
;   None.
;
;NOTES:
;  After some tests I found the optimal tup=280. and tlow=0.01
;
; MODIFICATION HISTORY:
;   Written by A.VECCHIO (LESIA, CNRS - RRL Radboud University): March 2020
;
; -

tup=280.
tlow=0.01

Vf=V*0.0
Vf0=Vf
V2=10.*alog10(V) ; I apply the FFT filter on DB data
sz=size(V2)
for i=0,sz(2)-1 do begin
	x=reform(V2(*,i))
	fft_filter,x,xf,xfnull,tlow,tup
	Vf(*,i)=xf
	Vf0(*,i)=xfnull

endfor

end
