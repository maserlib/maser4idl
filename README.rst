MASER User Library for IDL
==========================

About
----------------------------

The MASER IDL User library (maser4idl) contains IDL routines to deal
with services and data provided in the framework of
the MASER portal (Mesures, Analyses et Simulations d’Emissions Radio).

For more information about MASER, please visit: http://maser.lesia.obspm.fr/

Content
------------

The maser4idl directory contains the following items:

::

    bin/       directory for storing the maser-idl binary files
    doc/       directory containing the maser-idl documentation
    maser/     maser4idl source files directory
    scripts/   script files to install/compile/test/run maser-idl

    README.rst          current file
    CHANGELOG.rst       maser4idl changes log file
    requirements.txt    contains the list of python
                        modules required to run sphinx


Installation
-----------------------------------------

The maser4idl source files can be retrieved using git, by entering:

::

    git clone https://github.com/maserlib/maser4idl

Then from the maser4idl directory, enter:

::

    source scripts/load_maser4idl_env.sh, if you use (ba)sh shell

or

::

    source scripts/load_maser4idl_env.csh, if you use (t)csh shell

This will load the env. variable required to compile and execute the
IDL programs of library.

From IDL, the full library can be compiled by entering from the scripts/ sub-dir:

::

    IDL>@compile_maser4idl


**IMPORTANT**:
    * Some routines required the CDAWLib(https://spdf.gsfc.nasa.gov/CDAWlib.html) and the NASA CDF software (http://cdf.gsfc.nasa.gov) to work.
    * To generate the documentation required to install sphinx (http://www.sphinx-doc.org/en/stable/). If you have pip installed, enter *pip install sphinx*.

Usage
-----

Read the User manual for more information.



