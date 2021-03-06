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
#' @param station_id Define the station id you want. Can be an individual site, a string of site IDs, or all ASWE sites. Defaults to "All"; this will return a great deal of data.
#' @param get_year Define the year that you want to retrieve. Defaults to "All"
#' @param force Whether you want to re-download the archived file whether it is updated or no. Defaults to FALSE
#' @param ask Whether the user is asked whether to create a directory for the cached file. Defaults to TRUE
#' @param parameter_id Defaults to: "SWE", "Snow_Depth", "Precipitation", "Temperature". Type of data you want to retrieve
#' @keywords Get ASWE Data
#' @importFrom magrittr %>%
#' @importFrom grDevices cm
#' @export
#' @examples
#' get_aswe_databc()


get_aswe_databc <- function(station_id = "All",
                            get_year = "All",
                            parameter_id = c("SWE", "Snow_Depth", "Precipitation", "Temperature"), 
                            force = FALSE,
                            ask = TRUE,...){

   # --------------------------------------
   # Data archive - data before current water year 
   # Check to see whether archived data has been downloaded on the user's computer and whether it has been updated for this year 
   # --------------------------------------
  
   # Check to ensure that the ASWE archived data has been cached on the user's computer and is up to date
   fname <- paste0(parameter_id, "_archive.rds")
   dir <- data_dir()
   fpath <- file.path(dir, fname)
     
   if (!file.exists(fpath) | force) { # If the file exists or the user decides to force the download, grab the archive data using 
     
     # Check that the directory exists
     check_write_to_data_dir(dir, ask)
       
     # Get ASWE archive data
     archive <- ASWE_data_archive(parameter_id)
    
     # Save archive - all data before current year
     saveRDS(archive, fpath)
    
   } else {
     archive <- readRDS(fpath)
    
     # Get the maximum date within the archived data. It should be the current water year -1 if it is current
     time <- max(unique(archive$Date_UTC))
    
     # Make sure that the archive file was updated last water year. Otherwise 
     if (wtr_yr(time) != wtr_yr(Sys.Date()) - 1) {
       archive <- ASWE_data_archive(parameter_id)
       saveRDS(archive, fpath)
     }
    
     #update_message_once(paste0(what, ' archive was updated on ', format(time_update, "%Y-%m-%d")))
     print(paste0(parameter_id, ' archive was updated up to ', wtr_yr(max(unique(archive$Date_UTC)))))
   }
  
  # --------------------------------------
  # Get current water year data
  # --------------------------------------
  current <- snow_auto_current(parameter_id)

  # -------------------
  # Choices - filter the data by the station ID you specify
  # -------------------
  if (all(station_id != "All")) { # if you are looking for a subset of stations, subset archive and current data by these stations before joining to reduce time
    archive_1 <- archive %>%
      dplyr::filter(Station_ID %in% as.character(station_id))

    current_1 <- current %>%
      dplyr::filter(Station_ID %in% station_id)

    all_1 <- dplyr::full_join(archive_1, current_1, by = c("Date_UTC", "Station_ID", "value", "variable", "station_name"))
  } else {
    all_1 <- dplyr::full_join(archive, current, by = c("Date_UTC", "Station_ID", "value", "variable", "station_name"))
  }

  # Format the compiled data - ensure data is in the right format and that there are no duplicates
  all <- all_1 %>%
    dplyr::mutate(Date_UTC = as.POSIXct(Date_UTC, format = "%Y-%m-%d %H:%M:%S")) %>%
    dplyr::mutate(value = as.numeric(value)) %>%
    dplyr::arrange(Station_ID, Date_UTC) %>%
    dplyr::distinct(., .keep_all = TRUE) %>%
    dplyr::rename(date_utc = "Date_UTC",
                  station_id = "Station_ID")

  #Subset by water year (note - not actual year. Starts in oct of previous year)
  if (all(get_year == "All")){
    data_temp_1 <- all
  } else {
    all$wy <- wtr_yr(dates = all$date_utc) # THIS IS THE SLOW PART
    data_temp_1 <- all %>%
      dplyr::filter(wy %in% get_year) %>%
      dplyr::select(-wy)
  }

  data_final <- data_temp_1 %>%
    dplyr::distinct(., .keep_all = TRUE) %>% # ensure only unique entries exist
    dplyr::arrange(station_id, date_utc)

  ## Have a flag if the parameter input was incorrectly specified by the user
  if (all(!c("SWE", "Snow_Depth", "Precipitation", "Temperature") %in% parameter_id)) {
    stop("Did you specify the correct parameter_id? :)", call. = FALSE)
  }

  return(data_final)

} # function end
