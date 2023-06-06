; maser4idl version information batch file

defsysv, '!MASER4IDL_VERSION', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_VERSION', '0.3.1'

defsysv, '!MASER4IDL_RELEASE_DATE', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_RELEASE_DATE', '2023-06-06'

defsysv, '!MASER4IDL_CHANGES', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_CHANGES', ['0.3.1: Update rcdf.py']

defsysv, '!MASER4IDL_AUTHORS', EXISTS=flag
if not flag then defsysv, '!MASER4IDL_AUTHORS', ['X. Bonnin', 'Q.N Nguyen', 'B. Cecconi']