FUNCTION mysql_getdtype,fieldnames, $
                        table=table, $
                        database=database, $
                        hostname=hostname, $
                        username=username, $
                        password=password, $
                        cmd=cmd

;+
; NAME:
;		mysql_getdtype
;
; PURPOSE:
; 		Providing a list of field/column names, this function
;               returns the corresponding list of MySQL data types. 
;
; CATEGORY:
;		I/O 
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		IDL> sql_dtypes = mysql_getdtype(fieldnames)
;
; INPUTS:

;
; OPTIONAL INPUTS:
;		table	 - Name of the MySQL table containg the fields/columns.
;		database - Name of the database containing the table.
;		hostname - Specifies the host name of the database.
;		username - Specifies the user name.
;		password - Specifies the corresponding password.	
;
; KEYWORD PARAMETERS:
;		None.
;
; OUTPUTS:
;		sql_dtypes - Vector of string type containing the
;                            SQL data types for the input list of fields.	
;
; OPTIONAL OUTPUTS:
;		cmd - Contains the command lines executed by the
;                     IDL command spawn.
;
; COMMON BLOCKS:
;		None.
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS:
;		A MySQL client must be installed in the current machine.		
;		(This routine uses mysql command calling spawn idl function.)
;
; CALL:
;		mysql_query		
;
; EXAMPLE:
;		None.	
;
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 07-JUN-2010.
;
;-

status = 0
dbquote=string(34b)
sql_dtypes=''
cmd=''

;[1]:Initializing program
;[1]:====================
if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'sql_dtypes = mysql_getdtype(fieldnames, $'
   print,'                             table, $'
   print,'                             database=database,$'
   print,'                             hostname=hostname,$'
   print,'                             username=username,$'
   print,'                             password=password,$'
   print,'                             cmd=cmd)'
   return,''
endif
ncol=n_elements(fieldnames)

if (keyword_set(table)) then begin
   if (n_elements(table) ne ncol) then table=table[0]+strarr(ncol)
endif else table=''
if (keyword_set(database)) then begin
   if (n_elements(database) ne ncol) then database=database[0]+strarr(ncol)
endif else database=''
if not (keyword_set(username)) then username=''
if not (keyword_set(password)) then password=''

;[1]:====================

;[2]:Get columns information from database
;[2]:=====================================
sql_dtypes=strarr(ncol) & cmd=strarr(ncol)
for i=0l,ncol-1l do begin
   query_i = 'SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE (COLUMN_NAME='+dbquote+fieldnames[i]+dbquote+')'
   if (keyword_set(table)) then query_i=query_i+' AND (TABLE_NAME='+dbquote+table[i]+dbquote+')'
   if (keyword_set(database)) then query_i=query_i+' AND (TABLE_SCHEMA='+dbquote+database[i]+dbquote+')'

   dtype_i = mysql_query(query_i,hostname=hostname,username=username,$
                         password=password,database=database[i],$
                         status=status_i,cmd=cmd_i,nrows=nrows_i,/SILENT)
   cmd[i]=cmd_i
   if (dtype_i eq '') then begin
      message,/CONT,'Empty set!'
      return,''
   endif

   if (nrows_i gt 1) then begin
      dt_uniq=dtype_i[uniq(dtype_i,sort(dtype_i))]
      if (n_elements(dt_uniq) gt 1) then begin
         message,/CONT,'More than one data type exist for '+fieldnames[i]+', please refine the query!'
         return,dt_uniq
      endif 
      sql_dtypes[i] = dt_uniq[0]
   endif else sql_dtypes[i]=dtype_i[0]
endfor

return,sql_dtypes
END
