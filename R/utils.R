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



# =====================
# Function for returning elevation by station
# =====================
elevation <- function(data_manual_final, ...) {
  manual_data <- get_manual_swe(station_id = "All", survey_period = "All", get_year = "All") %>%
    dplyr::filter(!is.na(SWE_mm)) %>%
    dplyr::arrange(Station_ID) %>%
    dplyr::select(Snow_Course_Name, Station_ID, Elev_metres) %>%
    dplyr::rename(Elevation = Elev_metres) %>%
    dplyr::rename(Name = Snow_Course_Name) %>%
    dplyr::distinct(Station_ID, .keep_all = TRUE)

 auto <- snow_auto_stations() %>%
   dplyr::rename(Station_ID = LOCATION_ID) %>%
   dplyr::select(Station_ID, ELEVATION, LOCATION_NAME, geometry) %>%
   dplyr::rename(Elevation = ELEVATION, Name = LOCATION_NAME)

 stations_el <- bind_rows(auto, manual_data)
}

# =====================
# Function for assigning a basin name to a station ID
# =====================
basin_name <- function(id, exceptions = NULL){
  # get all of the sites within the archive
  all_sites <- unique(c(snow_auto_stations()$LOCATION_ID, snow_manual_stations()$LOCATION_ID))
  # Apply exceptions - remove sites that should be removed
  all_sites <-  all_sites[!all_sites %in% exceptions]

  # associate basins by the ID number
  basins_all <- c("UpperFraserWest", "UpperFraserEast", "Nechako", "MiddleFraser", "LowerFraser", "NorthThompson",
                  "SouthThompson", "UpperColumbia", "WestKootenay", "EastKootenay", "Okanagan", "Boundary", "Similkameen", "SouthCoast",
                  "VancouverIsland", "CentralCoast", "Skagit", "Peace", "SkeenaNass", "Stikine", "Liard", "Northwest", "HaidaGwaii",
                  "Nicola_old", "FraserPlateau", "LillBridge", "Quesnel", "LowerThompson", "Fraser", "Province")
  sites_first <- data.frame(Basin = basins_all, Station_ID_used = 2)
  sites_first[sites_first$Basin == "UpperFraserWest",][2] <- paste(c("1A12", "1A16", "1A23", "1A12P"), collapse = ";")
  sites_first[sites_first$Basin == "UpperFraserEast",][2] <- paste(c("1A02P", "1A14P", "1A17P", "1A05", "1A11", "1A15", "1A10", "1A06A", "1A05P", "1A19P", "1A03P"), collapse = ";")
  sites_first[sites_first$Basin == "Nechako",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "B"& substring(all_sites, 1, 1) == "1"), collapse = ";")
  sites_first[sites_first$Basin == "MiddleFraser",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "C" & substring(all_sites, 1, 1) == "1"), collapse = ";")
  sites_first[sites_first$Basin == "LowerFraser",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "D" & substring(all_sites, 1, 1) == "1"), collapse = ";")
  sites_first[sites_first$Basin == "NorthThompson",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "E" & substring(all_sites, 1, 1) == "1"), collapse = ";")
  sites_first[sites_first$Basin == "SouthThompson",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "F" & substring(all_sites, 1, 1) == "1"), collapse = ";")
  sites_first[sites_first$Basin == "UpperColumbia",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "A" & substring(all_sites, 1, 1) == "2"), collapse = ";")
  sites_first[sites_first$Basin == "WestKootenay",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) %in% c("D","B") & substring(all_sites, 1, 1) == "2"), collapse = ";")
  sites_first[sites_first$Basin == "EastKootenay",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "C" & substring(all_sites, 1, 1) == "2"), collapse = ";")
  sites_first[sites_first$Basin == "Okanagan",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "F" & substring(all_sites, 1, 1) == "2"), collapse = ";")
  sites_first[sites_first$Basin == "Boundary",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "E" & substring(all_sites, 1, 1) == "2"), collapse = ";")
  sites_first[sites_first$Basin == "Similkameen",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "G" & substring(all_sites, 1, 1) == "2"), collapse = ";")
  sites_first[sites_first$Basin == "SouthCoast",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "A" & substring(all_sites, 1, 1) == "3"), collapse = ";")
  sites_first[sites_first$Basin == "VancouverIsland",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "B" & substring(all_sites, 1, 1) == "3"), collapse = ";")
  sites_first[sites_first$Basin == "CentralCoast",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "C" & substring(all_sites, 1, 1) == "3"), collapse = ";")
  sites_first[sites_first$Basin == "Skagit",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "D" & substring(all_sites, 1, 1) == "3"), collapse = ";")
  sites_first[sites_first$Basin == "Peace",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "A" & substring(all_sites, 1, 1) == "4"), collapse = ";")
  sites_first[sites_first$Basin == "SkeenaNass",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "B" & substring(all_sites, 1, 1) == "4"), collapse = ";")
  sites_first[sites_first$Basin == "Liard",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "C" & substring(all_sites, 1, 1) == "4"), collapse = ";")
  sites_first[sites_first$Basin == "Stikine",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "D" & substring(all_sites, 1, 1) == "4"), collapse = ";")
  sites_first[sites_first$Basin == "Northwest",][2] <- paste(subset(all_sites, substring(all_sites, 2, 2) == "E" & substring(all_sites, 1, 1) == "4"), collapse = ";")
  sites_first[sites_first$Basin == "HaidaGwaii",][2] <- paste(NA, collapse = ";")

  # basin not on the map currenly - future
  sites_first[sites_first$Basin == "Nicola_old",][2] <- paste(c("1C01",	"1C09",	"1C19",	"1C25",	"1C29",	"2F13",	"2F18",	"2F23",	"2F24"), collapse = ";")
  sites_first[sites_first$Basin == "FraserPlateau",][2] <- paste(c("1C08", "1C22", "1C21"), collapse = ";")
  sites_first[sites_first$Basin == "LillBridge",][2] <- paste(c("1C06", "1C39", "1C38P", "1C38", "1C40P", "1C40", "1C12P", "1C14P", "1C14", "1C37", "1C05P", "1C05", "1C18P", "1C28"), collapse = ";")
  sites_first[sites_first$Basin == "Quesnel",][2] <- paste(c("1C33A", "1C13A", "1C17", "1C20P", "1C23", "1C41P"), collapse = ";")
  sites_first[sites_first$Basin == "LowerThompson",][2] <- paste(c("1C32", "1C09A", "1C19", "1C25", "1C29", "1C29P", "1C01"), collapse = ";")
  sites_first[sites_first$Basin == "Fraser",][2] <- paste(subset(all_sites, substring(all_sites, 1, 1) == "1"), collapse = ";")
  sites_first[sites_first$Basin == "Province",][2] <- paste(all_sites, collapse = ";")

  if(id == "All"){
    return(sites_first)
  } else {
   # find the basin within the dataframe and return the basin name
   basin_site <- sites_first[sites_first$Station_ID_used %like% id, ] %>%
     dplyr::select(Basin) %>%
     dplyr::distinct(Basin)
   return(basin_site)
  }
}

# =====================
# function for rounding all numerics within a dataframe to a certain significant figure
# =====================
round_df <- function(x, digits) {
  # round all numeric variables
  # x: data frame
  # digits: number of digits to round
  numeric_columns <- sapply(x, is.numeric)
  x[numeric_columns] <-  round(x[numeric_columns], digits)
  x
}

# =====================
# Functions for getting client credials to download data from Data BC
# =====================

GET_client <- function(link){
  res <- httr::GET(link,
                   httr::progress(), httr::user_agent("bcsnow"))
  httr::stop_for_status(res)
  return(res)
}

databc_GET_client <- function(layer, crs){
  base_url <- sprintf("https://openmaps.gov.bc.ca/geo/pub/%s/ows", layer)

  srs <- paste0("epsg:", crs)
  res <- httr::GET(base_url,
                   query = list(service = "WFS",
                                version = "2.0.0",
                                request = "GetFeature",
                                typeName = layer,
                                outputFormat = "json",
                                SRSNAME = srs))
  httr::stop_for_status(res)

  sf::read_sf(httr::content(res, as = "text"))

}

#update_message_once <- function(...) {
#  silence <- isTRUE(getOption("silence_update_message"))
#  messaged <- bcsnowdata_env$bcsnowdata_update_message
#  if (!silence && !messaged) {
#    message(...)
#    assign("bcsnowdata_update_message", TRUE, envir = bcsnowdata_env)
#  }
#}
