"{dirs$scripts}/lib/readRDS.gz.R" |> glue() |> source()
library(lubridate)

dt_loader <- function(file) {
  c(
    file = file,
    load = function() { fread(file, na.strings = '') },
    save = function(obj) { fwrite(obj, file = file) }
  )
}


rds_loader <- function(file) {
  c(
    file = file,
    load = function() {
      start_time <-  now(tzone = "US/Central")
      "Loading file at {file}" |> glue() |> message()
      object <- readRDS(file)
      delta_time <- (now(tzone = "US/Central") - start_time) %>% as.duration %>% as.character
      "Success! Time elapsed: {delta_time}" |> glue() |> message()
      object
      },
    save = function(obj) {
      "Saving file at {file}" |> glue() |> message()
      saveRDS(obj, file = file)
      message("success")
    }
  )
}


rds.gz_loader <- function(file) {
  c(
    file = file,
    load = function() {
      start_time <-  now(tzone = "US/Central")
      "Loading file at {file}" |> glue() |> message()
      object <- ktools::readRDS.gz(file)
      delta_time <- (now(tzone = "US/Central") - start_time) %>% as.duration %>% as.character
      "Success! Time elapsed: {delta_time}" |> glue() |> message()
      object
      },
    save = function(obj) {
      "Saving file at {file}" |> glue() |> message()
      ktools::saveRDS.gz(obj, file = file, compression_level = 9, threads = 24)
      message("success")
    }
  )
}

rds_list_loader <- function(dir) {
  c(
    dir = dir |> mkdirs(),
    load = function() {
      filenames <- dir |> list.files()
      files <- filenames |> lapply(\(filename) {"{dir}/{filename}" |> glue() |> readRDS()})
      names(files) <- filenames |> strsplit("[.]") |> lapply(\(split_element){split_element[[1]]}) |> unlist()
      files
    },
    save = function(obj_list) {
      filenames <- obj_list |> names()
      filepaths <- "{dir}/{filenames}.RDS" |> glue()
      obj_list |> seq_along() |> lapply(\(i) { saveRDS(obj_list[[i]], filepaths[[i]]) })
    }
  )
}

h5Seurat_loader <- function(file) {
  c(
    file = file,
    load = function(assays = NULL) { SeuratDisk::LoadH5Seurat(file, assays = assays) },
    save = function(obj) { SeuratDisk::SaveH5Seurat(obj, filename = file) }
  )
}

# "{dirs$scripts}/metadata/add-metadata.R" |> glue() |> source()
# seurat_add_metadata_loader <- function(file) {
#   c(
#     file = file,
#     load = function() {
#       start_time <-  now(tzone = "US/Central")
#       "Loading file at {file}" |> glue() |> message()
#       ktools::readRDS.gz(file) |> add_metadata()
#       delta_time <- (now(tzone = "US/Central") - start_time) %>% as.duration %>% as.character
#       "Success! Time elapsed: {delta_time}" |> glue() |> message()
#       "Loading file at {file}" |> glue() |> message()
#
#     }
#   )
# }