library(tidyverse)
library(data.table)
library(glue)
library(GateR)
gater_banner()

dirs <- list()
dirs$repo_root <- getwd()
dirs$project_root <- Sys.getenv('dirs.project_root') |> mkdirs()
dirs$b1042_project_root <- Sys.getenv('dirs.b1042_project_root') |> mkdirs()
dirs$objects <- Sys.getenv('dirs.objects') |> mkdirs()
dirs$junk_drawer <- Sys.getenv('dirs.junk_drawer') |> mkdirs()

creds <- list()
# creds$synapse$api_key <- Sys.getenv('creds.synapse.api_key')
# 
# "{dirs$repo_root}/r/config/dirs.R" |> glue() |> source()
# "{dirs$scripts}/config/config-factory.R" |> glue() |> source()
# "{dirs$scripts}/config/files.R" |> glue() |> source()
# "{dirs$scripts}/lib/toolbox.R" |> glue() |> source()

Sys.umask("000")
lubridate::now(tzone = "US/Central") |> as.character() |> cat()
getwd() |> cat()
# TODO: Figure out how to cat the version properly
version
gatelab_banner()