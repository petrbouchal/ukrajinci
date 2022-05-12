library(dplyr)
library(tidyr)
library(RSQLite)
library(targets)

targets::tar_load(compiled_orp)

compiled_orp_subset <- compiled_orp |>
  drop_na(orp_kod) |>
  select(orp_kod, orp_nazev, starts_with("Index"),
         celkem, podil, podil_0_18,
         datum, day_no)

arrow::write_parquet(compiled_orp_subset,
                     "data-export/compiled-orp-subest.parquet")

con <- dbConnect(RSQLite::SQLite(), "data-export/compiled-orp-subset.sqlite")
dbWriteTable(con, "orp", compiled_orp_subset)

dbReadTable(con, "orp") |> as_tibble()
dbDisconnect(con)

data_tbl <- compiled_orp_subset |> select(-starts_with("Index"), -orp_nazev) |> distinct() |>
  mutate(datum = as.character(datum))
indexy_tbl <- compiled_orp_subset |> select(orp_kod, starts_with("Index")) |> distinct()
orp_ciselnik_tbl <- distinct(compiled_orp, orp_kod, orp_nazev)

con2 <- dbConnect(RSQLite::SQLite(), "data-export/compiled-orp-subset-split.sqlite")
dbWriteTable(con2, "indexy", indexy_tbl, overwrite = TRUE)
dbWriteTable(con2, "data", data_tbl, overwrite = TRUE)
dbWriteTable(con2, "ciselnik", orp_ciselnik_tbl, overwrite = TRUE)
dbDisconnect(con2)

con2 <- dbConnect(RSQLite::SQLite(), "data-export/compiled-orp-subset-split.sqlite", extended_types = TRUE)
dbListTables(con2)
dbGetQuery(con2, "pragma table_info('data')")
dbGetQuery(con2, "pragma table_info('indexy')")
dbGetQuery(con2, "pragma table_info('ciselnik')")
dbGetQuery(con2, "SELECT * from indexy
                  LEFT JOIN data using (orp_kod)
                  LEFT JOIN ciselnik using (orp_kod)") |> as_tibble()

dbDisconnect(con2)


library(ggplot2)

ggplot(compiled_orp_subset) +
  geom_line(aes(day_no, podil)) +
  facet_wrap(~orp_nazev)
