# np_spss_conversion

The code here uses the data dictionary from redcap to convert the neuropsych SPSS file to a redcap interpretable csv file. 

## Redcap Info
The redcap database is separated into 7 different instruments:
* Demographics
* Repeated Demographics
* Neurology
* Baseline Testing
* Neuropsych Tests  (repeatable instrument)
* Neuroreader       (repeatable instrument)
* Other

We can change this if we want.

## Conversion Methodolgy
* The redcap data dictionary is assumed to have all the variables of interest we want. If something is not in the data dictionary that we want, we have to update it. Unique SPSS variables can be acquired from the data csv file.
* Redcap_repeat_instances are determined from the variable name in SPSS.
  * _BL = 1
  * _1 = 2
  * _2 = 3
  * _3 = 4
  * and so on
* These are the timepoints written for each instrument:
  * Demographics = only NA instances (this should be the only one with values)
  * Neurology = all
    * Variables with no timepoint in their SPSS variable had "_BL" appended to their name to make for easier processing
  * Baseline Testing = only NA instance (this should be the only one with values)
  * Neuropsych Tests = all (there should be no NA instances)
    * Many of the profile variables (example: wordlist_profile_lu_1.5SD) had "_BL" appended to their name to make for easier processing
  * Neuroreader = all (there should be no NA instances)
  * Other = only NA instance (this should be the only one with values)
* NpsyDate_1, Date_BL, np_date_2, np_date_3 are assumed to code the same information at different timepoints. NpsyDate_1 and Date_BL are mapped to np_date_1 and np_date_BL, respectively, to match the other two. This is the variable used for the neuropsyh date.
* Other mappings are in variable *name_mapper*.
* All forms parsed from the SPSS file are assigned as "Complete" in redcap. Other possible values are "Incomplete" or "Unverified". 

## Definitions
A **repeatable instrument** is a form on redcap that can be acquired at multiple instances. The differenct instances are indicated by the redcap_repeat_instance variable.
