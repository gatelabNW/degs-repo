library(UpSetR)

'{dirs$scripts}/differential-expression/heatmap-functions.R' |> glue() |> source()

create_upset_plot <- function (degs_path, bh_threshold = 0.01, logfc_threshold = 0.585, excluded_patterns = NULL){
  degs_files <- degs_path |> list.files()
  degs_files_metadata <- degs_files |> lapply(parse_deg_filename) |> bind_rows()
  cell_types <- degs_files_metadata$cluster1 |> unique() |> sort()

  result <- cell_types |> lapply(\(cell_type) {
    selected_files <- degs_files[grepl(glue("^{cell_type}__"), list.files(degs_path))]
    gene_set_list <- selected_files |> lapply(\(file) {
      df <- '{degs_path}/{file}' |> glue() |> read_degs()
      df <- df |> filter_degs(bh_threshold, logfc_threshold, excluded_patterns)
      df$gene
    })
    df_names <- selected_files |> lapply(parse_deg_filename) |> bind_rows()
    df_names <- "{df_names$group1}_vs._{df_names$group2}" |> glue()
    names(gene_set_list) <- df_names

    non_zero_count <- lapply(gene_set_list,function(gene_set){ length(gene_set)>1 }) |> unlist() |> sum()
    if (non_zero_count > 1) {
      upset(fromList(gene_set_list),order.by = "freq")
    }
  })
  names(result) <- cell_types
  result |> discard(is.null)
}


output_root <- "{dirs$documents}/differential-expression/combined/l2/upset-plots" |> glue() |> mkdir()
logfc_threshold <- 0.585
foo <- create_upset_plot(
  "{dirs$project_root}/documents/differential-expression/latest/l2/degs" |> glue(),
  logfc_threshold = logfc_threshold,
  bh_threshold = 0.01,
  excluded_patterns = c("^RP")
)
# "{output_root}/{logfc_threshold}_upset_by_diagnosis.pdf" |> glue() |> pdf(width = 16, height = 9)
# foo |> names() |> lapply(\(name){
#   print(foo[[name]])
#   grid.text(name,x = 0.65, y=0.95, gp=gpar(fontsize =20))
# })
# dev.off()