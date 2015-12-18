FUNCTION query,from, url, $
               starttime=starttime, $
               endtime=endtime, $
               where=where, sqlwhere=sqlwhere, $
               select=select, what=what, $
               maxrecords=maxrecords, $
               startindex=startindex, $
               join=join, order_by=order_by, $
               limit=limit, cmd=cmd, $
               STRUCTURE=STRUCTURE, $
               VERBOSE=VERBOSE

;+
; NAME:
;       query
;
; PURPOSE:
; 	This function permits to query 
;       a HELIO Query Interface (HQI).
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	votable=query(from)
;
; INPUTS:
;       from - Name of the database table to query. 
;	
; OPTIONAL INPUTS:
;	url       -  URL of the HQI service to query.
;                    Default is the HFC interface.
;	starttime -  String containing the start date and time
;                    of the data to be returned (ISO 8601 format).
;	endtime    - String containing the end date and time
;                    of the data to be returned (ISO 8601 format).
;       maxrecords - Maximal number of records to be returned.
;                    Default is 100000.
;       limit      - Equivant to maxrecords.
;       where      - String containing a PQL-like where clause.
;       sqlwhere   - String containing a SQL-like where clause.
;       select     - String containing a SQL-SELECT instruction.
;       what       - Equivalent to select.
;       join       - String containing a SQL-JOIN instruction.
;       order_by   - String containing a SQL-ORDER_BY instruction.
;       startindex - Obsolete.
;
; KEYWORD PARAMETERS:
;       /STRUCTURE     - Returns data in a IDL structure instead of a string.
;	/VERBOSE       - Talkative mode.
;
; OUTPUTS:
;	votable - String containing data returned by the HQI in
;                 a votable format.
;                 If /STRUCTURE keyword is set, a IDL structure is
;                 returned instead.
;
; OPTIONAL OUTPUTS:
;       cmd - String containing the command line called by this function.
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
;       wget
;	decode_votable
;
; EXAMPLE:
;       Search for all active regions detected on SDO images between 01 June
;       2012 at midnight (UTC) and 05 June 2012 at noon, and return data in a IDL structure:
;       
;         votable=query('VIEW_AR_HQI',where='OBSERVAT,SDO', $
;                       starttime='2012-06-01T00:00:00', $
;                       endtime='2012-06-05T12:00:00', $
;                       /STRUCTURE)
; 
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'Results=query(from,url, $'
   print,'              starttime=starttime, $'
   print,'              endtime=endtime, $'
   print,'              where=where,sqlwhere=sqlwhere, $'
   print,'              select=select,what=what, $'
   print,'              maxrecords=maxrecords, $'
   print,'              startindex=startindex, $'
   print,'              order_by=order_by,limit=limit, $'
   print,'              join=join, cmd=cmd, $'
   print,'              /STRUCTURE,/VERBOSE)'
   return,''
endif
STRUCTURE=keyword_set(STRUCTURE)
VERBOSE=keyword_set(VERBOSE)

if not (keyword_set(url)) then url='http://voparis-helio.obspm.fr/hfc-hqi'
url = url + '/HelioQueryService?'

url = url + 'FROM='+strtrim(from[0],2)
if (keyword_set(starttime)) then url = url + '&STARTTIME='+strtrim(starttime[0],2)
if (keyword_set(endtime)) then url = url + '&ENDTIME='+strtrim(endtime[0],2)
if (keyword_set(where)) then url = url + '&WHERE='+strtrim(where[0],2)
if (keyword_set(sqlwhere)) then url = url + '&SQLWHERE='+strtrim(sqlwhere[0],2)
if (keyword_set(what)) then url = url + '&WHAT='+strtrim(what[0],2)
if (keyword_set(select)) then url = url + '&SELECT='+strtrim(select[0],2)
if (keyword_set(maxrecords)) then url = url + '&MAXRECORDS='+strtrim(maxrecords[0],2)
if (keyword_set(startindex)) then url = url + '&STARTINDEX='+strtrim(startindex[0],2)
if (keyword_set(join)) then url = url + '&JOIN='+strtrim(join[0],2)
if (keyword_set(order_by)) then url = url + '&ORDER_BY='+strtrim(order_by[0],2)
if (keyword_set(limit)) then url = url + '&LIMIT='+strtrim(limit[0],2)

wget,url,response, $
     options='-qO-', $
     cmd=cmd

if (STRUCTURE) then votable=decode_votable(strjoin(response),/QUIET) else votable=response

return,votable
END
; =============================================================
; =============================================================
FUNCTION nearest_date,from,date_obs,url, $
                      sqlwhere=sqlwhere, $
                      cmd=cmd, $
                      VERBOSE=VERBOSE

;+
; NAME:
;       nearest_date
;
; PURPOSE:
; 	This function searches the entry
;       in a database table accessible through
;       the Helio Query Interface, and for which
;       the date and time are close as possible
;       of a given date of observation.
;       The nearest date found is then returned. 
;
; CATEGORY:
;	Web service
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	near_date=nearest_date(from,date_obs)
;
; INPUTS:
;       from     - Name of the database table to query. 
;       date_obs - String containing the date and time 
;                  (ISO 8601 format) for which the nearest
;                  date and time must be found in the table.
;	
; OPTIONAL INPUTS:
;	url       -  URL of the HQI service to query.
;                    Default is the HFC interface.
;       sqlwhere   - String containing a SQL-like where clause.
;
; KEYWORD PARAMETERS:
;	/VERBOSE       - Talkative mode.
;
; OUTPUTS:
;	near_date - String containing the nearest date and time
;                   found (ISO 8601 format).
;
; OPTIONAL OUTPUTS:
;       cmd - String containing the command line called by this function.
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
;	near_data=nearest_date('VIEW_AR_HQI','2011-01-01T00:00:00')		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

dbquote=string(34b)

if (n_params() lt 2) then begin
   message,/INFO,'Call is:'
   print,'Results=nearest_date(from,date_obs,url, $'
   print,'                     sqlwhere=sqlwhere, $'
   print,'                     cmd=cmd,/VERBOSE)'
   return,''
endif
VERBOSE=keyword_set(VERBOSE)

if not (keyword_set(url)) then url=''

date=strtrim(date_obs[0],2)
sql_date = strjoin(strsplit(date,'T',/EXTRACT),' ')

select='DATE_OBS'
limit=1
order='ABS(UNIX_TIMESTAMP(DATE_OBS)-UNIX_TIMESTAMP('+dbquote+sql_date+dbquote+'))'

response=query(from,url, $
               select=select,limit=limit,order_by=order, $
               sqlwhere=sqlwhere,cmd=cmd, $
               VERBOSE=VERBOSE,/STRUCTURE)
if (size(response,/TNAME) ne 'STRUCT') then return,''
near_date=response.date_obs

return,near_date
END
; =============================================================
; =============================================================
FUNCTION sql_query, query, $
                    _EXTRA=EXTRA, $
                    cmd=cmd, header=header, $
                    nrows=nrows, $
                    VERBOSE=VERBOSE


;+
; NAME:
;       sql_query
;
; PURPOSE:
; 	This function allows to
;       query the HFC database
;       using a MySQL client. 
;
; CATEGORY:
;	MySQL
;
; GROUP:
;	hfc_client
;
; CALLING SEQUENCE:
;	tabledata=sql_query(query)
;
; INPUTS:
;       query - String containg the MySQL query.
;	
; OPTIONAL INPUTS:
;	database - Scalar string containing the name of the database to query.	
;	hostname - Scalar string containing the host name of the database.
;	username - Scalar string containing the user name.
;	password - Scalar string containing the corresponding password.
;
; KEYWORD PARAMETERS:
;       /STRUCTURE - Return a IDL structure array instead of a
;                    vector of string type.
;	/XML       - Return response string using the xml format.
;	/VERBOSE   - Talkative mode.
;
; OUTPUTS:
;	tabledata - String or structure containing the query response.
;
; OPTIONAL OUTPUTS:
;       cmd    - String containing the command line called by this
;                function.
;       nrows  - Number of row(s) returned.
;       header - Response's header.
;		
; COMMON BLOCKS:		
;	None.
;	
; SIDE EFFECTS:
;	None.
;		
; RESTRICTIONS/COMMENTS:
;	mysql client software must be installed 
;       on the OS.
;			
; CALL:
;       mysql_query
;
; EXAMPLE:
;	tabledata=sql_query('select * from VIEW_AR_HQI WHERE DATE_OBS>="2001-01-01 00:00:00" LIMIT 10', $
;                           database='hfc1test',hostname='helio-fc1.obspm.fr', $
;                           user='guest',pass='guest',/STRUCT,/VERB)		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

if (n_params() lt 1) then begin
   message,/CONT,'Call is:'
   print,'Results=sql_query(query, $'
   print,'                  database=database, username=username, $'
   print,'                  hostname=hostname, password=password, $'
   print,'                  header=header,nrows=nrows,cmd=cmd, $' 
   print,'                  /STRUCTURE, /VERBOSE $'
   return,''
endif
VERBOSE=keyword_set(VERBOSE)

if (VERBOSE) then print,'Querying HFC database, please wait...'
tabledata=mysql_client(query,_EXTRA=EXTRA,nrows=nrows,header=header,cmd=cmd,/SILENT)
if (VERBOSE) then print,strtrim(n_elements(tabledata),2)+' row(s) returned.'

return,tabledata
END
