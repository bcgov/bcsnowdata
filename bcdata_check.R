# Testing the use of bcsnowdata versus getting snow data with bc data

# bcsnowdata
library(bcsnowdata)
library(bcdata)
library(dplyr)

id <- c("1C05P")
time_start <- Sys.time()
SWE_test <- get_aswe_databc(station_id = id,
                            get_year = "All",
                            parameter_id = "SWE",
                            force = TRUE,
                            ask = FALSE) 
total_time_bcsnowdata <- Sys.time() - time_start

# Try BC Data method

time_start <- Sys.time()
swe_bcdata <- bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '666b7263-6111-488c-89aa-7480031f74cd') %>%
  dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
  dplyr::filter(`DATE(UTC)` < min(swe_bcsnowdata_archive$`DATE(UTC)`)) %>%
  dplyr::full_join(bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '6789d794-c40a-4023-ac0b-0acc10d0d50f') %>%
                     select(contains(c(id, "DATE(UTC)")))) %>%
  dplyr::full_join(bcdc_get_data(record = '3a34bdd1-61b2-4687-8b55-c5db5e13ff50', resource = 'fe591e21-7ffd-45f4-b3b3-2291e4a6de15') %>%
                     select(contains(c(id, "DATE(UTC)"))))

total_time_bcdata <- Sys.time() - time_start

# Check for differences
bcsnowdata_test <- SWE_test %>%
  dplyr::select(date_utc, value) %>%
  dplyr::rename(t1 = date_utc, t2 = value)

bcdata_test <- swe_bcdata %>%
  dplyr::rename()
conames()


setdiff(names(SWE_test), names(swe_bcdata))

time_start <- Sys.time()
most_recent <- bcdc_get_data(record = '3a34bdd1-61b2-4687-8b55-c5db5e13ff50', resource = 'fe591e21-7ffd-45f4-b3b3-2291e4a6de15') %>%
  select(contains(c(id, "DATE(UTC)")))
time_mostrecent <- Sys.time() - time_start


# Get archive names
bcdata::bcdc_search("snow")
bcdc_get_data("3a34bdd1-61b2-4687-8b55-c5db5e13ff50")
# archive aswe




archive <- bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = 'f4ec0b1f-f8ba-4601-8a11-cff6b6d988a4')

# Current season SWE
bcdc_get_data('3a34bdd1-61b2-4687-8b55-c5db5e13ff50', resource = 'fe591e21-7ffd-45f4-b3b3-2291e4a6de15')
# Current season snow depth 
bcdc_get_data('3a34bdd1-61b2-4687-8b55-c5db5e13ff50', resource = 'abba1811-dd9a-4447-a297-2b5f81410abd')
# Current season precip

# Check functions
time_start <- Sys.time()
test_hourly <- get_aswe_databc(station_id = "2C09Q",
                        get_year = "All",
                        parameter = "swe",
                        timestep = "hourly")
time_total <- time_start - Sys.time()

time_start <- Sys.time()
test_daily <- get_aswe_databc(station_id = "2C09Q",
                              get_year = "All",
                              parameter = "swe",
                              timestep = "daily")
time_total <- time_start - Sys.time()

time_start <- Sys.time()
test_daily <- get_aswe_databc(station_id = "2C09Q",
                              get_year = "2022",
                              parameter = "swe",
                              timestep = "daily")
time_total <- time_start - Sys.time()

