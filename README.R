library(magrittr)

# ---- Functions ----

format_element <- function(x, level = 0, backtick = FALSE, array = FALSE) {
  is_array <- array || length(x) > 1
  if (backtick) {
    x %<>% paste0('`', ., '`')
  }
  if (is_array) {
    x %>%
      paste(collapse = ', ') %>%
      paste0('[', ., ']')
  } else {
    if (is.logical(x)) {
      x %>%
        ifelse(., 'true', 'false')
    } else if (is.numeric(x)) {
      x %>%
        as.character()
    } else if (is.character(x)) {
      indent <- rep(' ', level * 2) %>%
        paste(collapse = '')
      x %>%
        # Indent newlines to match block indentation level
        gsub('([\n]+)', paste0('\\1', indent), .) %>%
        # Indent internal lists
        gsub('(\n[ ]+)\\-', '\\1  -', .)
    } else {
      stop('Not supported: ', x)
    }
  }
}

format_markdown <- function(x, level = 1, prefix = '- ') {
  prefix <- rep(' ', level * 2) %>%
    paste(collapse = '') %>%
    paste0(., prefix)
  tags <- x %>%
    names() %>%
    {if (is.null(.)) rep("", length(x)) else .} %>%
    {ifelse(. == '', sprintf('[%d]', seq_along(.)), sprintf("`%s`", .))} %>%
    paste0(prefix, .)
  x %>%
    lapply(function(x) {
      if (is.list(x)) {
        x %>%
          format_markdown(level = level + 1) %>%
          paste0('\n', .)
      } else {
        x %>%
          format_element(level = level)
      }
    }) %>%
    paste(tags, ., collapse = '\n')
}

# apply_list <- function(x, fun, ...) {
#   if (is.list(x)) {
#     for (i in seq_along(x)) {
#       if (is.list(x[[i]])) {
#         x[[i]] <- apply_list(x[[i]], fun = fun, ...)
#       } else {
#         x[[i]] <- fun(x[[i]], ...)
#       }
#     }
#     x
#   } else {
#     fun(x, ...)
#   }
# }

# ---- Read JSON ----

json <- jsonlite::read_json('datapackage.json', simplifyVector = TRUE, simplifyMatrix = FALSE, simplifyDataFrame = FALSE)
path <- 'README.md'

# ---- Template ----

template <- '# Glacier Thickness Database (GlaThiDa)

This dataset adheres to the Frictionless Data [Tabular Data Package](https://frictionlessdata.io/specs/tabular-data-package/) specification. All metadata is provided in `datapackage.json`. This README is automatically generated from the contents of that file.

${intro}

## Credits

### Authors

People who have compiled and maintained GlaThiDa.

${authors}

### Contributors

People who have performed measurements, processed data, and/or submitted data to GlaThiDa, listed in alphabetical order by last name. This list does not include authors of published datasets which were added to GlaThiDa, without consultation, by the authors of GlaThiDa.

${contributors}

### Sources

Published datasets incorporated into GlaThiDa, listed in order of appearance. This list should not be considered complete.

${sources}

## Data structure

The dataset is composed of three tabular data files, referred to here as `T`, `TT`, and `TTT`. The metadata describing their structure follows the Frictionless Data [Tabular Data Resource](https://frictionlessdata.io/specs/tabular-data-resource/) specification.

All data files share a common format, structure, and encoding:

${structure}

${schema}
'

# ---- Build components ----

env <- list()

# Main Data Package properties

env$intro <- json %>%
  extract(setdiff(names(.), c('name', 'title', 'contributors', 'sources', 'resources'))) %>%
  format_markdown()

# List of authors, contributors, sources

contributors <- json[['contributors']] %>%
  lapply(function(x) {
    if (is.null(x$organization)) {
      stringr::str_interp('  - **${title}**\n', x)
    } else {
      stringr::str_interp('  - **${title}**, ${organization}\n', x)
    }
  })
roles <- json[['contributors']] %>%
  sapply('[[', 'role')

env$authors <- contributors[roles == 'author'] %>%
  paste(collapse = '')

env$contributors <- contributors[roles == 'contributor'] %>%
  paste(collapse = '')

env$sources <- json[['sources']] %>%
  sapply(function(x) {
    stringr::str_interp('  - [${title}](${path})\n', x)
  }) %>%
  paste(collapse = '')

# Common data structure

temp <- json$resources[[1]][c('format', 'mediatype', 'encoding', 'profile', 'dialect', 'schema')]
temp$schema <- temp$schema[c('missingValues')]
temp$dialect$lineTerminator %<>% stringi::stri_escape_unicode()
temp$schema$missingValues <- '[""]'
env$structure <- temp %>%
  format_markdown()

# Table schemas
table_template <- '### `${toupper(name)}` ${title}

${schema}

${fields}

'
field_template <- '##### `${name}` ${title}

${schema}

'
env$schema <- json$resources %>%
  lapply(function(resource) {
    r <- list(name = resource$name, title = resource$title)
    # Resource schema
    temp <- resource %>%
      extract(intersect(c('description', 'path', 'schema'), names(.)))
    temp$schema %<>%
      extract(intersect(c('primaryKey', 'foreignKeys'), names(.)))
    temp$schema$primaryKey %<>%
      format_element(backtick = TRUE, array = TRUE)
    for (i in seq_along(temp$schema$foreignKeys)) {
      temp$schema$foreignKeys[[i]]$fields %<>%
        format_element(backtick = TRUE, array = TRUE)
      temp$schema$foreignKeys[[i]]$reference$fields %<>%
        format_element(backtick = TRUE, array = TRUE)
      temp$schema$foreignKeys[[i]]$reference$resource %<>%
        format_element(backtick = TRUE)
    }
    r$schema <- temp %>%
      format_markdown(level = 1)
    # Field schemas
    r$fields <- resource$schema$fields %>%
      lapply(function(field) {
        f <- list(name = field$name, title = field$title)
        temp <- field %>%
          extract(setdiff(names(.), c('name', 'title')))
        if (!is.null(temp$pattern)) {
          # '*' in patterns mess up syntax highlighting
          temp$pattern %<>% format_element(backtick = TRUE)
        }
        if (!is.null(temp$format)) {
          # Looks better with backticks
          temp$format %<>% format_element(backtick = TRUE)
        }
        f$schema <- temp %>%
          format_markdown()
        field_template %>%
          stringr::str_interp(env = f)
      }) %>%
      paste(collapse = '')
    table_template %>%
      stringr::str_interp(env = r)
  }) %>%
  paste(collapse = '')

# ---- Write README ----

template %>%
  stringr::str_interp(env = env) %>%
  gsub('[\n]{2,}', '\n\n', .) %>%
  gsub('\n\n$', '\n', .) %>%
  readr::write_file(path = path)
