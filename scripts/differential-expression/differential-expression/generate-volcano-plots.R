source(glue("{dirs$scripts}/differential-expression/volcano_plot.R"))
library(parallel)

generate_volcano_plots <- function(degs_path, volcano_path, logfc_threshold = 0.585, bh_threshold = 0.01, excluded_patterns = NULL) {
  degs_files <- list.files(degs_path)
  if (degs_files |> length() == 0) {
    stop("No files found in DEGs folder {degs_path}" |> glue())
  }
  plots_path <- "{volcano_path}/lfc-{logfc_threshold}_bh-{bh_threshold}" |> glue() |> mkdirs()

  pdf_paths <- degs_files %>% mclapply(mc.cores = 24, \(file) {
  # pdf_paths <- degs_files %>% lapply (\(file) {
    degs <- '{degs_path}/{file}' |> glue() |> read_degs() |> filter_degs(excluded_patterns = excluded_patterns)
    filename <- substr(file,1,nchar(file)-4)
    path <- glue("{plots_path}/{filename}.pdf")
    # titles <- filename %>% str_split("_vs._")
    volcano_plot(degs,
                 file = path,
                 title = filename %>% gsub('_', ' ', .),
                 # subtitle = titles[[1]][2] %>% gsub('_', ' ', .) %>% str_to_title %>% gsub('Vs.', 'vs.', .),
                 lfc.threshold = logfc_threshold,
                 padj.thresh = bh_threshold
    )
    return(path)
  })
  combined_pdfs_file <- "{plots_path}/!lfc-{logfc_threshold}_bh-{bh_threshold}_combined.pdf" |> glue()
  if (file.exists(combined_pdfs_file)) { file.remove(combined_pdfs_file) }
  qpdf::pdf_combine(input = pdf_paths %>% as.vector,
                  output = combined_pdfs_file)

  f <- list.files(plots_path, all.files = TRUE, full.names = TRUE, recursive = TRUE)
  Sys.chmod(paths = f, mode = "0777", use_umask = TRUE)
  # Sys.chmod(f, (file.info(f)$mode | "777"))
}

# de_root <- "{dirs$documents}/differential-expression/fine-grained" |> glue()
# generate_volcano_plots(
#   degs_path = "{de_root}/degs" |> glue(),
#   volcano_path = "{de_root}/volcano-plots" |> glue() |> mkdirs(),
#   logfc_threshold = 0.25,
#   bh_threshold = 0.00001
#   # excluded_patterns = c("^RP")
# )

# c(0.585, 0.5, 0.25) |> lapply(\(threshold){
#   generate_volcano_plots(
#     "{de_root}/degs" |> glue(),
#     "{de_root}/volcano-plots" |> glue(),
#     threshold
#   )
# })
