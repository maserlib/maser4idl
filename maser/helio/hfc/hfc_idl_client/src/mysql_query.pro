FUNCTION mysql_query,sql_query, $
                     database=database, $
                     hostname=hostname, $
                     username=username, $
                     password=password, $
                     header=header,nrows=nrows,$
                     status=status,cmd=cmd,$
                     XML=XML,SILENT=SILENT

;+
; NAME:
;		mysql_query
;
; PURPOSE:
; 		Query a MySQL database
;               using a command line.
;
; CATEGORY:
;		I/O 
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		IDL> Response = mysql_query(sql_query)
;
; INPUTS:
;		sql_query - Scalar string containing the MySQL query sent to the database.
;
; OPTIONAL INPUTS:
;		database - Scalar string containing the name of the database to query.	
;		hostname - Scalar string containing the host name of the database.
;		username - Scalar string containing the user name.
;		password - Scalar string containing the corresponding password. 	
;
; KEYWORD PARAMETERS:
;		/XML    - Return response using the xml format.
;		/SILENT - Quiet mode. 
;
; OUTPUTS:
;		Response - Returns the query response in a vector of string type.		
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
;		None.		
;
; EXAMPLE:
;		None.	
;
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 07-JUN-2010.
;
;		04-AUG-2011, X.Bonnin:	Added /SILENT keyword.
;		20-DEC-2011, X.Bonnin:  Added /XML keyword.
;
;-

status = 0
quote=string(39b)

if (n_params() lt 1) then begin
	message,/INFO,'Call is:'
	print,'Response = mysql_query(sql_query, $'
	print,'                       database=database, $'
	print,'                       hostname=hostname, $'
	print,'                       username=username, $'
	print,'                       password=password, $'
	print,'                       header=header,nrows=nrows,$'
	print,'                       status=status,$'
	print,'                       /XML,/VERBOSE)'
	return,-1
endif

SILENT = keyword_set(SILENT)
XML = keyword_set(XML)
fields = ''
nrows = 0L

query = strtrim(sql_query[0],2)
if (~keyword_set(hostname)) then host = "" else host = "-h "+strtrim(hostname[0],2)
if (~keyword_set(username)) then user = "" else user = "-u "+strtrim(username[0],2)
if (~keyword_set(password)) then pass = "" else pass = "--password="+strtrim(password[0],2) 
if (~keyword_set(database)) then db = "" else db = strtrim(database[0],2)

if (XML) then cmd = 'mysql --xml ' else cmd = 'mysql '

cmd = cmd+host+' '+user+' '+pass+ $
		' '+db+' -e '+ quote+query+quote

spawn,cmd,response
response = strtrim(response,2)

header = response[0]
nrows = n_elements(response)
if (header eq '') then return,response

status = 1
if (nrows eq 1) then begin
   if not (SILENT) then print,'Empty set.'
   return,response
endif

nrows = nrows-1L
if not (SILENT) then print,strtrim(nrows,2)+' rows in set.'

status = 1
return,response[1:*]
END
