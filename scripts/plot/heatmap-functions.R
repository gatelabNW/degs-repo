"{dirs$scripts}/lib/plot/ggplot_formatting.R" |> glue() |> source()

prepare_degs <- function(degs_dir, bh_threshold = 0.01, logfc_threshold = 0.585, excluded_patterns = NULL) {
  degs_files <- degs_dir |> list.files() |> as.character()
  degs_combined <- '{degs_dir}/{degs_files}' |> glue() |> lapply(\(file) {
    file |> read_degs() |> filter_degs(bh_threshold, logfc_threshold, excluded_patterns)
  }) |> merge_dfs(ids = degs_files)

  degs_metadata <- degs_combined$id |> lapply(parse_deg_filename) |> bind_rows()
  degs_combined$cluster <- degs_metadata$cluster1
  degs_combined$comparison <- '{degs_metadata$group1}_vs._{degs_metadata$group2}' |> glue()
  degs_combined$significance <- -log10(degs_combined$BH)
  degs_combined
}

get_deg_counts <- function(degs_combined) {
  clusters <- degs_combined$cluster |> unique()
  comparisons <- degs_combined$comparison |> unique()
  columns <- list(cluster = clusters, comparison = comparisons)
  cluster_comparison_metadata <- expand.grid(columns) |> as.data.table()
  cluster_comparison_metadata$degs_count <- row.names(cluster_comparison_metadata) |> as.integer() |> lapply(\(i){
    degs_subset <- degs_combined[cluster == cluster_comparison_metadata[[i ,"cluster"]] & comparison == cluster_comparison_metadata[[i ,"comparison"]]]
    dim(degs_subset)[1]
  }) |> as.integer()

  cluster_comparison_metadata$cluster <- cluster_comparison_metadata$cluster %>% gsub('_', ' ', .)

  cluster_comparison_metadata
}

create_heatmap <- function(deg_counts, title = "Differentially Expressed Genes", file = NULL) {
  p <- ggplot(deg_counts, aes(cluster, comparison, fill= degs_count))
  p <- p + geom_tile(
    aes(
      # reorder(cell_group, value)
      # size = degs_count,
      # color = color
    )
  )
  # theme_Publication_blank() +
  p <- p + theme()
  p <- p + viridis::scale_fill_viridis()
  p <- p + labs(title = title,
       fill = "# of DEGs"
  )
  p <- p + theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = -45, hjust = 0),
    axis.text.y = element_text(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
  )

  if(!is.null(file)) {
    heatmap_dimensions <- get_heatmap_dimensions(deg_counts, base_width = 7)
    'Saving heatmap to {file}' |> glue() |> print()
    ggsave(
      plot = p,
      file = file,
      height = heatmap_dimensions$height,
      width = heatmap_dimensions$width,
      unit = 'in'
    )
    # set_panel_size(p, file = file, height = heatmap_dimensions$height, width = heatmap_dimensions$width)
    # set_panel_size(p, file = file, height = unit(heatmap_dimensions$height, "inch"), width = unit(heatmap_dimensions$height, "inch"))

  }

  p
}

get_heatmap_dimensions <- function(plot_dataset, base_width = 10) {
  row_count <- plot_dataset$comparison |> unique() |> length()
  column_count <- plot_dataset$cluster |> unique() |> length()
  ratio <- row_count / column_count
  # ratio <- column_count / row_count
  width <- base_width
  height <- width * ratio
  list(height = height, width = width)
}
