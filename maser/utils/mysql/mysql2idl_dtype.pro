FUNCTION mysql2idl_dtype,dtype_in,$
                         MYSQL2IDL=MYSQL2IDL,$
                         IDL2MYSQL=IDL2MYSQL,$
                         sql_dtypes=sql_dtypes,$
                         idl_dtypes=idl_dtypes,$
                         error=error


;+
; NAME:
;	mysql2idl_dtype
;
; PURPOSE:
; 	Providing a MySQL data type, this function
;       returns the corresponding IDL data type (or inversely). 
;
; CATEGORY:
;	MySQL database
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	IDL> dtype_out = mysql2idl_dtype(dtype_in)
;
; INPUTS:
;       dtype_in  - String containing the input data type.
;
; OPTIONAL INPUTS:
;       None.	
;
; KEYWORD PARAMETERS:
;	/MYSQL2IDL - Providing a MySQL data type, returns the
;                    corresponding IDL data type (Default case).
;       /IDL2MYSQL - Providing a IDL data type, returns the
;                    corresponding MySQL data type.
;
; OUTPUTS:
;	dtype_out - String containg the corresponding data type.	
;
; OPTIONAL OUTPUTS:
;	idl_types - The list of IDL data types available.
;       sql_types - The list of MySQL data types available. 
;       error     - Set to 1b if an error occurs.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS:
;		None.
;
; CALL:
;	        None.		
;
; EXAMPLE:
;		None.	
;
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 07-JUN-2010.
;
;-

error = 1b
dtype_out=''
if (n_params() lt 1) then begin
    message,/INFO,'Call is:'
    print,'dtype_out = mysql_dtype(dtype_in, $'
    print,'                        error=error, $'
    print,'                        sql_types=sql_types, $'
    print,'                        idl_types=idl_types, $'
    print,'                        /MYSQL2IDL,/IDL2MYSQL)'
    return,''
endif

MYSQL2IDL = keyword_set(MYSQL2IDL)
IDL2MYSQL = keyword_set(IDL2MYSQL)

if (MYSQL2IDL + IDL2MYSQL eq 0) then MYSQL2IDL = 1
if (MYSQL2IDL + IDL2MYSQL gt 1) then message,'You must choose between /MYSQL2IDL and /ILD2MYSQL options!'

sql_types = ['TINYINT','SMALLINT','MEDIUMINT','INT','INTEGER','BIGINT', $
             'FLOAT','DOUBLE','REAL','DECIMAL','NUMERIC', $
             'DATE' , 'DATETIME', 'TIME', 'TIMESTAMP', $
             'YEAR' , 'BIT', 'BOOL', 'CHAR', 'VARCHAR', $
             'BLOB', 'TEXT', 'LONGTEXT'] 
                
idl_types = ['FIX','FIX','LONG','LONG','LONG','LONG', $
             'FLOAT','DOUBLE','DOUBLE','STRING','STRING',$
             'STRING', 'STRING', 'STRING', 'STRING', $
             'STRING', 'STRING', 'STRING', 'STRING', 'STRING', $
             'STRING', 'STRING', 'STRING']

type = (strsplit(strupcase(strtrim(dtype_in[0],2)),'(',/EXTRACT))[0]
if (MYSQL2IDL) then begin
   i = (where(strmatch(sql_types,type)))[0]
   if (i ne -1) then dtype_out = idl_types[i] else return,''
endif

error = 0b
return,dtype_out
END
