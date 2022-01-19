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

#' This function retrieves hourly data from aswe sites, including both archived and current year data
#' @param parameter  Defines the parameter (type of data) your want to retrieve
#' @param get_year Define the year that you want to retrieve. Defaults to "All"
#' @param id Station ID you are looking for
#' @keywords internal
#' @importFrom magrittr %>%
#' @importFrom bcdata bcdc_get_data
#' @export 
#' @examples \dontrun{}

daily_archive <- function(parameter = c("swe", "snow_depth", "precipitation", "temperature"), get_year = "All", id) {
  
  yr <- get_year
  
  # Knit the current year with past year data if you need both current and archived data
  if (any(get_year %in% c("all", "All", "ALL")) | any(yr %in% wtr_yr(Sys.Date())) ) {
    
    if (parameter == "swe") {
      
      # knit the daily swe archive with daily SWE for this water year
      data <- bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '666b7263-6111-488c-89aa-7480031f74cd') %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::mutate(parameter = "swe", "id" = id) %>%
        dplyr::filter(!is.na(value)) %>%
        dplyr::full_join(daily_current(parameter, id))
      
    } else if (parameter == "snow_depth") {
      
      # historic daily data - not until present
      historic_daily <- #bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = 'f4ec0b1f-f8ba-4601-8a11-cff6b6d988a4') %>%
        #bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = 'f4ec0b1f-f8ba-4601-8a11-cff6b6d988a4')
        bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '945c144a-d094-4a20-a3c6-9fe74cad368a') %>%
        dplyr::filter(variable == "Snow_Depth", Pillow_ID %in% id) %>%
        dplyr::rename(id = "Pillow_ID",  date_utc = "Date") %>%
        dplyr::mutate(parameter = "snow_depth") %>%
        dplyr::select(-code, -variable)
      
      # get the historic hourly snow depth and calculate the daily average
      data_hourly <- hourly_archive(id, parameter, get_year)
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '204f91d4-b136-41d2-98b3-125ecefd6887') %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        # get current year sd
        dplyr::full_join(bcdata::bcdc_get_data('3a34bdd1-61b2-4687-8b55-c5db5e13ff50', resource = 'abba1811-dd9a-4447-a297-2b5f81410abd') %>%
                           dplyr::select(contains(c(id, "DATE(UTC)")))) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::mutate(parameter = "snow_depth", "id" = id) %>%
        dplyr::filter(!is.na(value))
      
    } else if (parameter == "precipitation") {
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '371a0479-1c6a-4f15-a456-11d778824f38') %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        # get current year precip
        dplyr::full_join(bcdata::bcdc_get_data(record = '3a34bdd1-61b2-4687-8b55-c5db5e13ff50', resource = '9f048a78-d74c-40c1-aa1f-9e2fcd1a19dd') %>%
                           dplyr::select(contains(c(id, "DATE(UTC)"))) ) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::mutate(parameter = "accum_precip", "id" = id) %>%
        dplyr::filter(!is.na(value))
      
    } else if (parameter == "temperature") {
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = 'fba88311-34b9-4422-b5ae-572fd23b2a00') %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        # get current year temperature
        dplyr::full_join(bcdata::bcdc_get_data(record = '3a34bdd1-61b2-4687-8b55-c5db5e13ff50', resource = '9f048a78-d74c-40c1-aa1f-9e2fcd1a19dd') %>%
                           dplyr::select(contains(c(id, "DATE(UTC)")))) %>%
        dplyr::mutate(parameter = "temperature", "id" = id) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::filter(!is.na(value)) 
    }
  } else {
    
    if (parameter == "swe") {
      
      # get only the archived data
      data <- bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '6789d794-c40a-4023-ac0b-0acc10d0d50f') %>%
        dplyr::select(contains(c(id, "DATE(UTC)")))%>%
        dplyr::mutate(parameter = "swe", "id" = id) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::filter(!is.na(value))
      
    } else if (parameter == "snow_depth") {
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '204f91d4-b136-41d2-98b3-125ecefd6887') %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::mutate(parameter = "snow_depth", "id" = id) %>%
        dplyr::rename(value = contains(id)) %>%
        dplyr::filter(!is.na(value)) 
      
    } else if (parameter == "precipitation") {
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = '371a0479-1c6a-4f15-a456-11d778824f38') %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::mutate(parameter = "accum_precip", "id" = id) %>%
        dplyr::filter(!is.na(value)) 
      
    } else if (parameter == "temperature") {
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data('5e7acd31-b242-4f09-8a64-000af872d68f', resource = 'fba88311-34b9-4422-b5ae-572fd23b2a00') %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::mutate(parameter = "temperature", "id" = id) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::filter(!is.na(value)) 
    }
  }
  
  if (any(yr %in% c("ALL", "all", "All"))) {
    data_o <- data
  } else {
  # Filter for the years your specify
  data_o <- data %>%
    dplyr::filter(lubridate::year(date_utc %in% yr))  
  }
}