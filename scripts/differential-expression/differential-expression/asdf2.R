generate_all_degs <- function(seurat, l2_column, output_root) {
  degs_path <- "{output_root}/degs" |> glue() |> mkdir()
  volcanos_path <- "{output_root}/volcano-plots" |> glue() |> mkdir()
  generate_degs(
    seurat = seurat,
    l1_column = 'diagnosis',
    l2_column = l2_column,
    output_dir = degs_path
  )
  generate_degs(
    seurat = seurat,
    l1_column = 'diagnosis_general',
    l2_column = l2_column,
    output_dir = degs_path,
  )
  make_plots(degs_path, volcanos_path, 0.585)
  make_plots(degs_path, volcanos_path, 0.5)
  make_plots(degs_path, volcanos_path, 0.25)
}

"{dirs$scripts}/differential-expression/generate-degs.R" |> glue() |> source()
"{dirs$scripts}/differential-expression/generate-volcano-plots.R" |> glue() |> source()
seurat <- o$seurat$ref_mapping_3$load()
output_root <- "{dirs$project_root}/documents/differential-expression/new_all-permutations" |> glue() |> mkdir()
generate_all_degs(seurat, 'predicted.celltype.l1', '{output_root}/l1' |> glue() |> mkdir())
generate_all_degs(seurat, 'predicted.celltype.l2', '{output_root}/l2' |> glue() |> mkdir())
generate_all_degs(seurat, NULL, '{output_root}/all' |> glue() |> mkdir())