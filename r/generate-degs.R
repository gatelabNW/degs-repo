library(Seurat)
library(MAST)
library(gtools)
library(parallel)
library(pbmcapply)
library(rjson)

# generate_degs <- function(seurat, degs_root, compare_by, group_by = NULL, comparisons = NULL, covariates = NULL, cores = 1) {
#   "\ngenerating DEGs \ncompare_by: {compare_by} \ngroup_by: {group_by} \ncomparisons: {comparisons} \ncovariates: {covariates} \nfolder: {degs_root}" |> glue() |> message()
#   if (group_by |> is.null()) {
#     seurat@meta.data$all <- 'all'
#     group_by <- 'all'
#   }
#   comparison_set <- generate_comparison_set(seurat, compare_by, group_by, comparisons)
#   seurat@meta.data$temp <- create_temp_column(seurat, group_by, compare_by)
#   Idents(seurat) <- 'temp'
#   # comparison_set |> seq_along() |> mclapply(mc.cores = cores, \(i){
#   comparison_set |> seq_along() |> lapply(\(i){
#     'Processing comparison {i} of {comparison_set |> length()}' |> glue() |> message()
#     comparison <- comparison_set[[i]]
#     # comparison_set |> lapply(\(comparison){
#     compare_groups(
#       seurat = seurat,
#       comparison = comparison,
#       degs_path = "{degs_root}/degs" |> glue() |> mkdirs(),
#       metadata_path = "{degs_root}/deg-metadata" |> glue() |> mkdirs(),
#       covariates = covariates
#     )
#   })
# }

generate_degs_2 <- function(seurat, deg_specs_list, cores = 1) {
  # deg_specs_list |> seq_along() |> lapply(\(i) {
  deg_specs_list[[1]] |> seq_along() |> mclapply(mc.cores = cores, \(i) {
    if (deg_specs_list$group_by[[i]] |> is.null()  || deg_specs_list$group_by[[i]] == 'all') {
      seurat@meta.data$all <- 'all'
      deg_specs_list$group_by[[i]] <- 'all'
    }
    seurat@meta.data$temp <- create_temp_column(seurat, deg_specs_list$group_by[[i]], deg_specs_list$compare_by[[i]])
    Idents(seurat) <- 'temp'
    compare_groups(
      seurat = seurat,
      comparison = deg_specs_list$comparison[[i]],
      degs_path = "{deg_specs_list$degs_root[[i]]}/degs" |> glue() |> mkdirs(),
      metadata_path = "{deg_specs_list$degs_root[[i]]}/deg-metadata" |> glue() |> mkdirs(),
      covariates = deg_specs_list$covariates[[i]]
    )
  })
}

generate_full_deg_instructions <- function(seurat, degs_root, compare_by, group_by = NULL, comparisons = NULL, covariates = NULL, cores = 1) {
  # "\ngenerating comparisons \ncompare_by: {compare_by} \ngroup_by: {group_by} \ncomparisons: {comparisons |> unlist() |> as.character()} \ncovariates: {covariates} \nfolder: {degs_root}" |> glue() |> message()
  "\ngenerating comparisons \ncompare_by: {compare_by} \ngroup_by: {group_by} \ncovariates: {covariates} \nfolder: {degs_root}" |> glue() |> message()
  if (group_by |> is.null()) {
    seurat@meta.data$all <- 'all'
    group_by <- 'all'
  }
  group_by_string <- c('', group_by) |> paste(collapse = '%')
  degs_root <- "{degs_root}/{group_by_string}@{compare_by}" |> glue() |> mkdirs()
  result <- list()
  result$comparison_set <- generate_comparison_set(seurat, compare_by, group_by, comparisons)
  result$group_by <- group_by |> list() |> rep(result$comparison_set |> length())
  result$compare_by <- compare_by |> rep(result$comparison_set |> length())
  result$covariates <- covariates |> list() |> rep(result$comparison_set |> length())
  result$degs_root <- degs_root |> rep(result$comparison_set |> length())
  
  result
}

generate_comparison_set <- function(seurat, compare_by, group_by = NULL, comparisons = NULL) {
  if (is.null(comparisons)) comparisons <- generate_comparisons(seurat, compare_by)
  if (!is.null(group_by)) { groups <- generate_groups(seurat, group_by) }
  groups |> mclapply(mc.cores = 6, \(group){
    # groups |> lapply(\(group){
    get_final_comparisons(comparisons, group)
  }) |> unlist(recursive = FALSE)
}

generate_comparisons <- function(seurat, column) {
  groups <- seurat@meta.data[[column]] |> unique() |> sort()
  comparisons <- combinations(n = length(groups), r = 2, v = groups)
  split(comparisons, seq(nrow(comparisons)))
}

generate_groups <- function(seurat, group_by) {
  subgroup_list <- group_by |> lapply(\(column) {
    subgroups <- seurat@meta.data[[column]] |> unique() |> sort()
    if (subgroups |> is.null()) { stop('Invalid group_by argument.  No metadata column found for \"{column}.\"' |> glue()) }
    subgroups
  })
  if (subgroup_list |> length() > 1) { subgroup_list |> create_subgroups() }
  else {subgroup_list[[1]]}
}

create_subgroups <- function(subgroup_list, subgroups_flat = NULL) {
  if (subgroups_flat |> is.null()) { subgroups_flat <- subgroup_list[[1]] }
  subgroups_flat <- subgroup_list[[2]] |> lapply(\(subgroup){
    subgroups_flat |> lapply(\(supergroup) {
      c(supergroup, subgroup)
    })
  }) |> unlist(recursive = FALSE)
  subgroup_list[[1]] <- NULL
  if (subgroup_list |> length() > 1) { subgroups_flat <- create_subgroups(subgroup_list, subgroups_flat) }
  subgroups_flat
}

get_final_comparisons <- function(comparisons, group) {
  comparisons |> lapply(\(comparison) {
    group_string <- c('', group) |> paste(collapse = '%')
    comparisons_final <- c(
      "{group_string}@{comparison[1]}" |> glue(),
      "{group_string}@{comparison[2]}" |> glue()
    )
  })
}

create_temp_column <- function(seurat, group_by, compare_by) {
  groupings_list <- group_by |> lapply(\(column){
    seurat@meta.data[[column]]
  })
  result <- ""
  for (i in seq_along(group_by)) {
    result <- "{result}%{groupings_list[[i]]}" |> glue()
  }
  "{result}@{seurat@meta.data[[compare_by]]}" |> glue()
}

compare_groups <- function(seurat, comparison, degs_path, metadata_path, covariates = NULL) {
  comparsison_string_1 <- comparison[1] |> strsplit('@') |> unlist() %>% .[2]
  comparsison_string_2 <- comparison[2] |> strsplit('@') |> unlist() %>% .[2]
  title <- glue("{comparsison_string_1} vs. {comparsison_string_2}")
  group_string <- comparison[1] |> strsplit('@') |> unlist() %>% .[1]
  title <- "{group_string}@{title}" |> glue()
  filename  <- gsub(' ', '_', title)
  tryCatch(
    {
      deg_metadata <- generate_deg_metadata(seurat, comparison, covariates)
      deg_metadata |>
        toJSON(indent=2, method="C") |>
        write("{metadata_path}/{filename}.json" |> glue())
      
      if (deg_metadata$comparison[[1]]$cell_count < 3) { 'Fewer than 3 cells in {comparison[1]}' |> glue() |> stop() }
      if (deg_metadata$comparison[[2]]$cell_count < 3) { 'Fewer than 3 cells in {comparison[2]}' |> glue() |> stop() }
      if ("{degs_path}/{filename}.csv" |> glue() |> file.exists()) { "DEGs already saved at {filename}.csv.  Skipping." |> glue() |> stop()}
      find_degs(
        seurat,
        save_path = glue("{degs_path}/{filename}.csv"),
        group_1 = comparison[1],
        group_2 = comparison[2],
        logfc.threshold = -Inf,
        covariates = covariates
      )
    },
    error=function(e) {
      "Error finding DEGs for {comparison[1]} vs. {comparison[2]}:" |> glue() |> message()
      print(e)
    }
  )
  
}


find_degs <- function(seurat, group_1, group_2, logfc.threshold = -Inf, save_path = NULL, covariates = NULL) {
  "Finding DEGs for {group_1} vs. {group_2}" |> glue() |> message()
  # TODO: Find out why multiple covariates are causing "error in evaluating the argument 'args' in selecting a method for function 'do.call': (subscript) logical subscript too long"
  # Disabling covariates until this is resolved
  
  
  # final_covariates <- covariates |> lapply(\(covariate) {
  #   column <- seurat@meta.data[[covariate]]
  # })
  
  
  degs <- FindMarkers(
    object = seurat,
    ident.1 = group_1,
    ident.2 = group_2,
    test.use = "MAST",
    logfc.threshold = logfc.threshold,
    # min.pct = 0.1,
    # min.cells.group = 1,
    # min.cells.feature = 1,
    assay = "RNA",
    # latent.vars = covariates,
    verbose = TRUE
  )
  degs$BH <- p.adjust(degs$p_val, method = "BH")
  degs$significance <- -log10(degs$BH)
  
  if (!is.null(save_path)) {
    "Savings DEGs to {save_path}" |> glue() |> message()
    fwrite(degs, file = '{save_path}.incomplete' |> glue(), row.names = TRUE)
    message("Success")
  }
  file.rename(from = '{save_path}.incomplete' |> glue(), to = save_path)
  # no retrun here to try to save memory
  # degs
}

generate_deg_metadata <- function(seurat, comparisons_final, covariates = NULL) {
  comparison_metadata <- comparisons_final |> lapply(\(group){
    metadata_subset <- seurat@meta.data[seurat@meta.data$temp == group,]
    result <- list()
    result$cell_count <- metadata_subset |> dim() %>% .[1]
    result$sex <- metadata_subset$sex |> table() |> as.list()
    result$apoe_genotype <- metadata_subset$apoe_genotype |> table() |> as.list()
    result$diagnosis_cogdx <- metadata_subset$diagnosis_cogdx |> table() |> as.list()
    
    result
  })
  names(comparison_metadata) <- comparisons_final
  deg_metadata <- list()
  deg_metadata$comparison  <- comparison_metadata
  deg_metadata$covariates  <- covariates
  deg_metadata
}