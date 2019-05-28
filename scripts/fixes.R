source('scripts/functions.R')

# ---- 3.0.1 ----

# Change POLITICAL_UNIT from “SJ” to “NO”
tables <- read_tables('data')
results <- test_nearest_political_unit(tables)
ids <- results %>%
  dplyr::filter(POLITICAL_UNIT == 'SJ', nearest == 'NO') %$%
  GlaThiDa_ID
for (name in names(tables)) {
  tables[[name]] %<>%
    dplyr::mutate(POLITICAL_UNIT = replace(POLITICAL_UNIT, GlaThiDa_ID %in% ids, "NO"))
}
write_tables(tables, path = 'data')

# Change ELEVATION from "9999" / "100000" to missing
tables <- read_tables('data')
mask <- with(tables$TTT, ELEVATION >= 9999 & !is.na(ELEVATION))
tables$TTT$ELEVATION[mask] <- NA
write_tables(tables, path = 'data')
