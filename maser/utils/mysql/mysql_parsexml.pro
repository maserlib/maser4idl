PRO mysql_parsexml,xml_response,tabledata, $
                   statement=statement, $
                   xmlns=xmlns, nrows=nrows, $
                   fieldnames=fieldnames, $
                   sql_dtypes=sql_dtypes, $
                   GET_FIELDNAMES=GET_FIELDNAMES

;+
; NAME:
;		mysql_parsexml
;
; PURPOSE:
; 		Reads the input sql response 
;               in xml format, and returns
;               data into a IDL structure.
;
; CATEGORY:
;		I/O 
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		IDL> tabledata = mysql_parsexml(xml_response)
;
; INPUTS:
;		xml_response - Vector of string type containing the
;                              MySQL response in xml format.
;
; OPTIONAL INPUTS:
;		fieldnames - Vector of string type containing the
;                            name of the fields/columns for which data must
;                            be returned in the output structure.
;                            If it is not defined, then return 
;                            all of the fields.
;               sql_dtypes - Vector of string type containing the
;                            SQL data types of the fields/columns
;                            provided in fieldnames input.  
;                            If it is not defined, then use only 
;                            string format for output data. 
;
; KEYWORD PARAMETERS:
;               /GET_FIELDNAMES - If set, return a vector of string
;                                 type containing the list of
;                                 fields/columns  
;                                 in the xml response. 
;
; OUTPUTS:
;		tabledata - IDL structure containing the SQL dataset
;                           provided by field/column names.		
;
; OPTIONAL OUTPUTS:
;               statement - MySQL Statement returns in the xml
;                           response.
;               xmlns     - xmlns state.
;               nrows     - Number of row(s) in the input set.
;
; COMMON BLOCKS:
;		None.
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS:
;		None.
;
; CALL:
;		mysql2idl_dtype		
;
; EXAMPLE:
;		None.	
;
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 07-JUN-2010.
;
;-

statement=''
xmlns=''
nrows=0l 
nval=0l
tabledata=0b

if (n_params() lt 1) then begin
   message,/CONT,'Call is:'
   print,'mysql_parsexml,xml_response,tabledata, $'
   print,'               statement=statement, $'
   print,'               xmlns=xmlns,nrows=nrows, $'
   print,'               fieldnames=fieldnames, $'
   print,'               sql_dtypes=sql_dtypes, $'
   print,'               /GET_FIELDNAMES'
   return
endif
GET_FIELD=keyword_set(GET_FIELDNAMES)

; Reading xml's header
nlines=n_elements(xml_response)
i=0l
while i lt nlines do begin
   row_i=strtrim(xml_response[i],2)
   ipos=strpos(row_i,'<resultset statement=')
   if (ipos ne -1) then begin
      items=strsplit(strmid(row_i,ipos),'"',/EXTRACT)
      statement=items[1]
   endif
   ixmlns=strpos(row_i,'xmlns:xsi=')
   if (ixmlns ne -1) then begin
      items=strsplit(strmid(row_i,ixmlns),'"',/EXTRACT)
      xmlns=items[1]
   endif
   i++
   if (statement ne '') and (xmlns ne '') then break
endwhile

; Reading xml's table data
field='' & value='' & col=-1l
while i lt nlines do begin
   row_i=strtrim(xml_response[i],2)
   if (row_i eq '<row>') then nrows++
   if (strmatch(row_i,'<field name=*')) then begin
      field_i=(strsplit(row_i,'"',/EXTRACT))[1]
      field=[field,field_i]
      ipos0=strpos(row_i,'>')+1l
      ipos1=strpos(row_i,'</field>')
      value=[value,strmid(row_i,ipos0,ipos1-ipos0)]
      nval++
      col=[col,nrows]
   endif
   i++
endwhile
if (nval eq 0l) or (nrows eq 0l) then return
field=field[1:*] & value=value[1:*] & col=col[1:*]


if (GET_FIELD) then begin
   fieldnames=field[uniq(field,sort(field))]
   tabledata=fieldnames
   return
endif else begin
   if not (keyword_set(fieldnames)) then $
      fieldnames=field[uniq(field,sort(field))]
endelse
nfield=n_elements(fieldnames)

; Generating output structure
if not keyword_set(sql_dtypes) then dtypes=strarr(nfield)+'VARCHAR' $
else dtypes=strupcase(strtrim(sql_dtypes,2))
if (n_elements(dtypes) ne nfield) then message,'Incorrect number of elements in sql_dtypes!'

ss='{'
for i=0l,nfield-1l do ss=ss+fieldnames[i]+':'+mysql2idl_dtype(dtypes[i],/MYSQL2IDL)+'(0),'
ss = strmid(ss,0,strlen(ss)-1L) + '}'
qflag = execute('tabledata='+ss)
if (qflag eq 0) then return
tabledata=replicate(tabledata,nrows)
tagnames=strupcase(tag_names(tabledata))

; Filling output structure
columns=lindgen(nrows)+1l
for i=0l,nval-1l do begin
   where_tag=(where(tagnames eq strupcase(field[i])))[0]
   where_col=(where(columns eq col[i]))[0]
   if (where_tag eq -1) or (where_col eq -1) then continue
   tabledata[where_col].(where_tag)=value[i]
endfor

END
