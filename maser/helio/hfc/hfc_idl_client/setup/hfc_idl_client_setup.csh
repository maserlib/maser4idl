#! /bin/tcsh
#
# Script to set environment variables 
# required by the hfc client.
# Must be placed in the hfc_client/setup sub-directory. 
#
# To load this script:
# >source hfc_idl_client_setup.csh
#
# X.Bonnin, 19-AUG-2013

# Define hfc client home directory
set CURRENT_DIR=`pwd`
set ARGS=`/usr/sbin/lsof +p $$ | grep -oE /.\*hfc_idl_client_setup.csh`
cd `dirname $ARGS`/..
setenv HFC_IDL_CLIENT_DIR `pwd`
cd $CURRENT_DIR

# Append hfc client idl source files directory to $IDL_PATH
if ($?IDL_PATH) then
    setenv IDL_PATH "$IDL_PATH":+$HFC_IDL_CLIENT_DIR/src
else
    setenv IDL_PATH "$<IDL_DEFAULT>":+$HFC_IDL_CLIENT_DIR/src
endif
