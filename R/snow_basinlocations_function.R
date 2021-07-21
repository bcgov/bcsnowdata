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


#' Get the location of snow basins (for mapping)
#'
#' This function gets the location of snow surveys from the Data BC catalogue
#' @param crs Defaults to 3005
#' @keywords Get snow locations
#' @export
#' @examples
#' snow_basin_areas()

snow_basin_areas <- function(crs = "3005") {

  databc_GET_client("WHSE_WATER_MANAGEMENT.SSL_SNOW_SURVEY_BASIN_AREA_SP", crs = crs)

}
