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
;=========================================
;=========================================
; NOTES:
;   - Adapted from https://idlastro.gsfc.nasa.gov/ftp/pro/structure/create_struct.pro
;   - Renamed to create_structure to avoid collision with CREATE_STRUCT function in IDL standard library
pro create_structure, struct, strname, tagnames, tag_descript, DIMEN = dimen, $
              CHATTER = chatter, NODELETE = nodelete, tempfile = tempfile
;+
; NAME:
;       CREATE_STRUCTURE
; PURPOSE:
;       Create an IDL structure from a list of tag names and dimensions
; EXPLANATION:
;       Dynamically create an IDL structure variable from list of tag names
;       and data types of arbitrary dimensions.   Useful when the type of
;       structure needed is not known until run time.
;
;       Unlike the intrinsic function CREATE_STRUCT(), this procedure does not
;       require the user to know the number of tags before run time.   (Note
;       there is no name conflict since the intrinsic CREATE_STRUCT() is a
;       function, and this file contains a procedure.)
; CALLING SEQUENCE:
;       CREATE_STRUCTURE, STRUCT, strname, tagnames, tag_descript,
;                             [ DIMEN = , /CHATTER, /NODELETE ]
;
; INPUTS:
;       STRNAME -   name to be associated with structure (string)
;               Must be unique for each structure created.   Set
;               STRNAME = '' to create an anonymous structure
;
;       TAGNAMES -  tag names for structure elements (string or string array)
;                Any strings that are not valid IDL tag names (e.g. 'a\2')
;                will be converted by IDL_VALIDNAME to a valid tagname by
;                replacing with underscores as necessary (e.g. 'a_2')
;
;       TAG_DESCRIPT -  String descriptor for the structure, containing the
;               tag type and dimensions.  For example, 'A(2),F(3),I', would
;               be the descriptor for a structure with 3 tags, strarr(2),
;               fltarr(3) and Integer scalar, respectively.
;               Allowed types are 'A' for strings, 'B' or 'L' for unsigned byte
;               integers, 'I' for integers, 'J' for longword integers,
;               'K' for 64bit integers, 'F' or 'E' for floating point,
;               'D' for double precision  'C' for complex, and 'M' for double
;               complex.   Uninterpretable characters in a format field are
;               ignored.
;
;               For vectors, the tag description can also be specified by
;               a repeat count.  For example, '16E,2J' would specify a
;               structure with two tags, fltarr(16), and lonarr(2)
;
; OPTIONAL KEYWORD INPUTS:
;       DIMEN -    number of dimensions of structure array (default is 1)
;
;       CHATTER -  If set, then CREATE_STRUCT() will display
;                  the dimensions of the structure to be created, and prompt
;                  the user whether to continue.  Default is no prompt.
;
;       tempfile -  path of the temporary file (without the ".pro" suffix) 
;
;       /NODELETE - If set, then the temporary file created
;                  CREATE_STRUCTURE will not be deleted upon exiting.   See below
;
; OUTPUTS:
;       STRUCT -   IDL structure, created according to specifications
;
; EXAMPLES:
;
;       IDL> create_structure, new, 'name',['tag1','tag2','tag3'], 'D(2),F,A(1)'
;
;       will create a structure variable new, with structure name NAME
;
;       To see the structure of new:
;
;       IDL> help,new,/struc
;       ** Structure NAME, 3 tags, 20 length:
;          TAG1            DOUBLE         Array[2]
;          TAG2            FLOAT          0.0
;          TAG3            STRING         Array[1]
;
; PROCEDURE:
;       Generates a temporary procedure file using input information with
;       the desired structure data types and dimensions hard-coded.
;       This file is then executed with CALL_PROCEDURE.
;
; NOTES:
;       If CREATE_STRUCTURE cannot write a temporary .pro file in the current
;       directory, then it will write the temporary file in the getenv('HOME')
;       directory.
;
;       Note that 'L' now specifies a LOGICAL (byte) data type and not a
;       a LONG data type for consistency with FITS binary tables
;
; RESTRICTIONS:
;       The name of the structure must be unique, for each structure created.
;       Otherwise, the new variable will have the same structure as the
;       previous definition (because the temporary procedure will not be
;       recompiled).  ** No error message will be generated  ***
;
; SUBROUTINES CALLED:
;       REPCHR()
;
; MODIFICATION HISTORY:
;       Version 1.0 RAS January 1992
;       Modified 26 Feb 1992 for Rosat IDL Library (GAR)
;       Modified Jun 1992 to accept arrays for tag elements -- KLV, Hughes STX
;       Accept anonymous structures W. Landsman  HSTX    Sep. 92
;       Accept 'E' and 'J' format specifications   W. Landsman Jan 93
;       'L' format now stands for logical and not long array
;       Accept repeat format for vectors        W. Landsman Feb 93
;       Accept complex and double complex (for V4.0)   W. Landsman Jul 95
;       Work for long structure definitions  W. Landsman Aug 97
;       Write temporary file in HOME directory if necessary  W. Landsman Jul 98
;       Use OPENR,/DELETE for OS-independent file removal W. Landsman Jan 99
;       Use STRSPLIT() instead of GETTOK() W. Landsman  July 2002
;       Assume since V5.3 W. Landsman  Feb 2004
;       Added RESOLVE_ROUTINE to ensure recompilation W. Landsman Sep. 2004
;       Delete temporary with FILE_DELETE   W. Landsman Sep 2006
;       Assume since V5.5, delete VMS reference  W.Landsman Sep 2006
;       Added 'K' format for 64 bit integers, IDL_VALIDNAME check on tags
;                       W. Landsman  Feb 2007
;       Use vector form of IDL_VALIDNAME() if V6.4 or later W.L. Dec 2007
;       Suppress compilation mesage of temporary file A. Conley/W.L. May 2009
;       Remove FDECOMP, some cleaner coding  W.L. July 2009
;       Do not limit string length to 1000 chars   P. Broos,  Feb 2011
;       Assume since IDL V6.4 W. Landsman Aug 2013
;       Add optional keyword tempfile X. Bonnin July 2025 
;-
;-------------------------------------------------------------------------------

 compile_opt idl2
 if N_params() LT 4 then begin
   print,'Syntax - CREATE_STRUCTURE, STRUCT, strname, tagnames, tag_descript,'
   print,'                  [ DIMEN = , tempfile = , /CHATTER, /NODELETE ]'
   return
 endif

 if ~keyword_set( chatter) then chatter = 0        ;default is 0
 if (N_elements(dimen) eq 0) then dimen = 1            ;default is 1

 if (dimen lt 1) then begin
  print,' Number of dimensions must be >= 1. Returning.'
  return
 endif

; For anonymous structure, strname = ''
  anonymous = 0b
  if (strlen( strtrim(strname,2)) EQ 0 ) then anonymous = 1b

 good_fmts = [ 'A', 'B', 'I', 'L', 'F', 'E', 'D', 'J','C','M', 'K' ]
 fmts = ["' '",'0B','0','0B','0.0','0.0','0.0D0','0L','complex(0)', $
           'dcomplex(0)', '0LL']
 arrs = [ 'strarr', 'bytarr', 'intarr', 'bytarr', 'fltarr', 'fltarr', $
          'dblarr', 'lonarr','complexarr','dcomplexarr','lon64arr']
 ngoodf = N_elements( good_fmts )

; If tagname is a scalar string separated by commas, convert to a string array

 if size(tagnames,/N_dimensions) EQ 0 then begin
            tagname = strsplit(tagnames,',',/EXTRACT)
 endif else tagname = tagnames

 Ntags = N_elements(tagname)

; Make sure supplied tag names are valid.

 tagname = idl_validname( tagname, /convert_all )

;  If user supplied a scalar string descriptor then we want to break it up
;  into individual items.    This is somewhat complicated because the string
;  delimiter is not always a comma, e.g. if 'F,F(2,2),I(2)', so we need
;  to check positions of parenthesis also.

 sz = size(tag_descript)
 if sz[0] EQ 0 then begin
      tagvar = strarr( Ntags)
      temptag = tag_descript
      for i = 0, Ntags - 1 do begin
         comma = strpos( temptag, ',' )
         lparen = strpos( temptag, '(' )
         rparen = strpos( temptag, ')' )
            if ( comma GT lparen ) and (comma LT Rparen) then pos = Rparen+1 $
                                                         else pos = comma
             if pos EQ -1 then begin
                 if i NE Ntags-1 then message, $
         'WARNING - could only parse ' + strtrim(i+1,2) + ' string descriptors'
                 tagvar[i] = temptag
                 goto, DONE
             endif else begin
                    tagvar[i] = strmid( temptag, 0, pos )
                    temptag = strmid( temptag, pos+1)
              endelse
             endfor
             DONE:

 endif else tagvar = tag_descript

; create string array for IDL statements, to be written into
; 'temp_'+strname+'.pro'

 pro_string = strarr (ntags + 2)

 if (dimen EQ 1) then begin

   pro_string[0] = "struct =  { " + strname + " $"
   pro_string[ntags+1] = " } "

 endif else begin

   dimen = long(dimen)                ;Changed to LONG from FIX Mar 95
   pro_string[0] = "struct "   + " = replicate ( { " + strname + " $"
   pro_string[ntags+1] = " } , " + string(dimen) + ")"

 endelse

 tagvar = strupcase(tagvar)

 for i = 0, ntags-1 do begin

   goodpos = -1
   for j = 0,ngoodf-1 do begin
         fmt_pos = strpos( tagvar[i], good_fmts[j] )
         if ( fmt_pos GE 0 ) then begin
              goodpos = j
              break
         endif
   endfor

  if goodpos EQ -1 then begin
      print,' Format not recognized: ' + tagvar[i]
      print,' Allowed formats are :',good_fmts
      stop,' Redefine tag format (' + string(i) + ' ) or quit now'
  endif


    if fmt_pos GT 0 then begin

           repeat_count = strmid( tagvar[i], 0, fmt_pos )
           if strnumber( repeat_count, value ) then begin
                fmt = arrs[ goodpos ] + '(' + strtrim(fix(value), 2) + ')'
           endif else begin
                print,' Format not recognized: ' + tagvar[i]
                stop,' Redefine tag format (' + string(i) + ' ) or quit now'
           endelse

    endif else  begin

; Break up the tag descriptor into a format and a dimension
    tagfmts = strmid( tagvar[i], 0, 1)
    tagdim = strtrim( strmid( tagvar[i], 1, 80),2)
    if strmid(tagdim,0,1) NE '(' then tagdim = ''
    fmt = (tagdim EQ '') ? fmts[goodpos] : arrs[goodpos] + tagdim
    endelse

  if anonymous and ( i EQ 0 ) then comma = '' else comma = " , "

      pro_string[i+1] = comma + tagname[i] + ": " + fmt + " $"

 endfor

; Check that this structure definition is OK (if chatter set to 1)

 if keyword_set ( Chatter )  then begin
   ans = ''
   print,' Structure ',strname,' will be defined according to the following:'
   temp = repchr( pro_string, '$', '')
   print, temp
   read,' OK to continue? (Y or N)  ',ans
   if strmid(strupcase(ans),0,1) eq 'N' then begin
      print,' Returning at user request.'
     return
   endif
 endif

; --- Determine if a file already exists with same name as temporary file

if ~keyword_set(tempfile) then begin 
    tempfile = 'temp_' + strlowcase( strname )
    while file_test( tempfile + '.pro' ) do tempfile = tempfile + 'x'
endif else tempfile = tempfile.replace('.pro', '')

; ---- open temp file and create procedure
; ---- If problems writing into the current directory, try the HOME directory

if file_basename(tempfile) eq tempfile then cd,current= prodir else prodir = filepath(tempfile)

 cdhome = 0
 openw, unit, tempfile +'.pro', /get_lun, ERROR = err
 if (err LT 0)  then begin
      prodir = getenv('HOME')
      tempfile = prodir + path_sep() + tempfile
      while file_test( tempfile + '.pro' ) do tempfile = tempfile + 'x'
      openw, unit, tempfile +'.pro', /get_lun, ERROR = err
      if err LT 0 then message,'Unable to create a temporary .pro file'
      cdhome = 1
  endif
 name = file_basename(tempfile)
 printf, unit, 'pro ' +  name + ', struct'
 printf,unit,'compile_opt hidden'
 for j = 0,N_elements(pro_string)-1 do $
        printf, unit, strtrim( pro_string[j] )
 printf, unit, 'return'
 printf, unit, 'end'
 free_lun, unit

; If using the HOME directory, it needs to be included in the IDL !PATH

 if cdhome then cd,getenv('HOME'),curr=curr
  resolve_routine, name
  Call_procedure, name, struct
 if cdhome then cd,curr

 if keyword_set( NODELETE ) then begin
    message,'Created temporary file ' + tempfile + '.pro',/INF
    return
 endif else file_delete, tempfile + '.pro'

  return
  end         ;pro create_struct
;=========================================
;=========================================
FUNCTION get_gattrs, id, tempfile = tempfile

; +
; NAME:
;   get_gattrs
;
; PURPOSE:
;   Returns CDF global attributes entries as a IDL structure.
;
; CALLING SEQUENCE:
;   gattrs = get_gattrs(id)
;
; INPUTS:
;   id - Opened CDF file id (as returned by cdf_open() function)
;
; OPTIONAL INPUTS:
;   tempfile - Path of the temporary file used to create the dynamical IDL structure. 
;              The file extension ".pro" must be not passed.
;
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   gattrs - IDL structure with global attributes names as tags
;            and entries as values
;
; OPTIONAL OUTPUTS:
;   None.
;
; CALLS:
;   create_structure
;
; COMMENTS/RESTRICTIONS:
;   None
;
; MODIFICATION HISTORY:
;   Written by X.Bonnin (LESIA, CNRS)
;
; -

gattrs = 0b
if ~keyword_set(tempfile) then tempfile = ""
 
; Get attributes from open CDF
cdf_control, id, get_numattrs=numattrs, /ZVAR
; If attributes found, then try to extract global ones
if (numattrs[0]) ne 0 then begin
    gattr_name = strarr(numattrs[0])
    gattr_type = strarr(numattrs[0])
    iatt = 0l
    nattrs = total(numattrs)
    ; First, get names and types of attributes
    for i=0,nattrs-1 do begin
        CDF_ATTINQ, id, i, name, scope, maxentry, maxzentry
        ; Only keep global attributes
        if (scope eq 'GLOBAL_SCOPE') then begin
            nentry = maxentry + 1
            gattr_name[iatt] = name
            if nentry le 0 then begin
                message,/INFO,'Warning: ' + name + ' attribute has no entry!'
                gattr_type[iatt] = 'A(1)'
            endif else begin
                gattr_type[iatt] = 'A('+strtrim(maxentry+1,2)+')'
            endelse
            iatt++
        endif
    endfor

    ; Initialize ouput structure
    strname = '' ; Use anonymous structure
    tag_descript = strjoin(gattr_type[0:iatt-1], ',')
    create_structure, gattrs, strname, $
        gattr_name[0:iatt-1], tag_descript, $
        tempfile = tempfile

    ; Second loops to fill structure with global attribute entries
    iatt = 0l
    for i=0,nattrs-1 do begin
        CDF_ATTINQ, id, i, name, scope, maxentry, maxzentry
        ; Only keep global attributes
        if (scope eq 'GLOBAL_SCOPE') then begin
            if maxentry lt 0 then begin
                entry_i = strarr(1)
                entry_i[0] = " "
            endif else begin
                entry_i = strarr(maxentry+1)
                for j=0,maxentry do begin
                    CDF_ATTGET, id, name, j, att_j
                    ; Store value as CDF_VARCHAR
                    entry_i[j] = strtrim(att_j,2)
                endfor
            endelse
            gattrs.(iatt) = entry_i
            iatt++
        endif
    endfor
endif

return, gattrs
END

;=========================================
;=========================================
FUNCTION rcdf, cdf_file, gattrs=gattrs, $
            tempfile = tempfile, $
            ONLY_GATTRS=ONLY_GATTRS, VERBOSE=VERBOSE

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
;   tempfile - Path of the temporary file used to create the dynamical IDL structure. 
;              The file extension ".pro" must be not passed.
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
;   get_gattrs
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
;   X.Bonnin, 02-MAY-2018:  - Fix a bug in rcdf when a global attribute
;                             has no entry.
;   X.Bonnin, 25-JAN-2022:  - Call get_gattrs() and create_structure() functions
;                             for extracting global attributes from input CDF
;   X.Bonnin, 11-JUL-2025   - Add optionl input tempfile
;   
; -

dquote = string(34b)
quote = string(39b)

digit = strtrim(indgen(10),2)

data = 0b & gattrs = 0b
if (n_params() lt 1) then begin
    message,/INFO,'Usage:'
    print,'data = rcdf(cdf_file, gattrs=gattrs, tempfile=tempfile, /ONLY_GATTRS, /VERBOSE)'
    return,0b
endif
ONLY_GATTRS = keyword_set(ONLY_GATTRS)
VERBOSE = keyword_set(VERBOSE)
if ~keyword_set( tempfile) then tempfile = ""

if (VERBOSE) then print,'Opening ' + cdf_file + '... '
id=cdf_open(cdf_file, /READONLY)

inq=cdf_inquire(id)
nvars=inq.nvars
nzvars=inq.nzvars
nvattrs=inq.natts

; Retrieve global attributes from input CDF file
gattrs = get_gattrs(id, tempfile = tempfile)

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
            vattrs_j = '' & vcount=1l
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
            if vcount eq 1 then begin
                message,/INFO,name_i+' CDF variable has no variable attribute!'
                vattrs_i = 0b
            endif else begin
                void = execute('vattrs_i={' + strjoin(vattrs_j[1:vcount-1], ',') + '}')
            endelse
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
            hasnum = (where(strmatch(digit, strmid(name_i, 0 ,1)) eq 1))[0]
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
            hasnum = (where(strmatch(digit, strmid(name_i, 0 ,1)) eq 1))[0]
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
