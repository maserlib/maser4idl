Introduction
====================================

The MASER IDL library (MASER-IDL) contains IDL routines to
deal with services and data provided in the framework
of the MASER portal.

For more information about MASER, please visit: http://maser.lesia.obspm.fr/

Installation
====================================

System Requirements
--------------------------------

In order to install MASER-IDL, make sure to have IDL 8.3 or higher
available on your system.

The following IDL routine libraries shall be installed and callable from IDL:

  * `CDAWlib`

.. _CDAWlib: http://spdf.gsfc.nasa.gov/CDAWlib.html

MASER-IDL has been successfuly tested on the following Operating Systems:

  * Mac OS X 10.10, 10.11
  * Debian Jessie 8.2

In order to use the "cdf" routines, the NASA CDF software
distribution shall be installed and configured on your system.
Especially, make sure that the directory containing the CDF binary
executables is on your $PATH, and the $CDF_LIB env. var. is set.
Visit http://cdf.gsfc.nasa.gov/ to learn more about the CDF format and software.

How to get MASER-IDL
----------------------------------

To download MASER-IDL, enter the following command from a terminal:

::

    git clone git://git.renater.fr/maser/maser-idl.git

Make sure to have Git (https://git-scm.com/) installed on your system.

If everything goes right, you should have a new local "maser-idl" directory created on your disk.

How to set up MASER-IDL
--------------------------------------

To set up the library on your system, enter the following
command from the "maser-idl" directory:

::

    bash scripts/setup_maser-idl.sh

or

::

    tcsh scripts/setup_maser-idl.csh

This will add the MASER-IDL routine directories into your $IDL_PATH env. variable.

If you have an issue during installation, please read the "Troubleshooting" section for help.

How to run MASER-IDL
-------------------------------------

From IDL, you can compile all of the MASER-IDL routines calling
the *compile_maser-idl.pro* IDL batch file in the scripts/ sub-directory:

::

    @compile_maser-idl

Be sure that all of the required external routine libraries are already compiled.

Overview
====================================

The MASER-IDL library is organized as follows:

    maser/
        data/
            stereo/
                Module to handle the STEREO NASA mission data.
            wind/
                Module to handle the Wind  NASA mission data.
        services/
            helio/
                Module to get and plot the HELIO Virtual Observatory data.
        utils/
            cdf/
                Module to handle the NASA Common Data Format (CDF).

Each module is described in details in the next sections.

In order to work, MASER-IDL relies on additional files and directories:

    bin/
        Used to store the MASER-IDL binary files

    data/
        Directory containing support data

    doc/
        Contains the MASER-IDL documentation

    scripts/
        Script files to set up and run the MASER-IDL library


