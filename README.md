
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ukrajinci

<!-- badges: start -->
<!-- badges: end -->

Tento repozitář obsahuje kód na kompilaci a analýzu dat o lidech, kteří
se v Česku zaregistrovali po udělení právní ochrany (moje nepřesná
terminologie, viz [MV
ČR](https://www.mvcr.cz/clanek/statistika-v-souvislosti-s-valkou-na-ukrajine-archiv.aspx)
pro upřesnění).

## Zdroje dat

MV ČR [publikuje denní
data](https://www.mvcr.cz/clanek/statistika-v-souvislosti-s-valkou-na-ukrajine-archiv.aspx)
pro upřesnění) s počty těchto lidí podle pohlaví, obce pobytu a věkových
skupin. Jsou to vždy kumulativní data a zřejmě dochází i k jejich
upřesňování, tj. změny mezi soubory z jednotlivých dnů mohou být buď
následkem reálné změny, nebo zpětného upřesnění.

## Omezení dat

Viz především text na webu MV.

V datech jsem zajím objevil tyto problémy:

-   v datech do 16. 3. nejsou kódy obcí, čili pro tyto dny je to skoro
    nepoužitelné pro územní pohled

-   XLSX link z 27. 3. vede na soubor z 28. 3. a XLSX soubor z 27. 3. na
    serveru ani není (XLS soubor tam je a správně odkázaný, ale XLSX je
    preferovaný, otevřenější formát)

-   30. března je místo XLS soubor XLT (data v něm sice jsou, ale není
        důvod to poskytovat v tomto formátu)

První problém snadno a přesně vyřešit nelze, druhý a třetí skript řeší.

Kromě toho je v datech velké množství lidí bez adresy a nějaké množství
lidí bez určeného pohlaví.

## Postup

Tento kód tato data stahuje, kompiluje a čistí, též na ně navazuje
číselníky územních celků pro snadné napojení na další data.

Skript běží automaticky každý den v 15:30.

## Výstupy

### Data

Poslední data lze najít [zde v různých formátech a úrovních
granularity](https://github.com/petrbouchal/ukrajinci/tree/targets-runs/data-export).

### Aplikace

S daty na úrovni ORP pak pracuje [ukázková
prezentace](https://petrbouchal.xyz/ukrajinci/), která též využívá
[data](https://www.mapavzdelavani.cz/downloads/paq_dataset_indexy.xlsx)
ze [vzdělávací mapy PAQ](mapavzdelavani.cz/).

## Jak to pustit

Vše v R:

``` r
install.packages("renv") # nemělo by být třeba
renv::restore() # nainstaluje potřebné balíky
targets::tar_make() # spustí celou pipeline
quarto::quarto_render() # vygeneruje webovou stránku/aplikaci do adresáře "docs"
```

Systém funguje tak, že při příštím spuštění pouze donačte nová data,
žádné stahování a počítání se zbytečně neopakuje.

## Technické detaily

-   o správu celé pipeline se stará systém `{targets}`
-   web/aplikaci generuje Quarto s interaktivní grafikou Observable Plot
-   zachycení použitých balíků dělá systém `{renv}`

Na Githubu běží automaticky každý den přes Github Actions. Lokálně třeba
pustit ručně, ale logika s neopakováním zbytečných stahování a výpočtů
platí. Při použití mimo Github Actions systém navíc skladuje původní
excelové soubory od MV.

### SessionInfo

<details>

``` r
source("_targets_packages.R")
#> 
#> Attaching package: 'shinyWidgets'
#> The following object is masked from 'package:bs4Dash':
#> 
#>     progressBar
sessionInfo()
#> R version 4.1.2 (2021-11-01)
#> Platform: aarch64-apple-darwin20 (64-bit)
#> Running under: macOS Monterey 12.4
#> 
#> Matrix products: default
#> LAPACK: /Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/lib/libRlapack.dylib
#> 
#> locale:
#> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices datasets  utils     methods   base     
#> 
#> other attached packages:
#>  [1] writexl_1.4.0      visNetwork_2.1.0   tibble_3.1.6       shinyWidgets_0.6.4 shinybusy_0.3.0    shiny_1.7.1       
#>  [7] rvest_1.0.2        rstudioapi_0.13    readxl_1.4.0       readr_2.1.2        purrr_0.3.4        pingr_2.0.1       
#> [13] markdown_1.1       lubridate_1.8.0    gt_0.4.0           future_1.24.0      forcats_0.5.1      czso_0.3.9        
#> [19] curl_4.3.2         clustermq_0.8.95.3 bs4Dash_2.1.0      arrow_7.0.0        stringr_1.4.0      tidyr_1.2.0       
#> [25] dplyr_1.0.8        targets_0.12.0    
#> 
#> loaded via a namespace (and not attached):
#>   [1] backports_1.4.1    systemfonts_1.0.4  igraph_1.2.11      lazyeval_0.2.2     sp_1.4-7           jqr_1.2.3         
#>   [7] listenv_0.8.0      usethis_2.1.5      ggplot2_3.3.5      digest_0.6.29      htmltools_0.5.2    fansi_1.0.3       
#>  [13] magrittr_2.0.3     memoise_2.0.1      base64url_1.4      geojsonsf_2.0.2    gert_1.6.0         config_0.3.1      
#>  [19] tzdb_0.3.0         credentials_1.3.2  globals_0.14.0     RCzechia_1.9.1     extrafont_0.17     vroom_1.5.7       
#>  [25] extrafontdb_1.0    askpass_1.1        colorspace_2.0-3   blob_1.2.2         gitcreds_0.1.1     xfun_0.30         
#>  [31] callr_3.7.0        crayon_1.5.1       jsonlite_1.8.0     glue_1.6.2         gtable_0.3.0       V8_4.1.0          
#>  [37] Rttf2pt1_1.3.10    scales_1.2.0       quarto_1.1         DBI_1.1.2          Rcpp_1.0.8.3       xtable_1.8-4      
#>  [43] units_0.8-0        foreign_0.8-81     bit_4.0.4          proxy_0.4-26       htmlwidgets_1.5.4  httr_1.4.2        
#>  [49] ellipsis_0.3.2     pkgconfig_2.0.3    sass_0.4.0         utf8_1.2.2         janitor_2.1.0      crul_1.2.0        
#>  [55] tidyselect_1.1.2   rlang_1.0.2        later_1.3.0        munsell_0.5.0      cellranger_1.1.0   tools_4.1.2       
#>  [61] cachem_1.0.6       cli_3.2.0          generics_0.1.2     RSQLite_2.2.13     evaluate_0.15      fastmap_1.1.0     
#>  [67] yaml_2.3.5         sys_3.4            processx_3.5.2     knitr_1.38         bit64_4.0.5        fs_1.5.2          
#>  [73] gh_1.3.0           whisker_0.4        mime_0.12          xml2_1.3.3         compiler_4.1.2     e1071_1.7-9       
#>  [79] bslib_0.3.1        stringi_1.7.6      ps_1.6.0           gdtools_0.2.4      hrbrthemes_0.8.0   rgeos_0.5-9       
#>  [85] lattice_0.20-45    classInt_0.4-3     vctrs_0.4.1        CzechData_0.6.0    pillar_1.7.0       lifecycle_1.0.1   
#>  [91] jquerylib_0.1.4    data.table_1.14.2  geojsonio_0.9.4    maptools_1.1-4     raster_3.5-15      httpuv_1.6.5      
#>  [97] R6_2.5.1           promises_1.2.0.1   renv_0.15.4        KernSmooth_2.23-20 parallelly_1.30.0  codetools_0.2-18  
#> [103] assertthat_0.2.1   openssl_2.0.0      rprojroot_2.0.3    withr_2.5.0        httpcode_0.3.0     parallel_4.1.2    
#> [109] hms_1.1.1          geojson_0.3.4      terra_1.5-21       grid_4.1.2         class_7.3-19       rmarkdown_2.13    
#> [115] snakecase_0.11.0   ptrr_0.2.1         sf_1.0-7
```

</details>
