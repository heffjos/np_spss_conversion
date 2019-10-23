library(tidyverse)
library(readxl)

name_mapper = c(
  "filter_$" = "filter_anc",

  #demographics
  "lang_sec_BL" = "lang_sec_BL_BL",
  "lang_first_BL" = "lang_first_BL_BL",
  "lang_fluency_BL" = "lang_fluency_BL_BL",

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
  "Hippocampus_Zscore1_3groups" = "Hippocampus_Zscore1_3groups_BL",
  "CR_BtwMeasureVariability" = "CR_BtwMeasureVariability_BL")

variable_view <- read_csv("./variable_view.csv",
                          col_names = c("key",
                                        "value_type",
                                        "x1",
                                        "x2",
                                        "field_description",
                                        "possible_values",
                                        "x3",
                                        "x4",
                                        "x5",
                                        "variable_type",
                                        "x6"))

variables_to_keep <- str_subset(names(variable_view), "^x[:digit:]$", negate = TRUE)
variable_view <- variable_view[ , variables_to_keep]

# variable_values processing
variable_values <- read_excel("./variable_values.xls",
                              col_names = c("key", "value", "label"),
                              col_types = c("text", "text", "text"),
                              skip = 2)

variable_values <- variable_values %>%
  fill(key) %>%
  mutate(value = as.numeric(value),
         key = recode(key, !!!name_mapper),
         redcap_repeat_instance = str_match(key, "_([:digit:]|[bB][lL])$")[, 2],
         redcap_repeat_instance = str_to_lower(redcap_repeat_instance),
         redcap_repeat_instance = ifelse(redcap_repeat_instance == "bl", "0", redcap_repeat_instance),
         redcap_repeat_instance = as.integer(redcap_repeat_instance) + 1,
         redcap_repeat_instance = ifelse(is.na(redcap_repeat_instance), 0, redcap_repeat_instance),
         redcap_repeat_instance = ordered(redcap_repeat_instance, c(2, 1, 3, 4, 0)),
         redcap = str_remove(key, "_([:digit:]|[bB][lL])$"),
         redcap = str_to_lower(redcap))

all_equal <- variable_values %>%
  group_by(key) %>%
  summarize(all_equal = all(first(value) == value), 
            redcap = first(redcap), 
            n_choices = n()) %>%
  ungroup() %>%
  filter(all_equal, n_choices > 1)

max_choices <- variable_values %>%
  add_count(key, name = "n_choices") %>%
  group_by(redcap) %>%
  filter(n_choices == max(n_choices)) %>%
  ungroup()

chosen_variable_values <- variable_values %>%
  group_by(redcap) %>%
  filter(redcap_repeat_instance == min(redcap_repeat_instance)) %>%
  summarize(new_choices = str_c(value, ", ", label, collapse = " | ")) %>%
  mutate(new_choices = str_replace(new_choices, "^0, [Yy]es \\| 1, [Nn]o$", "0, No | 1, Yes"),
         new_choices = str_replace(new_choices, "^0, [Nn]o \\| 1, [Yy]es$", "0, No | 1, Yes"),
         new_field_type = ifelse(new_choices == "0, No | 1, Yes", "yesno", "radio"))
  

# data dictionary processing
data_dictionary_file <- "clinical_data_dictionary_latest.csv"

data_dictionary <- read_csv(data_dictionary_file)
original_dictionary_header <- names(data_dictionary)
new_header_names = c("redcap", 
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
                     "field_annotations")
names(data_dictionary) <- new_header_names
  
data_long <- variable_view %>%
  mutate(key = recode(key, !!!name_mapper),
         redcap_repeat_instance = str_match(key, "_([:digit:]|[bB][lL])$")[, 2],
         redcap_repeat_instance = str_to_lower(redcap_repeat_instance),
         redcap_repeat_instance = ifelse(redcap_repeat_instance == "bl", "0", redcap_repeat_instance),
         redcap_repeat_instance = as.integer(redcap_repeat_instance) + 1,
         redcap = str_remove(key, "_([:digit:]|[bB][lL])$"),
         redcap = str_to_lower(redcap)) %>%
  left_join(data_dictionary %>% select(redcap, form_name), by = "redcap")

correct_field_type <- data_long %>%
  select(redcap, value_type) %>%
  distinct() %>%
  mutate(generic_field_type = case_when(value_type == "Date" ~ "text",
                                        value_type == "Numeric" ~ "text",
                                        value_type == "Restricted Numeric" ~ "text",
                                        value_type == "String" ~ "text",
                                        TRUE ~ NA_character_),
         new_validation = case_when(value_type == "Date" ~ "date_ymd",
                                    value_type == "Numeric" ~ "number",
                                    value_type == "Restricted Numeric" ~ "number",
                                    TRUE ~ NA_character_))
    
dictionary_merged <- data_dictionary %>%
  left_join(correct_field_type, by = "redcap") %>%
  mutate(new_validation = ifelse(generic_field_type == "text" & field_type == "text",
                                 new_validation,
                                 NA_character_),
         new_validation = ifelse(!is.na(validation), validation, new_validation)) %>%
  left_join(chosen_variable_values, by = "redcap") %>%
  mutate(new_field_type = ifelse(is.na(new_field_type), field_type, new_field_type),
         new_field_type = ifelse(new_field_type == "radio" 
                                 & !(field_type %in% c("radio", "yesno", "text")),
                                 field_type, new_field_type),
         new_choices = ifelse(is.na(new_choices), choices, new_choices),
         new_choices = ifelse(new_field_type == "yesno", NA_character_, new_choices),
         new_validation = ifelse(new_field_type == "text", new_validation, NA_character_))

compare_dictionary <- dictionary_merged %>% 
  select(redcap, 
         form_name,
         field_type, 
         new_field_type, 
         validation, 
         new_validation, 
         choices, 
         new_choices)

compare_dictionary %>%
  write_csv("info_compare_dictionary.csv", na = "")

out_data_dictionary <- dictionary_merged %>%
  mutate(validation = new_validation, field_type = new_field_type, choices = new_choices) %>%
  select(new_header_names)
names(out_data_dictionary) <- original_dictionary_header
write_csv(out_data_dictionary, "clinical_modified_dictionary.csv", na = "") 

# get missing variables
missing_from_redcap <- data_long %>%
  anti_join(data_dictionary %>% select(redcap, form_name), by = "redcap")

missing_from_spss <- data_dictionary %>%
  anti_join(data_long, by = "redcap")

# write out mapped info here
name_mapper_df <- tibble(original_key = names(name_mapper), new_key = unname(name_mapper))

name_mapper_df <- name_mapper_df %>%
  left_join(data_long, by = c("new_key" = "key")) %>%
  select(-value_type, -possible_values, -variable_type) %>%
  arrange(form_name, redcap_repeat_instance)

write_csv(name_mapper_df, "info_name_mapper.csv", na = "")


