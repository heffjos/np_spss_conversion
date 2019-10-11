library(tidyverse)

# find out instances numbers for SPSS variables not following the number convention
# manually assign the numbers to these variables
# if I cannot determine the number, go to Scott

data <- read_tsv("/home/jheffernan/test.tsv")

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
  "wcst_ver" = "wcst_ver_1")

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

has_subtests <- data_long %>%
  filter(form_name == "neuropsych_tests", !is.na(redcap_repeat_instance)) %>%
  inner_join(neuropsych_subtests, by = c("redcap", "form_name")) %>%
  group_by(record_id, subtest, redcap_repeat_instance) %>%
  summarize(has = as.integer(any(!is.na(value)))) %>%
  ungroup() %>%
  spread(subtest, has)

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

# this is important; show this variable to people
# missing values in has_values mean zero of those variables were filed for that instance
compare_counts <- counts_all %>%
  left_join(counts_values, by = c("form_name", "redcap_repeat_instance"))

# write each form_name out individually
nested_form_names <- data_long %>%
  select(-key) %>%
  nest(-form_name) %>%
  mutate(data = map(data, spread, redcap, value),
         data = map(data, filter_at, vars(-record_id, -redcap_repeat_instance), any_vars(!is.na(.))))

# get variables with missing instances
redcap_with_missing_instances <- data_long %>%
  filter(!is.na(form_name), is.na(redcap_repeat_instance)) %>%
  select(redcap, key, form_name, redcap_repeat_instance) %>%
  distinct()    

# DEMOGRAPHICS (keep all instances for now)
# some variables have multiple instances and currently it is not a repeated
# instrument on redcap, but let us include all instances anyways

check_equal_repeated_demographics <- data_long %>%
  filter(form_name == "demographics", !is.na(value)) %>%
  add_count(record_id, redcap) %>%
  filter(n > 1) %>%
  group_by(record_id, redcap) %>%
  summarize(all_equal = all(value == first(value)))

unequal_repeated_demographics <- data_long %>%
  semi_join(check_equal_repeated_demographics %>% filter(!all_equal), by = c("record_id", "redcap"))

repeated_demographics <- data_long %>%
  filter(form_name == "demographics") %>%
  count(redcap, redcap_repeat_instance)

demographics <- nested_form_names$data[[2]]

all_demographics <- demographics %>%
  mutate(redcap_repeat_instrument = "demographics") %>%
  select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything())

all_demographics %>%
  write_csv("tp-all_demographics.csv", na = "")

# NEUROLOGY (keep all instances, there are some variables with missing instances)
# some variables have multiple instances and currently it is not a repeated
# instrument on redcap

# write out all form redcap variables, their instances, and whether the variable has values
data_long %>%
  filter(!form_name %in% c("neuropsych_tests", "neuroreader")) %>%
  group_by(form_name, redcap, redcap_repeat_instance) %>%
  summarize(has_value = sum(!is.na(value)), total = n()) %>%
  write_csv("instances_in_spss.csv")

data_long %>%
  filter(!form_name %in% c("neuropsych_tests", "neuroreader")) %>%
  group_by(form_name, redcap, redcap_repeat_instance) %>%
  summarize(has_value = sum(!is.na(value)), total = n()) %>%
  filter(has_value != 0) %>%
  write_csv("instances_with_values.csv")

data_long %>%
  filter(form_name == "neuropsych_tests") %>%
  group_by(form_name, redcap, redcap_repeat_instance) %>%
  summarize(has_value = sum(!is.na(value)), total = n()) %>%
  filter(has_value != 0, redcap_repeat_instance %in% c(0, 1)) %>%
  write_csv("neuropsych_with_baseline.csv")

neurology <- nested_form_names$data[[3]]

all_neurology <- neurology %>%
  mutate(redcap_repeat_instrument = "neurology") %>%
  select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything())

all_neurology %>%
  filter(!is.na(redcap_repeat_instance)) %>%
  write_csv("tp-all_neurology.csv", na = "")

# BASELINE TESTING 
#   looks fine from instances_with_values.csv
#   just filter instance == NA
baseline_testing <- nested_form_names$data[[5]]

all_baseline_testing <- baseline_testing %>%
  mutate(redcap_repeat_instrument = "baseline_testing") %>%
  select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything())

all_baseline_testing %>%
  select(-redcap_repeat_instrument) %>%
  write_csv("tp-all_baseline_testing.csv", na = "")

# NEUROPSYCH TESTS

# there should always be a timepoint for neuropsych tests
# it was decided that _BL = 1, _1 = 2, _2 = 3, and so on
# this will be used for all instruments

# write out test neurpsych_tests upload data
neuropsych_tests <- nested_form_names$data[[4]]

all_neuropsych_tests <- neuropsych_tests %>%
  filter(!is.na(redcap_repeat_instance)) %>% # there shoud always be a timepoint for neuropsych_tests
  mutate(redcap_repeat_instrument = "neuropsych_tests") %>%
  select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything()) %>%
  left_join(has_subtests, by = c("record_id", "redcap_repeat_instance"))

all_neuropsych_tests %>%
  write_csv("tp-all_neurospych_tests.csv", na = "")

# NEUROREADER
neuroreader <- nested_form_names$data[[6]]

all_neuroreader <- neuroreader %>%
  filter(!is.na(redcap_repeat_instance), redcap_repeat_instance != 0) %>%
  mutate(redcap_repeat_instrument = "neuroreader") %>%
  select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything()) %>%
  filter_at(vars(-record_id, -redcap_repeat_instrument, -redcap_repeat_instance),
            any_vars(!is.na(.)))

all_neuroreader %>%
  write_csv("tp-all_neuroreader.csv", na = "")


# OTHER
#   looks file from instances_with_values.csv
#   just filter instance == NA
other <- nested_form_names$data[[7]]

all_other <- other %>%
  mutate(redcap_repeat_instrument = "other") %>%
  select(record_id, redcap_repeat_instrument, redcap_repeat_instance, everything())

all_other %>%
  select(-redcap_repeat_instrument) %>%
  write_csv("tp-all_other.csv", na = "")

  

# demographics     - has multiple instances, not a repeated instrument
# neurology        - has multiple instances, not a repeated instrument
# baseline_testing - looks good
# neuropsych_tests - has baseline values, can we ignore these?
# neuroreader      - looks good
# other            - looks good
  




  
  
  




