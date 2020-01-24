# np_spss_conversion

The code here uses the data dictionary from redcap to convert the neuropsych SPSS file to a redcap interpretable csv file. 

## Redcap Info
The redcap database is separated into 10 different instruments:
* Demographics
* Repeated Demographics (repeatable instrument)
* Neurology             (repeatable instruemnt)
* Baseline Testing
* Neuropsych Tests      (repeatable instrument)
* Neuroreader           (repeatable instrument)
* Other
* Health                (repeatable instrument)
* Medication            (repeatable instrument)
* Psychhx               (repeatable instrument)

All instruments require a "record_id" REDCap variable to be set. Repeatable instruments additionally require "redcap_repeat_instrument" and "redcap_repeat_instance" variables to be assigned values. The "redcap_repeat_instrument" is the instrument name and "redcap_repeat_instance" is the timepoint number the data was acquired.

## Conversion Methodolgy
* The redcap data dictionary is assumed to have all the variables of interest we want. If something is not in the data dictionary that we want, we have to update it. If the data dictionary is updated indpendently on redcap, the data dictionary must be downloaded and saved over the "clinical_data_dictionary_latest.csv" file before running the "convert_spss_to_redcap.R" script. Unique SPSS variables can be acquired from the data csv file.
* Redcap_repeat_instances are determined from the variable name in SPSS.
  * _BL = 1
  * _1 = 2
  * _2 = 3
  * _3 = 4
  * and so on
* These are the timepoints written for each instrument:
  * Demographics = only NA instances (this should be the only one with values)
  * Neurology = all
    * SPSS variables assinged to the neurology instrument with no timepoint in their SPSS variable name had "_BL" appended to their name to make for easier processing
  * Baseline Testing = only NA instance (this should be the only one with values)
  * Neuropsych Tests = all (there should be no NA instances)
    * Many of the profile variables (example: wordlist_profile_lu_1.5SD) had "_BL" appended to their name to make for easier processing
  * Neuroreader = all (there should be no NA instances)
    * SPSS variables assigned to the neuroreader instrument with no timepoitn in their SPSS varialbe name had "_BL" append to their name to make for easier processing. There was only one variable that fit this description.
  * Other = only NA instance (this should be the only one with values)
  * Health = all (there should be no NA instances)
  * Medication = all (there should be no NA instances)
  * Psychhx = all (there should be no NA instances)
* NpsyDate_1, Date_BL, np_date_2, np_date_3 are assumed to code the same information at different timepoints. NpsyDate_1 and Date_BL are mapped to np_date_1 and np_date_BL, respectively, to match the other two. This is the variable used for the neuropsyh date.
* Other mappings are in variable *name_mapper* variable.
* All forms parsed from the SPSS file are assigned as "Complete" in redcap. Other possible values are "Incomplete" or "Unverified".

## Independently Modifiying REDCap data dictionary
When idependently modifiying the redcap data dictionary to match newly added SPSS variables follow these naming scheme guidelines for the SPSS variables:
* If the SPSS variables correspond to a non-repeatable instrument, do **not** add a timepoint to the end of the SPSS variable name. Examples of timepoints are "_1", "_2", and so on.
* If the SPSS variables correspond to a repeatable instrument, indicate the timepoint for the variable by appending "_BL", "_1", "_2", and so on the the end of the base SPSS variable name. Keep the base SPSS variable name consistent across timepoints. If the variable is restricted to certain values, make sure the restrictions are the same in SPSS across timepoints.

## Definitions
A **repeatable instrument** is a form on redcap that can be acquired at multiple instances. The differenct instances are indicated by the redcap_repeat_instance variable.
