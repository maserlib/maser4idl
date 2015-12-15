PRO wget,url,response, $
         options=options, $
         cmd=cmd

;+
; NAME:
;       wget
;
; PURPOSE:
; 	Launch a wget software
;       call using spawn IDL command.
;
; CATEGORY:
;	Network
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	wget,url,response
;
; INPUTS:
;       url - String containing the url to reach.
;	
; OPTIONAL INPUTS:
;	options - String containg the wget options
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;	None.
;
; OPTIONAL OUTPUTS:
;       response - Vector of strings containing the 
;                  wget response.
;       cmd      - String containing the wget command line.
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
;       Simple quote character is not allowed 
;       in url argument, use double quotes 
;       if required.
;			
; CALL:
;       wget
;
; EXAMPLE:
;       None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

quote=string(39b)

if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'wget,url,response, $'
   print,'     options=options, $'
   print,'     cmd=cmd'
   return
endif

cmd='wget '
if (keyword_set(options)) then cmd=cmd+options+' '

cmd=cmd+quote+url+quote
spawn,cmd,response

return
END
; =============================================================
; =============================================================
PRO download,urls, $
             options=options, $
             target_directory=target_directory, $
             cmd=cmd,QUIET=QUIET

;+
; NAME:
;       download
;
; PURPOSE:
; 	Download one or more files
;       using wget software.
;
; CATEGORY:
;	Network
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	download,urls
;
; INPUTS:
;       urls - Scalar or Vector of strings
;              containing the urls of 
;              files to download.
;	
; OPTIONAL INPUTS:
;	options          - String containg wget options.
;       target_directory - Directory where file(s) must
;                          be saved.
;                          Default is current one.
;
; KEYWORD PARAMETERS:
;       /QUIET - wget quiet mode.
;
; OUTPUTS:
;	None.
;
; OPTIONAL OUTPUTS:
;       cmd - Scalar or Vector of strings
;             containing the wget command lines.
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
;       Simple quote character is not allowed 
;       in urls argument, use double quotes 
;       if required.
;			
; CALL:
;       wget
;
; EXAMPLE:
;       None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

CD,current=current_directory
cmd=''
if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'download_file,urls, $'
   print,'              options=options, $'
   print,'              target_directory=target_directory ,$'
   print,'              cmd=cmd,/QUIET'
   return
endif
QUIET=keyword_set(QUIET)

if (n_elements(urls) eq 0) then begin
   message,/CONT,'Empty urls!'
   return
endif

if not (keyword_set(options)) then options='' $
else options=strtrim(options[0],2)+' '

if not (keyword_set(target_directory)) then target_directory=current_directory
options=options+'-P '+target_directory

if (QUIET) then options=options+' -q'

nfiles=n_elements(urls)
cmd=strarr(nfiles)
for i=0l,nfiles-1l do begin
   wget,urls[i],response, $
        options=options, $
        cmd=cmd_i
   cmd[i]=cmd_i
endfor

return
END
; =============================================================
; =============================================================
FUNCTION file_ext,file

; Returns the extension of a given file
; Written by X.Bonnin (LESIA)

if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'ext=file_ext(file)'
   return,''
endif

basename=file_basename(file)
ext = strsplit(basename,'.',/EXTRACT)
ext = ext[n_elements(ext)-1l]

return,ext
END
; =============================================================
; =============================================================
FUNCTION read_image,image_file, $
                    target_directory=target_directory, $
                    local_file=local_file, $
                    REMOVE_FILE=REMOVE_FILE

;+
; NAME:
;       read_image
;
; PURPOSE:
; 	Reads an image file (jpg or png format accepted).
;
; CATEGORY:
;	I/O
;
; GROUP:
;	None.
;
; CALLING SEQUENCE:
;	array=read_image(image_file)
;
; INPUTS:
;       image_file - String containing the path to the image file to read.
;                    If the filepath is a HTTP or FTP url, then 
;                    the image file will be automatically downloaded
;                    before reading.
;	
; OPTIONAL INPUTS:
;       target_directory - Directory where the image file must
;                          be saved if a downloading is required.
;                          Default is current one.
;
; KEYWORD PARAMETERS:
;       /REMOVE_FILE - Delete the image file after reading.
;                      (Only works if a downloading is required.)
;
; OUTPUTS:
;	array - 2d array of byte type containing the loaded image.
;
; OPTIONAL OUTPUTS:
;       local_file - Path to the local file if a downloading
;                    has been done.
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
;       Simple quote character is not allowed 
;       in url, use double quotes 
;       if required.
;			
; CALL:
;       wget
;
; EXAMPLE:
;       None.		
;
; MODIFICATION HISTORY:
;	Written by X.Bonnin (LESIA).
;				
;-

CD,current=current_directory
sep=path_sep()
local_file=''

if (n_params() lt 1) then begin
   message,/INFO,'Call is:'
   print,'array=read_image(image_file, $'
   print,'                 target_directory=target_directory, $'
   print,'                 local_file=local_file, $'
   print,'                 /REMOVE_FILE)'
   return,0
endif
REMOVE_FILE=keyword_set(REMOVE_FILE)
if not (keyword_set(target_directory)) then target_directory=current_directory

distant_flag=(strmatch(image_file,'http*')) or (strmatch(image_file,'ftp*'))
if (distant_flag) then begin
   download,image_file, $
            options='-nc', $
            target_directory=target_directory, $
            /QUIET
  local_file=target_directory+sep+file_basename(image_file)
endif else local_file=image_file

if not (file_test(local_file)) then message,local_file+' does not exist!'

ext=file_ext(local_file)
case ext of
   'jpg':read_jpeg,local_file,array
   'png':read_png,local_file,array
   else:begin
      message,/CONT,'This file format is not supported!'
      return,''
   end
endcase

if (distant_flag) and (REMOVE_FILE) then file_delete,local_file,/NOEXPAND_PATH 

return,array
END
