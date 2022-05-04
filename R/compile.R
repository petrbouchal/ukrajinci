library(dplyr)

compile_raw <- function(all, kody_kraje, kody_kraje_nuts, kody_mc, kody_orp, kody_okresy, kody_okresy_nuts) {
  all |>
    left_join(kody_kraje, by = "obec_kod") |>
    left_join(kody_kraje_nuts, by = "obec_kod") |>
    left_join(kody_mc, by = c("obec_mc", "obec_kod")) |>
    left_join(kody_orp, by = "obec_kod") |>
    left_join(kody_okresy, by = "obec_kod") |>
    left_join(kody_okresy_nuts, by = "okres_kod") |>
    mutate(day_no = (datum - min(datum)) |> as.numeric("days"))
}
