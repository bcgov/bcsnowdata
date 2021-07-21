# Cache utilities
# Note that much of this code is inspired (cough *taken*) from the lovely bcmaps() function. 
# All credit to the authors and contributors of this package.
# January 15, 2021, Ashlee Jollymore, BC River Forecast Centre

data_dir <- function() {
  if (R.Version()$major >= 4) {
    getOption("bcsnowdata.data_dir", default = tools::R_user_dir("bcsnowdata", "cache"))
  } else {
    getOption("bcsnowdata.data_dir", default = rappdirs::user_cache_dir("bcsnowdata"))
  }
}

show_cached_files <- function() {
  file.path(list.files(data_dir(), full.names = TRUE))
}

check_write_to_data_dir <- function(dir, ask) {
  
  if (ask) {
    ans <- gtools::ask(paste("bcsnowdata would like to store this layer in the directory:",
                     dir, "Is that okay?", sep = "\n"))
    if (!(ans %in% c("Yes", "YES", "yes", "y"))) stop("Exiting...", call. = FALSE)
  }
  
  if (!dir.exists(dir)) {
    message("Creating directory to hold bcsnowdata data at ", dir)
    dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  } else {
    message("Saving to bcmaps data directory at ", dir)
  }
}