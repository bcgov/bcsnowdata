# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.



# ====================================================================
# Function for Retrieving Manual Snow Survey Data from Data BC
# ====================================================================
#' Get BC Manual Snow Data
#'
#' This function allows you to obtain data for . It retrieves this data from Data BC
#' @param station_id Define the station id you want. Can be an individual site, a string of site IDs, or all ASWE sites. Defaults to "All".
#' @param survey_period Survey period you want to retrieve. Defaults to 'All'
#' @param get_year Water year of data you want to retrieve. Defaults to 'All'
#' @param force Whether you want to re-download the archived file whether it is updated or no. Defaults to FALSE
#' @param ask Whether the user is asked whether to create a directory for the cached file. Defaults to TRUE
#' @keywords Manual snow data DataBC
#' @importFrom magrittr %>%
#' @export
#' @examples
#' get_manual_swe()

#================================================
# Manual snow data function
#================================================
# Options:
# 1. station.id - You can choose either a single site ("4A10"), or all sites ("All"),
# 2. survey period (survey.period = ) - Can choose either all sites ("All") or a specific survey period ("01-Jan", "01-Feb", "01-Mar", "01-Apr", "01-May", "15-May", "01-Jun", "15-Jun")
# 3. get.year - choose a specific year (i.e., "2007)

get_manual_swe <- function(station_id,
                           survey_period = "All",
                           get_year = "All",
                           force = FALSE,
                           ask = TRUE,...){

  # --------------------------------------
  # Data archive - data before current water year 
  # Check to see whether archived data has been downloaded on the user's computer and whether it has been updated for this year 
  # --------------------------------------
  
  # Check to ensure that the archived data has been cached on the user's computer and is up to date
  fname <- c("manualswe_archive.rds")
  dir <- data_dir()
  fpath <- file.path(dir, fname)
  
  if (!file.exists(fpath) | force) { # If the file exists or the user decides to force the download, grab the archive data using 
    
    # Check that the directory exists
    check_write_to_data_dir(dir, ask)
    
    # Get ASWE archive data
    archive <- snow_manual_archive()
    
    # Save archive - all data before current year
    saveRDS(archive, fpath)
    
  } else {
    archive <- readRDS(fpath)
    
    # Get the maximum date within the archived data. It should be the current water year -1 if it is current
    time <- max(unique(archive$`Date of Survey`))
    
    # Make sure that the archive file was updated last water year (or this year?). Otherwise update.
    if (wtr_yr(time) != wtr_yr(Sys.Date()) - 1 || wtr_yr(time) == wtr_yr(Sys.Date())) {
      
      # Get ASWE archive data
      archive <- snow_manual_archive()
      
      # Save archive - all data before current year
      saveRDS(archive, fpath)
    }
    
    #update_message_once(paste0(what, ' archive was updated on ', format(time_update, "%Y-%m-%d")))
    print(paste0('Manual SWE archive was updated up to ', max(unique(archive$`Date of Survey`))))
  }
  
  # Get current water year data
  current <- snow_manual_current()
  
  # If there is no data in the current year data, data is only the archive data. Otherwise, join the current year data with the archive
  if (dim(current)[1] == 0) {
    data <- archive
    print("No data for current water year")
  } else if (dim(current)[1] != 0) {
    # Combine archived data and current year data
    data <- dplyr::full_join(archive, current, by = c("Snow Course Name", "Number", "Elev. metres", "Date of Survey", "Snow Depth cm", "Water Equiv. mm", "Survey Code", "Snow Line Elev. m", "Snow Line Code", "% of Normal", "Density %", "Survey Period", "Normal mm", "wr")) %>%
      dplyr::distinct(Number, `Date of Survey`, `Snow Depth cm`, .keep_all = TRUE)
  }
  
  stations <- unique(data$Number) # stations within the manual data

  # convert the survey_period into the right format (in case the input format is incorrect)
  if (survey_period == "01-01"){
    survey_period <- "01-Jan"
  } else if (survey_period == "02-01"){
    survey_period <-  "01-Feb"
  } else if (survey_period == "03-01"){
    survey_period <-  "01-Mar"
  } else if (survey_period == "04-01"){
    survey_period <-  "01-Apr"
  } else if (survey_period == "05-01"){
    survey_period <-  "01-May"
  } else if (survey_period == "05-15"){
    survey_period <-  "15-May"
  } else if (survey_period == "06-01"){
    survey_period <-  "01-Jun"
  } else if (survey_period == "06-15"){
    survey_period <-  "15-Jun"
  } else if (survey_period == "latest"){
    survey_period <- 'latest'
  } else {
    survey_period <- survey_period
  }

  # set up loop to retrieve specified stations
  if(station_id[1] == "All"){
    swe_current <- data
  } else if (length(station_id) >= 1){
    data_sub <- data %>%
      dplyr::filter(Number %in% station_id)
    swe_current <- data_sub
  } else {
    swe_current <- NULL
    print('Error in getting manual SWE')
  }

  # Loop to get specified survey periods
  if(survey_period[1] == "All"){
    swe_current <- swe_current
  } else if (length(survey_period)>=1){
    swe_current <- swe_current %>%
      dplyr::filter(`Survey Period` %in% survey_period)
  } else {
    swe_current = NULL
  }

  # Loop to get specified year
  if(get_year[1] == "All"){
    swe_current <- swe_current
  } else if (length(get_year)>=1){
    swe_current <- swe_current %>%
      dplyr::filter(swe_current$wr %in% get_year)
  } else {
    swe_current = NULL
  }

  # massage data - remove periods from column names
  ## We should look at janitor::clean_name here
  swe_out <- swe_current %>%
    #dplyr::rename(Station_ID = Number, SWE_mm = `Snow Line Elev. m`, Date_UTC = `Date of Survey`) %>%
    dplyr::distinct() %>%
    dplyr::select(-wr) %>%
    dplyr::rename("snow_course_name" = `Snow Course Name`,
                  "station_id" = "Number",
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

  return(swe_out)
}

