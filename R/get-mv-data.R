library(dplyr)
library(rvest)
library(stringr)
library(purrr)
library(readxl)
library(lubridate)

list_mv_excel <- function(url = "https://www.mvcr.cz/clanek/statistika-v-souvislosti-s-valkou-na-ukrajine-archiv.aspx",
                         ext_regex = "xl[st]", excel_ext = "xls") {
  hh <- rvest::read_html(url)
  xlsxurls <- hh |>
    rvest::html_elements("#content > ul > li > a") |>
    html_attr("href") |>
    as_tibble() |>
    filter(str_detect(value, paste0(ext_regex, "\\.aspx"))) |>
    rename(path = value) |>
    mutate(url = paste0("https://www.mvcr.cz/", path),
           filename = basename(path) |> str_remove("\\.aspx$") |>
             str_replace(paste0("\\-", ext_regex,"$"), paste0(".", excel_ext))) |>
    distinct()

  return(xlsxurls)
}

load_one_excel <- function(path) {
  # print(path)
  dt <- readxl::read_excel(path)
  if(!"kod_obce" %in% names(dt)) dt$kod_obce <- NA

  dt |>
    mutate(file = path,
           kod_obce = as.character(kod_obce),
           datum = lubridate::parse_date_time(file, "d-m-y") |> as.Date()) |>
    rename(obec_kod = kod_obce)
}

download_and_load_one_excel <- function(url, path, fileext = ".xls") {

  tf <- tempfile(fileext = fileext)
  curl::curl_download(url, tf)
  load_one_excel(tf)

}

