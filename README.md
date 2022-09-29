# degs-repo
This repo serves as a wrapper for Seurat's FindMarkers that will generate DEGs for any number of comparisons.  Given a Seurat object, specify any number of metadata columns to group by, and this code will generate all possible DEGs for those groups.


## Renviron setup
This project requires a .Renviron file to properly initialize.  Please make a copy of the provided *example.Renviron* file to use as a template, and fill in your desired params.
