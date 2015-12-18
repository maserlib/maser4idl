FUNCTION get_feature,feature_name, $
                     starttime=starttime, $
                     endtime=endtime, $
                     near_date=near_date, $
                     code=code, $
                     instrument=instrument, $
                     observatory=observatory, $
                     telescope=telescope, $
                     maxrecords=maxrecords, $
                     cmd=cmd,ndata=ndata, $
                     QUIET=QUIET,DEBUG=DEBUG, $
                     HELP=HELP


;+
; NAME:
;       get_feature
;
; PURPOSE:
; 	This function permits to retrieve
;       feature data from the HFC. 
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	data=get_feature(feature_name)
;
; INPUTS:
;       feature_name - Name of the feature for which data
;                      must be returned.
;	
; OPTIONAL INPUTS:
;	starttime   - String containing the start date and time
;                     of the data to be returned (ISO 8601 format).
;	endtime     - String containing the end date and time
;                     of the data to be returned (ISO 8601 format).
;       near_date   - String containing the date and time
;                     of the data to be returned (ISO 8601 format).
;                     If no data exists for near_date, then
;                     the nearest date and time entries will be returned.
;       maxrecords  - Maximal number of records to be returned.
;                     Default is 100000.
;       code        - Name of the feature recognition code for
;                     which data must be returned.
;       instrument  - Name of the instrument for
;                     which data must be returned.
;       observatory - Name of the observatory for
;                     which data must be returned.       
;       telescope   - Name of the telescope/receiver for
;                     which data must be returned.
;
; KEYWORD PARAMETERS:
;	/QUIET      - Quiet mode.
;       /DEBUG      - Debug mode.
;       /HELP       - Display help message, then quit the program.
;
; OUTPUTS:
;	data - IDL structure containing the feature data found in the HFC.
;
; OPTIONAL OUTPUTS:
;       ndata - Number of data samples returned.
;       cmd   - String containing the command line called by this function.
;		
; COMMON BLOCKS:		
;	None.
;	
; SIDE EFFECTS:
;	None.
;		
; RESTRICTIONS/COMMENTS:
;	wget or curl software must be installed 
;       on the OS.
;			
; CALL:
;       nearest_date
;       query
;
; EXAMPLE:
;       Get sunspots data from SDO/HMI near 01 January 2011 at
;       midnight (UTC): 
; 
;	hfc_ss_data = get_feature('sunspots',near_date='2011-01-01T00:00:00', $
;                                 observatory='SDO',instrument='HMI')		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

ndata=0l
dbquote=string(34b)

if (n_params() lt 1) or (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_feature(feature_name, $'
   print,'                    starttime=starttime,$'
   print,'                    endtime=endtime, $'
   print,'                    near_date=near_date, $'
   print,'                    code=code,instrument=instrument, $'
   print,'                    observatory=observatory, $'
   print,'                    telescope=telescope, $'
   print,'                    maxrecords=maxrecords, $'
   print,'                    cmd=cmd,ndata=ndata, $'
   print,'                    /QUIET,/DEBUG,/HELP)'
   return,''
endif
DEBUG=keyword_set(DEBUG)
QUIET=keyword_set(QUIET) xor DEBUG

feature=strlowcase(strtrim(feature_name[0],2))
case feature of
   'activeregion':from='VIEW_AR_HQI'
   'activeregions':from='VIEW_AR_HQI'
   'ar':from='VIEW_AR_HQI'
   'sunspot':from='VIEW_SP_HQI'
   'sunspots':from='VIEW_SP_HQI'
   'sp':from='VIEW_SP_HQI'
   'ss':from='VIEW_SP_HQI'
   'coronalhole':from='VIEW_CH_HQI'
   'coronalholes':from='VIEW_CH_HQI'
   'ch':from='VIEW_CH_HQI'
   'filament':from='VIEW_FIL_HQI'
   'filaments':from='VIEW_FIL_HQI'
   'fi':from='VIEW_FIL_HQI'
   'prominence':from='VIEW_PRO_HQI'
   'prominences':from='VIEW_PRO_HQI'
   'pro':from='VIEW_PRO_HQI'
   'radiosource':from='VIEW_RS_HQI'
   'radiosources':from='VIEW_RS_HQI'
   'nrh_regions':from='VIEW_RS_HQI'
   'rs':from='VIEW_RS_HQI'
   'type3':from='VIEW_T3_HQI'
   't3':from='VIEW_T3_HQI'
   'type3_bursts':from='VIEW_T3_HQI'
   else:begin
      message,/INFO,'Unknown feature name!'
      return,''
   end
endcase

sqlwhere=''
if (keyword_set(code)) then sqlwhere=[sqlwhere,'CODE='+dbquote+strtrim(code[0],2)+dbquote]
if (keyword_set(instrument)) then sqlwhere=[sqlwhere,'INSTRUME='+dbquote+strtrim(instrument[0],2)+dbquote]
if (keyword_set(observatory)) then sqlwhere=[sqlwhere,'OBSERVAT='+dbquote+strtrim(observatory[0],2)+dbquote]
if (keyword_set(telescope)) then sqlwhere=[sqlwhere,'TELESCOP='+dbquote+strtrim(telescope[0],2)+dbquote]
if not (keyword_set(maxrecords)) then maxrecords=0

if (keyword_set(near_date)) then begin
   if (keyword_set(sqlwhere)) then sqlwhere1=strjoin(sqlwhere[1:*],' and ') else sqlwhere1=''
   ; Get nearest date in table
   if not (QUIET) then print,'Searching '+feature+' data near '+near_date+', please wait...'
   date_obs = nearest_date(from,near_date,sqlwhere=sqlwhere1,cmd=cmd)
   if (date_obs eq '') then begin
      message,/CONT,'Query has failed!'
      if (DEBUG) then print,'Command line was: '+cmd
      return,''
   endif
   sqlwhere=[sqlwhere,'DATE_OBS='+dbquote+date_obs+dbquote]
endif else begin
   if (keyword_set(starttime)) then begin 
      sqlwhere=[sqlwhere,'DATE_OBS>='+dbquote+starttime+dbquote]
      if not (QUIET) then print,'Searching '+feature+' data after '+starttime
   endif
   if (keyword_set(endtime)) then begin
      sqlwhere=[sqlwhere,'DATE_OBS<='+dbquote+endtime+dbquote]
      if not (QUIET) then print,'Searching '+feature+' data before '+endtime
   endif
endelse
if (keyword_set(sqlwhere)) then sqlwhere=strjoin(sqlwhere[1:*],' and ')

data=query(from, $
           sqlwhere=sqlwhere,$
           maxrecords=maxrecords, $
           cmd=cmd, $
           /STRUCTURE)
if (size(data,/TNAME) ne 'STRUCT') then begin
   message,/CONT,'Query has failed!'
   if (DEBUG) then print,'Command line was: '+cmd
   return,''
endif else begin
   ndata=n_elements(data)
   if not (QUIET) then print,strtrim(ndata,2)+' row(s) returned'
endelse          

return,data
END
; =============================================================
; =============================================================
FUNCTION get_observation,instrument=instrument, $
                         observatory=observatory, $
                         telescope=telescope, $
                         starttime=starttime, $
                         endtime=endtime, $
                         near_date=near_date, $
                         maxrecords=maxrecords, $
                         cmd=cmd,ndata=ndata, $
                         QUIET=QUIET, DEBUG=DEBUG, $
                         HELP=HELP

;+
; NAME:
;       get_observation
;
; PURPOSE:
; 	This function permits to retrieve
;       observation data from the HFC. 
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	data=get_observation()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;       instrument  - Name of the instrument for
;                     which data must be returned.
;       observatory - Name of the observatory for
;                     which data must be returned.
;       telescope   - Name of the telescope/receiver for
;                     which data must be returned.
;	starttime   - String containing the start date and time
;                     of the data to be returned (ISO 8601 format).
;	endtime     - String containing the end date and time
;                     of the data to be returned (ISO 8601 format).
;       near_date   - String containing the date and time
;                     of the data to be returned (ISO 8601 format).
;                     If no data exists for near_date, then
;                     the nearest date and time entries will be returned.
;       maxrecords  - Maximal number of records to be returned.
;                     Default is 100000.       
;
; KEYWORD PARAMETERS:
;	/QUIET      - Quiet mode.
;       /DEBUG      - Debug mode.
;       /HELP       - Display help message, then quit the program.
;
; OUTPUTS:
;	data - IDL structure containing the observation data found in the HFC.
;
; OPTIONAL OUTPUTS:
;       ndata - Number of data samples returned.
;       cmd   - String containing the command line called by this function.
;		
; COMMON BLOCKS:		
;	None.
;	
; SIDE EFFECTS:
;	None.
;		
; RESTRICTIONS/COMMENTS:
;	wget or curl software must be installed 
;       on the OS.
;			
; CALL:
;       nearest_date
;       query
;
; EXAMPLE:
;       Get observation data from SoHO/EIT between 05 April 2008 at
;       22:55:00 (UTC) and 10 April 2008 at 12:00:00 (UTC): 
; 
;	hfc_eit_data = get_observation(observatory='SoHO',instrument='EIT', $
;                                      starttime='2001-04-05T22:55:00', $
;                                      endtime='2001-04-10T12:00:00')		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

from='VIEW_OBS_HQI'
ndata=0l
dbquote=string(34b)

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_observation(instrument=instrument, $'
   print,'                        observatory=observatory, $'
   print,'                        telescope=telescope, $'
   print,'                        starttime=starttime,$'
   print,'                        endtime=endtime, $'
   print,'                        near_date=near_date, $'
   print,'                        maxrecords=maxrecords, $'
   print,'                        cmd=cmd,ndata=ndata, $'
   print,'                        /QUIET,/DEBUG,/HELP)'
   return,''
endif
DEBUG=keyword_set(DEBUG)
QUIET=keyword_set(QUIET) xor DEBUG

sqlwhere=''
if (keyword_set(instrument)) then sqlwhere=[sqlwhere,'INSTRUME='+dbquote+strtrim(instrument[0],2)+dbquote]
if (keyword_set(observatory)) then sqlwhere=[sqlwhere,'OBSERVAT='+dbquote+strtrim(observatory[0],2)+dbquote]
if not (keyword_set(maxrecords)) then maxrecords=0

if (keyword_set(near_date)) then begin
   if (keyword_set(sqlwhere)) then sqlwhere1=strjoin(sqlwhere[1:*],' and ') else sql1where=''
   ; Get nearest date in table
   if not (QUIET) then print,'Searching observation data near '+near_date+', please wait...'
   date_obs = nearest_date(from,near_date,sqlwhere=sqlwhere1,cmd=cmd)
   if (date_obs eq '') then begin
      message,/CONT,'Query has failed!'
      if (DEBUG) then print,'Command line was: '+cmd
      return,''
   endif
   sqlwhere=[sqlwhere,'DATE_OBS='+dbquote+date_obs+dbquote]
endif else begin
   if (keyword_set(starttime)) then begin 
      sqlwhere=[sqlwhere,'DATE_OBS>='+dbquote+starttime+dbquote]
      if not (QUIET) then print,'Searching observation data after '+starttime
   endif
   if (keyword_set(endtime)) then begin
      sqlwhere=[sqlwhere,'DATE_OBS<='+dbquote+endtime+dbquote]
      if not (QUIET) then print,'Searching observation data before '+endtime
   endif
endelse
if (keyword_set(sqlwhere)) then sqlwhere=strjoin(sqlwhere[1:*],' and ')

data=query(from, $     
           sqlwhere=sqlwhere,$
           maxrecords=maxrecords, $
           cmd=cmd, $
           /STRUCTURE)
if (size(data,/TNAME) ne 'STRUCT') then begin
   message,/CONT,'Query has failed!'
   if (DEBUG) then print,'Command line was: '+cmd
   return,''
endif else begin
   ndata=n_elements(data)
   if not (QUIET) then print,strtrim(ndata,2)+' row(s) returned'
endelse 

return,data
END
; =============================================================
; =============================================================
FUNCTION get_code,code=code, $
                  feature_name=feature_name, $
                  maxrecords=maxrecords, $
                  cmd=cmd, ndata=ndata, $
                  QUIET=QUIET, DEBUG=DEBUG, $
                  HELP=HELP

;+
; NAME:
;       get_code
;
; PURPOSE:
; 	This function permits to retrieve
;       information about HFC feature 
;       recognition codes. 
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	data=get_code()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;       code         - Name of the code.
;                      By default all of the HFC codes information 
;                      are returned.
;       feature_name - Filter codes providing the name of the feature
;                      detected.
;       maxrecords   - Maximal number of records to be returned.
;                      Default is 100000.       
;
; KEYWORD PARAMETERS:
;	/QUIET      - Quiet mode.
;       /DEBUG      - Debug mode.
;       /HELP       - Display help message, then quit the program.
;
; OUTPUTS:
;	data - IDL structure containing the code data found in the HFC.
;
; OPTIONAL OUTPUTS:
;       ndata - Number of data samples returned.
;       cmd   - String containing the command line called by this function.
;		
; COMMON BLOCKS:		
;	None.
;	
; SIDE EFFECTS:
;	None.
;		
; RESTRICTIONS/COMMENTS:
;	wget or curl software must be installed 
;       on the OS.
;			
; CALL:
;       query
;
; EXAMPLE:
;       To get all of the HFC feature recognition code content:
;       data = get_code()	
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

from='FRC_INFO'
dbquote=string(34b)

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_code(code=code, $'
   print,'                 feature_name=feature_name, $'
   print,'                 maxrecords=maxrecords, $'
   print,'                 cmd=cmd,ndata=ndata, $'
   print,'                 /QUIET,/DEBUG,/HELP)'
   return,''
endif
DEBUG=keyword_set(DEBUG)
QUIET=keyword_set(QUIET) xor DEBUG

sqlwhere=''
if (keyword_set(code)) then sqlwhere=[sqlwhere,'CODE='+dbquote+strtrim(code[0],2)+dbquote]
if (keyword_set(feature_name)) then sqlwhere=[sqlwhere,'FEATURE_NAME='+dbquote+strtrim(feature_name[0],2)+dbquote]
if (keyword_set(sqlwhere)) then sqlwhere=strjoin(sqlwhere[1:*],' and ')
if not (keyword_set(maxrecords)) then maxrecords=0

data=query(from, $     
           sqlwhere=sqlwhere,$
           maxrecords=maxrecords, $
           cmd=cmd, $
           /STRUCTURE)
if (size(data,/TNAME) ne 'STRUCT') then begin
   message,/CONT,'Query has failed!'
   if (DEBUG) then print,'Command line was: '+cmd
   return,''
endif else begin
   ndata=n_elements(data)
   if not (QUIET) then print,strtrim(ndata,2)+' row(s) returned'
endelse 

return,data
END
; =============================================================
; =============================================================
FUNCTION get_observatory,instrument=instrument, $
                         observatory=observatory, $
                         telescope=telescope, $
                         obs_type=obs_type, $
                         spectral_name=spectral_name, $
                         wavemin=wavemin,wavemax=wavemax, $
                         maxrecords=maxrecords, $
                         cmd=cmd, ndata=ndata, $
                         QUIET=QUIET, DEBUG=DEBUG, $
                         HELP=HELP

;+
; NAME:
;       get_observatory
;
; PURPOSE:
; 	This function permits to retrieve
;       information about HFC observatories. 
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	data=get_observatory()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;       instrument      - Name of the instrument.
;       observatory     - Name of the observatory.
;       telescope       - Name of the telescope/receiver.
;       obs_type        - Type of observation, can be 'Remote-sensing' or
;                         'In-situ'.
;       spectral_name   - Filter selection specifying the spectral
;                         domain (e.g., 'Radio' or 'Visible').
;       wavemin         - Minimal wavelength/frequency value.
;       wavemax         - Maximal wavelength/frequency value.
;       maxrecords      - Maximal number of records to be returned.
;                         Default is 100000.       
;
; KEYWORD PARAMETERS:
;	/QUIET      - Quiet mode.
;       /DEBUG      - Debug mode.
;       /HELP       - Display help message, then quit the program.
;
; OUTPUTS:
;	data - IDL structure containing the code data found in the HFC.
;
; OPTIONAL OUTPUTS:
;       ndata - Number of data samples returned.
;       cmd   - String containing the command line called by this function.
;		
; COMMON BLOCKS:		
;	None.
;	
; SIDE EFFECTS:
;	None.
;		
; RESTRICTIONS/COMMENTS:
;	wget or curl software must be installed 
;       on the OS.
;			
; CALL:
;       query
;
; EXAMPLE:
;       To get all of the HFC observatory content:
;       data = get_observatory()		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

from='OBSERVATORY'
dbquote=string(34b)

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_observatory(instrument=instrument, $'
   print,'                        observatory=observatory, $'
   print,'                        telescope=telescope, $'
   print,'                        obs_type=obs_type, $'
   print,'                        spectral_name=spectral_name, $'
   print,'                        wavemin=wavemin, $'
   print,'                        wavemax=wavemax, $'
   print,'                        maxrecords=maxrecords, $'
   print,'                        cmd=cmd,ndata=ndata, $'
   print,'                        /QUIET,/DEBUG,/HELP)'
   return,''
endif
DEBUG=keyword_set(DEBUG)
QUIET=keyword_set(QUIET) xor DEBUG

sqlwhere=''
if (keyword_set(instrument)) then sqlwhere=[sqlwhere,'INSTRUME='+dbquote+strtrim(instrument[0],2)+dbquote]
if (keyword_set(observatory)) then sqlwhere=[sqlwhere,'OBSERVAT='+dbquote+strtrim(observatory[0],2)+dbquote]
if (keyword_set(telescope)) then sqlwhere=[sqlwhere,'TELESCOP='+dbquote+strtrim(telescope[0],2)+dbquote]
if (keyword_set(obs_type)) then sqlwhere=[sqlwhere,'OBS_TYPE='+dbquote+strtrim(obs_type[0],2)+dbquote]
if (keyword_set(spectral_name)) then sqlwhere=[sqlwhere,'SPECTRAL_NAME='+dbquote+strtrim(spectral_name[0],2)+dbquote]
if (keyword_set(wavemin)) then sqlwhere=[sqlwhere,'WAVEMIN>='+strtrim(wavemin[0],2)]
if (keyword_set(wavemax)) then sqlwhere=[sqlwhere,'WAVEMAX<='+strtrim(wavemax[0],2)]
if (keyword_set(sqlwhere)) then sqlwhere=strjoin(sqlwhere[1:*],' and ')
if not (keyword_set(maxrecords)) then maxrecords=0

data=query(from, $     
           sqlwhere=sqlwhere,$
           maxrecords=maxrecords, $
           cmd=cmd, $
           /STRUCTURE)
if (size(data,/TNAME) ne 'STRUCT') then begin
   message,/CONT,'Query has failed!'
   if (DEBUG) then print,'Command line was: '+cmd
   return,''
endif else begin
   ndata=n_elements(data)
   if not (QUIET) then print,strtrim(ndata,2)+' row(s) returned'
endelse 

return,data
END
; =============================================================
; =============================================================
FUNCTION get_tables, QUIET=QUIET, $
                     HELP=HELP

;+
; NAME:
;       get_tables
;
; PURPOSE:
; 	This function returns the name of
;       the HFC tables available. 
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	data=get_tables()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;       None.      
;
; KEYWORD PARAMETERS:
;	/QUIET      - Quiet mode.
;       /HELP       - Display help message, then quit the program.
;
; OUTPUTS:
;	tables - IDL structure containing the HFC tables names
;                for each type of content.
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
;       None.
;
; EXAMPLE:
;       None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_tables(/QUIET,/HELP)'
   return,''
endif

tables={CODE:'FRC_INFO', $
        OBSERVATORY:'OBSERVATORY', $
        OBSERVATIONS:'VIEW_OBS_HQI', $
        ACTIVEREGIONS:'VIEW_AR_HQI', $
        SUNSPOTS:'VIEW_SP_HQI', $
        CORONALHOLES:'VIEW_CH_HQI', $
        FILAMENTS:'VIEW_FIL_HQI', $
        PROMINENCES:'VIEW_PRO_HQI', $
        NRH_REGIONS:'VIEW_RS_HQI', $
        TYPE3_BURSTS:'VIEW_T3_HQI'}

if not (keyword_set(QUIET)) then print,tables

return,tables
END
; =============================================================
; =============================================================
FUNCTION get_content, QUIET=QUIET, $
                      HELP=HELP

;+
; NAME:
;       get_content
;
; PURPOSE:
; 	This function returns the type of 
;       content available in the HFC. 
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	data=get_content()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;       None.      
;
; KEYWORD PARAMETERS:
;	/QUIET      - Quiet mode.
;       /HELP       - Display help message, then quit the program.
;
; OUTPUTS:
;	tables - Array of strings containing
;                the HFC content.
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
;       None.
;
; EXAMPLE:
;       None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_content(/QUIET,/HELP)'
   return,''
endif

content=tag_names(get_tables(/QUIET))

if not (keyword_set(QUIET)) then print,content

return,content
END
; =============================================================
; =============================================================
FUNCTION get_datafile,_EXTRA=EXTRA, $
                      target_directory=target_directory, $
                      cmd=cmd,ndata=ndata, $
                      DOWNLOAD_FILE=DOWNLOAD_FILE


;+
; NAME:
;       get_datafile
;
; PURPOSE:
; 	This function returns
;       the URL of original 
;       data files 
;       used by the HFC codes 
;       to detect the features
;       (when available).
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	qclk_url=get_datafile()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;	starttime        - String containing the start date and time
;                          of the quicklooks to be returned (ISO 8601 format).
;	endtime          - String containing the end date and time
;                          of the quicklooks to be returned (ISO 8601 format).
;       near_date        - String containing the date and time
;                          of the quicklooks to be returned (ISO 8601 format).
;                          If no quicklooks found for near_date, then
;                          the nearest date and time entries will be returned.
;       maxrecords       - Maximal number of records to be returned.
;                          Default is 100000.
;       code             - Name of the feature recognition code for
;                          which quicklooks must be returned.
;       instrument       - Name of the instrument for
;                          which quicklooks must be returned.
;       observatory      - Name of the observatory for
;                          which quicklooks must be returned.  
;       telescope        - Name of the telescope for 
;                          which quicklooks must be returned.
;       target_directory - Directory where data files must be
;                          downloaded if /DOWNLOAD_FILE keyword
;                          is set. Default is the current directory.
;
; KEYWORD PARAMETERS:
;       /DOWNLOAD_FILE - Download data files.
;	/QUIET         - Quiet mode.
;       /DEBUG         - Debug mode.
;       /HELP          - Display help message, then quit the program.
;
; OUTPUTS:
;	file_url - Array of strings containing the datafile URLs.
;
; OPTIONAL OUTPUTS:
;       ndata - Number of data samples returned.
;       cmd   - String containing the command line called by this function.
;		
; COMMON BLOCKS:		
;	None.
;	
; SIDE EFFECTS:
;	None.
;		
; RESTRICTIONS/COMMENTS:
;	wget or curl software must be installed 
;       on the OS.
;			
; CALL:
;       get_observation
;       download
;
; EXAMPLE:
;       None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

ndata=0l
dbquote=string(34b)

CD,current=current_directory
if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_datafile(instrument=instrument, $'
   print,'                     observatory=observatory, $'
   print,'                     telescope=telescope, $'
   print,'                     starttime=starttime,$'
   print,'                     endtime=endtime, $'
   print,'                     near_date=near_date, $'
   print,'                     maxrecords=maxrecords, $'
   print,'                     target_directory=target_directory, $'
   print,'                     cmd=cmd,ndata=ndata, $'
   print,'                     /DOWNLOAD_FILE, $'
   print,'                     /QUIET,/DEBUG,/HELP)'
   return,''
endif
DEBUG=keyword_set(DEBUG)
QUIET=keyword_set(QUIET) xor DEBUG
DOWNLOAD_FILE=keyword_set(DOWNLOAD_FILE)

if not (keyword_set(target_directory)) then target_directory=current_directory

data = get_observation(_EXTRA=EXTRA,cmd=cmd,ndata=ndata)
if (size(data,/TNAME) ne 'STRUCT') then return,''

file_url = data.url

if (DOWNLOAD_FILE) then begin
   download,file_url, $
            target_dir=target_directory, $
            QUIET=QUIET
endif

return,file_url
END
; =============================================================
; =============================================================
FUNCTION get_quicklook,_EXTRA=EXTRA, $
                       target_directory=target_directory, $
                       cmd=cmd,ndata=ndata, $
                       DOWNLOAD_FILE=DOWNLOAD_FILE


;+
; NAME:
;       get_quicklook
;
; PURPOSE:
; 	This function returns
;       the URL of quicklook
;       images stored in the ftp server
;       of the HFC.
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	qclk_url=get_quicklook()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;	starttime        - String containing the start date and time
;                          of the quicklooks to be returned (ISO 8601 format).
;	endtime          - String containing the end date and time
;                          of the quicklooks to be returned (ISO 8601 format).
;       near_date        - String containing the date and time
;                          of the quicklooks to be returned (ISO 8601 format).
;                          If no quicklooks found for near_date, then
;                          the nearest date and time entries will be returned.
;       maxrecords       - Maximal number of records to be returned.
;                          Default is 100000.
;       code             - Name of the feature recognition code for
;                          which quicklooks must be returned.
;       instrument       - Name of the instrument for
;                          which quicklooks must be returned.
;       observatory      - Name of the observatory for
;                          which quicklooks must be returned.  
;       telescope        - Name of the telescope for 
;                          which quicklooks must be returned.
;       target_directory - Directory where quicklook files must be
;                          downloaded if /DOWNLOAD_FILE keyword
;                          is set. Default is the current directory.
;
; KEYWORD PARAMETERS:
;       /DOWNLOAD_FILE - Download quicklook files.
;	/QUIET         - Quiet mode.
;       /DEBUG         - Debug mode.
;       /HELP          - Display help message, then quit the program.
;
; OUTPUTS:
;	qclk_url - Array of strings containing the quicklook URLs.
;
; OPTIONAL OUTPUTS:
;       ndata - Number of data samples returned.
;       cmd   - String containing the command line called by this function.
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
;       download
;
; EXAMPLE:
;       Download SDO/HMI quicklook images on 01 April 2012 at noon
;       into the ../tmp folder:
; 
;         qclk_url=get_quicklook(instrument='HMI',near_date='2012-04-01T12:00:00', $'
;                                target_directory='../tmp',/DOWNLOAD_FILE)		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

ndata=0l
dbquote=string(34b)
CD,current=current_directory

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_quicklook(instrument=instrument, $'
   print,'                      observatory=observatory, $'
   print,'                      telescope=telescope, $'
   print,'                      starttime=starttime,$'
   print,'                      endtime=endtime, $'
   print,'                      near_date=near_date, $'
   print,'                      maxrecords=maxrecords, $'
   print,'                      target_directory=target_directory, $'
   print,'                      cmd=cmd,ndata=ndata, $'
   print,'                      /DOWNLOAD_FILE, $'
   print,'                      /QUIET,/DEBUG,/HELP)'
   return,''
endif
DEBUG=keyword_set(DEBUG)
QUIET=keyword_set(QUIET) xor DEBUG
DOWNLOAD_FILE=keyword_set(DOWNLOAD_FILE)

if not (keyword_set(target_directory)) then target_directory=current_directory

data = get_observation(_EXTRA=EXTRA,cmd=cmd,ndata=ndata)
if (size(data,/TNAME) ne 'STRUCT') then return,''

qclk_url = data.qclk_url+'/'+data.qclk_fname

if (DOWNLOAD_FILE) then begin
   download,qclk_url, $
            target_dir=target_directory, $
            QUIET=QUIET
endif

return,qclk_url
END
; =============================================================
; =============================================================
FUNCTION get_gui,browser=browser, $
                 OPEN=OPEN, $
                 MIRROR_SITE=MIRROR_SITE, $
                 HELIO=HELIO,HFE=HFE,HEC=HEC, $
                 ICS=ICS,ILS=ILS,DES=DES, $
                 CXS=CXS,DPAS=DPAS,SHEBA=SHEBA, $
                 UOC=UOC,HELP=HELP

;+
; NAME:
;       get_gui
;
; PURPOSE:
; 	This function returns
;       the URL of the HFC web page.
;
; CATEGORY:
;	Web
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	gui_url=get_gui()
;
; INPUTS:
;       None.
;	
; OPTIONAL INPUTS:
;      browser - Specify the name of the web browser to use
;                if /OPEN keyword is set.
;                Default is Firefox.
;
; KEYWORD PARAMETERS:
;       /MIRROR_SITE - If set, return the url of the HFC mirror site.
;       /OPEN        - Open the HFC web site in a web browser page.
;       /HELIO       - If set, return url (or/and open) the HELIO project web
;                      page.
;       /HFE         - If set, return url (or/and open) the HELIO
;                      Front End web page.
;       /HEC         - If set, return url (or/and open) the HELIO
;                      Event Catalogue web page.
;       /ICS         - If set, return url (or/and open) the HELIO
;                      Capabilities Service web page.  
;       /ILS         - If set, return url (or/and open) the HELIO
;                      Location Service web page.
;       /DES         - If set, return url (or/and open) the Data
;                      Evaluation Service web page.
;       /DPAS        - If set, return url (or/and open) the Data
;                      Provider Access Service web page.
;       /CXS         - If set, return url (or/and open) the 
;                      ConteXt Service web page.
;       /UOC         - If set, return url (or/and open) the 
;                      Unified Observing Catalogue web page.
;       /SHEBA       - If set, return url (or/and open) the
;                      propagation service web page.
;       /HELP        - Display help message.
;
; OUTPUTS:
;	gui_url - URL of the HFC web page.
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
;	Require a web browser to be installed
;       if /OPEN keyword is called.
;       Default browser is firefox.
;			
; CALL:
;       None.
;
; EXAMPLE:
;       None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

os=!VERSION.OS

if (keyword_set(HELP)) then begin
   message,/INFO,'Call is:'
   print,'Results=get_quicklook(browser=browser, $'
   print,'                      /MIRROR_SITE, $'
   print,'                      /HELIO,/HFE,/HEC, $'
   print,'                      /ICS,/ILS,/UOC, /DES, $'
   print,'                      /DPAS,/CXS,/SHEBA, $'
   print,'                      /OPEN,/HELP)'
   return,''
endif

case 1 of
   keyword_set(HELIO):gui_url='http://www.helio-vo.eu/'
   keyword_set(HFE):gui_url='http://hfe.helio-vo.eu/Helio/'
   keyword_set(HEC):gui_url='http://hec.helio-vo.eu/hec/hec_gui.php'
   keyword_set(ICS):gui_url='http://www.helio-vo.eu/services/interfaces/helio-ics_uix.php'
   keyword_set(ILS):gui_url='http://www.helio-vo.eu/services/interfaces/helio-ils_uix.php'
   keyword_set(UOC):gui_url='http://www.helio-vo.eu/services/interfaces/helio-uoc_uix.php'
   keyword_set(CXS):gui_url='http://www.helio-vo.eu/services/interfaces/helio-cxs_uix.php'
   keyword_set(DES):gui_url='http://manunja.cesr.fr/Amda-Helio/WebServices/TEST_N/testDes.html'
   keyword_set(DPAS):gui_url='http://www.helio-vo.eu/services/interfaces/helio-dpas_uix.php'
   keyword_set(SHEBA):gui_url='http://cagnode58.cs.tcd.ie:8080/PropagationModelGUI/'
   else:begin
      if (keyword_set(MIRROR_SITE)) then $
         gui_url='http://bass2000.obspm.fr/hfc-gui/' $
      else $
         gui_url='http://voparis-helio.obspm.fr/hfc-gui/' 
   end
endcase

if not (keyword_set(browser)) then browser='firefox'

if (keyword_set(OPEN)) then begin
   if (os eq 'darwin') then spawn,'open -a '+browser+' '+gui_url,resp $
   else spawn,browser+' '+gui_url,resp
endif 

return,gui_url
END
