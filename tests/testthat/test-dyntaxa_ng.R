test_that("can lookup taxonomic name from taxonomic identifier", {
  # NB: quoting of the string
  res <- dyntaxa_search('"urn:lsid:dyntaxa.se:Taxon:220023"') %>% pull(scientificName)
  is_valid <- res == "Campanula rotundifolia"
  expect_true(is_valid)
})

test_that("can lookup taxonomic identifier from taxonomic name", {
  # NB: usage of + to match both search terms
  key <- dyntaxa_search("Alces+alces") %>% pull(taxonId)
  is_valid <- key == "urn:lsid:dyntaxa.se:Taxon:206046"
  expect_true(is_valid)
})

test_that("can lookup taxonomic hierarchy/classification from identifier or name", {
  # NB: quoting of the key
  key <- "urn:lsid:dyntaxa.se:Taxon:206046"
  res <- dyntaxa_search(paste0('"', key, '"')) %>%
    select(kingdom, phylum, class, order, family, genus, species) %>% collect()
  is_valid <- nrow(res) == 1
  expect_true(is_valid)
})

test_that("can lookup taxa downstream from identifier or name", {
  res <- dyntaxa_search("Cervidae") %>% 
    filter(taxonomicStatus == "accepted") %>% collect()
  is_valid <- nrow(res) > 20
  expect_true(is_valid)
})

test_that("can lookup taxonomic immediate children of an identifier or name", {
  res <- dyntaxa_search("Carnivora") %>% filter(taxonRank == "suborder") %>%
    filter(taxonomicStatus == "accepted") %>%
    collect()
  is_valid <- nrow(res) == 2
  expect_true(is_valid)
})

test_that("can lookup taxa downstream at specific rank", {
  # can be filtered at species level (or at other ranks)
  res <- dyntaxa_search("Carnivora") %>% 
    filter(taxonRank == "species") %>%
    filter(taxonomicStatus == "accepted") %>%
    collect()
  is_valid <- nrow(res) > 20
  expect_true(is_valid)
})

test_that("can lookup synonyms for Sagedia zonata", {
  res <- dyntaxa_search("Sagedia+zonata synonym") %>% 
    collect() %>% pull(scientificName)
  is_valid <- length(res) > 20
  expect_true(is_valid)
})

test_that("can lookup synonyms for Citronfjäril", {
  res <- dyntaxa_search("Citronfjäril") %>%
    select(taxonomicStatus, scientificName) %>% 
    pull(scientificName)
  is_valid <- res == "Gonepteryx rhamni"  
  expect_true(is_valid)
})
