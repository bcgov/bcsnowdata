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


#' @keywords Get manual archive
#' @importFrom magrittr %>%
#' @export
#' @examples \dontrun{}
snow_manual_archive <- memoise::memoise(snow_manual_archive_)

#' @keywords Get manual current
#' @importFrom magrittr %>%
#' @export
#' @examples \dontrun{}
snow_manual_current <- memoise::memoise(snow_manual_current_)