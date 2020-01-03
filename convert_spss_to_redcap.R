library(tidyverse)

# find out instances numbers for SPSS variables not following the number convention
# manually assign the numbers to these variables
# if I cannot determine the number, go to Scott

# non-repeated instruments do not have redcap_repeat_instrument or redcap_repeat_instance

prepare_instrument_data <- function(instrument, data) {
  cat("Instrument: ", instrument, "\n")

  if (is.na(instrument)) {

    out <- data

  } else if (instrument == "demographics") {

    out <- data %>%
      mutate(redcap_repeat_instrument = instrument) %>%
      select(record_id, everything()) %>%
      select(-redcap_repeat_instrument, -redcap_repeat_instance)

  } else if (instrument == "repeated_demographics") {

    out <- data %>%
      mutate(redcap_repeat_instrument = instrument) %>%
      select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything())

  } else if (instrument == "neurology") {

    out <- data %>%
      mutate(redcap_repeat_instrument = instrument) %>%
      select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything())

  } else if (instrument == "baseline_testing") {
    
    out <- data %>%
      mutate(redcap_repeat_instrument = "") %>%
      select(record_id, everything()) %>%
      select(-redcap_repeat_instrument, -redcap_repeat_instance)

  } else if (instrument == "neuropsych_tests") {

    out <- data %>%
      mutate(redcap_repeat_instrument = instrument) %>%
      select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything()) %>%
      left_join(has_subtests, by = c("record_id", "redcap_repeat_instance"))

  } else if (instrument == "neuroreader") {

    out <- data %>%
      mutate(redcap_repeat_instrument = instrument) %>%
      select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything())

  } else if (instrument == "other") {

    out <- data %>%
      mutate(redcap_repeat_instrument = "") %>%
      select(record_id, everything()) %>%
      select(-redcap_repeat_instrument, -redcap_repeat_instance)

  } else {

    stop("Unknown instrument: ", instrument)

  }

  if (!is.na(instrument)) {
    out[paste0(instrument, "_complete")] = 2
  }

  return(out)
}
  

data <- read_tsv("/home/heffjos/Documents/Work/lumfleet/test.tsv")

record_ids <- data %>%
  select(MRN) %>%
  distinct() %>%
  mutate(record_id = 1:n())

data <- data %>%
  left_join(record_ids, by = "MRN")

name_mapper = c(
  "filter_$" = "filter_anc",

  # neuropsych_tests
  "cognitive_change" = "cognitive_change_1",
  "depression_label" = "depression_label_1",
  "depression_label3" = "depression_label_3",
  "HVLT_MemProfile" = "hvlt_memprofile_1",
  "HVLTMemProfile2" = "hvlt_memprofile_2",
  "HVLTMemProfile2_MixedExplained" = "hvlt_memprofile_mixedexplained_2",
  "HVLT_MemProfile_MixedExplained" = "hvlt_memprofile_mixedexplained_1",
  "letfluency_ver" = "letfluency_ver_1",
  "trails_ver" = "trails_ver_1",
  "wcst_ver" = "wcst_ver_1",
  "NpsyDate_1" = "np_date_1",
  "Date_BL" = "np_date_BL",
  "moca_1_date" = "moca_date_1",
  "WordListMemProfile2" = "WordListMemProfile_2",
  "wratread_ss_MissingData" = "wratread_ss_MissingData_BL",
  "Amnestic_NPsyRating" = "Amnestic_NPsyRating_BL",
  "MCIType_WMLoad" = "MCIType_WMLoad_BL",
  # some profiles for something with neuropsych I think
  "wordlist_profile_lu_1.5SD" = "wordlist_profile_lu_1d5SD_BL",
  "LM_profile_lu_1.5SD" = "LM_profile_lu_1d5SD_BL",
  "VR_profile_lu_1.5SD" = "VR_profile_lu_1d5SD_BL",
  "memory_profile_1.5SD" = "memory_profile_1d5SD_BL",
  "memory_profile_1.5SD_luLATEST" = "memory_profile_1d5SD_luLATEST_BL",
  "wordlist_profile_lu_1SD" = "wordlist_profile_lu_1SD_BL",
  "wordlist_profile_petersenORIGINAL" = "wordlist_profile_petersenORIGINAL_BL",
  "wordlist_profile_petersenwithrecognition" = "wordlist_profile_petersenwithrecognition_BL",
  "LM_profile_lu_1SD" = "LM_profile_lu_1SD_BL",
  "VR_profile_lu_1SD" = "VR_profile_lu_1SD_BL",
  "memory_profile_1SD_luLATEST" = "memory_profile_1SD_luLATEST_BL",
  "memory_profile_lu_1SD" = "memory_profile_lu_1SD_BL",

  # neurology
  "VascularRisks_Burden" = "VascularRisks_Burden_BL",
  "PPA_group" = "PPA_group_BL",
  "etiology_1_NPsy" = "etiology_NPsy_1",
  "Etiology_1_Neurology" = "etiology_neurology_1",
  "etiology_1_Neurology_Explained" = "etiology_neurology_explained_1", 
  "etiology_BL_explained" = "etiology_explained_BL",
  "etiology_1_explained" = "etiology_explained_1",
  "etiology_2_explained" = "etiology_explained_2",
  "etiology_3_explained" = "etiology_explained_3",
  # below are missing a timepoint, so I added them to baseline (_BL)
  "Include_JakBondi" = "Include_JakBondi_BL", 
  "JakBondi_MCI_type" = "JakBondi_MCI_type_BL", 
  "JakBondi_MCI_AmnesticvsNonamnestic" = "JakBondi_MCI_AmnesticvsNonamnestic_BL", 
  "JakBondi_Domains" = "JakBondi_Domains_BL", 
  "PetersenMCItype" = "PetersenMCItype_BL", 
  "PetersenMCI_Domains" = "PetersenMCI_Domains_BL", 
  "Petersen_AmnesticvsNonamnestic" = "Petersen_AmnesticvsNonamnestic_BL", 
  "notes" = "notes_BL", 
  "Amnestic" = "Amnestic_BL", 
  "PetersenAmnestic" = "PetersenAmnestic_BL", 
  "Domains" = "Domains_BL", 
  "PetersenDomains" = "PetersenDomains_BL", 
  "MCItype" = "MCItype_BL", 
  "frontosubcort_v_amnestic" = "frontosubcort_v_amnestic_BL", 
  "frontosubcort_v_amnestic_anc" = "frontosubcort_v_amnestic_anc_BL", 
  "original_frontosub_v_am_anc" = "original_frontosub_v_am_anc_BL", 
  "etiology_NPsy_Explained" = "etiology_NPsy_Explained_BL", 
  "neurologyvisitdate" = "neurologyvisitdate_BL", 
  "neurology_dx_old" = "neurology_dx_old_BL", 
  "etiology_anc" = "etiology_anc_BL", 
  "neurobehav_anc" = "neurobehav_anc_BL", 
  "data_entry_ambiguities" = "data_entry_ambiguities_BL", 
  "VascularRisksPresent" = "VascularRisksPresent_BL", 
  "VascularRisks_Number" = "VascularRisks_Number_BL",
  "dxdiscrepancybetweenproviders" = "dxdiscrepancybetweenproviders_BL",

  # neuroreader
  "Hippocampus_Zscore1_3groups" = "Hippocampus_Zscore1_3groups_BL")

data_dictionary_file <- "clinical_data_dictionary_latest.csv"

data_dictionary  <- read_csv(data_dictionary_file, skip = 1,
                             col_names = c("redcap", 
                                           "form_name", 
                                           "section_header", 
                                           "field_type",
                                           "field_label", 
                                           "choices", 
                                           "field_note", 
                                           "validation", 
                                           "min", 
                                           "max", 
                                           "identifier", 
                                           "branching_logic",
                                           "required", 
                                           "custom_alignment", 
                                           "question_number", 
                                           "matrix_group_name",
                                           "matrix_ranking", 
                                           "field_annotations"))

neuropsych_subtests <- data_dictionary %>%
  filter(form_name == "neuropsych_tests", 
         str_detect(branching_logic, '\\[.*\\] = "1"')) %>%
  mutate(subtest = str_match(branching_logic, "\\[(.*)\\]")[, 2]) %>%
  select(redcap, form_name, subtest)

data_long <- data %>%
  gather(key, value, -record_id) %>%
  mutate(key = recode(key, !!!name_mapper),
         redcap_repeat_instance = str_match(key, "_([:digit:]|[bB][lL])$")[, 2],
         redcap_repeat_instance = str_to_lower(redcap_repeat_instance),
         redcap_repeat_instance = ifelse(redcap_repeat_instance == "bl", "0", redcap_repeat_instance),
         redcap_repeat_instance = as.integer(redcap_repeat_instance) + 1,
         redcap = str_remove(key, "_([:digit:]|[bB][lL])$"),
         redcap = str_to_lower(redcap)) %>%
  left_join(data_dictionary %>% select(redcap, form_name), by = "redcap")

no_values <- data_long %>%
  select(key, redcap_repeat_instance, redcap, form_name) %>%
  distinct()

has_subtests <- data_long %>%
  filter(form_name == "neuropsych_tests", !is.na(redcap_repeat_instance)) %>%
  inner_join(neuropsych_subtests, by = c("redcap", "form_name")) %>%
  group_by(record_id, subtest, redcap_repeat_instance) %>%
  summarize(has = as.integer(any(!is.na(value)))) %>%
  ungroup() %>%
  spread(subtest, has)

# compare_counts
counts_all <- data_long %>%
  select(form_name, redcap_repeat_instance, redcap, key) %>%
  distinct() %>%
  count(form_name, redcap_repeat_instance, name = "all") %>%
  filter(!is.na(form_name))

counts_values <- data_long %>%
  filter(!is.na(value)) %>%
  select(form_name, redcap_repeat_instance, redcap, key) %>%
  distinct() %>%
  count(form_name, redcap_repeat_instance, name = "has_value") %>%
  filter(!is.na(form_name))

counts_participants <- data_long %>% 
  filter(!is.na(value)) %>% 
  select(record_id, form_name, redcap_repeat_instance) %>% 
  distinct() %>% 
  count(form_name, redcap_repeat_instance, name = "participants_with_values")

# this is important; show this variable to people
# missing values in has_values mean zero of those variables were filed for that instance
# displays the number of variables for that instance and form
# displays the variables with values for that instance and form
compare_counts <- counts_all %>%
  left_join(counts_values, by = c("form_name", "redcap_repeat_instance")) %>%
  left_join(counts_participants, by = c("form_name", "redcap_repeat_instance")) %>%
  mutate(has_value = ifelse(is.na(has_value), 0, has_value),
         participants_with_values = ifelse(is.na(participants_with_values), 0, participants_with_values))

write_csv(compare_counts, "info_compare_counts.csv")

# write each form_name out individually
nested_form_names <- data_long %>%
  select(-key) %>%
  nest_legacy(-form_name) %>%
  mutate(data = map(data, spread, redcap, value),
         data = map(data, filter_at, vars(-record_id, -redcap_repeat_instance), any_vars(!is.na(.))),
         prepared_data = map2(form_name, data, prepare_instrument_data))

# write out instruments
nested_form_names %>%
  mutate(file_name = paste0("tp-all_", form_name, ".csv"),
         prepared_data = walk2(prepared_data, file_name, write_csv, na = ""))

# write out all instruments in one giant csv file
nested_form_names %>%
  filter(!is.na(form_name)) %>%
  pull(prepared_data) %>%
  bind_rows() %>%
  write_csv("all_data.csv", na = "")
  

# get variables with missing instances
redcap_with_missing_instances <- data_long %>%
  filter(!is.na(form_name), is.na(redcap_repeat_instance)) %>%
  select(redcap, key, form_name, redcap_repeat_instance) %>%
  distinct()    

# write out variables missing from redcap
missing_from_redcap <- data_long %>%
  filter(is.na(form_name)) %>%
  select(key, redcap, redcap_repeat_instance, form_name) %>%
  distinct()

write_csv(missing_from_redcap, "info_missing_from_redcap.csv")

# write out extra varialbes in redcap
extra_in_redcap <- data_dictionary %>%
  anti_join(data_long, by = "redcap") %>%
  select(redcap, form_name)

write_csv(extra_in_redcap, "info_extra_in_redcap.csv")

# write out mapped variables information
name_mapper_df <- tibble(original_key = names(name_mapper), new_key = unname(name_mapper))

name_mapper_df <- name_mapper_df %>%
  left_join(no_values, by = c("new_key" = "key"))
  
# demographics     - has multiple instances, not a repeated instrument
# neurology        - has multiple instances, not a repeated instrument
# baseline_testing - looks good
# neuropsych_tests - has baseline values, can we ignore these?
# neuroreader      - looks good
# other            - looks good
  
