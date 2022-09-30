generate_degs_with_plots <- function(seurat, degs_root, compare_by, group_by = NULL, comparisons = NULL, covariates = NULL, cores = 1) {
  group_by_string <- c('', group_by) |> paste(collapse = '%')
  degs_root <- "{degs_root}/{group_by_string}@{compare_by}" |> glue() |> mkdirs()
  # generate_degs(seurat, degs_root, compare_by, group_by, comparisons, covariates, cores)
  deg_instructions_list <- generate_full_deg_instructions(seurat, degs_root, compare_by, group_by, comparisons, covariates, cores)
  generate_degs_2(seurat, deg_instructions_list, cores = 1)
  generate_volcano_plots(
    degs_path = "{degs_root}/degs" |> glue(),
    volcano_path = "{degs_root}/volcano-plots" |> glue() |> mkdirs(),
    logfc_threshold = 0.25,
    bh_threshold = 0.000001,
  )
}
# "{dirs$scripts}/metadata/add-metadata.R" |> glue() |> source()
# seurat <- f$seurat$chen$astrocyte$load()
# seurat <- seurat |> add_metadata()
"{dirs$scripts}/differential-expression/generate-degs.R" |> glue() |> source()
"{dirs$scripts}/differential-expression/generate-volcano-plots.R" |> glue() |> source()
de_root <- "{dirs$project_root}/documents/differential-expression/test/separate-seurat-objects/astrocyte" |> glue() |> mkdirs()

generate_degs_with_plots(
  seurat = seurat,
  degs_root = de_root,
  compare_by = c('diagnosis_cogdx'),
  group_by = NULL,
  comparisons = list(
    c('MCI', 'NCI'),
    c('MCI+', 'NCI'),
    c('AD', 'NCI'),
    c('AD+', 'NCI'),
    c('OD', 'NCI'),
    c('AD', 'AD+'),
    c('MC', 'MC+'),
    c('MC', 'AD')
  ),
  covariates = c('sex', 'apoe_genotype'),
  cores = 8
)
