'{dirs$scripts}/differential-expression/heatmap-functions.R' |> glue() |> source()
logfc_threshold <- 0.25
bh_threshold <- 0.00001
excluded_patterns <- c('^RP')


degs_combined <- '{dirs$documents}/differential-expression/latest/l2/degs' |> glue() |> prepare_degs(logfc_threshold = logfc_threshold, bh_threshold = bh_threshold, excluded_patterns = excluded_patterns)
deg_counts <- get_deg_counts(degs_combined)
output_root <- '{dirs$documents}/differential-expression/latest/heatmap/lfc-{logfc_threshold}_bh-{bh_threshold}' |> glue() |> mkdir()

create_heatmap(deg_counts, title = 'all_l2_clusters', file = '{output_root}/heatmap_all_l2_clusters.pdf' |> glue())

# cluster_metadata <- o$metadata$cluster$load()
# cluster_metadata$predicted.celltype.l1 |> unique() |> lapply(\(l1_cluster) {
#   selected_l2_clusters <- cluster_metadata[predicted.celltype.l1 == l1_cluster]$predicted.celltype.l2
#   plot_dataset <- deg_counts[cluster %in% selected_l2_clusters]
#   create_heatmap(plot_dataset, title = l1_cluster, file = '{output_root}/heatmap_{l1_cluster}.pdf' |> glue())
# })

degs_combined <- '{dirs$documents}/differential-expression/latest/l1/degs' |> glue() |> prepare_degs(logfc_threshold = logfc_threshold, bh_threshold = bh_threshold, excluded_patterns = excluded_patterns)
deg_counts <- get_deg_counts(degs_combined)
create_heatmap(deg_counts, title = 'all_l1_clusters', file = '{output_root}/heatmap_all_l1_clusters.pdf' |> glue())
