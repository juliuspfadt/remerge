# remerge

## Shiny app to merge REM data for JASP

[https://juliuspfadt.shinyapps.io/remerge/](https://juliuspfadt.shinyapps.io/remerge/)

**This app allows users to upload two data sets that can then be merged into a single data set**

### Description

When collecting relational event data, researchers often obtain two data sets: 
1.  A data set that contains the relational event history and 
2.  a data set that contains the person attributes, often called covariates

Given the implementation of relational event modeling (REM) techniques in JASP and the fact that 
JASP cannot handle two data sets at once, this app allows to upload an event data set and a covariates data set
which can then be merged. The merged data set can be downloaded. 

For now, the allowed file types are `.csv`and `.xlsx`, and the merged data set is downloaded as a `.csv` file, 
which JASP can handle easily. 

Since the app fills the rows of the covariates data set with `NA`s 
it may be necessary to add `NA` in the "Missing value list" in JASP under Preferences/Settings > Data.
