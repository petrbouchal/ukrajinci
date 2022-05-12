library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("tibble", "dplyr", "czso", "tidyr", "rvest", "stringr", "purrr",
               "readxl", "lubridate", "readr", "arrow", "forcats", "writexl")
)

on_gha <- Sys.getenv("GITHUB_ACTIONS") == "true"

cnf <- config::get(config = "default")
names(cnf) <- paste0("c_", names(cnf))
list2env(cnf, envir = .GlobalEnv)

options(clustermq.scheduler = "multicore",
        crayon.enabled = TRUE,
        scipen = 100,
        czso.dest_dir = "~/czso_data",
        yaml.eval.expr = TRUE)

for (file in list.files("R", full.names = TRUE)) source(file)

if (on_gha) c_mv_timeout_hrs <- 0

load_files_local_l <- list(
  tar_file(excel_files,
           curl::curl_download(excel_urls, file.path(c_excel_dir, excel_paths)),
           pattern = map(excel_urls, excel_paths)),
  tar_target(dt_all, load_one_excel(excel_files), pattern = map(excel_files))
)

load_files_gha_l <- list(
  tar_target(dt_all, download_and_load_one_excel(excel_urls, excel_paths),
             pattern = map(excel_urls, excel_paths))
)

if (on_gha) {
  load_files_l <- load_files_gha_l
}  else {
  load_files_l <- load_files_local_l
}

tg_l <- list(
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
  tar_target(compiled_orp, compile_orp(compiled_raw, obyv_orp, paq_indexy),
             pattern = map(compiled_raw))
)

write_l_gha <- list(
  tar_file(compiled_orp_csv_subset, write_data(compiled_orp |>
                                                 drop_na(orp_kod) |>
                                                 select(orp_nazev, starts_with("Index"),
                                                        celkem, podil, podil_0_18,
                                                        datum) |>
                                                 mutate(day_no = (datum - min(datum)) |> as.numeric("days")) |>
                                                 arrange(day_no),
                                               write_csv,
                                               file.path("data-export", "compiled-orp-subset.csv"))),
  tar_file(compiled_raw_csv, write_data(compiled_raw, write_csv, file.path("data-export", "compiled-orig.csv"))),
  tar_file(compiled_obce_csv, write_data(compiled_obce, write_csv, file.path("data-export", "compiled-obce.csv")))
)
write_l_local <- list(write_l_gha,
                      tar_file(compiled_orp_csv, write_data(compiled_orp, write_csv,
                                                            file.path("data-export", "compiled-orp.csv"))),
                      tar_file(compiled_orp_excel, write_data(compiled_orp, write_xlsx,
                                                              file.path("data-export", "compiled-orp.xlsx"))),
                      tar_file(compiled_raw_excel, write_data(compiled_raw, write_xlsx, file.path("data-export", "compiled-orig.xlsx"))),
                      tar_file(compiled_raw_parquet, write_data(compiled_raw, arrow::write_parquet,
                                                                file.path("data-export", "compiled-orig.parquet"))),
                      tar_file(compiled_obce_parquet, write_data(compiled_obce, arrow::write_parquet,
                                                                 file.path("data-export", "compiled-obce.parquet"))),
                      tar_file(compiled_obce_excel, write_data(compiled_obce, write_xlsx, file.path("data-export", "compiled-obce.xlsx")))
)

write_l <- if(on_gha) write_l_gha else write_l_local

list(tg_l, write_l)
