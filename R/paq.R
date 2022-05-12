read_paq_xlsx <- function(path) {
  read_excel(path) |>
    rename(orp_kod = ORP_KOD) |> select(-ORP_nazev) |>
    mutate(orp_kod = as.character(orp_kod),
           Index_destabilizujici_chudoby = str_replace(Index_destabilizujici_chudoby, "á$", "é"))
}
