#! /bin/bash

# PURPOSE:
#   Set up the MASER4IDL env. variable
#
# USAGE:
#   source load_maser4idl_env.sh
#
# MODIFICATION HISTORY:
#   Written by X.Bonnin (LESIA, CNRS), 20-MAR-2017

# get the script directory
curdir=`pwd`
pushd . > /dev/null
workdir="${BASH_SOURCE[0]:-$0}";
while([ -h "${workdir}" ]); do
    cd "`dirname "${workdir}"`"
    workdir="$(readlink "`basename "${workdir}"`")";
done
cd "`dirname "${workdir}"`" > /dev/null
workdir="`pwd`";
popd  > /dev/null

cd $workdir/..
export MASER_IDL_HOME_DIR=`pwd`

export IDL_PATH=+$MASER_IDL_HOME_DIR/maser:"$IDL_PATH"
export IDL_PATH=+$MASER_IDL_HOME_DIR/scripts:"$IDL_PATH"
cd $curdir