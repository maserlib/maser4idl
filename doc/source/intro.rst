Introduction
====================================

The MASER IDL library (maser4idl) contains IDL routines to
deal with services and data provided in the framework
of the MASER portal.

For more information about MASER, please visit: http://maser.lesia.obspm.fr/

Installation
====================================

System Requirements
--------------------------------

In order to install maser4idl, make sure to have IDL 8.3 or higher
available on your system.

The following IDL routine libraries shall be installed and callable from IDL:

  * `CDAWlib`

.. _CDAWlib: http://spdf.gsfc.nasa.gov/CDAWlib.html

maser4idl has been successfuly tested on the following Operating Systems:

::

  * Mac OS X 10.10, 10.11
  * Debian Jessie 8.2

.. warning::

    In order to use the "cdf" routines, the NASA CDF software
    distribution shall be installed and configured on your system.
    Especially, make sure that the directory containing the CDF binary
    executables is on your $PATH, and the $CDF_LIB env. var. is set.
    Visit http://cdf.gsfc.nasa.gov/ to learn more about the CDF format and  software.

How to get maser4idl?
----------------------------------

To download maser4idl, enter the following command from a terminal:

.. code-block:: bash

    git clone https://github.com/maserlib/maser4idl

Make sure to have Git (https://git-scm.com/) installed on your system.

If everything goes right, you should have a new local "maser4idl" directory created on your disk.

How to install maser4idl?
--------------------------------------

To set up the library on your system, enter the following
command from the "maser4idl" directory:

.. code-block:: bash

    source scripts/setup_maser-idl.sh (if (ba)sh shell)

or

.. code-block:: bash

    source scripts/setup_maser-idl.csh (if (t)csh shell)

This will add the maser4idl routine directories into the $IDL_PATH env. variable.

If you have an issue during installation, please read the "Troubleshooting" section for help.

To compile the library routines from IDL, run:

.. code-block:: IDL

    IDL>@compile_maser4idl


How to create a binary file containing all of the maser4idl compiled routines?
--------------------------------------------------------------------

To create a binary file containing all of the maser4idl compiled routines, go to the scripts/ folder and enter:

.. code-block:: bash

    bash build_bin.sh

How to build the maser4idl user manual?
---------------------------------------

To generate the maser4idl user manual, make sur that sphinx (http://www.sphinx-doc.org/en/stable/) is installed on your system.

Then from the scripts/ sub-dir, run:

.. code-block:: bash

    bash build_doc.sh

This should create the documentation in html and pdf formats in the doc/build/ directory.


Overview
====================================

The maser4idl library is organized as follows:

::

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

In order to work, maser4idl relies on additional files and directories:

    bin/
        Used to store the maser4idl binary files

    data/
        Directory containing support data

    doc/
        Contains the maser4idl documentation

    scripts/
        Script files to set up and run the maser4idl library

Support
====================================

* xavier dot bonnin at obspm dot fr
* quynh-nuh dot nguyen at obspm dot fr
* baptiste dot cecconi at obspm dot fr

