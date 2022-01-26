rm(list = ls())

library(dplyr)
library(bcdata)
library(bcsnowdata)

bcdata::bcdc_search("snow")

test_3 <- get_aswe_databc(station_id = snow_auto_location()$LOCATION_ID[1],
                                get_year = "All",
                                parameter = "temperature",
                                timestep = "daily")

# test over all
# swe - hourly: OK
# swe - daily: OK
# snow_depth - hourly: OK
# snow_depth - daily: OK
# precipitation - hourly: OK
# precipitation: Daily: OK
# temperature- hourly: OK

test_function <- function(station_id, get_year, parameter, timestep) {
  print(paste0(station_id, " I = ", match(station_id, snow_auto_location()$LOCATION_ID)))
  get_aswe_databc(station_id, get_year, parameter, timestep)
}

t_all <- lapply(snow_auto_location()$LOCATION_ID, test_function,
  get_year = "All",
  parameter = "temperature",
  timestep = "daily")


manual_test <- get_manual_swe(station_id = snow_manual_location()$LOCATION_ID[7],
                              get_year = "All",
                              survey_period = "All")

lapply(snow_auto_location()$LOCATION_ID, get_aswe_databc,
       get_year = "All",
       parameter = "temperature",
       timestep = "hourly")
 

# Test the get data function

test_bchydro_new <- get_snow(id = "2C09Q",
                             get_year = "All",
                             parameter = "swe",
                             timestep = "hourly")

test_BC <- test_bchydro_new$aswe