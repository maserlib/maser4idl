; maser4idl version information batch file

defsysv, '!MASER4IDL_VERSION', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_VERSION', '0.1.8'

defsysv, '!MASER4IDL_RELEASE_DATE', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_RELEASE_DATE', '2022-01-25'

defsysv, '!MASER4IDL_CHANGES', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_CHANGES', ['0.1.8: Update rcdf.py']

defsysv, '!MASER4IDL_AUTHORS', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_AUTHORS', ['X. Bonnin', 'Q.N Nguyen', 'B. Cecconi']