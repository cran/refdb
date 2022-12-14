

#' Associate columns to fields
#'
#' Associate columns to fields so they are recognized
#' and appropriately treated by refdb functions.
#'
#' @param x a reference database (tibble).
#' @param source name of the column which contains the data source.
#' @param id name of the column which contains the record IDs.
#' @param organism  name of the column which contains the names of the organisms.
#' @param taxonomy a vector of column names.
#' @param sequence name of the column which contains the sequences.
#' @param marker name of the column which contains marker names.
#' @param latitude name of the column which contains latitudes (WGS 84)
#' @param longitude name of the column which contains longitudes (WGS 84).
#' @param reference a vector of column names.
#' @param config_yaml a file path to a YAML file
#'
#' @details
#' Taxonomy reordering. NA to ignore, NULL to delete.
#' Fields set using config_yaml always overwrite those set by arguments
#'
#' @return
#' The function returns \code{x} with updated attributes.
#'
#' @examples
#' lib <- read.csv(system.file("extdata", "ephem.csv", package = "refdb"))
#' lib <- refdb_set_fields(lib,
#'                         taxonomy = c(family = "family_name",
#'                             genus = "genus_name",
#'                             species = "species_name"),
#'                         sequence = "DNA_seq",
#'                         marker = "marker")
#'
#' @export
#'
refdb_set_fields <- function(x,
                             source = NA,
                             id = NA,
                             organism = NA,
                             taxonomy = NA,
                             sequence = NA,
                             marker = NA,
                             latitude = NA,
                             longitude = NA,
                             reference = NA,
                             config_yaml = NULL) {

  if (!is.null(config_yaml)) {

    yml <- yaml::read_yaml(config_yaml)
    yml <- lapply(yml, unlist)

    for (i in seq_along(yml)) {
      assign(names(yml)[i], yml[[i]])
    }
  }

  fields_list <- attr(x, "refdb_fields")
  if(is.null(fields_list)) {
    fields_list <- list()
  }

  error_field_col <- function(x, field, col) {
    if(!col %in% colnames(x)) {
      stop("The value ", col, " used for ", field,
           " does not match with any column of x.")
    }
  }


  if (!is.na(source)) {
    error_field_col(x, "source", source)
    fields_list$source <- source
    x[, source] <- as.character(x[, source, drop = TRUE])
  }

  if (!is.na(id)) {
    error_field_col(x, "id", id)
    fields_list$id <- id
    x[, id] <- as.character(x[, id, drop = TRUE])
  }

  if (!is.na(organism)) {
    error_field_col(x, "organism", organism)
    fields_list$organism <- organism
    x[, organism] <- as.character(x[, organism, drop = TRUE])
  }

  if (!all(is.na(taxonomy))) {

    if(!all(taxonomy %in% colnames(x))) {
      stop("The values: ", setdiff(taxonomy, colnames(x)),
           " used for taxonomy do not match with any column of x.")
    }

    names(taxonomy) <- stringr::str_to_lower(names(taxonomy))

    if(!all(names(taxonomy) %in% valid_taxo_rank())) {
      stop("Taxonomic ranks are not valid. The `taxonomy` object must be a named vector. Use valid_taxo_rank() to find valid ranks.")
    }
    taxo_order <- match(names(taxonomy), valid_taxo_rank())
    fields_list$taxonomy <- taxonomy[order(taxo_order, na.last = NA)]
    x[, taxonomy] <- lapply(x[, taxonomy], as.character)
  }

  if (!is.na(sequence)) {
    error_field_col(x, "sequence", sequence)
    fields_list$sequence <- sequence
    x[, sequence] <- bioseq::as_dna(as.character(x[, sequence, drop = TRUE]))
  }

  if (!is.na(marker)) {
    error_field_col(x, "marker", marker)
    fields_list$marker <- marker
    x[, marker] <- as.character(x[, marker, drop = TRUE])
  }

  if (!is.na(latitude)) {
    error_field_col(x, "latitude", latitude)
    fields_list$latitude <- latitude
  }

  if (!is.na(longitude)) {
    error_field_col(x, "longitude", longitude)
    fields_list$longitude <- longitude
  }

  if (!all(is.na(reference))) {

    if(!all(reference %in% colnames(x))) {
      stop("The values: ", setdiff(reference, colnames(x)),
           " used for reference do not match with any column of x.")
    }
    fields_list$reference <- reference
  }

  attr(x, "refdb_fields") <- fields_list

  return(x)
}




#' Functions to set fields for various databases
#'
#' @param x a reference database.
#'
#' @return
#' The function returns \code{x} with updated attributes.
#'
#' @name fields_dbs
#'
#' @examples
#' lib <- read.csv(system.file("extdata", "baetidae_bold.csv", package = "refdb"))
#' refdb_set_fields_BOLD(lib)
#'
NULL

#' @rdname fields_dbs
#' @export
refdb_set_fields_NCBI <- function(x) {
  if(!"source" %in% colnames(x)) {
    x <- tibble::tibble(source = "NCBI", x)
  }
  refdb_set_fields(x, config_yaml = system.file("extdata", "yaml_ncbi.yml",
                                                package = "refdb"))
}


#' @rdname fields_dbs
#' @export
refdb_set_fields_BOLD <- function(x) {
  if(!"source" %in% colnames(x)) {
    x <- tibble::tibble(source = "BOLD", x)
  }
  refdb_set_fields(x, config_yaml = system.file("extdata", "yaml_bold.yml",
                                                package = "refdb"))
}


#' @rdname fields_dbs
#' @export
refdb_set_fields_PR2 <- function(x) {
  if(!"source" %in% colnames(x)) {
    x <- tibble::tibble(source = "PR2", x)
  }
  refdb_set_fields(x, config_yaml = system.file("extdata", "yaml_pr2.yml",
                                                package = "refdb"))
}

#' @rdname fields_dbs
#' @export
refdb_set_fields_diatbarcode <- function(x) {
  if(!"source" %in% colnames(x)) {
    x <- tibble::tibble(source = "Diat.barcode", x)
  }
  refdb_set_fields(x, config_yaml = system.file("extdata", "yaml_diatbarcode.yml",
                                                package = "refdb"))
}




#' Internal check for fields
#'
#' @param x a reference database (tibble object).
#' @param what a vector of fields to be checked.
#'
#' @return
#' Invisible or error.
#'
check_fields <- function(x,
                         what = c("source", "id",
                                  "taxonomy", "sequence", "marker")) {
  fields <- attributes(x)$refdb_fields

  diff <- setdiff(what, names(fields))
  if(length(diff) > 0) {
    stop("Missing field: ", paste(diff, collapse = ", "),
         "\n-- See function `refdb_set_fields` to set fields.")
  }

  # Annoying
  diff <- setdiff(unlist(fields[what]), colnames(x))
  if(length(diff) > 0) {
    stop("Some declared fields associated to non-existing columns: ",
         paste(diff, collapse = ", "),
         "\n-- See function `refdb_set_fields`.")
  }

  invisible()
}





#' Write fields to a file
#'
#' This function can be used to save fields defined
#' using e.g. \code{refdb_set_fields} to a file.
#' Data are saved in YAML and can be read again using the
#' \code{config_yaml} argument of \code{refdb_set_fields}.
#'
#' @param x a reference database with some fields to be saved.
#' @param file a path to the file to write.
#'
#' @return
#' No return value, called for its side effects.
#'
#' @examples
#' lib <- read.csv(system.file("extdata", "ephem.csv", package = "refdb"))
#' tmp <- tempfile()
#' refdb_write_fields(lib, tmp)
#'
#' @export
#'
refdb_write_fields <- function(x, file) {
  ff <- attributes(x)$refdb_fields
  if("taxonomy" %in% names(ff)) {
    ff$taxonomy <- as.list(ff$taxonomy)
  }
  yaml::write_yaml(ff, file = file)
}




#' Get fields of a reference database
#'
#' @param x a reference database.
#' @param silent if \code{TRUE} silently and invisibly
#' returns fields.
#'
#' @return
#' The list of fields is returned invisibly.
#'
#' @examples
#' lib <- read.csv(system.file("extdata", "ephem.csv", package = "refdb"))
#' refdb_get_fields(lib)
#'
#' @export
#'
refdb_get_fields <- function(x, silent = FALSE) {
  ff <- attributes(x)$refdb_fields

  if(is.null(ff)) {
    if(!silent) {
      cat("There are no field defined yet. Use the function refdb_set_fields to set fields.")
    }
  } else {
    # TODO: A cool print
    ff$taxonomy <- as.list(ff$taxonomy)
    if(!silent) {
      cat(yaml::as.yaml(ff))
    }
  }
  invisible(ff)
}
