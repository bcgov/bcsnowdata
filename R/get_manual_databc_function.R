# Copyright 2022 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

# ====================================================================
# Function for Retrieving Manual Snow Survey Data from Data BC
# ====================================================================
#' Get BC Manual Snow Data
#'
#' This function allows you to obtain data for . It retrieves this data from Data BC
#' @param station_id Define the station id you want. Can be an individual site, a string of site IDs ("4A10"), or all ASWE sites ("All"). Defaults to "All".
#' @param survey_period Survey period you want to retrieve. Can choose either all sites ("All") or a specific survey period ("01-Jan", "01-Feb", "01-Mar", "01-Apr", "01-May", "15-May", "01-Jun", "15-Jun"). Defaults to 'All'
#' @param get_year Water year of data you want to retrieve. Defaults to 'All'
#' @keywords Manual snow data DataBC
#' @importFrom magrittr %>%
#' @importFrom grDevices cm
#' @export
#' @examples \dontrun{}
#' get_manual_swe()
get_manual_swe <- function(station_id = "All",
                           survey_period = "All",
                           get_year = "All") {
  
  if (survey_period == "latest") {
    get_year <- wtr_yr(Sys.Date())
    
    survey_period <- ifelse(lubridate::month(Sys.Date()) > 5, paste0("0", as.character(lubridate::month(Sys.Date())), "-01"),
                            ifelse(lubridate::day(Sys.Date()) > 15, paste0("0", as.character(lubridate::month(Sys.Date())), "-01"), 
                                   paste0("0", as.character(lubridate::month(Sys.Date())), "-01"))
                            )
  }
  time_start <- Sys.time()
  # If you only want to get the current water year data
  if (get_year == wtr_yr(Sys.Date())) {
    # Get the current year manual data
    data <- bcdata::bcdc_get_data("12472805-6f6d-457b-8db2-5c1f42a00099")
  } else {
    # Get the archived manual data from Data BC and join with current year
    #data <- bcdata::bcdc_get_data("705df46f-e9d6-4124-bc4a-66f54c07b228") %>%
    #  dplyr::full_join(bcdata::bcdc_get_data("12472805-6f6d-457b-8db2-5c1f42a00099"))
    
    # Old method
    data <- snow_manual_archive() %>%
      dplyr::full_join(snow_manual_current())
  }
  time <- Sys.time() - time_start
  # Filter by the station you want
  if (any(station_id %in% c("All", "all", "ALL"))) {
    data_id <- data
  } else {
    data_id <- data %>%
      dplyr::filter(Number %in% station_id)
  }
  
  # Add in water year
  data_id$wy <- wtr_yr(data_id$`Date of Survey`)
  
  # Filter by the year you want
  if (any(get_year %in% c("All", "all", "ALL"))) {
    data_yr <- data_id
  } else {
    data_yr <- data_id %>%
      dplyr::filter(wy %in% get_year)
  }
  
  # Filter by the survey period you want
  if (any(survey_period %in% c("ALL", "all", "All"))) {
    data_sp <- data_yr
  } else {
    
    # convert the survey_period into the right format (in case the input format is incorrect)
    if (survey_period == "01-01") {
      survey_period <- "01-Jan"
    } else if (survey_period == "02-01") {
      survey_period <- "01-Feb"
    } else if (survey_period == "03-01") {
      survey_period <- "01-Mar"
    } else if (survey_period == "04-01") {
      survey_period <- "01-Apr"
    } else if (survey_period == "05-01") {
      survey_period <- "01-May"
    } else if (survey_period == "05-15") {
      survey_period <- "15-May"
    } else if (survey_period == "06-01") {
      survey_period <- "01-Jun"
    } else if (survey_period == "06-15") {
      survey_period <- "15-Jun"
    } else {
      survey_period <- survey_period
    }
    
    # Filter by the survey period
    data_sp <- data_yr %>%
      dplyr::filter(Number %in% survey_period)
  }

  # massage data - remove periods from column names
  ## We should look at janitor::clean_name here
  data_o <- data_sp %>%
    dplyr::distinct() %>%
    dplyr::select(-wy) %>%
    dplyr::rename(
      "snow_course_name" = `Snow Course Name`,
      "id" = "Number",
      elev_metres = `Elev. metres`,
      date_utc = `Date of Survey`,
      snow_depth_cm = `Snow Depth cm`,
      swe_mm = `Water Equiv. mm`,
      survey_code = `Survey Code`,
      snow_line_elev_m = `Snow Line Elev. m`,
      snow_line_code = `Snow Line Code`,
      x_of_normal = `% of Normal`,
      density_percent = `Density %`,
      survey_period = `Survey Period`,
      normal_mm = `Normal mm`
    )
}
