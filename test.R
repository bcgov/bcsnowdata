library(dplyr)
library(bcsnowdata)

test_aswe <- get_aswe_databc(station_id = snow_auto_location()$LOCATION_ID[10],
                                get_year = "All",
                                parameter = "snow_depth",
                                timestep = "hourly")

# test over all
# swe - hourly: OK
# swe - daily: OK
# snow_depth - hourly: OK
# snow_depth - daily:

test_function <- function(station_id, get_year, parameter, timestep) {
  print(paste0(station_id, " I = ", match(station_id, snow_auto_location()$LOCATION_ID)))
  get_aswe_databc(station_id, get_year, parameter, timestep)
}

lapply(snow_auto_location()$LOCATION_ID, test_function,
  get_year = "All",
  parameter = "snow_depth",
  timestep = "daily")

match("1D09P", snow_auto_location()$LOCATION_ID)

manual_test <- get_manual_swe(station_id = snow_manual_location()$LOCATION_ID[7],
                              get_year = "All",
                              survey_period = "All")

lapply(snow_auto_location()$LOCATION_ID, get_aswe_databc,
       get_year = "All",
       parameter = "swe",
       timestep = "hourly")
 

# Test the get data function

test_bchydro_new <- get_snow(id = "2C09Q",
                             get_year = "All",
                             parameter = "swe",
                             timestep = "hourly")

test_BC <- test_bchydro_new$aswe