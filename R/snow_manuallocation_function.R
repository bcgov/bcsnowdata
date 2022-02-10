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
# ==============

#' This function gets the location of snow surveys from the Data BC catalog
#' @keywords Get manual snow survey locations
#' @export
#' @examples \dontrun{}
#' snow_manual_location()
snow_manual_location <- function() {
  #crs = "3005"
  #databc_GET_client("WHSE_WATER_MANAGEMENT.SSL_SNOW_MSS_LOCS_SP", crs = crs)
  
  bcdata::bcdc_get_data("9f653102-5627-45a7-bd4c-686e365ee04a")
}
