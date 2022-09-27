"{dirs$scripts}/config/config-factory.R" |> glue() |> source()

f <- list()

f$seurat$chen$full <- "{dirs$project_root}/chen-lab-analysis/rna_data.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$astrocyte <- "{dirs$project_root}/chen-lab-analysis/subset/astrocyte_annotation.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$endothelial_cell <- "{dirs$project_root}/chen-lab-analysis/subset/endothelial_cell_annotation.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$excitatory_neuron <- "{dirs$project_root}/chen-lab-analysis/subset/excitatory_neuron_annotation.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$immune_cell <- "{dirs$project_root}/chen-lab-analysis/subset/immune_cell_annotation.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$interneuron <- "{dirs$project_root}/chen-lab-analysis/subset/interneuron_annotation.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$oligodendrocyte <- "{dirs$project_root}/chen-lab-analysis/subset/oligodendrocyte_annotation.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$OPC <- "{dirs$project_root}/chen-lab-analysis/subset/OPC_annotation.rds.rds" |> glue() |> rds.gz_loader()
f$seurat$chen$stromal_cell <- "{dirs$project_root}/chen-lab-analysis/subset/stromal_cell_annotation.rds" |> glue() |> rds.gz_loader()

f$seurat$latest <- "{dirs$seurat}/seurat-latest.rds" |> glue() |> rds_loader()
# f$seurat$add_metadata <- f$seurat$chen$file |> glue() |> seurat_add_metadata_loader()

f$seurat$pre_find_neighbors <- "{dirs$seurat}/seurat-latest.rds" |> glue() |> rds_loader()
f$seurat$remove_unannotated <- "{dirs$seurat}/seurat-remove-unannotated" |> glue() |> rds_loader()

f$seurat$h5$latest <- "{dirs$seurat}/seurat-latest.rds" |> glue() |> h5Seurat_loader()
f$seurat$object_list$raw <- "{dirs$seurat}/seurat-object-list/raw" |> glue() |> rds_list_loader()
f$seurat$object_list$add_metadata <- "{dirs$seurat}/seurat-object-list/add-metadata" |> glue() |> rds_list_loader()
f$seurat$object_list$remove_unannotated <- "{dirs$seurat}/seurat-object-list/remove-unannotated" |> glue() |> rds_list_loader()
f$seurat$object_list$remove_unannotated_pp <- "{dirs$seurat}/seurat-object-list/remove-unannotated_pp" |> glue() |> rds_list_loader()
f$seurat$object_list$add_metadata_pp <- "{dirs$seurat}/seurat-object-list/add-metadata_pp" |> glue() |> rds_list_loader()

f$seurat$object_list_pp <- "{dirs$seurat}/seurat-object-list.rds_pp.rds" |> glue() |> rds_loader()


f$seurat$matrix_list <- "{dirs$seurat}/matrix-list.rds" |> glue() |> rds_loader()
f$seurat$matrix_combined <- "{dirs$seurat}/matrix_combined.rds" |> glue() |> rds_loader()

f$liger$latest <- "{dirs$liger}/liger-latest.RDS" |> glue() |> rds_loader()

f$rosmap$annotations <- "{dirs$rosmap$snRNAseq_modified}/annotation.2022-01-24.tsv" |> glue() |> dt_loader()