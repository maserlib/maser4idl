function gt_brstr, tt, lhb, rhb, trim=trim, include=include

if strpos(tt,lhb) lt 0 or strpos(tt,rhb) lt 0 then begin
  message,'string limits not found',/cont
  return,''
endif

if not keyword_set(include) then begin
  tt1 = strmid(tt,strpos(tt,lhb)+strlen(lhb),strlen(tt)+100)
  out = strmid(tt1,0,strpos(tt1,rhb))
endif else begin
  tt1 = strmid(tt,strpos(tt,lhb),strlen(tt)+100)
  out = strmid(tt1,0,strpos(tt1,rhb)+strlen(rhb))
endelse

if keyword_set(trim) then out=strtrim(out,2)

return, out
end
