
<!--
Copyright 2020 Province of British Columbia
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
-->

# bcsnowdata

<!-- badges: start -->

[![img](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
<!-- badges: end -->

## Project Status

This package is currently under development, and may be subject to
future changes and iterations.

This package is maintained by River Forecast Centre, which is part of
the Water Management Branch of the Ministry of Forest Lands, Natural
Resource Operations and Rural Development.

## What does bcsnowdata do?

This package contains functions for retrieving snow-related data from
the BC Data Catalogue, which can be found at:
<https://catalogue.data.gov.bc.ca/dataset?q=snow&download_audience=Public&sort=score+desc%2C+record_publish_date+desc>.

The authors of this package are not responsible for any errors within
the source data, and assume no responsibility or liability for
subsequent use of any data resources compiled by these functions.

### Features

This package features two functions for retrieving BC snow data from the
BC Data Catalogue: 1) one for the ASWE stations, and 2) one for manual
snow surveys. It also contains functions for retrieving the location
metadata of snow survey and automated snow weather stations, as well as
snow basin administrative areas.

### Installation

The snow package can be installed from GitHub:

``` r
install.packages("remotes", repos = "http://cran.us.r-project.org")
remotes::install_github("bcgov/bcsnowdata")
library(bcsnowdata)
```

### Usage

As of November 2019, this section is the same as the vignette
demonstrating the use of the five functions contained within the
bcsnowdata() package.

#### Automated Snow Function

The first function is get\_aswe\_databc(), which retrieves data for
automated snow stations. It retrieves daily data for dates before 2011,
and hourly data available after 2011, for automated snow stations from
data available on the Data Catalogue.

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
    year, multiple years, or all on record (the function default).

4.  update\_archive: Specifies whether you want to update the archive of
    manual data that is saved on your computer to speed up the data
    process. Archive data is data older than the current water year (Oct
    - Sept). Data older than a month will be automatically updated. This
    is not as significant a time saver as for the ASWE data, given that
    there is less manual data available.

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
<https://catalogue.data.gov.bc.ca/dataset/automated-snow-weather-station-locations>

``` r
ASWE_locations <- snow_auto_location()

head(ASWE_locations)
Simple feature collection with 6 features and 10 fields
geometry type:  POINT
dimension:      XY
bbox:           xmin: 981486.2 ymin: 903297.6 xmax: 1499553 ymax: 1225253
projected CRS:  NAD83 / BC Albers
# A tibble: 6 x 11
  id    SNOW_ASWS_STN_ID LOCATION_ID LOCATION_NAME ELEVATION STATUS LATITUDE
  <chr>            <int> <chr>       <chr>             <int> <chr>     <dbl>
1 WHSE~                1 1A01P       Yellowhead L~      1860 Active     52.9
2 WHSE~                2 1A02P       McBride Upper      1611 Active     53.3
3 WHSE~                3 1A03P       Barkerville        1520 Active     53.1
4 WHSE~                4 1A05P       Longworth Up~      1740 Active     54.0
5 WHSE~                5 1A12P       Kaza Lake          1257 Active     56.0
6 WHSE~                6 1A14P       Hedrick Lake       1100 Active     54.1
# ... with 4 more variables: LONGITUDE <dbl>, OBJECTID <int>,
#   SE_ANNO_CAD_DATA <chr>, geometry <POINT [m]>
```

##### Manual Snow Survey Locations

The snow\_auto\_location() function returns a dataframe containing
location metadata for all of the manual snow survey locations. The
returned dataframe includes both active as well as inactive stations, in
addition to their latitude, longitude and elevation.

Data obtained from:
<https://catalogue.data.gov.bc.ca/dataset/manual-snow-survey-locations>

``` r
manual_locations <- snow_manual_location()

head(manual_locations)
Simple feature collection with 6 features and 10 fields
geometry type:  POINT
dimension:      XY
bbox:           xmin: 1214133 ymin: 477179.7 xmax: 1353969 ymax: 614635.2
projected CRS:  NAD83 / BC Albers
# A tibble: 6 x 11
  id    SNOW_MSS_LOC_ID LOCATION_ID LOCATION_NAME ELEVATION STATUS LATITUDE
  <chr>           <int> <chr>       <chr>             <int> <chr>     <dbl>
1 WHSE~              84 1D09        Wahleach Lake      1480 Active     49.2
2 WHSE~              85 1D10        Nahatlatch R~      1550 Active     49.8
3 WHSE~              86 1D11        Boston Bar C~      1340 Inact~     49.6
4 WHSE~              87 1D12        Boston Bar C~      1230 Inact~     49.6
5 WHSE~              88 1D13        Wolverine Cr~       250 Inact~     50.5
6 WHSE~              89 1D14        Ottomite           1460 Inact~     49.6
# ... with 4 more variables: LONGITUDE <dbl>, OBJECTID <int>,
#   SE_ANNO_CAD_DATA <chr>, geometry <POINT [m]>
```

##### Snow Survey Administrative Basin Areas

The snow\_auto\_location() returns a dataframe containing location
metadata for the administrative basin areas. Returned data includes the
polygon geometries necessary to map snow basin areas (for example, upon
integration with the bcmaps() package).

Data obtained from:
<https://catalogue.data.gov.bc.ca/dataset/snow-survey-administrative-basin-areas>

``` r
basin_locations <- snow_basin_areas()

head(basin_locations)
Simple feature collection with 6 features and 8 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: 531975.4 ymin: 456322.4 xmax: 1581028 ymax: 1242968
projected CRS:  NAD83 / BC Albers
# A tibble: 6 x 9
  id    BASIN_ID FEATURE_CODE BASIN_NAME OBJECTID SE_ANNO_CAD_DATA
  <chr> <chr>    <chr>        <chr>         <int> <chr>           
1 WHSE~ 12       FA12420100   Boundary         42 <NA>            
2 WHSE~ 13       FA12420100   Similkame~       43 <NA>            
3 WHSE~ 2        FA12420100   Upper Fra~       44 <NA>            
4 WHSE~ 11       FA12420100   Okanagan         45 <NA>            
5 WHSE~ 1        FA12420100   Upper Fra~       23 <NA>            
6 WHSE~ 23       FA12420100   Haida Gwa~       24 <NA>            
# ... with 3 more variables: FEATURE_AREA_SQM <dbl>, FEATURE_LENGTH_M <dbl>,
#   geometry <MULTIPOLYGON [m]>
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

-----

*This project was created using the
[bcgovr](https://github.com/bcgov/bcgovr) package.*
