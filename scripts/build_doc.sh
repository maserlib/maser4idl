#! /bin/bash

# PURPOSE:
# Bash script to build the MASER-IDL documentation.
# Documentation required to use sphinx Python software.
#
# USAGE:
#   bash build_doc.sh [docdir]
#
#, where [docdir] is an optional input argument providing the MASER-IDL doc. directory.
# If it is not provided, the script assumed that the docdir is in ../doc from the current directory.
#
# LAST MODIF.:
# X.Bonnin, 07-DEC-2015


if [ $# = 1 ]; then
    docdir=$1
else
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
    docdir=$workdir/../doc
fi

currentdir=`pwd`
cd $docdir

# Buid doc
sphinx-build source build

# Create pdf version
make latexpdf

cd $currentdir





