# install and load packages
install.packages("readxl")
library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(viridis)

# import data
vert_res2 <- read_excel("results2_asvs_normalized_MON_blastnedited.xlsx")
vert_res3 <- read.delim("results3_asvs_merged_MON-vetted - vertebrates.tsv", sep = "\t", header = TRUE)

head(vert_res3)
str(vert_res3)

# rename some species names with likely alternative
vert_res3$Taxon[vert_res3$Taxon == "Callipepla sp."] <- "Callipepla gambelii" # abundant quail species in Tucson Mountains
vert_res3$Taxon[vert_res3$Taxon == "Unassigned Columbidae"] <- "Zenaida macroura" # the other predominant dove species in the area
vert_res3$Taxon[vert_res3$Taxon == "Canis sp."] <- "Canis spp." # likely includes coyote and domesticated dog
vert_res3$Taxon[vert_res3$Taxon == "Melanerpes carolinus"] <- "Melanerpes uropygialis" # range of Gila woodpecker rather than red-bellied
vert_res3$Taxon[vert_res3$Taxon == "Odocoileus virginianus"] <- "Odocoileus hemionus" # range of mule deer rather than white-tailed deer

# long format
vert_res3_long_df <- vert_res3 %>%
  pivot_longer(
    cols = starts_with("MON"),
    names_to = "Timepoint",
    values_to = "Reads"
  )

# top 5 taxa in terms of read count
top_5_taxa <- vert_res3_long_df %>%
  group_by(Taxon) %>%
  summarize(TotalReads = sum(Reads, na.rm = TRUE)) %>%
  top_n(5, TotalReads) %>%
  pull(Taxon)

ggplot(filter(vert_res3_long_df, Taxon %in% top_5_taxa), aes(x = Timepoint, y = Reads, color = Taxon, group = Taxon)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  labs(
    x = "Timepoint",
    y = "eDNA Reads",
    title = "Top 5 Taxa Over Time",
    color = "Species"
  ) +
  scale_x_discrete(labels = 1:9) +
  scale_color_viridis_d() +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(hjust = 0.5, color = "black", face = "bold"),
    axis.title = element_text(color = "black"),
    axis.text = element_text(color = "black"),
    legend.title = element_text(color = "black"),
    legend.text = element_text(color = "black"),
    panel.grid.major.y = element_line(color = "grey80"),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black")
  )

ggsave("vert_res3_top5_taxa_over_time.svg", width = 8, height = 6, units = "in")

# top 10 taxa in terms of read count

top_10_taxa <- vert_res3_long_df %>%
  group_by(Taxon) %>%
  summarize(TotalReads = sum(Reads, na.rm = TRUE)) %>%
  slice_max(order_by = TotalReads, n = 10) %>%
  pull(Taxon)

ggplot(filter(vert_res3_long_df, Taxon %in% top_10_taxa), aes(x = Timepoint, y = Reads, color = Taxon, group = Taxon)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  labs(
    x = "Timepoint",
    y = "eDNA Reads",
    title = "Top 10 Taxa Over Time",
    color = "Species"
  ) +
  scale_x_discrete(labels = 1:9) +
  scale_color_brewer(palette = "Paired") +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(hjust = 0.5, color = "black", face = "bold"),
    axis.title = element_text(color = "black"),
    axis.text = element_text(color = "black"),
    legend.title = element_text(color = "black"),
    legend.text = element_text(color = "black"),
    panel.grid.major.y = element_line(color = "grey80"),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black")
  )

ggsave("vert_res3_top10_taxa_over_time.svg", width = 8, height = 6, units = "in")

# top 10 taxa in terms of read count with reads normalized within each taxon

vert_res3_long_df_prop <- vert_res3_long_df %>%
  group_by(Taxon) %>%
  mutate(Proportion = Reads / sum(Reads, na.rm = TRUE)) %>%
  ungroup()

str(vert_res3_long_df_prop)

ggplot(filter(vert_res3_long_df_prop, Taxon %in% top_10_taxa), 
       aes(x = Timepoint, y = Proportion, color = Taxon, group = Taxon)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    x = "Timepoint",
    y = "Proportional of Reads per Taxon",
    title = "Normalized Detection Over Time",
    color = "Species"
  ) +
  scale_x_discrete(labels = 1:9) +
  scale_color_brewer(palette = "Paired") +  # or manual palette if needed
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.line = element_line(color = "black"),
    axis.text = element_text(color = "black"),
    axis.title = element_text(color = "black"),
    legend.title = element_text(color = "black")
  )

ggsave("vert_res3_top10_taxa_over_time_proportions.svg", width = 8, height = 6, units = "in")

# "species richness" per sample across 9 samples

vert_res3_species_richness <- vert_res3_long_df %>%
  group_by(Timepoint) %>%
  summarize(Richness = sum(Reads > 0, na.rm = TRUE))

ggplot(vert_res3_species_richness, aes(x = Timepoint, y = Richness)) +
  geom_col(fill = "grey40") +
  labs(
    title = "Species Richness per Timepoint",
    x = "Timepoint",
    y = "Number of Taxa Detected"
  ) +
  scale_x_discrete(labels = 1:9) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(size = 17, hjust = 0.5, color = "black", face = "bold"),
    axis.title = element_text(size = 15, color = "black"),
    axis.text = element_text(size = 13, color = "black"),
    legend.title = element_text(color = "black"),
    legend.text = element_text(color = "black"),
    panel.grid.major.y = element_line(color = "grey80"),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black")
  )

ggsave("vert_res3_species_richness_across_samples.svg", width = 8, height = 6, units = "in")

