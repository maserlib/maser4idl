The *utils/cdf* module
====================================

The *utils/cdf* module contains the following IDL programs:

- *make_cdf.pro*
- *rcdf.pro*

For more information about the CDF format, please visit http://cdf.gsfc.nasa.gov/.

The *make_cdf* program
-------------------------------------------

The *make_cdf* procedure allows users to produce an CDF format file, from
a list of given zVariables and attributes, and providing the corresponding "master" CDF file.

The calling sequence
````````````````````````````
The full calling sequence of *make_cdf* is:

::

    make_cdf,master_cdf,output_cdf,variables,vattributes=vattributes,gattributes=gattributes,/VERBOSE

, where:

master_cdf
    is the path to the master CDF file to use

output_cdf
    is the path of the output CDF file to create

variables
    is a IDL structure containing the zVariables to be updated in the output CDF file

vattributes
    is an optional IDL structure containing the attribute entries for the zVariables.

gattributes
    is an optional IDL structure containing the global attribute entries

/VERBOSE
    is a boolean input keyword to activate the verbose mode

The *rcdf* program
-------------------------------------------

The *rcdf* function is a CDF format light reader.
It returns a IDL structure containing the variable data - records and attributes - of an input CDF format file.
The Global attributes can also be retrieved using a dedicated output argument.

Only zVariables data can be read.

The calling sequence
````````````````````````````
The full calling sequence of *rcdf* is:

    zVariables = rcdf(cdf_file, gatts=gattrs,/VERBOSE)

, where:

cdf_file
    is the path of the input CDF format file to read

gattrs
    can be used to return a structure containing the list of the CDF global attributes

/VERBOSE
    is a boolean input keyword to activate the verbose mode

The outputs
````````````````````````````
The *zVariables* output is a IDL structure containing one tag by zVariable.
Each tag stores a sub-structure with the following items:

id
    The index of the zVariable

datatype
    The CDF data type of zVariable

numelem
    The "Number Elements" as defined in the CDF format

recvar
    The "Record Variance" as defined in the CDF format

dimvar
    The "Dimension Variables" as defined in the CDF format

dim
    The zVariable dimension sizes

data
    The zVariable data (not returned if the zVariable has no record)

vattributes
    Structure containing the zVariable attributes entries
