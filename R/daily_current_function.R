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

#' This function retrieves daily data from aswe sites for the current water year only. 
#' Daily values are calculated as the daily mean except for temperature, where the daily max and min are retrieved and for swe, where the 16:00 UTC measurement is used
#' @param parameter  Defines the parameter (type of data) your want to retrieve
#' @param id Station ID you are looking for
#' @keywords internal
#' @importFrom magrittr %>%
#' @importFrom bcdata bcdc_get_data
#' @export 
#' @examples \dontrun{}

daily_current <- function(parameter = c("swe", "snow_depth", "precipitation", "temperature"), id) {
  
  if (parameter == "swe") {
    current <- bcdata::bcdc_get_data("3a34bdd1-61b2-4687-8b55-c5db5e13ff50", resource = "fe591e21-7ffd-45f4-b3b3-2291e4a6de15") %>%
      dplyr::select(contains(c(id, "DATE(UTC)"))) 
    
    colnames(current) <- gsub( " .*$", "", colnames(current))
    
    # Melt dataframe
    current_out <- data.frame(current, check.names = FALSE) %>%
      reshape::melt(id = "DATE(UTC)") %>%
      dplyr::mutate(parameter = parameter) %>%
      dplyr::rename(date_utc = "DATE(UTC)") %>%
      # Get the 16:00 UTC measurement. Should also linear interpolate?
      dplyr::mutate(hour = lubridate::hour(date_utc)) %>%
      dplyr::filter(hour == 16) %>% # should eventually do interpolation in case 16:00 UTC measurement is missing??
      dplyr::select(-hour) %>%
      dplyr::arrange(id, date_utc)
    
    if ("variable" %in% colnames(current_out)) {
      current_out <- current_out %>%
        dplyr::rename(id = "variable")
    } else {
      current_out <- current_out
    }
    
  } else if (parameter == "snow_depth") {
    current <- bcdata::bcdc_get_data("3a34bdd1-61b2-4687-8b55-c5db5e13ff50", resource = "abba1811-dd9a-4447-a297-2b5f81410abd") %>%
      dplyr::select(contains(c(id, "DATE(UTC)"))) 
    
    colnames(current) <- gsub( " .*$", "", colnames(current))
    
    # Melt dataframe
    current_m <- data.frame(current, check.names = FALSE) %>%
      reshape::melt(id = "DATE(UTC)") %>%
      dplyr::mutate(parameter = parameter) %>%
      dplyr::rename(date_utc = "DATE(UTC)")
      
    # Get the daily mean snow depth
    if ("variable" %in% colnames(current_m)) {
      current_out <- current_m %>%
        dplyr::rename(id = "variable") %>%
        dplyr::mutate(date = as.Date(date_utc)) %>%
        dplyr::group_by(id, date) %>%
        dplyr::summarise(value = mean(value, na.rm = TRUE)) %>%
        dplyr::rename(date_utc = date)
    } else {
      current_out <- current_m
    }
    
  } else if (parameter == "precipitation") {
    current <- bcdata::bcdc_get_data(record = "3a34bdd1-61b2-4687-8b55-c5db5e13ff50", resource = "9f048a78-d74c-40c1-aa1f-9e2fcd1a19dd") %>%
      dplyr::select(contains(c(id, "DATE(UTC)"))) 
    
    colnames(current) <- gsub( " .*$", "", colnames(current))
    
    # Melt dataframe
    current_m <- data.frame(current, check.names = FALSE) %>%
      reshape::melt(id = "DATE(UTC)") %>%
      dplyr::mutate(parameter = "cum_precip") %>%
      dplyr::rename(date_utc = "DATE(UTC)")
    
    if ("value" %in% colnames(current_m)) {
      current_out <- current_m %>%
        dplyr::rename(id = "variable") %>%
        dplyr::mutate(date = as.Date(date_utc)) %>%
        dplyr::group_by(id, date) %>%
        dplyr::summarise(value = mean(value, na.rm = TRUE))%>%
        dplyr::rename(date_utc = date) %>%
        dplyr::mutate(parameter = "cum_precip") 
    } else {
      current_out <- current_m
    }
    
  } else if (parameter == "temperature") {
    current <- bcdata::bcdc_get_data(record = "3a34bdd1-61b2-4687-8b55-c5db5e13ff50", resource = "0bc026a2-7487-4f01-8b97-16d1b591a82f") %>%
      dplyr::select(contains(c(id, "DATE(UTC)"))) 
    
    colnames(current) <- gsub( " .*$", "", colnames(current))
    
    # Melt dataframe
    current_m <- data.frame(current, check.names = FALSE) %>%
      reshape::melt(id = "DATE(UTC)") %>%
      dplyr::mutate(parameter = parameter) %>%
      dplyr::rename(date_utc = "DATE(UTC)") 
    
    if ("variable" %in% colnames(current_m)) {
      current_out <- current_m %>%
        dplyr::rename(id = "variable") %>%
        # Get the daily max and min temp
        dplyr::mutate(date = as.Date(date_utc)) %>%
        dplyr::group_by(id, date) %>%
        dplyr::summarise(t_max = max(value, na.rm = TRUE),
                         t_min = min(value, na.rm = TRUE)) %>%
        dplyr::rename(date_utc = date) %>%
        reshape2::melt(id = c("date_utc", "id")) %>%
        dplyr::rename(parameter = "variable") %>%
        dplyr::arrange(date_utc, id, parameter)
    } else {
      current_out <- current_m
    }
  }
}
