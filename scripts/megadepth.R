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
  mutate(Sample = if_else(sample == "NA12878-HIGH", "NA12878", "HGDP")) %>%
  ggplot(aes(x = "", y = value, fill = sample2)) +
  geom_point(position = position_jitter(seed = 42, width = 0.05), shape = 21) +
  scale_color_manual(values = c("NA12878" = "blue", "HGDP" = "red")) +
  scale_y_continuous(labels = scales::comma, breaks = scales::breaks_pretty(8)) +
  facet_wrap(~var, nrow = 3, scales = "free") +
  theme_bw() +
  ggtitle("Megadepth fragment size distribution summary results")

# density plot
data %>%
  filter(fragment_length > 0,
         fragment_length < 1500) %>%
  ggplot(aes(x = fragment_length, y = count, colour = sample)) +
  geom_density(stat = "identity") +
  scale_x_continuous(labels = scales::comma, breaks = scales::breaks_pretty(8)) +
  scale_y_continuous(labels = scales::comma, breaks = scales::breaks_pretty(8)) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank()) +
  ggtitle("Megadepth fragment size distribution")


