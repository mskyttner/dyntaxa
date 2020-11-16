
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dyntaxa

<!-- badges: start -->

[![R build
status](https://github.com/mskyttner/dyntaxa/workflows/R-CMD-check/badge.svg)](https://github.com/mskyttner/dyntaxa/actions)
<!-- badges: end -->

The goal of the `dyntaxa` R package is to provide a read-only R package
to interface with Dyntaxa - the taxonomic database of organisms in
Sweden.

Dyntaxa contains information about 61,500 species occurring in Sweden.
This includes about 95% of known multicellular species – remaining gaps
mainly found among the fungi. The scope of organisms include
multicellular species documented in Sweden and such unicellular species
that are included in environmental monitoring by the Swedish EPA. In
addition to these species there are many names at other taxonomic
levels, scientific synonyms, Swedish vernaculars.

## Credits and acknowledgements

The Dyntaxa database is published by
[Artdatabanken](https://www.gbif.org/publisher/b8323864-602a-4a7d-9127-bb903054e97d)
at
[GBIF.org](https://www.gbif.org/dataset/de8934f4-a136-481c-a87a-b0b202b80a31)
by Johan Liljeblad.

## Citation to use for refering to Dyntaxa

Liljeblad J (2019). Dyntaxa. Svensk taxonomisk databas. ArtDatabanken.
Checklist dataset <https://doi.org/10.15468/j43wfc>.

## Installation

You can install the `dyntaxa` R package from
[GitHub](https://github.com/mskyttner/dyntaxa) with:

``` r
remotes::install_github("mskyttner/dyntaxa")
```

## Example usage

This package can be used to automate the following tasks:

  - Taxonomic identifier from a taxonomic name and vice versa
  - Taxonomic name from a vernacular (common) name and vice versa
  - Taxonomic hierarchy/classification from identifier or name
  - Taxonomic children of an identifier or name
  - All taxa downstream to a certain rank from identifier or name
  - Taxonomic synonyms from identifier or name

Here are some short and simple usage examples which shows you how to
download and access data from Dyntaxa for those tasks.

``` r
# we use dplyr for data manipulation (pipe, filtering etc)
suppressPackageStartupMessages(library(dplyr))



library(dyntaxa)
    __             __
.--|  .--.--.-----|  |_.---.-.--.--.---.-.
|  _  |  |  |     |   _|  _  |_   _|  _  |
|_____|___  |__|__|____|___._|__.__|___._|
      |_____|
Cannot find Dyntaxa data locally...
... attempting download using library(dyntaxa); dyntaxa_init()

#lookup taxonomic name from taxonomic identifier
dyntaxa_search('"urn:lsid:dyntaxa.se:Taxon:220023"') %>% 
  pull(scientificName)
[1] "Campanula rotundifolia"

# lookup taxonomic identifier from taxonomic name
dyntaxa_search("Alces+alces") %>% pull(taxonId)
[1] "urn:lsid:dyntaxa.se:Taxon:206046"

# search fulltext index for several terms
dyntaxa_search("blåklocka OR vitsippa")
# A tibble: 7 x 17
  taxonId acceptedNameUsa… parentNameUsage… scientificName taxonRank
  <chr>   <chr>            <chr>            <chr>          <chr>    
1 urn:ls… urn:lsid:dyntax… urn:lsid:dyntax… Anemone nemor… species  
2 urn:ls… urn:lsid:dyntax… urn:lsid:dyntax… Campanula rot… species  
3 urn:ls… urn:lsid:dyntax… urn:lsid:dyntax… Campanula rot… subspeci…
4 urn:ls… urn:lsid:dyntax… urn:lsid:dyntax… Campanula ame… species  
5 urn:ls… urn:lsid:dyntax… urn:lsid:dyntax… Anemone nemor… species  
6 urn:ls… urn:lsid:dyntax… urn:lsid:dyntax… Campanula per… species  
7 urn:ls… urn:lsid:dyntax… urn:lsid:dyntax… Campanula per… variety  
# … with 12 more variables: scientificNameAuthorship <chr>,
#   taxonomicStatus <chr>, nomenclaturalStatus <chr>, taxonRemarks <chr>,
#   kingdom <chr>, phylum <chr>, class <chr>, order <chr>, family <chr>,
#   genus <chr>, species <chr>, vern <chr>
```

## Archive for dyntaxa datasets

Available older dyntaxa database files can be listed from the file
mirror archive:

``` r

dyntaxa_archive() %>% slice(1:5)
# A tibble: 5 x 3
  fn                   ts                  url                                  
  <chr>                <dttm>              <chr>                                
1 dyntaxa-dwca-2020_1… 2020-11-16 02:00:00 https://archive.infrabas.se/dyntaxa/…
2 dyntaxa-dwca-2020_1… 2020-11-15 02:00:00 https://archive.infrabas.se/dyntaxa/…
3 dyntaxa-dwca-2020_1… 2020-11-14 02:00:00 https://archive.infrabas.se/dyntaxa/…
4 dyntaxa-dwca-2020_1… 2020-11-13 02:00:00 https://archive.infrabas.se/dyntaxa/…
5 dyntaxa-dwca-2020_1… 2020-11-12 02:00:00 https://archive.infrabas.se/dyntaxa/…
```

Some files are duplicates, find out which ones:

``` r

knitr::kable(dyntaxa_archive_diffs())
```

|       cl | init                | dl                                                                      | diff\_bytes |
| -------: | :------------------ | :---------------------------------------------------------------------- | ----------: |
| 10225313 | 2020-11-16 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_16_02_00.zip> |        4122 |
| 10221191 | 2020-11-15 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_15_02_00.zip> |         216 |
| 10220975 | 2020-11-14 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_14_02_00.zip> |       \-204 |
| 10221179 | 2020-11-13 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_13_02_00.zip> |       \-135 |
| 10221314 | 2020-11-12 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_12_02_00.zip> |        \-93 |
| 10221407 | 2020-11-11 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_11_02_00.zip> |         365 |
| 10221042 | 2020-11-10 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_10_02_00.zip> |         450 |
| 10220592 | 2020-11-09 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_09_02_00.zip> |         558 |
| 10220034 | 2020-11-08 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_08_02_00.zip> |       \-165 |
| 10220199 | 2020-11-07 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_07_02_00.zip> |         140 |
| 10220059 | 2020-11-06 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_06_02_00.zip> |      \-7008 |
| 10227067 | 2020-11-05 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_05_02_00.zip> |        2100 |
| 10224967 | 2020-11-04 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_04_02_00.zip> |       \-472 |
| 10225439 | 2020-11-03 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_03_02_00.zip> |         295 |
| 10225144 | 2020-11-02 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_02_02_00.zip> |        \-76 |
| 10225220 | 2020-11-01 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_11_01_02_00.zip> |        2118 |
| 10223102 | 2020-10-31 02:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_31_02_00.zip> |      \-1589 |
| 10224691 | 2020-10-30 01:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_30_07_00.zip> |        1427 |
| 10223264 | 2020-10-30 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_30_08_00.zip> |        3224 |
| 10220040 | 2020-10-29 01:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_29_23_00.zip> |         337 |
| 10219703 | 2020-10-29 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_29_22_00.zip> |        \-86 |
| 10219789 | 2020-10-28 01:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_28_22_00.zip> |       \-610 |
| 10220399 | 2020-10-28 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_28_23_00.zip> |         289 |
| 10220110 | 2020-10-27 01:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_27_23_00.zip> |        \-40 |
| 10220150 | 2020-10-27 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_27_22_00.zip> |      \-4790 |
| 10224940 | 2020-10-26 01:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_26_22_00.zip> |         302 |
| 10224638 | 2020-10-26 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_26_23_00.zip> |        \-49 |
| 10224687 | 2020-10-25 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_25_22_00.zip> |        \-84 |
| 10224771 | 2020-10-24 23:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_25_23_00.zip> |         \-5 |
| 10224776 | 2020-10-24 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_24_22_00.zip> |        \-96 |
| 10224872 | 2020-10-23 23:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_24_21_00.zip> |        \-36 |
| 10224908 | 2020-10-23 00:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_23_21_00.zip> |        5105 |
| 10219803 | 2020-10-22 10:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_22_22_00.zip> |         457 |
| 10219346 | 2020-10-22 09:00:00 | <https://archive.infrabas.se/dyntaxa/dyntaxa-dwca-2020_10_23_22_00.zip> |          NA |
