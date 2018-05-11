#! /bin/csh

# PURPOSE:
#   Set up the MASER4IDL env. variable
#
# USAGE:
#   source setup_maser_env.csh
#
# MODIFICATION HISTORY:
#   Written by X.Bonnin (LESIA, CNRS), 15-DEC-2015
#
#   Updated by X.Bonnin, 11-MAY-2018: - Add called condition to get script dirname

set called=($_)

if ( "$called" != "" ) then  ### called by source
   set script_fn=`readlink -f $called[2]`
else                         ### called by direct excution of the script
   set script_fn=`readlink -f $0`
endif
set script_dir=`dirname $script_fn`
setenv MASER_IDL_HOME_DIR `cd $script_dir/.. && pwd`

setenv IDL_PATH +$MASER_IDL_HOME_DIR/maser:"$IDL_PATH"
setenv IDL_PATH +$MASER_IDL_HOME_DIR/scripts:"$IDL_PATH"
cd $currentdir