library(Seurat)

add_metadata <- function(seurat) {
  metadata <- "{dirs$metadata}/dataset_1153_basic_04-08-2022.csv" |> glue() |> fread(keepLeadingZeros = TRUE)
  metadata_long <- "{dirs$metadata}/dataset_1153_long_04-08-2022.csv" |> glue() |> fread(keepLeadingZeros = TRUE)
  
  ids <- seurat@meta.data$projid |> unique()
  metadata.subset <- metadata[ projid %in% ids]
  # metadata.subset <- metadata.subset[, c('projid', "apoe_genotype", "age_first_ad_dx", "age_bl", "msex", "race7")]
  
  race_mapper <- data.table(
    race7 = c(1, 2, 3, 4, 5, 6, 7),
    race = c('white', 'black','native-american', 'pacific-islander', 'asian', 'other', 'unknown')
  )
  metadata.subset <- race_mapper[metadata.subset, on = c("race7" = "race7")]
  
  metadata.subset$sex[metadata.subset$msex == 1] <- 'male'
  metadata.subset$sex[metadata.subset$msex == 0] <- 'female'
  
  cogdx_mapper <- data.table(
    cogdx = c(1, 2, 3, 4, 5, 6),
    diagnosis_cogdx = c('NCI', 'MCI','MCI+', 'AD', 'AD+', 'OD')
  )
  metadata.subset <- cogdx_mapper[metadata.subset, on = c("cogdx" = "cogdx")]
  
  niareagansc_mapper <- data.table(
    niareagansc = c(1, 2, 3, 4),
    niareagansc_ad_likelihood = c('High','Intermediate+', 'Low', 'No AD')
  )
  metadata.subset <- niareagansc_mapper[metadata.subset, on = c("niareagansc" = "niareagansc")]
  
  
  metadata.subset <- metadata.subset[seurat@meta.data |> as.data.table(), on = c('projid' = 'projid')]
  metadata.subset <- metadata.subset |> as.data.frame()
  rownames(metadata.subset) <- seurat@meta.data |> rownames()
  
  metadata.subset <- metadata.subset[, c('apoe_genotype', 'sex', 'race', 'age_bl', 'age_first_ad_dx', 'cogdx', 'diagnosis_cogdx', 'niareagansc', 'niareagansc_ad_likelihood', 'ad_reagan')]
  
  seurat <- seurat |> AddMetaData(metadata.subset)
  colnames(seurat@meta.data)[colnames(seurat@meta.data) == 'ct'] <- 'cluster_fine_grain'
  colnames(seurat@meta.data)[colnames(seurat@meta.data) == 'cell.type'] <- 'cluster_coarse_grain'
  
  # seurat@meta.data |> colnames() |> lapply(\(colname){
  #   if (seurat@meta.data[[colname]] |> class() %>% .[[1]] == "character") {
  #     seurat@meta.data[[colname]] <- seurat@meta.data[[colname]] %>% gsub('/|@|%', '~', .)
  #   }
  # })
  seurat@meta.data$cluster_fine_grain <- seurat@meta.data$cluster_fine_grain %>% gsub('/|@|%', '~', .)
  seurat@meta.data$cluster_coarse_grain <- seurat@meta.data$cluster_coarse_grain %>% gsub('/|@|%', '~', .)
  
  seurat
}