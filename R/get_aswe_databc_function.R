# Copyright 2022 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# ================



#' Get BC ASWE Data Function. This function allows you to obtain data from BC ASWE sites. It retrieves this data from Data BC
#' @param station_id Define the station id you want. Can be an individual site, a string of site IDs, or all ASWE sites. Defaults to "All"; this will return a great deal of data.
#' @param get_year Define the year that you want to retrieve. Defaults to "All"
#' @param parameter Defaults to: "swe", "snow_depth", "precipitation", "temperature". Type of data you want to retrieve
#' @param timestep Whether the user wants the hourly or daily data. Choices are "hourly" or "daily"
#' @keywords Get ASWE Data
#' @importFrom magrittr %>%
#' @importFrom grDevices cm
#' @export
#' @examples \dontrun{}
get_aswe_databc <- function(station_id = "All",
                            get_year = "All",
                            parameter = c("swe", "snow_depth", "precipitation", "temperature"),
                            timestep = c("hourly", "daily")) {
  
  # Flag if the parameter input was incorrectly specified by the user
  if (all(!c("swe", "snow_depth", "precipitation", "temperature") %in% parameter)) {
    stop("Did you specify the correct parameter_id? :)", call. = FALSE)
  }
  
  # If the user wants all of the stations, 
  if (any(station_id %in% c("ALL", "all", "All"))) {
    id <- snow_auto_location()$LOCATION_ID
  } else {
    id <- station_id
  }
  
  # Does the user want daily data or hourly? Get hourly first
  if (timestep == "hourly") {
    message("Note: Hourly data only available until 2003")

    if (get_year < 2003) {
      print("No hourly data available before 2003")
    } else {
      # If the user wants to simply get the hourly current year data, grab only that 
      if (get_year == wtr_yr(Sys.Date())) {
        data <- hourly_current(parameter, id)
      } else {
        # Get the archived and current year hourly data
        data <- hourly_archive(parameter, get_year, id)
      } 
    }
  } 
  
  if (timestep == "daily") {
    # If the user wants to simply get the daily current year data, grab only that 
    if (get_year == wtr_yr(Sys.Date())) {
      data <- daily_current(parameter, id)
    } else {
      # Get the archived and current year hourly data
      data <- daily_archive(parameter, get_year, id)
    } 
  }
  
  # Need an option to get the historic daily knitted together with the hourly? ***********************
  data_final <- data %>%
    dplyr::distinct(., .keep_all = TRUE) %>% # ensure only unique entries exist
    dplyr::arrange(station_id, date_utc)
}
