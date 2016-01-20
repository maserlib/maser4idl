;
; PURPOSE:
; IDL Batch file to compile of the routines in the MASER-IDL directory.
;
; Be sure that the MASER_IDL_HOME_DIR/maser env. variable is included
; in your $PATH and the CDAWlib is compiled before running this script.
;
; USAGE:
;   idl>@compile_maser-idl
;
; MODIFICATION HISTORY:
;   Written by X.Bonnin (LESIA, CNRS), 15-DEC-2015

@compile_maser-utils
@compile_maser-helio
@compile_maser-wind