

combine_deg_instructions <- function(deg_instructions, deg_instructions_combined) {
  deg_instructions_combined <- deg_instructions |> names() |> lapply(\(name){
    c(deg_instructions_combined[[name]], deg_instructions[[name]])
  })
  names(deg_instructions_combined) <- names(deg_instructions)
  deg_instructions_combined
}


"{dirs$scripts}/metadata/add-metadata.R" |> glue() |> source()
c(
  'astrocyte',
  'endothelial_cell',
  'excitatory_neuron',
  'immune_cell',
  'interneuron',
  'oligodendrocyte',
  'OPC',
  'stromal_cell'
) |> sort() |> lapply(\(cluster){
  seurat <- f$seurat$chen[[cluster]]$load()
  seurat <- seurat |> add_metadata()
  "{dirs$scripts}/differential-expression/generate-degs.R" |> glue() |> source()
  "{dirs$scripts}/differential-expression/generate-volcano-plots.R" |> glue() |> source()
  de_root <- "{dirs$project_root}/documents/differential-expression/separate-seurat-objects/{cluster}" |> glue() |> mkdirs()
  deg_instructions_combined <- list()
  deg_instructions_combined <- generate_full_deg_instructions(
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
    covariates = c('sex', 'apoe_genotype')
  ) |> combine_deg_instructions(deg_instructions_combined)

  deg_instructions_combined <- generate_full_deg_instructions(
    seurat = seurat,
    degs_root = de_root,
    compare_by = 'diagnosis_cogdx',
    group_by = c('cluster_fine_grain'),
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
    covariates = c('sex', 'apoe_genotype')
  ) |> combine_deg_instructions(deg_instructions_combined)

  deg_instructions_combined <- generate_full_deg_instructions(
    seurat = seurat,
    degs_root = de_root,
    compare_by = c('apoe_genotype'),
    group_by = NULL,
    comparisons = list(
      c('34', '23'),
      c('33', '23'),
      c('34', '33')
    ),
    covariates = c('sex')
  ) |> combine_deg_instructions(deg_instructions_combined)

  deg_instructions_combined <- generate_full_deg_instructions(
    seurat = seurat,
    degs_root = de_root,
    compare_by = c('apoe_genotype'),
    group_by = c('cluster_fine_grain'),
    comparisons = list(
      c('34', '23'),
      c('33', '23'),
      c('34', '33')
    ),
    covariates = c('sex')
  ) |> combine_deg_instructions(deg_instructions_combined)

  generate_degs_2(seurat, deg_instructions_combined, cores = 8)
})
