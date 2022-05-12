library(czso)
library(dplyr)

get_cis_nuts <- function() {
  x <- kody_kraje_nuts <- czso::czso_get_codelist("cis108vaz43") |>
    select(nuts3_kod = CHODNOTA1, obec_kod = CHODNOTA2, nuts3_nazev = TEXT1)
  stopifnot(nrow(x) > 1)
  x
}

get_cis_kraje <- function() {
  x <- czso::czso_get_codelist("cis100vaz43") |>
    select(kraj_kod = CHODNOTA1, obec_kod = CHODNOTA2, kraj_nazev = TEXT1)
  stopifnot(nrow(x) > 1)
  x
}

get_cis_orp <- function() {
  x <- czso::czso_get_codelist("cis65vaz43") |>
    select(orp_kod = CHODNOTA1, obec_kod = CHODNOTA2, orp_nazev = TEXT1)
  stopifnot(nrow(x) > 1)
  x
}

get_cis_mc <- function() {
  x <- czso::czso_get_codelist("cis43vaz44") |>
    select(obec_mc = TEXT2, mc_kod = CHODNOTA2, obec_kod = CHODNOTA1)
  stopifnot(nrow(x) > 1)
  x
}

get_cis_okresy <- function() {
  x <- czso::czso_get_codelist("cis101vaz43") |>
    select(okres_kod = CHODNOTA1, obec_kod = CHODNOTA2)
  stopifnot(nrow(x) > 1)
  x
}

get_cis_okresy_nuts <- function() {
  x <- czso::czso_get_codelist("cis109vaz101") |>
    select(okres_kod = CHODNOTA2, okres_kod_nuts = CHODNOTA1)
  stopifnot(nrow(x) > 1)
  x
}

get_obyv_obce <- function(code = "130141r21") {
  obyv0 <- czso::czso_get_table(code)
  x <- obyv0 |>
    filter(vuzemi_cis == 43, vuk_text == "Střední stav obyvatel") |>
    select(obec_obyv_2020 = hodnota, obec_kod = vuzemi_kod)
  stopifnot(nrow(obyv0) > 1)
  x
}

get_obyv_orp <- function(code = "130141r21") {
  obyv0 <- czso::czso_get_table(code)
  x <- obyv0 |>
    filter(vuzemi_cis == 43, vuk_text == "Střední stav obyvatel") |>
    select(obec_obyv_2020 = hodnota, obec_kod = vuzemi_kod)
  stopifnot(nrow(obyv0) > 1)
  x
}

get_obyv_orp <- function(code = "130181r21") {
  x <- czso::czso_get_table(code) |>
    count(orp_kod = vuzemi_kod, wt = hodnota, name = "orp_obyv_2020")
  stopifnot(nrow(x) > 1)
  x
}
