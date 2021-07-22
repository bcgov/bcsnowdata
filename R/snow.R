# Copyright 2021 Province of British Columbia
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

# ======================================
# Functions for retrieving data from ASWE stations
# ======================================

# Get historic data - pre 2011 daily data
snow_daily_archive_ <- function() {
  message("Reading Archived Daily Snow Data")
  res <- GET_client(link = "https://pub.data.gov.bc.ca/datasets/5e7acd31-b242-4f09-8a64-000af872d68f/daily_asp_archive.csv")

  archive <- httr::content(res,
    encoding = "UTF-8", type = "text/csv",
    col_types = readr::cols(
      Pillow_ID = readr::col_character(),
      Date = readr::col_character(),
      variable = readr::col_character(),
      value = readr::col_double(),
      code = readr::col_character()
    ),
    progress = FALSE
  )

  ## Trouble parsing because of all NA. Remove NA first then parse.
  archive <- archive[!is.na(archive$value), ]

  ## Assuming measurement is from 16:00 each day.
  ## This facilitate combining archived and current data
  ## station id 4A29P between "1984-02-15" and "1990-05-31" has day and month flipped
  ## Will accept parsing failures now
  archive$Date_UTC <- lubridate::ymd_hm(paste0(archive$Date, " 16:00"), tz = "UTC")

  names(archive)[names(archive) == "Pillow_ID"] <- "Station_ID"

  archive[, c("Date_UTC", "Station_ID", "value", "code", "variable")]
}

# Get the data from 2011 to the present year. This is the hourly data
snow_auto_archive_ <- function(parameter_id = c("SWE", "Snow_Depth", "Precipitation", "Temperature")) {
  parameter_id <- match.arg(parameter_id)

  if (parameter_id == "SWE") {
    link <- "SW"
    long_name <- "Snow_Water_Equivalent"
  }

  if (parameter_id == "Snow_Depth") {
    link <- "SD"
    long_name <- "Snow_Depth"
  }

  if (parameter_id == "Precipitation") {
    link <- "PC"
    long_name <- "Precipitation"
  }

  if (parameter_id == "Temperature") {
    link <- "TA"
    long_name <- "Temperature"
  }

  ## 2011 to present data
  message(sprintf("Reading Post-2010 Archive %s data", long_name))
  res_archive <- GET_client(link = sprintf("http://www.env.gov.bc.ca/wsd/data_searches/snow/asws/data/%s_Archive.csv", link))


  tbl <- httr::content(res_archive,
    encoding = "UTF-8", type = "text/csv",
    col_types = readr::cols(
      .default = readr::col_double(),
      `DATE(UTC)` = readr::col_datetime()
    ), progress = FALSE
  )

  long <- tidyr::gather(tbl, site, value, -`DATE(UTC)`)

  long$Station_ID <- substr(long$site, 1, 5)

  long$station_name <- substr(long$site, 7, nchar(long$site))
  long$Date_UTC <- long$`DATE(UTC)`

  long$variable <- long_name

  long[, c("Date_UTC", "Station_ID", "station_name", "value", "variable")]
}

# Current year snow data
snow_auto_current_ <- function(parameter_id = c("SWE", "Snow_Depth", "Precipitation", "Temperature")) {
  parameter_id <- match.arg(parameter_id)

  if (parameter_id == "SWE") {
    link <- "SW"
    long_name <- "Snow_Water_Equivalent"
  }

  if (parameter_id == "Snow_Depth") {
    link <- "SD"
    long_name <- "Snow_Depth"
  }

  if (parameter_id == "Precipitation") {
    link <- "PC"
    long_name <- "Precipitation"
  }

  if (parameter_id == "Temperature") {
    link <- "TA"
    long_name <- "Temperature"
  }


  res_current <- GET_client(link = sprintf("http://www.env.gov.bc.ca/wsd/data_searches/snow/asws/data/%s.csv", link))


  tbl <- httr::content(res_current,
    encoding = "UTF-8", type = "text/csv",
    col_types = readr::cols(
      .default = readr::col_double(),
      `DATE(UTC)` = readr::col_datetime()
    )
  )

  long <- tidyr::gather(tbl, site, value, -`DATE(UTC)`)

  long$Station_ID <- substr(long$site, 1, 5)

  long$station_name <- substr(long$site, 7, nchar(long$site))
  long$Date_UTC <- long$`DATE(UTC)`

  long$variable <- long_name

  long[, c("Date_UTC", "Station_ID", "station_name", "value", "variable")]
}


snow_auto_stations <- function(crs = "3005") {
  databc_GET_client("WHSE_WATER_MANAGEMENT.SSL_SNOW_ASWS_STNS_SP", crs = crs)
}

# ======================================
# Functions for retrieving data from manual snow surveys
# ======================================

# Archived  manual snow data
snow_manual_archive_ <- function() {
  res <- GET_client("http://www.env.gov.bc.ca/wsd/data_searches/snow/asws/data/allmss_archive.csv")

  # Retrieve data archive from Data BC
  data_manual <- httr::content(res,
    encoding = "UTF-8",
    col_types = readr::cols(
      `Snow Course Name` = readr::col_character(),
      Number = readr::col_character(),
      `Elev. metres` = readr::col_double(),
      `Date of Survey` = readr::col_date(format = ""),
      `Snow Depth cm` = readr::col_double(),
      `Water Equiv. mm` = readr::col_double(),
      `Survey Code` = readr::col_character(),
      `Snow Line Elev. m` = readr::col_double(),
      `Snow Line Code` = readr::col_character(),
      `% of Normal` = readr::col_double(),
      `Density %` = readr::col_double(),
      `Survey Period` = readr::col_character(),
      `Normal mm` = readr::col_double()
    )
  )

  # add in water year to the data
  data_manual$wr <- wtr_yr(data_manual$`Date of Survey`)

  # Replace station IDs that show up as scientific notation within the archived data
  data_manual_final <- data_manual %>%
    dplyr::mutate(Number = replace(Number, Number == "2.00E+01", "2E01")) %>%
    dplyr::mutate(Number = replace(Number, Number == "2.00E+02", "2E02")) %>%
    dplyr::mutate(Number = replace(Number, Number == "2.00E+03", "2E03")) %>%
    dplyr::mutate(Number = replace(Number, Number == "1.00E+07", "1E07")) %>%
    dplyr::mutate(Number = replace(Number, Number == "4.00E+01", "4E01")) %>%
    dplyr::distinct(Number, `Date of Survey`, `Snow Depth cm`, .keep_all = TRUE)
}

# Current year manual snow data
snow_manual_current_ <- function() {
  res <- GET_client("http://www.env.gov.bc.ca/wsd/data_searches/snow/asws/data/allmss_current.csv")

  ## TODO - specify parsing to avoid message
  content <- httr::content(res, encoding = "UTF-8")

  # Specify water year in new column
  content$wr <- wtr_yr(content$`Date of Survey`)

  if (nrow(content) == 0) message("No current manual snow data available")

  content
}

# Get the location of manual snow stations
snow_manual_stations <- function(crs = "3005") {
  databc_GET_client("WHSE_WATER_MANAGEMENT.SSL_SNOW_MSS_LOCS_SP", crs = crs)
}

# ======================================
## Memoised function
# ======================================

snow_daily_archive <- memoise::memoise(snow_daily_archive_)
snow_auto_archive <- memoise::memoise(snow_auto_archive_)
snow_auto_current <- memoise::memoise(snow_auto_current_)
snow_manual_archive <- memoise::memoise(snow_manual_archive_)
snow_manual_current <- memoise::memoise(snow_manual_current_)

# ==================================================================
# Functions for compiling data
# ==================================================================

# -------------
# Function for creating a complete archive - all data before the current water year
# Data is parsed by the type of data (i.e., ASWE), and contains all data before the current water year
# -------------

ASWE_data_archive <- function(parameter_id = c("SWE", "Snow_Depth", "Precipitation", "Temperature")) {

  # Replace the user input values with the values within the data variable space
  if (parameter_id == "SWE") {
    archive_var <- gsub("SWE", "Snow_Water_Equivalent", parameter_id)
  }
  if (parameter_id == "Snow_Depth") {
    archive_var <- gsub("Snow_Depth", "Snow_Depth", parameter_id)
  }
  if (parameter_id == "Temperature") {
    archive_var <- c("Temp_Max", "Temp_Min")
  }
  if (parameter_id == "Precipitation") {
    archive_var <- c("Precipitation", "Accumulated_Precip")
  }

  # Get the pre-2011 data and parse by the parameter ID
  archive_pre2011 <- snow_daily_archive() %>%
    dplyr::filter(variable %in% archive_var) # in to compensate for multiple variables

  # Get the 2011-not current year data
  archive_2011present <- snow_auto_archive(parameter_id)

  # filter pre 2011 data to ensure that there is no data overlap between that avialble within the hourly data
  archive_pre2011 <- archive_pre2011 %>%
    dplyr::filter(Date_UTC < min(archive_2011present$Date_UTC)) # take only data not within the post 2011 hourly data

  # Compile together
  archive_all <- dplyr::full_join(archive_pre2011, archive_2011present)
}

# Function for retrieving the current year data and binding to a
snow_2011tcurrent_archived <- function(parameter_id = c("SWE", "Snow_Depth", "Precipitation", "Temperature"), archived) {
  parameter_id <- match.arg(parameter_id)

  tbl_current <- snow_auto_current(parameter_id = parameter_id)

  dplyr::bind_rows(tbl_current, archived)
}

# Function for binding together the 2011-current year data
snow_auto <- function(parameter_id = c("SWE", "Snow_Depth", "Precipitation", "Temperature")) {
  parameter_id <- match.arg(parameter_id)

  tbl_current <- snow_auto_current(parameter_id = parameter_id)

  tbl_archive <- snow_auto_archive(parameter_id = parameter_id)

  dplyr::bind_rows(tbl_current, tbl_archive)
}
