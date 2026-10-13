# dplyr uses non-standard evaluation -- declare the bare column symbols so
# R CMD check does not flag them as undefined globals.
utils::globalVariables(c("V1", "V2", "V3", "note", "elementid", "val"))
