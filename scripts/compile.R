library(sf)
library(lubridate)
library(ggplot2)
library(geojsonio)
library(tidyr)

obce <- CzechData::load_RUIAN_state("obce")
orpy <- CzechData::load_RUIAN_state("orp")
orpy <- RCzechia::orp_polygony()
kraje <- CzechData::load_RUIAN_state("kraje")


kkk <- czso::czso_get_catalogue()

kody2 <- czso::czso_get_codelist("cis108vaz43") |>
  select(orp_kod = CHODNOTA1, obec_kod = CHODNOTA2)

kody3 <- czso::czso_get_codelist("cis100vaz43") |>
  select(nuts3_kod = CHODNOTA1, obec_kod = CHODNOTA2, nazev = TEXT1)

kody <- obce |>
  st_set_geometry(NULL) |>
  select(kod, orp_kod)

orp_day <- all |>
  left_join(kody2, by = c(kod_obce = "obec_kod")) |>
  group_by(datum, orp_kod) |>
  summarise(celkem = sum(celkem), .groups = "drop") |>
  mutate(orp_kod = as.character(orp_kod),
         day_no = (datum - min(datum)) |> as.numeric("days"))

kraj_day <- all |>
  left_join(kody3, by = c(kod_obce = "obec_kod")) |>
  group_by(datum, nuts3_kod, nazev) |>
  summarise(celkem = sum(celkem), .groups = "drop") |>
  mutate(day_no = (datum - min(datum)) |> as.numeric("days"))

readr::write_rds(orp_day, "orp_day.rds")
readr::write_csv(orp_day, "orp_day.csv")
readr::write_csv(kraj_day, "kraj_day.csv")
jsonlite::write_json(orp_day, "orp_day.json")

orpy <- st_cast(orpy, "MULTIPOLYGON")

obyv0 <- czso::czso_get_table("130181r21")
obyv_orp <- obyv0 |>
  count(orp_kod = vuzemi_kod, wt = hodnota, name = "pocob")

orp_day_g <- orp_day |>
  drop_na(orp_kod) |>
  left_join(orpy |> select(nazev = NAZ_ORP, orp_kod = KOD_ORP)) |>
  left_join(obyv_orp) |>
  ungroup() |>
  st_as_sf()

st_write(orp_day_g, "orp_day_g.geojson", append = FALSE)
st_write(orp_day_g |> filter(day_no == 0), "orp_day_g_0.geojson", append = FALSE)

geojsonio::topojson_write(orp_day_g |> filter(day_no == 0), file = "sub.topo")

ggplot(orp_day_g |> filter(day_no == 28)) +
  scale_fill_viridis_c(labels = scales::percent) +
  geom_sf(aes(fill = celkem/pocob), colour = NA) +
  theme_void()


library(gganimate)

ganim <- ggplot(orp_day_g) +
  geom_sf(aes(fill = celkem/pocob), colour = NA) +
  labs(title = "{frame_time}", subtitle = "Frame {frame} of {nframes}") +
  scale_fill_viridis_c(labels = scales::percent) +
  theme_void() +
  transition_time(datum)

animate(ganim, nframes = 29, fps = 3)

pragr::district_names

table(pragr::district_names$name %in% all$obec_mc)
table(mc$TEXT %in% all$obec_mc)

mc$TEXT[!mc$TEXT %in% all$obec_mc]

mc <- czso::czso_get_codelist("cis108vaz43")
