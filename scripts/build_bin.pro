;
; PURPOSE:
; IDL Batch file to build a binary file containing all of
; compiled MASER-IDL routines.
;
; The resulting binary file "maser4idl.sav" will be saved in the /bin directory
;
; The content of the "maser4idl.sav" file can be loaded from IDL, using the "RESTORE" command.
;
; USAGE:
;
;
; MODIFICATION HISTORY:
;

maser_home_dir = getenv("MASER_IDL_HOME_DIR")
if maser_home_dir eq '' then message,'$MASER_IDL_HOME_DIR is not defined!'
maser_bin_dir = maser_home_dir + path_sep() + 'bin'

if not file_test(maser_bin_dir, /DIR) then file_mkdir, maser_bin_dir

@compile_maser4idl

; Binary file containing maser-idl library routines
binfile = maser_bin_dir+path_sep()+'maser4idl.sav'
save, /ROUTINES, filename=binfile, $
        description='maser4idl library routines', $
        /VERBOSE, /EMBEDDED, /COMPRESS
if file_test(binfile) then print, binfile+' saved' else message,binfile+' has not been created correctly'

