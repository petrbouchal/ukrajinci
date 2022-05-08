compile_orp <- function(data, obyv_orp, paq_indexy) {
  # print(unique(data))
  data |>
    group_by(datum, orp_kod, orp_nazev) |>
    summarise(across(where(is.numeric), sum, na.rm = TRUE), .groups = "drop") |>
    left_join(obyv_orp, by = "orp_kod") |>
    mutate(all_0_18 = x_do_3 + x_do_6 + x_do_15 + x_do_18 +
             m_do_3 + m_do_6 + m_do_15 + m_do_18 +
             z_do_3 + z_do_6 + z_do_15 + z_do_18,
           podil_0_18 = all_0_18 / celkem,
           podil = celkem / orp_obyv_2020) |>
    left_join(paq_indexy, by = "orp_kod")

}

compile_obce <- function(data, obyv_obce) {
  data |>
    group_by(datum, obec_kod, obec) |>
    summarise(across(where(is.numeric), sum, na.rm = TRUE), .groups = "drop") |>
    left_join(obyv_obce, by = "obec_kod") |>
    mutate(all_0_18 = x_do_3 + x_do_6 + x_do_15 + x_do_18 +
             m_do_3 + m_do_6 + m_do_15 + m_do_18 +
             z_do_3 + z_do_6 + z_do_15 + z_do_18,
           podil_0_18 = all_0_18 / celkem,
           podil = celkem / obec_obyv_2020)
}
