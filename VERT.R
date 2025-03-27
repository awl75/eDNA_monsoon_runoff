install.packages("readxl")
library(readxl)

vert_res2 <- read_excel("results2_asvs_normalized_MON_blastnedited.xlsx")

vert_res3 <- read.delim("results3_asvs_merged_MON-vetted - vertebrates.tsv", sep = "\t", header = TRUE)
