rm(list = ls())
library(bcsnowdata)

#bcdata::bcdc_search("snow")

time_start <- Sys.time()
test_3 <- get_aswe_databc(station_id = "3B26P",
                                get_year = "All",
                                parameter = "swe",
                                timestep = "hourly")
time <- Sys.time() - time_start

# test over all
# swe - hourly: OK
# swe - daily: OK
# snow_depth - hourly: OK
# snow_depth - daily: OK
# precipitation - hourly: OK
# precipitation: Daily: OK
# temperature- hourly: OK
# "3B26P"

test_multiple <- c("2F05P", "2F08P", "2F18P", "2F19P")
time_start <- Sys.time()
test_4 <- get_aswe_databc(station_id = test_multiple,
                          get_year = "2022",
                          parameter = "temperature",
                          timestep = "hourly")
time <- Sys.time() - time_start

test_function <- function(station_id, get_year, parameter, timestep) {
  print(paste0(station_id, " I = ", match(station_id, snow_auto_location()$LOCATION_ID)))
  get_aswe_databc(station_id, get_year, parameter, timestep)
}
time_start <- Sys.time()
t_all <- lapply(snow_auto_location()$LOCATION_ID, test_function,
  get_year = "All",
  parameter = "swe",
  timestep = "daily")
time <- Sys.time() - time_start


manual_test <- get_manual_swe(station_id = snow_manual_location()$LOCATION_ID[7],
                              get_year = "All",
                              survey_period = "All")

test_function <- function(station_id, get_year, survey_period) {
  print(paste0(station_id, " I = ", match(station_id, snow_manual_location()$LOCATION_ID)))
  get_manual_swe(station_id, get_year, survey_period)
}
time_start <- Sys.time()
t_all <- lapply(snow_manual_location()$LOCATION_ID, test_function,
                get_year = "All",
                survey_period = "All")
time <- Sys.time() - time_start
 

# Test the get data function

test_bchydro_new <- get_snow(id = "2C09Q",
                             get_year = "All",
                             parameter = "swe",
                             timestep = "hourly")

test_BC <- test_bchydro_new$aswe

manual_data <- bcsnowdata::snow_manual_location() 

manual_test <- get_manual_swe(station_id = "2C04",
                              survey_period = "All",
                              get_year = "All")