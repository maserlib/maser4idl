#!/bin/bash

# Call the build_bin.pro IDL batch file to generate a IDL binary .sav "maser4idl.sav" in the
# bin/ sub-directory
# The maser-idl.sav file contains all of the maser-idl routines compiled.

# They can be loaded in IDL using the RESTORE command as followed:
#       RESTORE,'maser-idl.sav',/VERBOSE
#
# IMPORTANT:
#   Be sure that IDL can be called from the terminal using the "idl" command.
#   You must be in the buid_bin.sh directory to run the script.
#
# X.Bonnin, 16/01/2016


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

currentdir=`pwd`
cd $workdir

source setup_maser4idl_env.sh

echo `idl -e @build_bin`

cd $currentdir

exit 0