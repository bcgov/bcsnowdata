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

#' Get Snow Function
#' Function that determines whether the user has specified that they want data for a manual or ASWE site 
#' @param id Define the station id you want. Can be an individual site, a string of site IDs, or all ASWE sites. Defaults to "All"; this will return a great deal of data.
#' @param get_year Define the year that you want to retrieve. Defaults to "All"
#' @param timestep Whether the user wants the hourly or daily data. Choices are "hourly" or "daily"
#' @param parameter Defaults to: "swe", "snow_depth", "precipitation", "temperature". Type of data you want to retrieve
#' @param survey_period The manual survey period a user wants. Defaults to "all"
#' @keywords Get snow data
#' @importFrom magrittr %>%
#' @export
#' @examples \dontrun{}

get_snow <- function(id = c("All", "automated", "manual"), 
                     get_year = "All",
                     survey_period = "All",
                     parameter = c("swe", "snow_depth", "precipitation", "temperature"),
                     timestep = c("hourly", "daily")) {
  
  if (any(id %in% c("All", "all", "ALL"))) {
    station <- c(snow_auto_location()$LOCATION_ID, snow_manual_location()$LOCATION_ID)
  } else if (any(id %in% c("automated", "ASWE", "aswe"))) {
    station <- snow_auto_location()$LOCATION_ID
  } else if (any(id %in% c("manual", "MANUAL", "Manual"))) {
    station <- snow_manual_location()$LOCATION_ID
  } else {
    station <- id
  }
  
  # split the stations the user has specified into ASWE or manual sites
  
  if (any(station %in% snow_auto_location()$LOCATION_ID)) {
    
    aswe_data <- get_aswe_databc(station_id = station[station %in% snow_auto_location()$LOCATION_ID],
                                 get_year = get_year,
                                 parameter = parameter,
                                 timestep = timestep)
  } else {
    aswe_data <- list()
  }
    
  # Get any manual data
  if (any(station %in% snow_manual_location()$LOCATION_ID)) {
    
    manual_data <- get_manual_swe(station_id = station[station %in% snow_manual_location()$LOCATION_ID],
                                              survey_period = survey_period,
                                              get_year = get_year)
  } else {
    manual_data <- list()
  }
  
  if (length(aswe_data)[1] > 1 && length(manual_data)[1] > 1) {
    d_out <- list(aswe = aswe_data, manual = manual_data)
  } else if (length(aswe_data)[1] > 1 && length(manual_data)[1] < 1) {
    d_out <- aswe_data
  } else if (length(aswe_data)[1] < 1 && length(manual_data)[1] > 1) {
    d_out <- manual_data
  }
  d_out
}
