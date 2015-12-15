#! /bin/bash

# PURPOSE:
#   Set up the MASER-IDL env. variable
#
# USAGE:
#   source setup_maser-idl_env.sh
#
# MODIFICATION HISTORY:
#   Written by X.Bonnin (LESIA, CNRS), 15-DEC-2015

currentdir=`pwd
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $scriptdir/..
export MASER_IDL_HOME_DIR=`pwd`

export IDL_PATH=+$MASER_IDL_HOME_DIR/maser:"$IDL_PATH"

cd $currentdir