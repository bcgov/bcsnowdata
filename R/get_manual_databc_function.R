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
#' @param use_archive Whether you want to cache data to speed downstream calculations. Defaults to c("Yes", "No"),
#' @param update_archive Whether you want to update the historical archive (data before this water year). Can choose either yes or no. If the archive is greater than 30 days old it will automatically update
#' @param directory_archive The directory where the data cache will be saved. Defaults to "./data/cache/" of your active directory
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
                           use_archive = c("Yes", "No"),
                           update_archive = c("Yes", "No"),
                           directory_archive = "./data/cache/"){

  # ------------------------------------------------------------------------
  # If the user wants to cache data to speed downstream functions

  if (use_archive == "Yes") {
    if (directory_archive != "./data/cache/") { # If the user has specified where the data should be cached.

      # Create a directory for the data archive. If it exists, this won't override, but will create a data folder if it doesn't exist. Warnings are suppressed if the directory exists
      int_dirarch <- directory_archive # reassign internal variable
      dir.create(file.path(int_dirarch), showWarnings = FALSE)

    } else { # If the user doesn't specify where to create a data archive, create one within the working directory
      print("No path for data cache specified: data saved at /data/cache in working directory")

      # Create a directory for the data archive. If it exists, this won't override, but will create a data folder if it doesn't exist. Warnings are suppressed if the directory exists
      int_dirarch <- file.path("./", "data/cache") # reassign internal variable for data cache directory

      # Create the 'data' folder within your working directory
      dir.create(file.path("./", "data"), showWarnings = FALSE)

      # Create the "cache" folder within the data/working directory
      dir.create(int_dirarch, showWarnings = FALSE)
    }

    # If the choice is to update the data, then automatically update the data
    if (update_archive == "Yes") {
      # Create the ASWE file archive for SWE
      data_archive_manual <- snow_manual_archive()
      data_current_manual <- snow_manual_current()

      # Save archive - all data before current year
      saveRDS(data_archive_manual, file = paste0(int_dirarch, "SWEmanual_archive.RDS"))
    }

    # If the choice is to not automatically update the data, ensure that the data file exists and is 'fresh' (i.e., less than a month old)
    if (update_archive == "No") {
      if (file.exists(paste0(int_dirarch, "SWEmanual_archive.RDS"))){

        # Ensure that the file is not stale. If it is, re-read the file and save it
        if ((Sys.Date() - (as.Date(file.info(paste0(int_dirarch, "SWEmanual_archive.RDS"))$mtime))) >= 30){
          # Create the ASWE file archive for SWE
          data_archive_manual <- snow_manual_archive()

          # Save archive - all data beyond current year
          saveRDS(data_archive_manual, file = paste0(int_dirarch, "SWEmanual_archive.RDS"))

          # if the file exists and is not stale, read the archive from the cache
        } else {
          data_archive_manual <- readRDS(paste0(int_dirarch, "SWEmanual_archive.RDS"))
        }
      } else { # if the file doesn't exist, create it

        # Create the manual data file from Data Catalogue
        data_archive_manual <- snow_manual_archive()

        # Save archive - all data beyond current year
        saveRDS(data_archive_manual, file = paste0(int_dirarch, "SWEmanual_archive.RDS"))
      }

      # Get the current year manual data
      data_current_manual <- snow_manual_current()
    }

  } else { # if you aren't using  a data cache. Not as important as for the manual as it is faster
    data_archive_manual <- snow_manual_archive()
    data_current_manual <- snow_manual_current()
  }
  
  # If there is no data in the current year data, data is only the archive data. Otherwise, join the current year data with the archive
  if (dim(data_current_manual)[1] == 0) {
    data <- data_archive_manual
  } else if (dim(data_current_manual)[1] != 0) {
    # Combine archived data and current year data
    data <- dplyr::full_join(data_archive_manual, data_current_manual) %>%
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
    SWE_current <- data
  } else if (length(station_id)>= 1){
    data_sub <- data %>%
      dplyr::filter(Number %in% station_id)
    SWE_current <- data_sub
  } else {
    SWE_current <- NULL
    print('Error in getting manual SWE')
  }

  # Loop to get specified survey periods
  if(survey_period[1] == "All"){
    SWE_current <- SWE_current
  } else if (length(survey_period)>=1){
    SWE_current <- SWE_current %>%
      dplyr::filter(`Survey Period` %in% survey_period)
  } else {
    SWE_current = NULL
  }

  # Loop to get specified year
  if(get_year[1] == "All"){
    SWE_current <- SWE_current
  } else if (length(get_year)>=1){
    SWE_current <- SWE_current %>%
      dplyr::filter(SWE_current$wr %in% get_year)
  } else {
    SWE_current = NULL
  }

  # massage data - remove periods from colum names
  ## We should look at janitor::clean_name here
  SWE_out <- SWE_current %>%
    #dplyr::rename(Station_ID = Number, SWE_mm = `Snow Line Elev. m`, Date_UTC = `Date of Survey`) %>%
    dplyr::distinct() %>%
    dplyr::select(-wr)

  ## Maintain column names
  colnames(SWE_out) <- c("Snow_Course_Name", "Station_ID", "Elev_metres", "Date_UTC",
                         "Snow_Depth_cm", "SWE_mm", "Survey_Code", "Snow_Line_Elev_m",
                         "Snow_Line_Code", "X_of_Normal", "Density_", "Survey_Period",
                         "Normal_mm")
  return(SWE_out)
}

