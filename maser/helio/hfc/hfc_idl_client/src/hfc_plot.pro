PRO show,data, $
         feature_name=feature_name, $
         _EXTRA=EXTRA, $
         xsize=xsize,ysize=ysize, $
         qclk_ctable=qclk_ctable, $
         feat_ctable=feat_ctable, $
         qclk_dir=qclk_dir, $
         SOLAR_RADIUS=SOLAR_RADIUS, $
         SIGHT=SIGHT, $
         PIXELS=PIXELS, $
         CENTROID_ONLY=CENTROID_ONLY, $
         CONTOURS_ONLY=CONTOURS_ONLY, $
         TRACKING_COLORS=TRACKING_COLORS, $
         NO_FEATURE=NO_FEATURE, $
         NO_QUICKLOOK=NO_QUICKLOOK, $
         FREE_WINDOW=FREE_WINDOW, $
         ONE_WINDOW=ONE_WINDOW, $
         FULL_SCREEN=FULL_SCREEN, $
         REMOVE_FILE=REMOVE_FILE, $
         QUIET=QUIET,HELP=HELP

;+
; NAME:
;       show
;
; PURPOSE:
; 	Display hfc data.
;
; CATEGORY:
;	plot
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	show,data
;   or
;       show,instrument=instrument,observatory=observatory,near_date=near_date, ...
;   or 
;       show,feature_name=feature_name,instrument=instrument, ...
;
; INPUTS:
;       data    - IDL structure containing HFC observation or
;                 feature data.
;                 If data argument is not provided, data can be 
;                 queried from HFC giving dedicated 
;                 optional arguments (see OPTIONAL INPUTS below).
;	
; OPTIONAL INPUTS:
;       feature_name - Name of the feature to plot. (Only works when
;                      data argument is not provided).
;       EXTRA        - Accept all of the optional arguments from get_observation
;                      or get_feature functions. See the functions headers for
;                      more details. (Only works when data argument is not provided)
;       qclk_dir     - Directory where quicklook files are saved.
;       xsize        - Size in pixels of the window along x-axis.
;       ysize        - Size in pixels of the window along y-axis.
;       qclk_ctable  - Color table index for the quicklook image.
;                      Default is 0 (B&W).
;       feat_ctable  - Color table index for the feature image.  
;                      Default is 39 (Rainbow + B&W).    
;
; KEYWORD PARAMETERS:
;       /SOLAR_RADIUS    - If available, overplot the solar radius
;                          contour.
;       /SIGHT           - If set, overplot a cross to indicate the line
;                          of sight.
;       /PIXELS          - If set, use pixels coordinates instead of
;                          dedicated units coordinates.
;       /CENTROID_ONLY   - If set, Only overplot feature centroids.
;       /CONTOURS_ONLY   - If set, Only overplot feature contours. 
;       /TRACKING_COLORS - If set, overplot features using the
;                          tracking indices as colors.
;       /NO_FEATURE      - If set, do not overplot feature.
;       /NO_QUICKLOOK    - If set, do not show quicklook image.
;       /ONE_WINDOW      - If set, force the display in one window.
;                          If more than one observation must be showed, then
;                          the progam will set !P.MULTI variable.
;       /FREE_WINDOW     - If set, create one window for each
;                          observation. (Disabled if /ONE_WINDOW is set.)
;       /FULL_SCREEN     - If set, use a full sceen window.
;       /REMOVE_FILE     - if downloading is required, remove file(s)
;                          after reading.
;	/QUIET           - Quiet mode.
;       /HELP            - Display help message, then quit the program.
;
; OUTPUTS:
;	None.
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
;	wget software must be installed 
;       on the OS.
;			
; CALL:
;       get_observation
;       get_feature
;       read_image
;       chain2image
;       tag_exist
;       display2d
;
; EXAMPLE:
;       1 - To plot Nancay radioheliograph image for 01 January 2008 at 08:00:00
;       
;           hfc_nrh_data=get_observation(observat='Nancay',instrume='Radioheliograph',near_date='2008-01-01T08:00:00')
;           show,hfc_nrh_data 		
;       or
;           show,observat='Nancay',instrume='Radioheliograph',near_date='2008-01-01T08:00:00'
;
;       2 - To plot Sunspots detected on SDO/HMI between 10 June 2012
;           at 12:00:00 and 10 June 2012 at 18:00:00 with tracking information:
;       
;           hfc_hmi_data=get_feature('sunspots',observat='SDO',instrume='HMI', $
;                                    starttime='2012-06-10T12:00:00', $
;                                    endtime='2012-06-10T18:00:00')
;           show,hfc_hmi_data,/TRACKING_COLORS,/ONE_WINDOW,/FULL_SCREEN		
;       or
;           show,feature_name='sunspots,observat='SDO',instrume='HMI', $
;                starttime='2012-06-10T12:00:00', $
;                endtime='2012-06-10T18:00:00', $
;                /TRACKING_COLORS,/ONE_WINDOW,/FULL_SCREEN
; 
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-


device,get_screen_size=screen
CD,current=current_directory

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'show,data, $'
   print,'     feature_name=feature_name, $'
   print,'     xsize=xsize,ysize=ysize, $'
   print,'     qclk_ctable=qclk_ctable, $'
   print,'     feat_ctable=feat_ctable, $'
   print,'     qclk_dir=qclk_dir, $'
   print,'     /SOLAR_RADIUS,/SIGHT, $'
   print,'     /PIXELS,/CENTROID_ONLY, $'
   print,'     /CONTOURS_ONLY,/TRACKING_COLORS, $'
   print,'     /NO_QUICKLOOK,/NO_FEATURE, $'
   print,'     /ONE_WINDOW,/FREE_WINDOW, $'
   print,'     /FULL_WINDOW,/REMOVE_FILE, $'
   print,'     /QUIET,_EXTRA=EXTRA'
   return
endif
QUIET=keyword_set(QUIET)
SOLAR_RADIUS=keyword_set(SOLAR_RADIUS)
SIGHT=keyword_set(SIGHT)
PIXELS=keyword_set(PIXELS)
CENTROID=keyword_set(CENTROID_ONLY)
CONTOURS=keyword_set(CONTOURS_ONLY)
TCOLORS=keyword_set(TRACKING_COLORS)
NO_QCLK=keyword_set(NO_QUICKLOOK)
NO_FEAT=keyword_set(NO_FEATURE)
ONE=keyword_set(ONE_WINDOW)
FULL=keyword_set(FULL_SCREEN)
FREE=keyword_set(FREE_WINDOW) and not ONE
REMOVE_FILE=keyword_set(REMOVE_FILE)

if not (keyword_set(qclk_dir)) then qclk_dir=current_directory
if not (keyword_set(qclk_ctable)) then qclk_ctable=0
if not (keyword_set(feat_ctable)) then feat_ctable=39

if (FULL) then begin
   xsize=screen[0]
   ysize=screen[1]
endif else begin
   if not (keyword_set(xsize)) then xsize=0.5*screen[1]
   if not (keyword_set(ysize)) then ysize=0.5*screen[1]
endelse

if (n_params() lt 1) then begin
   if (keyword_set(feature_name)) then begin
      data=get_feature(feature_name,_EXTRA=EXTRA)
   endif else data = get_observation(_EXTRA=EXTRA)
endif 
if (size(data,/TNAME) ne 'STRUCT') then begin
   message,/CONT,'Input argument must be a IDL structure!'
   return
endif 
feat_flag=tag_exist(data,'FEATURE_NAME')
if (NO_FEAT) then feat_flag=0b
track_flag=tag_exist(data,'TRACK_ID')

if not (tag_exist(data,'DATE_OBS')) then message,'Input structure must contain DATE_OBS values!' 
if not (tag_exist(data,'OBSERVAT')) then message,'Input structure must contain OBSERVAT values!' 
if not (tag_exist(data,'INSTRUME')) then message,'Input structure must contain INSTRUME values!' 
if not (tag_exist(data,'TELESCOP')) then message,'Input structure must contain INSTRUME values!'
if not (tag_exist(data,'CDELT1')) then message,'Input structure must contain CDELT1/CDELT2 values!'
if not (tag_exist(data,'NAXIS1')) then message,'Input structure must contain NAXIS1/NAXIS2 values!'
if not (tag_exist(data,'CENTER_X')) then message,'Input structure must contain CENTER_X/CENTER_Y values!'

obs_id=data.date_obs+'-'+data.observat+'-'+data.instrume+'-'+data.telescop
id_list=obs_id[uniq(obs_id,sort(obs_id))]
nobs=n_elements(id_list)
if not (QUIET) then print,strtrim(nobs,2)+' observation(s) to show.'

if (ONE) then begin
   nplt_x=nobs<5
   nplt_y=(nobs/nplt_x) + fix((nobs mod nplt_x) gt 0)
   pmulti0=!p.multi
   !p.multi=[0,nplt_x,nplt_y]
endif

for i=0,nobs-1 do begin
   where_id=where(id_list[i] eq obs_id,ni)
   if (where_id[0] eq -1) then message,'Something wrong with the current observation!'
   data_i = data[where_id]

   dx=data_i[0].cdelt1
   dy=data_i[0].cdelt2
   x0=data_i[0].center_x
   y0=data_i[0].center_y
   nx=data_i[0].naxis1
   ny=data_i[0].naxis2
   rsun=data_i[0].r_sun

   x=lindgen(nx) & xmid=x0
   y=lindgen(ny) & ymid=y0
   if not (PIXELS) then begin
      x=dx*(x - x0) & xmid=0
      y=dy*(y - y0) & ymid=0
      rsun=dx*rsun
      xtitle='Arcsec'
      ytitle='Arcsec'
   endif
   xmin=min(x,max=xmax,/NAN) 
   ymin=min(y,max=ymax,/NAN)
   
   if (data_i[0].obsinst_key eq 'WIND__WAVES') or $
      (data_i[0].obsinst_key eq 'STEREO_A__SWAVES') or $
      (data_i[0].obsinst_key eq 'STEREO_B__SWAVES') or $
      (data_i[0].obsinst_key eq 'NANC__DAN') then begin
      xtitle='Time (UT)' & ytitle='Frequency (MHz)'
   endif
      
   if (NO_QCLK) then begin
      image=bytarr(naxis1,naxis2)
   endif else begin
      qclk_url=data_i[0].qclk_url+'/'+data_i[0].qclk_fname
      image=read_image(qclk_url, $
                       target_directory=qclk_dir, $
                       REMOVE_FILE=REMOVE_FILE)
   endelse

   display2d,image,Xin=x,Yin=y, $
             xtitle=xtitle,ytitle=ytitle, $
             title=id_list[i], $
             xsize=xsize,ysize=ysize, $
             color=qclk_ctable, $
             FREE=FREE

   if (SIGHT) then begin
      oplot,[xmin,xmax],[ymid,ymid]
      oplot,[xmid,xmid],[ymin,ymax]
   endif
   
   if (SOLAR_RADIUS) then begin
      theta=findgen(361)/!radeg
      xr=rsun*cos(theta) + xmid
      yr=rsun*sin(theta) + ymid
      oplot,xr,yr
   endif

   if (feat_flag) then begin
      loadct,feat_ctable,/SILENT
      if (TCOLORS) and (track_flag) then $
         feat_col=(20b*byte(data_i.track_id) mod 200) + 54b $
      else $
         feat_col=bytarr(ni) + bytscl(randomu(seed),min=0.0,max=1.0,top=200) + 54b
      for j=0l,ni-1l do begin
         if not (CONTOURS) then begin
            feat_x_pix=data_i[j].feat_x_pix
            feat_y_pix=data_i[j].feat_y_pix
            if not (PIXELS) then begin
               feat_x_pix=dx*(feat_x_pix - x0)
               feat_y_pix=dy*(feat_y_pix - y0)
            endif
            oplot,[feat_x_pix,feat_x_pix],[feat_y_pix,feat_y_pix],/PSYM,color=feat_col[j]
         endif
         if not (CENTROID) then begin
            cc_x_pix=data_i[j].cc_x_pix
            cc_y_pix=data_i[j].cc_y_pix
            cc=data_i[j].cc
            feat_cc_pix=chain2image(cc,[cc_x_pix,cc_y_pix])
            if not (PIXELS) then begin
               feat_cc_pix[0,*]=dx*(feat_cc_pix[0,*] - x0)
               feat_cc_pix[1,*]=dy*(feat_cc_pix[1,*] - y0)
            endif
            oplot,feat_cc_pix[0,*],feat_cc_pix[1,*],color=feat_col[j]
         endif
      endfor
   endif
endfor

if (ONE) then !p.multi=pmulti0

END
