#! /bin/csh

# PURPOSE:
#   Set up the MASER-IDL env. variable
#
# USAGE:
#   source setup_maser_env.csh
#
# MODIFICATION HISTORY:
#   Written by X.Bonnin (LESIA, CNRS), 15-DEC-2015

set currentdir=`pwd`
set ARGS=($_)
set scriptpath=`dirname $ARGS[2]`
cd $scriptpath/..
setenv MASER_IDL_HOME_DIR `pwd`

setenv IDL_PATH +$MASER_IDL_HOME_DIR/maser:"$IDL_PATH"
cd $currentdir