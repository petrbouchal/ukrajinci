library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("tibble", "dplyr", "czso", "tidyr", "rvest", "stringr", "purrr",
               "readxl", "lubridate", "readr", "arrow", "forcats")
  )


cnf <- config::get(config = "default")
names(cnf) <- paste0("c_", names(cnf))
list2env(cnf, envir = .GlobalEnv)

options(clustermq.scheduler = "multicore",
        crayon.enabled = TRUE,
        scipen = 100,
        czso.dest_dir = "~/czso_data",
        yaml.eval.expr = TRUE)

for (file in list.files("R", full.names = TRUE)) source(file)

list(
  tar_target(mv_urls, c_mv_urls),
  tar_target(name = excel_metadata,
             command = list_mv_excel(url = mv_urls),
             pattern = map(mv_urls), iteration = "vector",
             cue = tar_cue_age(
               name = excel_metadata,
               age = as.difftime(c_mv_timeout_hrs, units = "hours")
             )),
  load_files_l,
  tar_target(excel_urls, excel_metadata$url),
  tar_target(excel_paths, excel_metadata$filename),

  tar_target(kody_kraje, get_cis_kraje()),
  tar_target(kody_kraje_nuts, get_cis_nuts()),
  tar_target(kody_mc, get_cis_mc()),
  tar_target(kody_okresy, get_cis_okresy()),
  tar_target(kody_okresy_nuts, get_cis_okresy_nuts()),
  tar_target(kody_orp, get_cis_orp()),
  tar_target(compiled_raw, compile_raw(dt_all, kody_kraje, kody_kraje_nuts, kody_mc,
                                       kody_orp, kody_okresy, kody_okresy_nuts),
             pattern = map(dt_all)),
  tar_target(obyv_obce, get_obyv_obce()),
  tar_target(compiled_obce, compile_obce(compiled_raw, obyv_obce),,
             pattern = map(compiled_raw)),
  tar_download(paq_indexy_xlsx, c_url_paq_indexy, c_file_paq_indexy),
  tar_file_read(paq_indexy, paq_indexy_xlsx, read = read_paq_xlsx(!!.x)),
  tar_target(obyv_orp, get_obyv_orp()),
  tar_file(compiled_orp_csv, write_data(compiled_orp |> drop_na(orp_kod), write_csv,
  tar_target(compiled_orp, compile_orp(compiled_raw, obyv_orp, paq_indexy),
             pattern = map(compiled_raw)),
                                        file.path("data-export", "compiled-orp.csv"))),
  tar_file(compiled_orp_csv_subset, write_data(compiled_orp |>
                                                 drop_na(orp_kod) |>
                                                 select(orp_nazev, starts_with("Index"),
                                                        celkem, podil, podil_0_18,
                                                        datum, day_no),
                                               write_csv,
                                        file.path("data-export", "compiled-orp-subset.csv"))),
  tar_file(compiled_raw_csv, write_data(compiled_raw, write_csv, file.path("data-export", "compiled-orig.csv"))),
  tar_file(compiled_raw_arrow, write_data(compiled_raw %>% mutate(across(where(is.character), as_factor)),
                                          arrow::write_feather,
                                          file.path("data-export", "compiled-orig.arrow"),
                                          compression = "lz4"))
)
