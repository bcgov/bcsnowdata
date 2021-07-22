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

#' Function for identifying the water year.
#' This function assigns the water year according to a column or vector of dates
#' @param dates A column of dates (in date format)
#' @param start_month The month that the water year starts on. Defaults to 10 (October)
#' @importFrom magrittr %>%
#' @import grDevices
#' @export
#' @examples
#' wtr_yr()
wtr_yr <- function(dates, start_month = 10) {
  # Convert possible character vector into date
  d1 <- as.Date(dates)
  # Year offset
  offset <- ifelse(as.integer(format(d1, "%m")) < start_month, 0, 1)
  # Water year
  adj_year <- as.integer(format(d1, "%Y")) + offset
  # Return the water year
  adj_year
}
