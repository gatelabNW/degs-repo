# options(future.globals.maxSize = 4000*1024^2)
# options(echo = TRUE)
# options(renv.config.install.staged = FALSE)
# if (Sys.getenv('isAnalyticsNode') == 'true') {
#   dyn.load("/software/hdf5/1.8.19-serial/lib/libhdf5_hl.so.10")
#   dyn.load("/software/geos/3.8.1/lib/libgeos.so.3.8.1")
# }

source("renv/activate.R")



# options(repos = c("http://ran.synapse.org", "http://cran.fhcrc.org"))
#
if (!file.exists('.Renviron')) {stop("Cannot initialize project.  No .Renviron file present. Please see README.md for instructions.")}

tryCatch(
  {
    source('scripts/config/init.R')
  },
  error=function(e) {
    message('An error occurred during initialization')
    print(e)
  }
)


