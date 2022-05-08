library(dplyr)

compile_raw <- function(all, kody_kraje, kody_kraje_nuts, kody_mc, kody_orp,
                        kody_okresy, kody_okresy_nuts) {
  dt_joined <- all |>
    left_join(kody_kraje, by = "obec_kod") |>
    left_join(kody_kraje_nuts, by = "obec_kod") |>
    left_join(kody_mc, by = c("obec_mc", "obec_kod")) |>
    left_join(kody_orp, by = "obec_kod") |>
    left_join(kody_okresy, by = "obec_kod") |>
    left_join(kody_okresy_nuts, by = "okres_kod")

  var_stems <- c("_do_3", "_do_6", "_do_15", "_do_18", "_do_65", "_sen")
  names_z <- c(paste0("z", var_stems))
  names_m <- c(paste0("m", var_stems))
  names_x <- c(paste0("x", var_stems))

  names_all <- c(names_x, names_m, names_z)

  all_named <- rep(0, length(names_all))
  names(all_named) <- names_all

  fake_df <- tibble(!!!all_named)
  fake_df$drop_this <- TRUE

  dt <- bind_rows(dt_joined, fake_df) |>
    filter(is.na(drop_this)) |>
    mutate(across(where(is.numeric), replace_na, 0)) |>
    select(-drop_this)
}

