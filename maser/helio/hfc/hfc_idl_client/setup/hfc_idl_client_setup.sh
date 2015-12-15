#! /bin/sh

# Script to load environment variables 
# required by the hfc client software.
# Must be placed in the hfc_client/setup sub-directory. 
#
# To load this script:
# >source hfc_idl_client_setup.sh
#
# X.Bonnin, 19-AUG-2013

CURRENT_DIR=`pwd`

ARGS=${BASH_SOURCE[0]}
cd `dirname $ARGS`/..
export HFC_IDL_CLIENT_DIR=`pwd`
cd $CURRENT_DIR

# Append hfc client idl library path to $IDL_PATH
IDL_PATH=$IDL_PATH:+$HFC_IDL_CLIENT_DIR/src
export IDL_PATH