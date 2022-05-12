
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
s počty těchto lidí podle pohlaví, obce pobytu a věkových skupin. Jsou
to vždy kumulativní data a zřejmě dochází i k jejich upřesňování, tj.
změny mezi soubory z jednotlivých dnů mohou být buď následkem reálné
změny, nebo zpětného upřesnění.

Na tato data se pak napojují číselníky území ČSÚ a indexová data PAQ o
školách na úrovni ORP (viz níže).

## Omezení dat

Viz především text na webu MV.

V datech jsem zajím objevil tyto problémy:

-   v datech do 16. 3. nejsou kódy obcí, čili pro tyto dny je to skoro
    nepoužitelné pro územní pohled
-   XLSX link z 27. 3. vede na soubor z 28. 3. a XLSX soubor z 27. 3. na
    serveru ani není (XLS soubor tam je a správně odkázaný, ale XLSX je
    preferovaný, otevřenější formát)
-   pro 30. března je místo XLS soubor XLT (data v něm sice jsou, ale
    není důvod to poskytovat v tomto formátu)

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
ze [vzdělávací mapy PAQ](https://mapavzdelavani.cz/).

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
#> Attaching package: 'arrow'
#> The following object is masked from 'package:utils':
#> 
#>     timestamp
#> 
#> Attaching package: 'bs4Dash'
#> The following object is masked from 'package:graphics':
#> 
#>     box
#> * Option 'clustermq.scheduler' not set, defaulting to 'LOCAL'
#> --- see: https://mschubert.github.io/clustermq/articles/userguide.html#configuration
#> Using libcurl 7.79.1 with LibreSSL/3.3.6
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#> 
#> Attaching package: 'lubridate'
#> The following object is masked from 'package:arrow':
#> 
#>     duration
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union
#> 
#> Attaching package: 'pingr'
#> The following object is masked from 'package:utils':
#> 
#>     nsl
#> 
#> Attaching package: 'readr'
#> The following object is masked from 'package:curl':
#> 
#>     parse_date
#> 
#> Attaching package: 'rvest'
#> The following object is masked from 'package:readr':
#> 
#>     guess_encoding
#> 
#> Attaching package: 'shiny'
#> The following objects are masked from 'package:bs4Dash':
#> 
#>     actionButton, column, insertTab, tabsetPanel
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
#>  [1] writexl_1.4.0      visNetwork_2.1.0   tidyr_1.2.0        tibble_3.1.6       stringr_1.4.0      shinyWidgets_0.6.4 shinybusy_0.3.0   
#>  [8] shiny_1.7.1        rvest_1.0.2        rstudioapi_0.13    readxl_1.4.0       readr_2.1.2        purrr_0.3.4        pingr_2.0.1       
#> [15] markdown_1.1       lubridate_1.8.0    gt_0.4.0           future_1.24.0      forcats_0.5.1      dplyr_1.0.8        czso_0.3.9        
#> [22] curl_4.3.2         clustermq_0.8.95.3 bs4Dash_2.1.0      arrow_7.0.0        targets_0.12.0    
#> 
#> loaded via a namespace (and not attached):
#>  [1] bit64_4.0.5       httr_1.4.2        tools_4.1.2       backports_1.4.1   bslib_0.3.1       utf8_1.2.2        R6_2.5.1         
#>  [8] DBI_1.1.2         colorspace_2.0-3  withr_2.5.0       tidyselect_1.1.2  processx_3.5.2    bit_4.0.4         compiler_4.1.2   
#> [15] extrafontdb_1.0   cli_3.2.0         xml2_1.3.3        sass_0.4.0        scales_1.2.0      callr_3.7.0       systemfonts_1.0.4
#> [22] digest_0.6.29     rmarkdown_2.13    pkgconfig_2.0.3   htmltools_0.5.2   extrafont_0.17    parallelly_1.30.0 fastmap_1.1.0    
#> [29] htmlwidgets_1.5.4 rlang_1.0.2       jquerylib_0.1.4   generics_0.1.2    jsonlite_1.8.0    config_0.3.1      magrittr_2.0.3   
#> [36] Rcpp_1.0.8.3      munsell_0.5.0     fansi_1.0.3       gdtools_0.2.4     lifecycle_1.0.1   ptrr_0.2.1        stringi_1.7.6    
#> [43] yaml_2.3.5        grid_4.1.2        hrbrthemes_0.8.0  parallel_4.1.2    listenv_0.8.0     promises_1.2.0.1  crayon_1.5.1     
#> [50] hms_1.1.1         knitr_1.38        ps_1.6.0          pillar_1.7.0      igraph_1.2.11     base64url_1.4     codetools_0.2-18 
#> [57] quarto_1.1        glue_1.6.2        evaluate_0.15     data.table_1.14.2 renv_0.15.4       vctrs_0.4.1       tzdb_0.3.0       
#> [64] httpuv_1.6.5      Rttf2pt1_1.3.10   cellranger_1.1.0  gtable_0.3.0      assertthat_0.2.1  ggplot2_3.3.5     xfun_0.30        
#> [71] mime_0.12         xtable_1.8-4      later_1.3.0       globals_0.14.0    ellipsis_0.3.2
```

</details>
