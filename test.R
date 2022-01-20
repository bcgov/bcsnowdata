library(dplyr)
library(bcsnowdata)

test_bchydro_new <- get_aswe_databc(station_id = "2C09Q",
                                get_year = "All",
                                parameter = "swe")

manual_test <- get_manual_swe(station_id = snow_manual_location()$LOCATION_ID[7],
                              get_year = "All",
                              survey_period = "All")

