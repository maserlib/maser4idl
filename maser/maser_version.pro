; maser4idl version information

defsysv, '!MASER4IDL_VERSION', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_VERSION', '0.6.1'

defsysv, '!MASER4IDL_RELEASE_DATE', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_RELEASE_DATE', '2017-05-12'

defsysv, '!MASER4IDL_CHANGES', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_CHANGES', ['0.6.1: Update rcdf.py | add version.pro']

defsysv, '!MASER4IDL_AUTHORS', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_AUTHORS', ['X. Bonnin', 'Q.N Nguyen', 'B. Cecconi']

END