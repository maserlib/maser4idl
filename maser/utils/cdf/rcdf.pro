PRO rcdf_dtype, input_type, output_type, $
        cdf_datatype=cdf_datatype, idl_datatype=idl_datatype, $
        ARRAY=ARRAY, REVERSE=REVERSE

; +
; NAME:
;   rcdf_dtype
;
; PURPOSE:
;   Gives the correspondance between CDF datatype
;   and IDL data type
;
; CALLING SEQUENCE:
;   rcdf_dtype, input_type, output_type
;
; INPUTS:
;   input_type - Scalar of string type containing the input datatype (CDF data type by default)
;
; OPTIONAL INPUTS:
;   None.
;
; KEYWORD PARAMETERS:
;   /ARRAY - Returns IDL array type (e.g., fltarr)
;   /REVERSE - If set, provide the IDL array data type and return the CDF data type.
;
; OUTPUTS:
;   output_type - corresponding data type (IDL array data type by default)
;
; OPTIONAL OUTPUTS:
;   cdf_datatype - list of available CDF data types
;   idl_datatype - List of corresponding idl data type
;
; MODIFICATION HISTORY:
;   Written by X.Bonnin (LESIA, CNRS)
;
;   X.Bonnin, 12-NOV-2015:  Add /ARRAY keyword.
;   X.Bonnin, 05-JAN-2015:  Fix a bug (used int() instead of fix())
;
; -

    if n_params() lt 2 then begin
        message,/INFO,'Usage:'
        print,'rcdf_dtype, input_type, output_type, $'
        print,'                     cdf_datatype=cdf_datatype, $'
        print,'                     idl_datatype=idl_datatype, $'
        print,'                     /ARRAY, /REVERSE'
        return
    endif


    output_type = -1
    REVERSE=keyword_set(REVERSE)
    ARRAY=keyword_set(ARRAY)
    if (n_elements(input_type) eq 0) then input_type = ''

    cdf_datatype = ['CDF_UINT1','CDF_UINT2','CDF_UINT4','CDF_INT1','CDF_INT2','CDF_INT4', $
        'CDF_INT8','CDF_REAL2','CDF_REAL4', 'CDF_CHAR', 'CDF_UCHAR','CDF_BYTE', 'CDF_FLOAT', $
        'CDF_DOUBLE','CDF_EPOCH', 'CDF_EPOCH16', 'CDF_TIME_TT2000', 'CDF_REAL8']
    if (ARRAY) then $
        idl_datatype = ['bytarr', 'uintarr', 'ulonarr', 'intarr', 'intarr', 'lonarr', $
            'lon64arr','fltarr', 'dblarr', 'strarr','strarr','bytarr', 'fltarr', $
            'dblarr','dblarr','dblarr','dblarr', 'dblarr'] $
    else $
        idl_datatype = ['byte', 'uint','ulong','fix', 'fix', 'long', $
            'long64', 'float', 'double', 'string', 'string', 'byte', 'float', $
            'double', 'double', 'double', 'double', 'double']

    if (REVERSE) then begin
        i = (where(strlowcase(input_type) eq idl_datatype))[0]
        if (i ne -1) then output_type = cdf_datatype[i]
    endif else begin
        i = (where(strupcase(input_type) eq cdf_datatype))[0]
        if (i ne -1) then output_type = idl_datatype[i]
    endelse

END
; ========================================
;=========================================
FUNCTION rcdf, cdf_file, gattrs=gattrs, $
                            ONLY_GATTRS=ONLY_GATTRS, $
                            VERBOSE=VERBOSE

; +
; NAME:
;   rcdf
;
; PURPOSE:
;   Light reader for CDF format file.
;
; CALLING SEQUENCE:
;   rcdf, cdf_file, vars_info=vers_info
;
; INPUTS:
;   cdf_file - Path of the CDF format file to read.
;
; OPTIONAL INPUTS:
;   None.
;
; KEYWORD PARAMETERS:
;   /ONLY_GATTRS - Only load Global attributes
;   /VERBOSE - Talkative mode
;
; OUTPUTS:
;   data - An array of structures containing the name of the
;              CDF variables and the corresponding data.
;
; OPTIONAL OUTPUTS:
;   gattrs - Global attributes
;
; CALLS:
;   rcdf_dtype
;
; COMMENTS/RESTRICTIONS:
;   - CDF Header/variable info (e.g., CDF NAME,
;     DATA ENCODING, CDF COMPRESSION, etc.)
;     are not loaded.
;   - Only works with zVariables.
;
; MODIFICATION HISTORY:
;   Written by X.Bonnin (LESIA, CNRS)
;
;   X.Bonnin, 20-MAY-2015:  - Add gattrs loading.
;   X.Bonnin, 12-NOV-2015:  - Treat the case where a variable has no data.
;                           - Treat string type in cdf_varget
;   X.Bonnin, 16-NOV-2015:  - Fix a bug that produces
;                             an error if a CDF variable has no var. attribute.
;                           - Byte data type is not correctly
;                             taken account when reading var. attribute.
;   X.Bonnin, 06-APR-2016:  - Add /ONLY_GATTRS
;   X.Bonnin, 13-JUL-2016:  - Fix a bug that raises an error if an attribute
;                             entry has inside quotes.
;                           - If a zVariable name starts with a number
;                             then add an underscore "_" as prefix to
;                             allow IDL to read it.
; -

dquote = string(34b)
quote = string(39b)

num = strtrim(indgen(10),2)

data = 0b & gattrs = 0b
if (n_params() lt 1) then begin
    message,/INFO,'Usage:'
    print,'data = rcdf(cdf_file, gattrs=gattrs, /ONLY_GATTRS, /VERBOSE)'
    return,0b
endif
ONLY_GATTRS = keyword_set(ONLY_GATTRS)
VERBOSE = keyword_set(VERBOSE)

if (VERBOSE) then print,'Opening ' + cdf_file + '... '
id=cdf_open(cdf_file, /READONLY)

inq=cdf_inquire(id)
nvars=inq.nvars
nzvars=inq.nzvars
nvattrs=inq.natts

; Get Global and variable attributes
cdf_control, id, get_numattrs=numattrs, /ZVAR
if (numattrs[0]) ne 0 then begin
    gattr_list = strarr(numattrs[0]) & iatt = 0l
    nattrs = total(numattrs)
    for i=0,nattrs-1 do begin
        CDF_ATTINQ, id, i, name, scope, maxentry, maxzentry
        if (scope eq 'GLOBAL_SCOPE') then begin
            nentry = maxentry + 1
            if nentry le 0 then begin
                message,/INFO,'Warning: ' + name + ' attribute has no entry!'
                continue
            endif
            entry_i = strarr(maxentry+1)
            for j=0,maxentry do begin
                CDF_ATTGET, id, name, j, att_j
                ; replace quotes by double quotes
                att_j = strjoin(strsplit(att_j, quote, /EXTRACT), dquote)
                entry_i[j] = att_j
            endfor
            entry_i = '[' + quote + strjoin(entry_i, ',') + quote + ']'

            gattr_list[iatt] = name + ':' + entry_i
            iatt++
        endif
    endfor
    str = 'gattrs = {' + strjoin(gattr_list,',') + '}'
    void = execute(str)
endif

if ONLY_GATTRS then return, 0b

; Get CDF Zvariables
if (nzvars gt 0) then begin
    if (VERBOSE) then print, 'Loading '+strtrim(nzvars,2)+' CDF variables ...'

    varname = strarr(nzvars)
    for varNum_i=0,nzvars-1 do begin
        vinq_i=cdf_varinq(id,varNum_i, /ZVAR)
        name_i=vinq_i.name
        datatype_i=vinq_i.datatype
        numelem_i=strtrim(vinq_i.numelem,2)
        recvar_i=strjoin(quote+strtrim(vinq_i.recvar,2)+quote,',')
        dimvar_i=strjoin(strtrim(fix(vinq_i.dimvar),2),',')
        if strtrim(dimvar_i,2) eq '' then dimvar_i = quote+'N/A'+quote
        dim_i=strjoin(strtrim(vinq_i.dim,2),',')

        ;rcdf_dtype, datatype_i, idl_dtype, /ARRAY

        ; Get variable attributes
        if nvattrs gt 0 then begin
            vattrs_i=0b
            vattrs_j = '' & vcount=0l
            for attrNum_j=0, nvattrs-1 do begin
                CDF_ATTGET_ENTRY, id, attrNum_j, varNum_i, attType, value, $
                    status, /ZVAR, CDF_TYPE=cdftype, ATTRIBUTE_NAME=attName
                    if status ne 1 then continue
                    rcdf_dtype, cdftype, idl_attType
                    if idl_attType eq 'byte' then value = fix(value)
                    if idl_attType eq 'string' then begin
                        value = strjoin(strsplit(value, quote, /EXTRACT), dquote) ; replace quotes by double quotes
                        value = quote + value + quote
                    endif
                    ventry_j = attName + ':' + idl_attType + '(' + strtrim(value,2)+ ')'
                    vattrs_j = [vattrs_j, ventry_j]
                    vcount++
            endfor
            if vcount eq 0 then begin
                message,/INFO,name_i+' CDF variable has no variable attribute!'
                vattrs_i = 0b
            endif else $
                void = execute('vattrs_i={' + strjoin(vattrs_j[1:vcount-1], ',') + '}')
        endif else vattrs_i = 0b
        ; Get number of records
        cdf_control, id, get_var_info=varinf, variable=name_i, /ZVAR
        nrec_i = varinf.maxrec + 1l

        ; Get values
        if nrec_i gt 0 then begin
           if datatype_i eq 'CDF_CHAR' or datatype_i eq 'CDF_UCHAR'  $
            then STRING=1b else STRING=0b
            cdf_varget,id,name_i, values_i,rec_count=nrec_i, $
                /ZVARIABLE, /TO_COL, STRING=STRING

            ; If var name start with a number than add "_" prefix
            hasnum = (where(strmatch(num, strmid(name_i, 0 ,1)) eq 1))[0]
            if hasnum[0] ne -1 then begin
                message,/INFO,'Warning: ' + $
                    name_i + " has been renamed to " + $
                    '_' + name_i
                name_i = '_' + name_i
            endif

            ;data_i = idl_dtype + '(' + dim_i + ')'
            void = execute(name_i+ '= {id:'+strtrim(varNum_i,2)+$
            ', datatype:'+quote+datatype_i+quote+$
            ', numelem:'+numelem_i+$
            ', recvar:['+recvar_i+']'+$
            ', dimvar:['+dimvar_i+']'+$
            ', dims:['+dim_i+']'+$
            ', data:values_i' +$
            ', vattributes:vattrs_i}')
            varname[varNum_i] = name_i
        endif else begin
            message,/INFO,name_i+ ' CDF variable has no data!'

            ; If var name start with a number than add "_" prefix
            hasnum = (where(strmatch(num, strmid(name_i, 0 ,1)) eq 1))[0]
            if hasnum[0] ne -1 then begin
                message,/INFO,'Warning: ' + $
                    name_i + " has been renamed to " + $
                    '_' + name_i
                name_i = '_' + name_i
            endif

            void = execute(name_i+ '= {id:'+strtrim(varNum_i,2)+$
            ', datatype:'+quote+datatype_i+quote+$
            ', numelem:'+numelem_i+$
            ', recvar:['+recvar_i+']'+$
            ', dimvar:['+dimvar_i+']'+$
            ', dims:['+dim_i+']'+$
            ', vattributes:vattrs_i}')
            varname[varNum_i] = name_i
        endelse

    endfor

    ; Generate output structure
    tmp = strjoin(varname+':'+varname,',')
    void = execute('zvars = {' + tmp + '}')
endif

cdf_close,id
if (VERBOSE) then print,'Closing CDF file ...'

if (void) then return,zvars else return,!null
END