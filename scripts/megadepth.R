require(tidyverse)
require(here)
require(glue)

fn <- list.files(here("nogit/alignment_qc/outputs"), pattern = "*frags.tsv",
                 recursive = TRUE, full.names = TRUE)

read_frags <- function(x) {
  data <-
    data.table::fread(cmd = glue("grep -v 'STAT' {x}"), sep = "\t", header = FALSE,
                      col.names = c("fragment_length", "count"), data.table = FALSE) %>%
    tibble::as_tibble() %>%
    mutate(sample = sub("(.*)\\.frags\\.tsv", "\\1", basename(x))) %>%
    mutate(sample = sub("(.*)\\.alt_bwamem_GRCh38DH.20181023\\..*", "\\1", sample)) %>%
    select(sample, fragment_length, count)

  summary <-
    data.table::fread(cmd = glue("tail -n6 {x}"), sep = "\t", header = FALSE,
                      col.names = c("stat", "var", "value"), data.table = FALSE) %>%
    tibble::as_tibble() %>%
    mutate(sample = sub("(.*)\\.frags\\.tsv", "\\1", basename(x))) %>%
    mutate(sample = sub("(.*)\\.alt_bwamem_GRCh38DH.20181023\\..*", "\\1", sample)) %>%
    dplyr::select(sample, var, value)

  list(data = data, summary = summary)
}

d <- purrr::map(fn, read_frags)
data <- d %>% purrr::map_df("data")
summary <- d %>% purrr::map_df("summary")

# summary plot
summary %>%
  mutate(Sample = case_when(
    sample == "210420_A00692_0202_ML212023_NA12878-2_MAN-20210322_ILMNDNAPCRFREE" ~ "NA12878-PCRFREE",
    grepl("TOB152", sample) ~ "TOB",
    grepl("HGDP", sample) ~ "HGDP",
    TRUE ~ sample
  )) %>%
  ggplot(aes(x = "", y = value, fill = Sample)) +
  geom_point(position = position_jitter(seed = 42, width = 0.05), shape = 21) +
  scale_color_manual(values = c("NA12878-PCRFREE" = "green", "NA12878-HIGH" = "blue", "HGDP" = "red", "TOB" = "purple")) +
  scale_y_continuous(labels = scales::comma, breaks = scales::breaks_pretty(8)) +
  facet_wrap(~var, nrow = 3, scales = "free") +
  theme_bw() +
  ggtitle("Megadepth fragment size distribution summary results")

# density plot
data %>%
  filter(fragment_length > 0,
         fragment_length < 1500) %>%
  mutate(Sample = case_when(
    sample %in% c("210420_A00692_0202_ML212023_NA12878-2_MAN-20210322_ILMNDNAPCRFREE", "NA12878-HIGH") ~ "NA12878",
    grepl("TOB152", sample) ~ "TOB",
    grepl("HGDP", sample) ~ "HGDP",
    TRUE ~ sample
  )) %>%
  ggplot(aes(x = fragment_length, y = count, colour = sample)) +
  geom_density(stat = "identity") +
  scale_x_continuous(labels = scales::comma, breaks = scales::breaks_pretty(8)) +
  scale_y_continuous(labels = scales::comma, breaks = scales::breaks_pretty(8)) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank()) +
  # facet_wrap(~Sample) +
  ggtitle("Megadepth fragment size distribution")


