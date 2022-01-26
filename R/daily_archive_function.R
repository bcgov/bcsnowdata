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
  if (any(yr %in% c("all", "All", "ALL")) | any(yr %in% wtr_yr(Sys.Date()))) {
    if (parameter == "swe") {
      # knit the daily swe archive with daily SWE for this water year
      data <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "666b7263-6111-488c-89aa-7480031f74cd") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::mutate(parameter = "swe", "id" = id) %>%
        dplyr::full_join(daily_current(parameter, id))
      
      if ("value" %in% colnames(data)) {
        data <- data %>%
          dplyr::filter(!is.na(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::filter(!is.na(value))
      )
      
    } else if (parameter == "snow_depth") {
      
      # Get snow depth from historic daily data - not always complete to present water year
      historic_daily <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "945c144a-d094-4a20-a3c6-9fe74cad368a") %>%
        dplyr::filter(variable == "SD", Pillow_ID %in% paste0("_", id)) %>%
        dplyr::rename(id = "Pillow_ID",  date_utc = "Date") %>%
        dplyr::mutate(parameter = "snow_depth", id = stringr::str_replace(id, "_", "")) %>%
        dplyr::select(-code, -variable) 
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "204f91d4-b136-41d2-98b3-125ecefd6887") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::mutate(date = as.Date(`DATE(UTC)`)) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") 
      
      if ("value" %in% colnames(data)) {
        data <-  data %>%
          dplyr::mutate(date = as.Date(date_utc), parameter = "snow_depth", "id" = id) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          # cut out the data that is available within daily archive and knit together
          dplyr::rename(date_utc = "date") %>%
          dplyr::filter(date_utc > max(historic_daily$date_utc)) %>%
          dplyr::full_join(historic_daily) %>%
          dplyr::arrange(date_utc) %>%
          # get current year sd
          dplyr::full_join(daily_current(parameter = parameter, id = id) %>%
                           dplyr::rename(date_utc = "date")) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::mutate(date = as.Date(date_utc), parameter = "snow_depth", "id" = id) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          # cut out the data that is available within daily archive and knit together
          dplyr::rename(date_utc = "date") %>%
          dplyr::filter(date_utc > max(historic_daily$date_utc)) %>%
          dplyr::full_join(historic_daily) %>%
          dplyr::arrange(date_utc) %>%
          # get current year sd
          dplyr::full_join(daily_current(parameter = parameter, id = id) %>%
                             dplyr::rename(date_utc = "date")) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      )
      
    } else if (parameter == "precipitation") {
      
      # Get t max and t min from historic daily data - not always complete to present water year
      historic_daily <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "945c144a-d094-4a20-a3c6-9fe74cad368a") %>%
        dplyr::filter(variable %in% c("AccumP"), Pillow_ID %in% paste0("_", id)) %>%
        dplyr::rename(id = "Pillow_ID",  date_utc = "Date") %>%
        dplyr::mutate(parameter = "cum_precip", id = stringr::str_replace(id, "_", "")) %>%
        dplyr::select(-code, -variable) 
      
      # knit the precipitation available until 2003 to the current year data.
      # Note that precip data is only hourly from the data catalog.
      # ************* WILL NEED TO CHANGE UTC BEFORE TAKING DAILY MEAN********************
      data <-  bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "371a0479-1c6a-4f15-a456-11d778824f38") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::mutate(parameter = "cum_precip", "id" = id) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") 
      
      if ("value" %in% colnames(data)) {
        data <- data %>%
          dplyr::mutate(date = as.Date(date_utc)) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          # Join with the daily mean
          dplyr::full_join(historic_daily) %>%
          # join with current year daily mean precip
          dplyr::full_join(daily_current(parameter = parameter, id = id)) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::mutate(date = as.Date(date_utc)) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          # Join with the daily mean
          dplyr::full_join(historic_daily) %>%
          # join with current year daily mean precip
          dplyr::full_join(daily_current(parameter = parameter, id = id)) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      )
      
    } else if (parameter == "temperature") {
      
      # Get t max and t min from historic daily data - not always complete to present water year
      historic_daily <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "945c144a-d094-4a20-a3c6-9fe74cad368a") %>%
        dplyr::filter(variable %in% c("T_Max", "T_Min"), Pillow_ID %in% paste0("_", id)) %>%
        dplyr::rename(id = "Pillow_ID",  date_utc = "Date") %>%
        dplyr::mutate(parameter = as.character(ifelse(variable == "T_Max", "t_max", "t_min")), id = as.character(stringr::str_replace(id, "_", ""))) %>%
        dplyr::select(-code, -variable) 
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data(record = "5e7acd31-b242-4f09-8a64-000af872d68f", 
                                     resource = "fba88311-34b9-4422-b5ae-572fd23b2a00") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)")
      
      if ("value" %in% colnames(data)) {
        data <- data %>%
          dplyr::mutate(date = as.Date(date_utc), "id" = id) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, id) %>%
          dplyr::summarise(t_max = max(value, na.rm = TRUE),
                           t_min = min(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          reshape2::melt(id = c("date_utc", "id")) %>%
          dplyr::rename(parameter = "variable") %>%
          dplyr::full_join(historic_daily) %>%
          # get current year temperature
          dplyr::full_join(daily_current(parameter = parameter, id = id)) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value)) %>%
          dplyr::filter(!is.infinite(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::mutate(date = as.Date(date_utc), "id" = id) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, id) %>%
          dplyr::summarise(t_max = max(value, na.rm = TRUE),
                           t_min = min(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          reshape2::melt(id = c("date_utc", "id")) %>%
          dplyr::rename(parameter = "variable") %>%
          dplyr::full_join(historic_daily) %>%
          # get current year temperature
          dplyr::full_join(daily_current(parameter = parameter, id = id)) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      )
    }
  } else {
    
    if (parameter == "swe") {
      
      # get only the archived data
      data <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", 
                                    resource = "6789d794-c40a-4023-ac0b-0acc10d0d50f") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::mutate(parameter = "swe", "id" = id) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") %>%
        dplyr::mutate(value = ifelse(!(id %in% names(.)), NA, value)) 
      
      if ("value" %in% colnames(data)) {
        data <- data %>%
          dplyr::filter(!is.na(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::filter(!is.na(value))
      )
      
    } else if (parameter == "snow_depth") {
      
      # Get snow depth from historic daily data - not always complete to present water year
      historic_daily <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "945c144a-d094-4a20-a3c6-9fe74cad368a") %>%
        dplyr::filter(variable == "SD", Pillow_ID %in% paste0("_", id)) %>%
        dplyr::rename(id = "Pillow_ID",  date_utc = "Date") %>%
        dplyr::mutate(parameter = "snow_depth", id = stringr::str_replace(id, "_", "")) %>%
        dplyr::select(-code, -variable) 
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "204f91d4-b136-41d2-98b3-125ecefd6887") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::mutate(date = as.Date(`DATE(UTC)`)) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") 
      
      if ("value" %in% colnames(data)) {
        data <- data %>%
          dplyr::mutate(date = as.Date(date_utc), parameter = "snow_depth", "id" = id) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          # cut out the data that is available within daily archive and knit together
          dplyr::rename(date_utc = "date") %>%
          dplyr::filter(date_utc > max(historic_daily$date_utc)) %>%
          dplyr::full_join(historic_daily) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::mutate(date = as.Date(date_utc), parameter = "snow_depth", "id" = id) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          # cut out the data that is available within daily archive and knit together
          dplyr::rename(date_utc = "date") %>%
          dplyr::filter(date_utc > max(historic_daily$date_utc)) %>%
          dplyr::full_join(historic_daily) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      )

    } else if (parameter == "precipitation") {
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      historic_daily <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "945c144a-d094-4a20-a3c6-9fe74cad368a") %>%
        dplyr::filter(variable %in% c("AccumP"), Pillow_ID %in% paste0("_", id)) %>%
        dplyr::rename(id = "Pillow_ID",  date_utc = "Date") %>%
        dplyr::mutate(parameter = "cum_precip", id = stringr::str_replace(id, "_", "")) %>%
        dplyr::select(-code, -variable) 
      
      # knit the precipitation available until 2003 to the current year data.
      # Note that precip data is only hourly from the data catalog.
      # ************* WILL NEED TO CHANGE UTC BEFORE TAKING DAILY MEAN********************
      data <-  bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "371a0479-1c6a-4f15-a456-11d778824f38") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::mutate(parameter = "cum_precip", "id" = id) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)") 
      
      if ("value" %in% colnames(data)) {
        data <- data %>%
          dplyr::mutate(date = as.Date(date_utc)) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          # Join with the daily mean
          dplyr::full_join(historic_daily) %>%
          # join with current year daily mean precip
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::mutate(date = as.Date(date_utc)) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, parameter, id) %>%
          dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          # Join with the daily mean
          dplyr::full_join(historic_daily) %>%
          # join with current year daily mean precip
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      )
    } else if (parameter == "temperature") {
      
      # Get t max and t min from historic daily data - not always complete to present water year
      historic_daily <- bcdata::bcdc_get_data("5e7acd31-b242-4f09-8a64-000af872d68f", resource = "945c144a-d094-4a20-a3c6-9fe74cad368a") %>%
        dplyr::filter(variable %in% c("T_Max", "T_Min"), Pillow_ID %in% paste0("_", id)) %>%
        dplyr::rename(id = "Pillow_ID",  date_utc = "Date") %>%
        dplyr::mutate(parameter = ifelse(variable == "T_Max", "t_max", "t_min"), id = stringr::str_replace(id, "_", "")) %>%
        dplyr::select(-code, -variable) 
      
      # knit the daily snow depth available pre 2003 with hourly 2003-current
      data <-  bcdata::bcdc_get_data(record = "5e7acd31-b242-4f09-8a64-000af872d68f", 
                                     resource = "fba88311-34b9-4422-b5ae-572fd23b2a00") %>%
        dplyr::select(contains(c(id, "DATE(UTC)"))) %>%
        dplyr::rename(value = contains(id), date_utc = "DATE(UTC)")
      
      if ("value" %in% colnames(data)) {
        data <- data %>%
          dplyr::mutate(date = as.Date(date_utc), "id" = id) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, id) %>%
          dplyr::summarise(t_max = max(value, na.rm = TRUE),
                           t_min = min(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          reshape2::melt(id = c("date_utc", "id")) %>%
          dplyr::rename(parameter = "variable") %>%
          dplyr::full_join(historic_daily) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      } else (
        data <- data %>%
          dplyr::mutate(value = NA) %>%
          dplyr::mutate(date = as.Date(date_utc), "id" = id) %>%
          dplyr::filter(date > max(historic_daily$date_utc)) %>%
          dplyr::group_by(date, id) %>%
          dplyr::summarise(t_max = max(value, na.rm = TRUE),
                           t_min = min(value, na.rm = TRUE)) %>%
          dplyr::rename(date_utc = date) %>%
          reshape2::melt(id = c("date_utc", "id")) %>%
          dplyr::rename(parameter = "variable") %>%
          dplyr::full_join(historic_daily) %>%
          dplyr::arrange(date_utc) %>%
          unique() %>%
          dplyr::filter(!is.na(value))
      )
    }
  }
  
  if (any(yr %in% c("ALL", "all", "All"))) {
    data_o <- data
  } else {
  # Filter for the years your specify
  data_o <- data %>%
    dplyr::filter(lubridate::year(date_utc %in% yr))  
  }
  return(data_o)
}
