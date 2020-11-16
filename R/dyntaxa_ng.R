#' Listing of available dyntaxa database archive files
#' @details Source: https://archive.infrabas.se/dyntaxa/
#' @export 
#' @importFrom lubridate parse_date_time
#' @importFrom stringr str_subset str_match_all
#' @importFrom httr GET content
#' @importFrom dplyr tibble select mutate
dyntaxa_archive <- function() {
  
  parse_ts <- function(x)
    lubridate::parse_date_time(stringr::str_subset(x,
      "\\d{4}_\\d{2}_\\d{2}_\\d{2}_\\d{2}"), orders = "%Y_%m_%d_%H_%M")
  
  httr::GET("https://archive.infrabas.se/dyntaxa/") %>%
    httr::content(as = "text") %>%
    stringr::str_match_all(pattern = "(dyntaxa-dwca-.*?\\.zip)") %>%
    dplyr::tibble(fn = unlist(.)) %>%
    dplyr::select(fn) %>%
    dplyr::mutate(ts = parse_ts(fn)) %>%
    arrange(desc(ts)) %>%
    dplyr::mutate(url = paste0("https://archive.infrabas.se/dyntaxa/", fn)) %>%
    distinct()
}

#' Deduplicates dyntaxa files downloadable from the archive mirror
#' 
#' This function makes a HEAD request and based on content length,
#' it computes a diff. 
#' @details a suggested command that can be used to prune dupes is
#' provided as an attribute attached to the result
#' @return a tibble with an attribute "prune_cmd"
#' @export 
#' @importFrom purrr map_chr
#' @importFrom httr HEAD
dyntaxa_archive_diffs <- function() {
  
  a <- dyntaxa_archive()
  
  # compute content lengths for all urls from HEAD requests
  cl <- purrr::map_chr(a$url, function(x) httr::HEAD(x)$headers$`content-length`)
  a$cl <- as.numeric(cl)
  
  diffs <- a %>% group_by(cl) %>%
    summarize(init = min(ts), dl = first(url)) %>%
    arrange(desc(init)) %>%
    mutate(diff_bytes = c((lag(cl, 1) - cl)[-1], NA))
  
  prune <- setdiff(a$url, diffs$dl)
  fn <- a %>% filter(url %in% prune) %>% pull(fn)
  cmd <- sprintf("rm %s", paste(collapse = " ", fn))

  class(diffs) <- c("tbl_df", "tbl", "data.frame")
  structure(diffs, prune_cmd = cmd) 
  
}

#' Location on disk for dyntaxa SQLite3 database
#' 
#' Returns the location for the SQLite3 database
#' @return the path where the downloaded SQLite3 database will reside
#' @export
dyntaxa_fts <- function() 
  file.path(app_dir("dyntaxa")$config(), "dyntaxa-fts.sqlite")

#' A connection to a full text searchable index of Dyntaxa
#' 
#' If a local database does not exist, this function downloads and creates it.
#' @param db optional path to local database file (see dyntaxa_fts() for location)
#' @param refresh_url optional url for downloading data from non-default locations
#' @importFrom RSQLite dbConnect SQLite dbExistsTable dbRemoveTable dbWriteTable dbListTables dbExecute dbGetQuery
#' @importFrom readr read_tsv
#' @importFrom dplyr group_by arrange summarize select
dyntaxa_con <- function(db, refresh_url) {
  
  if (missing(db)) dyntaxa_db <- dyntaxa_fts()
  
  if (file.exists(dyntaxa_db) && missing(refresh_url)) {
    con <- RSQLite::dbConnect(RSQLite::SQLite(), dyntaxa_db)
    return(con)
  }
  
  message("Generating full text search index for Dyntaxa at ", dyntaxa_db)
  if (!dir.exists(dirname(dyntaxa_db))) 
    dir.create(dirname(dyntaxa_db))
  
  if (missing(refresh_url))
    refresh_url <- dyntaxa_archive()$url[1]
  
  tmp <- tempfile()
  download.file(refresh_url, tmp)
  
  fn <- unzip(tmp, list = TRUE)$Name
  tsvs <- c("Taxon.csv", "VernacularName.csv")
  
  stopifnot({
    "URL does not contain zip with required files" = all(tsvs %in% fn)    
  })
  
  t <- suppressMessages(readr::read_tsv(unz(tmp, filename = "Taxon.csv")))
  v <- suppressMessages(readr::read_tsv(unz(tmp, filename = "VernacularName.csv")))
  
  v2 <-
    v %>% dplyr::group_by(taxonId) %>% dplyr::arrange(desc(isPreferredName)) %>%
    dplyr::summarize(vern = paste(collapse = " ", vernacularName)) %>%
    dplyr::select(taxonId, vern)
  
  taxa <- t %>% left_join(v2, by = "taxonId")
  
  con <- RSQLite::dbConnect(RSQLite::SQLite(), dyntaxa_db)
  
  if (RSQLite::dbExistsTable(con, "taxa"))
    RSQLite::dbRemoveTable(con, "taxa")
  
  RSQLite::dbWriteTable(con, "taxa", taxa)
  
  if (!"fts" %in% RSQLite::dbListTables(con)) {
    
    RSQLite::dbExecute(con, statement = "create virtual table fts using fts5(key, terms);")
    
    n_terms <- RSQLite::dbExecute(con, statement = paste0(
      "insert into fts select taxonID as key, printf('",
      paste(collapse = " ", rep("%s", 12)), "',
          `taxonID`,
          `scientificName`, `taxonRank`, `taxonomicStatus`,
          `kingdom`, `phylum`, `class`,
          `order`, `family`, `genus`, `species`, `vern`) as terms FROM taxa;")
    )
  }
  n_keys <- RSQLite::dbGetQuery(con, "select count(*) from fts;")
  message("Added FTS index for ", n_keys, " taxa, covering ", n_terms,
          " search terms.")
  return(con)
}

#
#dyntaxa_con()
#dyntaxa_con(refresh_url = "https://api.artdatabanken.se/taxonservice/v1/DarwinCore/DarwinCoreArchiveFile?Subscription-Key=4b068709e7f2427d9fc76bf42d8e2b57")
#unlink(dyntaxa_fts())
#con <- dyntaxa_con()

#' @noRd
search_fuzzy <- function(con, search_term) {
  
  query <- paste("select key, terms from fts",
                 sprintf("where terms match '%s'", search_term))
  res <- custom_query(con, query)
  #return(as_tibble(res))
  return (res)
}

#' @noRd
custom_query <- function(con, sql_query){
  
  con %>%
    tbl(sql(sql_query)) %>%
    collect()
  
}

#' @noRd
#' @import dplyr
search_ <- function(con, term) {
  if (term == "*") return(con %>% tbl("taxa") %>% collect())
  keys <- con %>% search_fuzzy(term) %>% dplyr::pull(key)
  con %>% tbl("taxa") %>% filter(taxonId %in% keys) %>% collect()
}

#' @noRd
dyntaxa_disconnect <- function(con) {
  RSQLite::dbDisconnect(con)
}

#' Search dyntaxa using full text search syntax
#' 
#' Use search terms except for barewords "AND", "OR" or "NOT" case sensitive.
#' Strings including other characters needs to be quoted. See the examples.
#' 
#' @param term search phrase
#' @return tibble with search results
#' @details For a descripton of the search syntax, see <https://www.sqlite.org/fts5.html>
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  dyntaxa_search("blåklocka")
#'  dyntaxa_search('"^italiensk*"')
#'  dyntaxa_search('NEAR("geting" "norsk")')$vern
#'  }
#' }
#' @rdname dyntaxa_search
#' @export 
dyntaxa_search <- function(term) {
  con <- dyntaxa_con()
  on.exit(dyntaxa_disconnect(con))
  if (!missing(term)) return(search_(con, term))
  return(search_(con, "*"))
}

#' Download Dyntaxa darwin core archive and 
#' prepare data for local use with this R package
#' @export 
dyntaxa_init_fts <- function() {
  con <- dyntaxa_con()
  on.exit(dyntaxa_disconnect(con))
  invisible(TRUE)
}

