#' Turn `conditionContrasts` object into a `traitSignal` object.
#'
#' @param contrasts data frame
#'
#' @return data frame
#'
#' @importFrom dplyr across arrange everything filter mutate rename select
#' @importFrom rlang .data
#' @importFrom stringr str_remove
#' @importFrom tidyr unite
#' @importFrom utils combn
#' 
contrast_signal <- function(contrasts) {
  if(is.null(contrasts))
    return(NULL)
  
  dplyr::mutate(
    dplyr::select(
      dplyr::rename(
        contrasts,
        cellmean = "value"),
      -p.value),
    signal = .data$cellmean)
}
#' Correlation Table
#' 
#' @param key_trait 
#' @param traitSignal 
#' @param corterm 
#' @param mincor 
#' @param reldataset 
#' 
#' @param data frame
#'
cor_table <- function(key_trait, traitSignal, corterm, mincor = 0,
                      reldataset = NULL) {
  
  if(is.null(key_trait) || is.null(traitSignal))
    return(NULL)
  
  if(is.null(reldataset))
    return(NULL)
  #    return(dplyr::distinct(object, .data$dataset, .data$trait))
  
  # Select rows of traitSignal() with Key Trait or Related Datasets.
  object <- select_data_pairs(traitSignal, key_trait, reldataset)
  
  # Filter by mincor
  dplyr::filter(
    foundr::bestcor(object, key_trait, corterm),
    .data$absmax >= mincor)
}
#' Eigen Contrasts from Dataset
#' 
#' @param object 
#' @param contr_object 
#' 
#' @return data frame
#'
eigen_contrast_dataset <- function(object, contr_object) {
  if(is.null(object) | is.null(contr_object))
    return(NULL)
  
  if(!foundr:::is_sex_module(object))
    return(foundr:::eigen_contrast_dataset_value(object, contr_object))
  
  foundr:::eigen_contrast_dataset_sex(object, contr_object)
}
#' Eigen Traits from Dataset
#' 
#' @param object 
#' @param sexname 
#' @param modulename 
#' @param contr_object 
#' @param eigen_object 
#' 
#' @return data frame
#'
eigen_traits_dataset <- function(object = NULL,
                                 sexname = NULL,
                                 modulename = NULL,
                                 contr_object = NULL,
                                 eigen_object = eigen_contrast(object, contr_object)) {
  if(is.null(object) | is.null(contr_object))
    return(NULL)
  
  if(!foundr:::is_sex_module(object))
    return(foundr:::eigen_traits_dataset_value(object, sexname, modulename, contr_object, eigen_object))
  
  foundr:::eigen_traits_dataset_sex(object, sexname, modulename, contr_object, eigen_object)
}
#' Mutate Datasets
#' 
#' @param object 
#' @param datasets 
#' @param undo 
#' 
#' @return data frame with `dataset` and possibly `probandset` columns
#'
mutate_datasets <- function(object, datasets = NULL, undo = FALSE) {
  if(is.null(object))
    return(NULL)
  
  if(undo) {
    for(i in seq_along(datasets)) {
      object <- dplyr::mutate(
        object,
        dataset = ifelse(
          .data$dataset == datasets[[i]],
          names(datasets)[i], .data$dataset))
    }
  } else {
    if(is.null(datasets))
      return(object)
    
    object$dataset <- as.character(object$dataset)
    m <- match(object$dataset, names(datasets), nomatch = 0)
    object$dataset[m>0] <- datasets[m]
    if("probandset" %in% names(object)) {
      object$probandset <- as.character(object$probandset)
      m <- match(object$probandset, names(datasets), nomatch = 0)
      object$probandset[m>0] <- datasets[m]
    }
  }
  object
}
#' Order Choices
#' 
#' @param traitStats
#'  
#' @return vector of stats terms
#' 
order_choices <- function(traitStats) {
  p_types <- paste0("p_", unique(traitStats$term))
  p_types <- p_types[!(p_types %in% c("p_cellmean", "p_signal", "p_rest", "p_noise", "p_rawSD"))]
  p_types <- stringr::str_remove(p_types, "^p_")
  if("strain:diet" %in% p_types)
    p_types <- unique(c("strain:diet", p_types))
  c(p_types, "alphabetical", "original")
}
#' Order Trait Statistics
#'
#' @param orders name of order criterion 
#' @param traitStats data frame with statistics
#'
#' @return data frame
#' @importFrom dplyr arrange filter left_join select
#' @importFrom stringr str_remove
#' @importFrom rlang .data
#'
order_trait_stats <- function(orders, traitStats) {
  out <- traitStats
  if(is.null(out))
    return(NULL)
  
  if(orders == "alphabetical") {
    out <- dplyr::arrange(out, .data$trait)
  } else {
    if(orders != "original") {
      # Order by p.value for termname
      termname <- stringr::str_remove(orders, "p_")
      out <- 
        dplyr::arrange(
          dplyr::filter(
            out,
            .data$term == termname),
          .data$p.value)
    }
  }
  out
}
#' Select data including Key Trait and Related Datasets
#'
#' @param object data frame
#' @param key_trait name of key trait
#' @param rel_dataset name of related datasets
#'
#' @importFrom dplyr filter select
#' @importFrom tidyr unite
#' @importFrom rlang .data
#' 
#' @return data frame
#'
select_data_pairs <- function(object, key_trait, rel_dataset = NULL) {
  if(is.null(object))
    return(NULL)
  
  dplyr::select(
    dplyr::filter(
      tidyr::unite(
        object,
        datatraits,
        .data$dataset, .data$trait,
        sep = ": ", remove = FALSE),
      (.data$datatraits %in% key_trait) |
        (.data$dataset %in% rel_dataset)),
    -datatraits)
}
#' Stat Terms
#'
#' @param object 
#' @param signal 
#' @param condition_name 
#' @param drop_noise 
#' @param cellmean 
#' @param ... 
#'
#' @return vector of terms
#'
term_stats <- function(object, signal = TRUE, condition_name = NULL,
                      drop_noise = TRUE, cellmean = signal, ...) {
  terms <- unique(object$term)
  # Drop noise and other terms not of interest to user.
  terms <- terms[!(terms %in% c("rest","rawSD"))]
  if(drop_noise) { 
    terms <- terms[terms != "noise"]
  }
  
  if(is.null(condition_name))
    condition_name <- "condition"
  if(signal) {
    # Return the strain terms with condition if present
    if(any(grepl(condition_name, terms)))
      terms <- c("signal", terms[grepl(paste0(".*strain.*", condition_name), terms)])
    else
      terms <- c("signal", terms[grepl(".*strain", terms)])
  } else {
    terms <- terms[terms != "signal"]
  }
  if(!cellmean) {
    terms <- terms[terms != "cellmean"]
  }
  terms
}
#' Time Trait Subset
#'
#' @param object 
#' @param timetrait_all 
#'
#' @return data frame
#'
time_trait_subset <- function(object, timetrait_all) {
  if(is.null(object) || is.null(timetrait_all))
    return(NULL)
  
  object <- tidyr::unite(object,
                         datatraits,
                         .data$dataset, .data$trait,
                         remove = FALSE, sep = ": ")
  timetrait_all <- tidyr::unite(timetrait_all,
                                datatraits,
                                .data$dataset, .data$trait,
                                remove = FALSE, sep = ": ")
  dplyr::select(
    dplyr::filter(
      object,
      .data$datatraits %in% timetrait_all$datatraits),
    -datatraits)
}
#' Time Units
#'
#' @param timetrait_all data frame
#'
#' @return data frame
#'
time_units <- function(timetrait_all) {
  # Find time units in datasets
  timeunits <- NULL
  if("minute" %in% timetrait_all$timetrait)
    timeunits <- c("minute","minute_summary")
  if("week" %in% timetrait_all$timetrait)
    timeunits <- c(timeunits, "week","week_summary")
  timeunits
}
#' Trait Pairs
#'
#' @param traitnames 
#' @param sep 
#' @param key 
#'
#' @return vector or `trait1 ON trait2`
#'
trait_pairs <- function(traitnames, sep = " ON ", key = TRUE) {
  if(length(traitnames) < 2)
    return(NULL)
  
  if(key) {
    # Key Trait vs all others.
    paste(traitnames[-1], traitnames[1], sep = sep)
  } else {
    # All Trait Pairs, both directions.
    as.vector(
      unlist(
        dplyr::mutate(
          as.data.frame(utils::combn(traitnames, 2)),
          dplyr::across(
            dplyr::everything(), 
            function(x) {
              c(paste(x, collapse = sep),
                paste(rev(x), collapse = sep))
            }))))
  }
}
#' Volcano Defaults
#'
#' @param ordername name of order column
#'  
#' @return list of volcano parameters
#' 
vol_default <- function(ordername) {
  vol <- list(min = 0, max = 10, step = 1, value = 2)
  switch(
    ordername,
    module = {
    },
    kME = {
      vol$min <- 0.8
      vol$max <- 1
      vol$step <- 0.05
      vol$value <- 0.8
    },
    p.value = {
      vol$min <- 0
      vol$max <- 10
      vol$step <- 1
      vol$value <- 2
    },
    size = {
      vol$min <- 0
      vol$max <- 30
      vol$step <- 5
      vol$value <- 15
    })
  vol$label <- ordername
  if(ordername == "p.value")
    vol$label <- "-log10(p.value)"
  
  vol
}