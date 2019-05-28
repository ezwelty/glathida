library(magrittr)

# ---- Datasets ----

countries <- 'scripts/countries.geojson' %>%
  sf::read_sf()

col_names <- list(
  T = c(
    "GlaThiDa_ID", "POLITICAL_UNIT", "GLACIER_NAME", "GLACIER_DB", "GLACIER_ID", "LAT", "LON", "SURVEY_DATE", "ELEVATION_DATE",
    "AREA", "MEAN_SLOPE", "MEAN_THICKNESS", "MEAN_THICKNESS_UNCERTAINTY", "MAXIMUM_THICKNESS", "MAX_THICKNESS_UNCERTAINTY",
    "SURVEY_METHOD", "SURVEY_METHOD_DETAILS", "NUMBER_OF_SURVEY_POINTS", "NUMBER_OF_SURVEY_PROFILES",
    "TOTAL_LENGTH_OF_SURVEY_PROFILES", "INTERPOLATION_METHOD", "INVESTIGATOR", "SPONSORING_AGENCY", "REFERENCES",
    "DATA_FLAG", "REMARKS"),
  TT = c(
    'GlaThiDa_ID', 'POLITICAL_UNIT', 'GLACIER_NAME', 'SURVEY_DATE', 'LOWER_BOUND', 'UPPER_BOUND',
    'AREA', 'MEAN_SLOPE', 'MEAN_THICKNESS', 'MEAN_THICKNESS_UNCERTAINTY', 'MAXIMUM_THICKNESS', 'MAX_THICKNESS_UNCERTAINTY',
    'DATA_FLAG', 'REMARKS'),
  TTT = c(
    "GlaThiDa_ID", "POLITICAL_UNIT", "GLACIER_NAME", "SURVEY_DATE", "PROFILE_ID",
    "POINT_ID", "POINT_LAT", "POINT_LON", "ELEVATION", "THICKNESS", "THICKNESS_UNCERTAINTY", "DATA_FLAG", "REMARKS")
)

col_types <- readr::cols(
  GlaThiDa_ID = 'd',
  POLITICAL_UNIT = 'c',
  GLACIER_NAME = 'c',
  GLACIER_DB = 'c',
  GLACIER_ID = 'c',
  LAT = 'd',
  LON = 'd',
  SURVEY_DATE = 'c',
  ELEVATION_DATE = 'c',
  AREA = 'd',
  MEAN_SLOPE = 'd',
  MEAN_THICKNESS = 'd',
  MEAN_THICKNESS_UNCERTAINTY = 'd',
  MAXIMUM_THICKNESS = 'd',
  MAX_THICKNESS_UNCERTAINTY = 'd',
  SURVEY_METHOD = 'c',
  SURVEY_METHOD_DETAILS = 'c',
  NUMBER_OF_SURVEY_POINTS = 'i',
  NUMBER_OF_SURVEY_PROFILES = 'i',
  TOTAL_LENGTH_OF_SURVEY_PROFILES = 'd',
  INTERPOLATION_METHOD = 'c',
  INVESTIGATOR = 'c',
  SPONSORING_AGENCY = 'c',
  REFERENCES = 'c',
  DATA_FLAG = 'i',
  REMARKS = 'c',
  LOWER_BOUND = 'd',
  UPPER_BOUND = 'd',
  PROFILE_ID = 'c',
  POINT_ID = 'c',
  POINT_LAT = 'd',
  POINT_LON = 'd',
  ELEVATION = 'd',
  THICKNESS = 'd',
  THICKNESS_UNCERTAINTY = 'd'
)

# ---- Read tables ----

read_tables <- function(path, types = c('T', 'TT', 'TTT')) {
  if (path %>% file.exists() && !path %>% dir.exists()) {
    # *.xls(x)
    tables <- list()
    found_types <- path %>%
      readxl::excel_sheets() %>%
      gsub(' - .*$', '', .)
    for (i in seq_along(found_types)) {
      if (found_types[i] %in% types) {
        tables[[found_types[i]]] <- path %>%
          readxl::read_excel(sheet = i, skip = 1) %>%
          extract(i = -1, j = )
      }
    }
  } else {
    # *.csv
    files <- types %>%
      paste0('.csv')
    if (path %>% dir.exists()) {
      paths <- path %>%
        file.path(files)
    } else {
      paths <- path %>%
        paste(files, sep = '_')
    }
    exists <- paths %>%
      file.exists()
    tables <- list()
    for (i in seq_along(paths[exists])) {
      tables[[types[exists][i]]] <- paths[exists][i] %>%
        readr::read_csv(col_types = col_types)
    }
  }
  tables
}

# ---- Write tables ----

write_tables <- function(tables, path = '.') {
  files <- tables %>%
    names() %>%
    paste0('.csv')
  if (path %>% dir.exists()) {
    paths <- path %>%
      file.path(files)
  } else {
    paths <- path %>%
      paste(files, sep = '_')
  }
  for (i in seq_along(paths)) {
    type <- names(tables)[i]
    missing_cols <- setdiff(
      col_names[[type]],
      names(tables[[type]]))
    tables[[type]] %>%
      `is.na<-`(missing_cols) %>%
      dplyr::select(col_names[[type]]) %>%
      dplyr::mutate_all(as.character) %>%
      readr::write_csv(paths[i], na = '')
  }
}

# ---- Table operations ----

merge_tables <- function(x, start_id = 1) {
  tables <- list()
  if (!is.null(start_id)) {
    old_ids <- x %>%
      lapply(function(xi) {
        xi[['T']]$GlaThiDa_ID
      })
    id <- start_id
    new_ids <- old_ids %>%
      lapply(function(ids) {
        new <- seq(id, id + length(ids) - 1)
        id <<- max(new) + 1
        new
      })
  }
  for (type in c('T', 'TT', 'TTT')) {
    tables[[type]] <- seq_along(x) %>%
      lapply(function(i) {
        if (!is.null(x[[i]][[type]])) {
          df <- x[[i]][[type]]
          if (!is.null(start_id)) {
            df %<>%
              dplyr::mutate(
                GlaThiDa_ID = GlaThiDa_ID %>%
                  match(old_ids[[i]]) %>%
                  new_ids[[i]][.]
              )
          }
          df
        }
      }) %>%
      dplyr::bind_rows() %>%
      {if (nrow(.) > 0) . else NULL}
  }
  test_glathida_id_unique(tables)
  tables
}

fill_number_survey_points <- function(tables) {
  # Fill
  ids <- tables[['T']] %>%
    dplyr::filter(is.na(NUMBER_OF_SURVEY_POINTS)) %$%
    GlaThiDa_ID
  n <- tables[['TTT']] %>%
    dplyr::filter(GlaThiDa_ID %in% ids) %>%
    dplyr::mutate(GlaThiDa_ID = GlaThiDa_ID %>% as.numeric()) %>%
    dplyr::count(GlaThiDa_ID)
  mask <- n$GlaThiDa_ID %>%
    match(tables[['T']]$GlaThiDa_ID)
  tables[['T']]$NUMBER_OF_SURVEY_POINTS[mask] <- n$n
  # Report
  if (nrow(n) > 0) {
    cat('Filled for:', n$GlaThiDa_ID %>% paste(collapse = ', '), '\n')
  }
  # Return
  tables
}

# ---- Validate schema ----

# SURVEY_DATE: Validate
validate_date <- function(x) {
  years <- x %>% substr(1, 4) %>% as.numeric()
  months <- x %>% substr(5, 6) %>% as.numeric()
  days <- x %>% substr(7, 8) %>% as.numeric()
  valid <- x %>% length() %>% logical() %>% not()
  valid %<>%
    and(years == 9999 | (years > 1900 & years < 2019)) %>%
    and(months == 99 | (months >= 1 & months <= 12)) %>%
    and(days == 99 | (days >= 1 & days <= 31))
  if (any(!valid)) {
    warning('Invalid dates: ', x[!valid] %>% unique() %>% paste(collapse = ', '))
  }
  full <- valid & months != 99 & days != 99
  tryCatch(
    dates <- full %>%
      {paste(years[.], months[.], days[.], sep = '-')} %>%
      as.POSIXlt(),
    error = function(e) {
      warning('Invalid dates: One or more complete dates do not exist')
    }
  )
  x
}

# Base types
positive_integer <- function(maxlength) {
  list(
    class = 'numeric',
    is_greater_than = 0, is_less_than = 10^maxlength,
    f = round
  )
}
textarea <- list(
  class = 'character'
)

# Field schema
schema <- list(
  # T
  GlaThiDa_ID = list(
    required = TRUE,
    class = 'numeric',
    regex = '[0-9]+'
  ),
  POLITICAL_UNIT = list(
    required = TRUE,
    class = 'character',
    is_in = countries$iso3166_1_alpha_2,
    f = toupper
  ),
  GLACIER_NAME = list(
    required = FALSE,
    class = 'character',
    regex = '[0-9A-Z \\-\\.\\:\\(\\)\\/\\\']{0,60}',
    f = toupper
  ),
  GLACIER_DB = list(
    class = 'character',
    is_in = c('GLIMS', 'RGI', 'WGI', 'FOG', 'OTH'),
    f = toupper
  ),
  GLACIER_ID = list(
    class = 'character',
    regex = '.{0,14}'
  ),
  LAT = list(
    required = TRUE,
    class = 'numeric',
    is_weakly_greater_than = -90, is_weakly_less_than = 90,
    f = function(x) round(x, digits = 6)
  ),
  LON = list(
    required = TRUE,
    class = 'numeric',
    is_weakly_greater_than = -180, is_weakly_less_than = 180,
    f = function(x) round(x, digits = 6)
  ),
  SURVEY_DATE = list(
    required = FALSE,
    class = 'numeric',
    regex = '[0-9]{8}',
    f = validate_date
  ),
  ELEVATION_DATE = list(
    class = 'numeric',
    regex = '[0-9]{8}',
    f = validate_date
  ),
  AREA = list(
    class = 'numeric',
    f = function(x) round(x, digits = 5)
  ),
  # NOTE: TT.MEAN_SLOPE erroneously allows 3 digit slope
  MEAN_SLOPE = list(
    class = 'numeric',
    is_greater_than = 0, is_less_than = 90,
    f = round
  ),
  MEAN_THICKNESS = list(
    c(tables = c('T'), positive_integer(6)),
    c(tables = c('TT'), required = TRUE, positive_integer(6))
  ),
  MEAN_THICKNESS_UNCERTAINTY = positive_integer(6),
  MAXIMUM_THICKNESS = positive_integer(6),
  MAX_THICKNESS_UNCERTAINTY = positive_integer(6),
  SURVEY_METHOD = list(
    class = 'character',
    is_in = c('DRIh', 'DRIm', 'GPR', 'GPRa', 'GPRt', 'GEL', 'HYM', 'SEI', 'OTH')
  ),
  NUMBER_OF_SURVEY_POINTS = positive_integer(4),
  NUMBER_OF_SURVEY_PROFILES = positive_integer(4),
  TOTAL_LENGTH_OF_SURVEY_PROFILES = list(
    class = 'numeric',
    is_greater_than = 0,
    f = function(x) round(x, digits = 2)
  ),
  INTERPOLATION_METHOD = list(
    class = 'character',
    is_in = c('IDW', 'KRG', 'ANU', 'TRI', 'OTH'),
    f = toupper
  ),
  INVESTIGATOR = textarea,
  SPONSORING_AGENCY = textarea,
  REFERENCES = textarea,
  DATA_FLAG = list(
    list(
      tables = c('T', 'TT'),
      class = 'numeric',
      is_in = c(1, 2, 3)
    ),
    list(
      tables = c('TTT'),
      class = 'numeric',
      is_in = c(1, 2, 3)
    )
  ),
  REMARKS = textarea,
  # TT only
  LOWER_BOUND = c(required = TRUE, positive_integer(4)),
  UPPER_BOUND = c(required = TRUE, positive_integer(4)),
  # TTT only
  PROFILE_ID = list(
    required = FALSE,
    class = 'character'
  ),
  POINT_ID = list(
    required = TRUE,
    class = 'character'
  ),
  POINT_LAT = list(
    required = TRUE,
    class = 'numeric',
    is_weakly_greater_than = -90, is_weakly_less_than = 90,
    f = function(x) round(x, digits = 7)),
  POINT_LON = list(
    required = TRUE,
    class = 'numeric',
    is_weakly_greater_than = -180, is_weakly_less_than = 180,
    f = function(x) round(x, digits = 7)),
  ELEVATION = positive_integer(6),
  THICKNESS = c(required = TRUE, positive_integer(6)),
  THICKNESS_UNCERTAINTY = positive_integer(6)
)

# Format field and validate against schema
format_field <- function(x, name, type = 'T') {
  fieldname <- paste0(type, '.', name)
  # Select field schema
  meta <- schema[[name]]
  if (is.list(meta[[1]])) {
    i <- meta %>%
      sapply(function(m) {
        type %>%
          is_in(m$tables)
      }) %>%
      which()
    meta <- meta[[i]]
  }
  if (!is.null(meta$class)) {
    # Coerce to required class
    new_x <- switch(
      meta$class,
      character = x %>% as.character(),
      numeric = x %>% as.numeric()
    )
    if (any(is.na(new_x) != is.na(x))) {
      warning(paste('NAs introduced by coercion of', fieldname, 'to', meta$class))
    } else {
      x <- new_x
    }
  }
  # Remove missing values for testing
  is_na <- x %>% is.na()
  x_na <- x
  x <- x[!is_na]
  if (!is.null(meta$required) && meta$required) {
    # Check for missing values
    if (any(is_na)) {
      warning(paste('Missing values in required', fieldname))
    }
  }
  if (all(is_na)) {
    # No values to validate
    return(x_na)
  }
  if (!is.null(meta$f)) {
    # Apply custom transform
    x %<>% meta$f()
  }
  if (!is.null(meta$is_in)) {
    # Enforce allowable values
    invalid <- !x %in% meta$is_in
    if (any(invalid)) {
      warning(paste('Invalid values in ', fieldname, ':', paste(unique(x[invalid]), collapse = ', ')))
    }
  }
  if (!is.null(meta$regex)) {
    # Enforce regular expression
    invalid <- !grepl(paste0('^', meta$regex, '$'), x, perl = TRUE)
    if (any(invalid)) {
      warning(paste('Invalid values in', fieldname, ':', paste(head(unique(x[invalid]), n = 10), collapse = ', ')))
    }
  }
  invalid <- logical(length(x))
  if (!is.null(meta$is_greater_than)) {
    invalid %<>% and(x > meta$is_greater_than)
  }
  if (!is.null(meta$is_less_than)) {
    invalid %<>% and(x < meta$is_less_than)
  }
  if (!is.null(meta$is_weakly_greater_than)) {
    invalid %<>% and(x >= meta$is_weakly_greater_than)
  }
  if (!is.null(meta$is_weakly_less_than)) {
    invalid %<>% and(x <= meta$is_weakly_less_than)
  }
  if (any(invalid)) {
    warning(paste('Out of range values in', fieldname, ':', paste(unique(x[invalid]), collapse = ', ')))
  }
  # Restore missing values
  x_na %>%
    replace(!is_na, x)
}

# Format table and validate against schema
format_table <- function(df, type = 'T', skip = NULL) {
  for (name in names(df)) {
    if (!name %in% skip) {
      # cat(name, '\n')
      df[[name]] %<>% format_field(name = name, type = type)
    }
  }
  df
}

format_tables <- function(tables, skip = NULL) {
  for (i in seq_along(tables)) {
    tables[[i]] %<>%
      format_table(type = names(tables)[i], skip = skip)
  }
  tables
}

# ---- Additional tests ----

# T.GlaThiDa_ID: Unique
test_glathida_id_unique <- function(tables) {
  invalid <- tables[['T']]$GlaThiDa_ID %>% duplicated()
  if (any(invalid)) {
    errors <- tables[['T']]$GlaThiDa_ID[invalid] %>% unique() %>% sort() %>%
      paste(collapse = ', ')
    cat('Repeated GlaThiDa_ID values:', errors)
  }
}

# TT(T).GlaThiDa_ID: Described in T
test_glathida_id_described <- function(tables) {
  for (type in c('TT', 'TTT')) {
    if (!is.null(tables[[type]])) {
      missing <- tables[[type]]$GlaThiDa_ID %>%
        setdiff(tables[['T']]$GlaThiDa_ID)
      if (length(missing) > 0) {
        missing %>%
          paste(collapse = ', ') %>%
          paste0(type, '.GlaThiDa_ID values missing in T.GlaThiDa_ID: ', .) %>%
          cat('\n')
      }
    }
  }
}

# POLITICAL_UNIT, GLACIER_NAME(, SURVEY_DATE): Equal across tables, based on GlaThiDa_ID
test_repeated_field_equal <- function(tables, field) {
  cols <- c('POLITICAL_UNIT', 'GLACIER_NAME', 'SURVEY_DATE')
  ids <- tables$T$GlaThiDa_ID %>% unique()
  for (id in ids) {
    # cat(id, '\n')
    dfs <- tables %>%
      lapply(function(df) {
        if (!is.null(df)) {
          df %>%
            dplyr::filter(GlaThiDa_ID == id)
        }
      })
    for (type in c('TT', 'TTT')) {
      if (!is.null(dfs[[type]]) && nrow(dfs[[type]]) == 0) {
        next
      }
      fieldname = paste0(type, '.', field)
      invalid <- !dfs[[type]][[field]] %in% dfs[['T']][[field]]
      if (any(invalid)) {
        cat(id, as.character(dfs[['T']][, cols]), '\n')
        cat(
          'Mismatched', fieldname,
          'Expected:', dfs[['T']][[field]],
          'Found:', dfs[[type]][[field]] %>% unique() %>% paste(collapse = ', '),
          '\n')
      }
    }
  }
}

# TTT.POINT_LAT, TTT.POINT_LON: Near T.LAT, T.LON
test_points_nearby <- function(tables, radius = units::as_units(10, 'km')) {
  x <- tables[['T']] %>%
    dplyr::mutate_at(.vars = c('LON', 'LAT'), .funs = as.numeric) %>%
    sf::st_as_sf(coords = c('LON', 'LAT'), crs = 4326)
  y <- tables[['TTT']] %>%
    dplyr::mutate_at(.vars = c('POINT_LON', 'POINT_LAT'), .funs = as.numeric) %>%
    sf::st_as_sf(coords = c('POINT_LON', 'POINT_LAT'), crs = 4326)
  x$max_distance <- units::as_units(NA, 'km')
  for (id in x$GlaThiDa_ID) {
    xi <- x$GlaThiDa_ID %>% equals(id) %>% which()
    ymask <- y$GlaThiDa_ID == id
    if (any(ymask)) {
      x$max_distance[xi] <- sf::st_distance(x[xi, ], y[ymask, ]) %>%
        max() %>%
        units::set_units('km') %>%
        round()
    }
  }
  distances <- tables$T %>%
    dplyr::mutate(
      max_distance = x$max_distance
    ) %>%
    dplyr::select(GlaThiDa_ID, POLITICAL_UNIT, GLACIER_NAME, LAT, LON, max_distance) %>%
    dplyr::filter(max_distance > radius) %>%
    dplyr::arrange(-max_distance)
  if (nrow(distances) > 0) {
    distances %>%
      print(n = nrow(.))
  }
}

# POINT_LAT, POINT_LON: No duplicates
get_duplicate_points <- function(tables, fields = c('POINT_LAT', 'POINT_LON')) {
  tables$TTT %>%
    dplyr::group_by_at(fields) %>%
    dplyr::filter(dplyr::n() > 1)
}

# NUMBER_OF_SURVEY_POINTS = count(TTT)
test_number_survey_points <- function(tables) {
  mismatch <- tables[['TTT']] %>%
    dplyr::group_by(GlaThiDa_ID) %>%
    dplyr::tally()
  ti <- mismatch$GlaThiDa_ID %>%
    match(tables[['T']]$GlaThiDa_ID)
  mismatch %<>%
    dplyr::transmute(
      GlaThiDa_ID,
      GLACIER_NAME = tables[['T']]$GLACIER_NAME[ti],
      NUMBER_OF_SURVEY_POINTS = tables[['T']]$NUMBER_OF_SURVEY_POINTS[ti] %>%
        as.numeric(),
      n
    ) %>%
    dplyr::filter(
      !is.na(NUMBER_OF_SURVEY_POINTS),
      NUMBER_OF_SURVEY_POINTS != n)
  if (nrow(mismatch) > 0) {
    mismatch %>%
      print(n = nrow(.))
  }
}

# POINT_ID: Unique by GlaThiDa_ID, SURVEY_DATE(, PROFILE_ID)
test_point_id_unique <- function(tables) {
  if (!'PROFILE_ID' %in% names(tables[['TTT']])) {
    cols <- c('GlaThiDa_ID', 'SURVEY_DATE')
  } else {
    cols <- c('GlaThiDa_ID', 'SURVEY_DATE', 'PROFILE_ID')
  }
  duplicates <- tables[['TTT']] %>%
    dplyr::group_by_at(cols) %>%
    dplyr::summarise(
      duplicates = POINT_ID %>% extract(duplicated(.)) %>% paste(collapse = '|')
    ) %>%
    dplyr::filter(duplicates != '')
  if (nrow(duplicates) > 0) {
    duplicates
  }
}

get_nearest_political_unit <- function(points) {
  nearest <- sf::st_nearest_feature(points, countries)
  countries$iso3166_1_alpha_2[nearest]
}

get_political_unit_distance <- function(points, POLITICAL_UNIT) {
  index <- match(POLITICAL_UNIT, countries$iso3166_1_alpha_2)
  sf::st_distance(points, countries[index, ], by_element = TRUE) %>%
    round() %>%
    units::set_units('km')
}

# POLITICAL_UNIT: Near T.LAT, T.LON
test_nearest_political_unit <- function(tables) {
  cols <- intersect(
    c('GlaThiDa_ID', 'GLACIER_NAME', 'GLACIER_ID', 'GLACIER_DB', 'LAT', 'LON', 'POLITICAL_UNIT'),
    names(tables[['T']]))
  tables[['T']] %>%
    dplyr::select(cols) %>%
    sf::st_as_sf(coords = c('LON', 'LAT'), crs = 4326) %>%
    dplyr::mutate(
      nearest = get_nearest_political_unit(.)
    ) %>%
    dplyr::filter(nearest != POLITICAL_UNIT) %>%
    dplyr::mutate(
      distance = get_political_unit_distance(., POLITICAL_UNIT)
    )
}
