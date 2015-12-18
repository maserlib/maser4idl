FUNCTION mysql_client,sql_query, $
                      database=database, $
                      hostname=hostname, $
                      username=username, $
                      password=password, $
                      header=header,nrows=nrows,$
                      status=status,cmd=cmd,$
                      STRUCTURE=STRUCTURE, $
                      XML=XML,SILENT=SILENT

;+
; NAME:
;		mysql_client
;
; PURPOSE:
; 		IDL client to query a MySQL database.
;
; CATEGORY:
;		I/O 
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		IDL> Response = mysql_client(sql_query)
;
; INPUTS:
;		sql_query - Scalar string containing the MySQL query.
;
; OPTIONAL INPUTS:
;		database - Scalar string containing the name of the database to query.	
;		hostname - Scalar string containing the host name of the database.
;		username - Scalar string containing the user name.
;		password - Scalar string containing the corresponding password. 	
;
; KEYWORD PARAMETERS:
;               /STRUCTURE - Return a IDL structure array instead of a
;                            vector of string type.
;		/XML       - Return response string using the xml format.
;		/SILENT    - Quiet mode. 
;
; OUTPUTS:
;		Response - Returns the query response in a vector of
;                          string type (or a structure if /STRUCTURE 
;                          keyword is set).		
;
; OPTIONAL OUTPUTS:
;               cmd    - String containing the command line executed.
;		nrows  - Long integer containing the number of rows returned.
;		header - Scalar of string type containing the first row returned.
;		status - Equal to 1 if the sql request is run without error, 0 else.
;
; COMMON BLOCKS:
;		None.
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS:
;		A MySQL client must be installed in the current machine.		
;		(This routine calls mysql command using spawn idl function.)
;
; CALL:
;		mysql_query
;               mysql_parsexml	
;               mysql_getdtype	
;
; EXAMPLE:
;		None.	
;
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 07-JUN-2010.
;
;-

status = 0
nrows = 0L
header=''
tabledata=''

if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'tabledata = mysql_client(sql_query, $'
   print,'                         database=database, $'
   print,'                         hostname=hostname, $'
   print,'                         username=username, $'
   print,'                         password=password, $'
   print,'                         header=header,nrows=nrows,$'
   print,'                         status=status,cmd=cmd,$'
   print,'                         /STRUCTURE,/XML,/SILENT)'
   return,''
endif
SILENT = keyword_set(SILENT)
STRUCTURE=keyword_set(STRUCTURE)
XML = keyword_set(XML) or STRUCTURE

query = strtrim(sql_query[0],2)
if not (keyword_set(hostname)) then host = "" else host = "-h "+strtrim(hostname[0],2)
if not (keyword_set(username)) then user = "" else user = "-u "+strtrim(username[0],2)
if not (keyword_set(password)) then pass = "" else pass = "--password="+strtrim(password[0],2) 
if not (keyword_set(database)) then db = "" else db = strtrim(database[0],2)

response=mysql_query(query,database=database, username=username, $
                     hostname=hostname,password=password, $
                     header=header,nrows=nrows, cmd=cmd, $
                     XML=XML,SILENT=SILENT)

if (STRUCTURE) then begin
   mysql_parsexml,response, fieldnames, $
                  statement=statement, $
                  xmlns=xmlns, $
                  /GET_FIELDNAMES

   ; Get data types (only if a table name is provided
   ; in the sql query, otherwise use string type only)
   from_pos=stregex(strupcase(query),' FROM ')
   if (from_pos ne -1) then begin
      table=(strsplit(strmid(query,from_pos),/EXTRACT))[1]
      sql_dtypes=mysql_getdtype(fieldnames, $
                                table=table, $
                                database=database, $
                                hostname=hostname, $
                                username=username, $
                                password=password)
   endif else sql_dtypes=''

   mysql_parsexml,response, tabledata, $
                  fieldnames=fieldnames, $
                  sql_dtypes=sql_dtypes

endif else tabledata=response

return,tabledata
END
