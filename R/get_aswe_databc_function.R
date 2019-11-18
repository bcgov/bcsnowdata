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




# Function for returning ASWE data (taht is, data from the ASWE sites, including SWE, snow depth, temperature and precipitation),
# This is the individual function that was taken from "SWE_getdata_function.R"
# This version is the same, but only adapted so that it works within the R package documentation
# Created on 10Oct2019 by Ashlee Jollymore
# ================

#' Get BC ASWE Data Function
#'
#' This function allows you to obtain data from BC ASWE sites. It retrieves this data from Data BC
#' @param station_id Define the station id you want. Can be an individual site, a string of site IDs, or all ASWE sites. Defaults to "All", but this is a lot of data so takes forever.
#' @param get_year Define the year that you want to retrieve. Defaults to "All"
#' @param use_archive Whether you want to cache data to speed downstream calculations. Defaults to c("Yes", "No"),
#' @param update_archive Whether you want to update the historical archive (data before this water year). Can choose either yes or no. If the archive is greater than 30 days old it will automatically update
#' @param directory_archive The directory where the data cache will be saved. Defaults to "./data/cache/" of your active directory
#' @param parameter_id Defaults to: "SWE", "Snow_Depth", "Precipitation", "Temperature". Type of data you want to retrieve
#' @keywords Get ASWE Data
#' @importFrom magrittr %>%
#' @importFrom grDevices cm
#' @export
#' @examples
#' get_aswe_databc()


get_aswe_databc <- function(station_id = "All",
                            get_year = "All",
                            use_archive = c("Yes", "No"),
                            update_archive = c("Yes", "No"),
                            directory_archive = "./data/cache/",
                            parameter_id = c("SWE", "Snow_Depth", "Precipitation", "Temperature"), ...){

   # --------------------------------------
   # Get all of the data before this current year
   # --------------------------------------
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

    # If the choice is to update the data, then automatically update the data; otherwise, skip it
    if (update_archive == "Yes") {
      # Create the ASWE file archive for SWE
      archive <- ASWE_data_archive(parameter_id)

      # Save archive - all data before current year
      saveRDS(archive, file = paste0(int_dirarch, parameter_id, "_archive.RDS"))
    }

    # If the choice is to not automatically update the data, ensure that the data file exists and is 'fresh' (i.e., less than a month old)
    if (update_archive == "No") {
     if (file.exists(paste0(int_dirarch, parameter_id, "_archive.RDS"))){

       # Ensure that the file is not stale. If it is, re-read the file and save it
       if ((Sys.Date() - (as.Date(file.info(paste0(int_dirarch, parameter_id, "_archive.RDS"))$mtime ))) >= 30){
         # Create the ASWE file archive for SWE
         archive <- ASWE_data_archive(parameter_id)

         # Save archive - all data beyond current year
         saveRDS(archive, file = paste0(int_dirarch, parameter_id, "_archive.RDS"))

         # if the file exists and is not stale, read the archive from the cache
       } else {
         archive <- readRDS(paste0(int_dirarch, parameter_id, "_archive.RDS"))
       }
     } else { # if the file doesn't exist, create it
       # Create the ASWE file archive for SWE
       archive <- ASWE_data_archive(parameter_id)

       # Save archive - all data beyond current year
       saveRDS(archive, file = paste0(int_dirarch, parameter_id, "_archive.RDS"))
     }
    }
     # If the user doesn't want to use a cache, skip all of the data archiving. None of the data called by the function will be saved.
   } else if (use_archive == "No") {

     # Get the archived ASWE data directly from the Data Catalogue without saving or archiving any data
     archive <- ASWE_data_archive(parameter_id)
   }

  # --------------------------------------
  # Get current water year data
  # --------------------------------------
  current <- snow_auto_current(parameter_id)

  # If you are using the cache, save the current year data within the data cache folder
  if (use_archive == "Yes") {
   saveRDS(current, file = paste0(int_dirarch, parameter_id, "_current.RDS"))
  }

  # -------------------
  # Choices - filter the data by the station ID you specify
  # -------------------
  if (all(station_id != "All")) { # if you are looking for a subset of stations, subset archive and current data by these stations before joining to reduce time
    archive_1 <- archive %>%
      dplyr::filter(Station_ID %in% as.character(station_id))

    current_1 <- current %>%
      dplyr::filter(Station_ID %in% station_id)

    all_1 <- dplyr::full_join(archive_1, current_1)
  } else {
    all_1 <- dplyr::full_join(archive, current)
  }

  # Format the compiled data - ensure data is in the right format and that there are no duplicates
  all <- all_1 %>%
    dplyr::mutate(Date_UTC = as.POSIXct(Date_UTC, format = "%Y-%m-%d %H:%M:%S")) %>%
    dplyr::mutate(value = as.numeric(value)) %>%
    dplyr::arrange(Station_ID, Date_UTC) %>%
    dplyr::distinct(., .keep_all = TRUE)

  #Subset by water year (note - not actual year. Starts in oct of previous year)
  if (all(get_year == "All")){
    data_temp_1 <- all
  } else {
    all$wy <- wtr_yr(dates = all$Date_UTC) # THIS IS THE SLOW PART
    data_temp_1 <- all %>%
      dplyr::filter(wy %in% get_year) %>%
      dplyr::select(-wy)
  }

  data_final = data_temp_1 %>%
    dplyr::distinct(., .keep_all = TRUE) %>% # ensure only unique entries exist
    dplyr::arrange(Station_ID, Date_UTC)

  ## Have a flag if the parameter input was incorrectly specified by the user
  if (all(!c("SWE", "Snow_Depth", "Precipitation", "Temperature") %in% parameter_id)) {
    stop("Did you specify the correct parameter_id? :)", call. = FALSE)
  }

  return(data_final)

} # function end
