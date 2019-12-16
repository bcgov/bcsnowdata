bcsnowdata
==========

<!-- Add a project state badge
See https://github.com/BCDevExchange/Our-Project-Docs/blob/master/discussion/projectstates.md
If you have bcgovr installed and you use RStudio, click the 'Insert BCDevex Badge' Addin. -->

<a id="devex-badge" rel="Exploration" href="https://github.com/BCDevExchange/assets/blob/master/README.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>

Project Status
--------------

This package is currently under development, and may be subject to
future changes and iterations.

This package is maintained by <a target="_blank" rel="noopener noreferrer" href = "https://www2.gov.bc.ca/gov/content/environment/air-land-water/water/drought-flooding-dikes-dams/river-forecast-centre" class = "uri">River Forecast Centre</a>, which is part of
the Water Management Branch of the BC <a target="_blank" rel="noopener noreferrer" href = "https://www2.gov.bc.ca/gov/content/governments/organizational-structure/ministries-organizations/ministries/forests-lands-natural-resource-operations-and-rural-development" class = "uri">Ministry of Forest, Lands, Natural Resource Operations and Rural Development </a>.

What does bcsnowdata do?
------------------------

This package contains functions for retrieving snow-related data from
the BC Data Catalogue, which can be found at the
<a target="_blank" rel="noopener noreferrer" href="https://catalogue.data.gov.bc.ca/dataset?q=snow&amp;download_audience=Public&amp;sort=score+desc%2C+record_publish_date+desc" class="uri">BC Data Catalogue</a>.

The authors of this package assume no liability for the accuracy, completeness, or any other quality-related aspect with regards to the snow data itself.

### Features

This package features two functions for retrieving BC snow data from the
BC Data Catalogue: 1) one for the ASWE stations, and 2) one for manual
snow surveys. It also contains functions for retrieving the location
metadata of snow survey and automated snow weather stations, as well as
snow basin administrative areas.

The authors of this package are not responsible for any errors within
the source data, and assume no responsibility or liability for
subsequent use of any data resources compiled by these functions.

### Installation

The snow package can be installed from GitHub:
``` r
install.packages("remotes")
remotes::install_github("bcgov/bcsnowdata")
```
### Usage

As of November 2019, this section is the same as the vignette
demonstrating the use of the five functions contained within the
bcsnowdata() package.

#### Automated Snow Function

The first function is get\_aswe\_databc(), which retrieves data for
automated snow stations. It retrieves daily data for dates previous to
2011, and hourly data available after 2011, for automated snow stations
from data available on the Data Catalogue.

The user can define multiple options within the function, including:

1.  station\_id: This function will retrieve data for one station (by
    specified station ID), or multiple stations specified within a
    string (i.e., c(“2F05P”, “1C18P”)). The user can also specify to
    return all ASWE stations within the Data BC catalogue, although this
    is not recommended as it will return data for all of the stations.

2.  get\_year: Specifies the year you want to return. Can be one water
    year, multiple, or all.

3.  update\_archive: Specifies whether you want to update the archive of
    ASWE data that is saved on your computer to speed up the data
    process. Data older than a month will be automatically updated.

4.  parameter\_id: Specifies what type of data you want to retrieve. The
    choices include SWE, Temperature, SD (snow depth), and
    Precipitation.

##### get\_aswe\_databc() Example

The function in this example will retrieve data for station ID 2F05P for
all years on record without updating the cache of historic data (data
prior to this water year).

``` r
# Retrieve SWE for one site over all years; don't cache data
id <- c("2F05P")
SWE_test <- get_aswe_databc(station_id = id, get_year = "All", use_archive = "No", 
    parameter_id = "SWE")
```

#### Manual Snow Survey Data Function

The manual snow station data funtion - get\_manual\_swe() - is similar
to the function that gets data from the ASWE sites.

Specifically, the user can define multiple options within the function,
including:

1.  station\_id: This function will retrieve data for one station (by
    specified station ID), or multiple stations specified within a
    string (i.e., c(“2F05P”, “1C18P”)). The user can also specify to
    return all manual snow survey locations within the Data BC
    catalogue. This is significantly faster than the ASWE station
    function.

2.  survey\_period: Specifies what survey period the user wants to
    return. Can be “All” (the default within the function), or else a
    specific survey period (or number of them). The format can either be
    numeric month year (i.e., “03-01” is March 1), or annotated in the
    format day-month, such as “01-Mar”.

3.  get\_year: Specifies the year you want to return. Can be one water
    year, multiple years, or all onn record (the function default).

4.  update\_archive: Specifies whether you want to update the archive of
    manual data that is saved on your computer to speed up the data
    process. Archive data is data older than the current water year
    (Oct - Sept). Data older than a month will be automatically updated.
    This is not as significant a time saver as for the ASWE data, given
    that there is less manual data available.

The function in this example will retrieve data for station ID 1C21 for
all years and all survey periods on record without updating the cache of
historic data (data prior to this water year).

``` r
# Retrieve manual snow survey data for one site over all survey periods and
# years; don't use data cache
id <- c("1C21")
manual_test <- get_manual_swe(station_id = id, survey_period = "All", get_year = "All", 
    use_archive = "No")
```

##### Automated Snow Weather Station Locations

The snow\_auto\_location() returns a dataframe containing location
metadata for all of the automated snow weather stations. The returned
dataframe includes both active as well as inactive stations, in addition
to their latitude, longitude and elevation.

Data obtained from:
<a href="https://catalogue.data.gov.bc.ca/dataset/automated-snow-weather-station-locations" class="uri">https://catalogue.data.gov.bc.ca/dataset/automated-snow-weather-station-locations</a>

``` r
ASWE_locations <- snow_auto_location()

head(ASWE_locations)
Simple feature collection with 6 features and 10 fields
geometry type:  POINT
dimension:      XY
bbox:           xmin: 1217284 ymin: 454025.8 xmax: 1455320 ymax: 879332.5
epsg (SRID):    3005
proj4string:    +proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs
# A tibble: 6 x 11
  id    SNOW_ASWS_STN_ID LOCATION_ID LOCATION_NAME ELEVATION STATUS
  <chr>            <int> <chr>       <chr>             <int> <chr> 
1 WHSE~                1 1C41P       Yanks Peak         1670 Active
2 WHSE~                2 1D06P       Tenquille La~      1680 Active
3 WHSE~                3 1D09P       Wahleach Lake      1480 Active
4 WHSE~                4 1D17P       Chilliwack R~      1600 Active
5 WHSE~                5 1D19P       Spuzzum            1180 Active
6 WHSE~                6 1E02P       Mount Cook         1550 Active
# ... with 5 more variables: LATITUDE <dbl>, LONGITUDE <dbl>,
#   OBJECTID <int>, SE_ANNO_CAD_DATA <chr>, geometry <POINT [m]>
```

##### Manual Snow Survey Locations

The snow\_auto\_location() function returns a dataframe containing
location metadata for all of the manual snow survey locations. The
returned dataframe includes both active as well as inactive stations, in
addition to their latitude, longitude and elevation.

Data obtained from:
<a href="https://catalogue.data.gov.bc.ca/dataset/manual-snow-survey-locations" class="uri">https://catalogue.data.gov.bc.ca/dataset/manual-snow-survey-locations</a>

``` r
manual_locations <- snow_manual_location()

head(manual_locations)
Simple feature collection with 6 features and 10 fields
geometry type:  POINT
dimension:      XY
bbox:           xmin: 1432172 ymin: 557054.9 xmax: 1633453 ymax: 770315.2
epsg (SRID):    3005
proj4string:    +proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs
# A tibble: 6 x 11
  id    SNOW_MSS_LOC_ID LOCATION_ID LOCATION_NAME ELEVATION STATUS LATITUDE
  <chr>           <int> <chr>       <chr>             <int> <chr>     <dbl>
1 WHSE~              86 2F18        Brenda Mine        1460 Inact~     49.9
2 WHSE~              87 2A14        Mount Abbot        2010 Active     51.2
3 WHSE~              88 2A16        Goldstream         1920 Active     51.7
4 WHSE~              89 2A17        Fidelity Mou~      1870 Active     51.2
5 WHSE~              90 2A18        Keystone Cre~      1890 Active     51.4
6 WHSE~              91 2A19        Vermont Creek      1520 Active     51.0
# ... with 4 more variables: LONGITUDE <dbl>, OBJECTID <int>,
#   SE_ANNO_CAD_DATA <chr>, geometry <POINT [m]>
```

##### Snow Survey Administrative Basin Areas

The snow\_auto\_location() returns a dataframe containing location
metadata for the administrative basin areas. Returned data includes the
polygon geometries necessary to map snow basin areas (for example, upon
integration with the bcmaps() package).

Data obtained from:
<a href="https://catalogue.data.gov.bc.ca/dataset/snow-survey-administrative-basin-areas" class="uri">https://catalogue.data.gov.bc.ca/dataset/snow-survey-administrative-basin-areas</a>

``` r
basin_locations <- snow_basin_areas()

head(basin_locations)
Simple feature collection with 6 features and 8 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: 531975.4 ymin: 456322.4 xmax: 1581028 ymax: 1242968
epsg (SRID):    3005
proj4string:    +proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs
# A tibble: 6 x 9
  id    BASIN_ID FEATURE_CODE BASIN_NAME OBJECTID SE_ANNO_CAD_DATA
  <chr> <chr>    <chr>        <chr>         <int> <chr>           
1 WHSE~ 12       FA12420100   Boundary         42 <NA>            
2 WHSE~ 13       FA12420100   Similkame~       43 <NA>            
3 WHSE~ 2        FA12420100   Upper Fra~       44 <NA>            
4 WHSE~ 11       FA12420100   Okanagan         45 <NA>            
5 WHSE~ 1        FA12420100   Upper Fra~       23 <NA>            
6 WHSE~ 23       FA12420100   Haida Gwa~       24 <NA>            
# ... with 3 more variables: FEATURE_AREA_SQM <dbl>,
#   FEATURE_LENGTH_M <dbl>, geometry <MULTIPOLYGON [m]>
```

##### Assign water year

This package also contains a function (wtr\_yr()) for assigning water
year to a column of dates. It is meant as an internal function that can
also be called externally. The main input is a vector or column of dates
that are used to calculate the corresponding water year. The default
start to the calendar year is October (start\_month = 10).

``` r
wtr_yr(as.Date("2018-12-01"))
[1] 2019
```

### Project Status

This project is in active development and subject to change.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/bcsnowdata/issues/).

### How to Contribute

If you would like to contribute to the package, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

### License

    Copyright 2019 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

------------------------------------------------------------------------

*This project was created using the
[bcgovr](https://github.com/bcgov/bcgovr) package.*
