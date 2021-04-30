require(tidyverse)
require(here)
require(glue)
fn <- list.files(here("nogit/alignment_qc/outputs"), pattern = "*frags.tsv",
                 recursive = TRUE, full.names = TRUE)

read_frags <- function(x) {
  d1 <-
    data.table::fread(cmd = glue("grep -v 'STAT' {x}"), sep = "\t", header = FALSE,
                      col.names = c("x1", "x2"), data.table = FALSE) %>%
    tibble::as_tibble() %>%
    mutate(sample = sub("(.*)\\.frags\\.tsv", "\\1", basename(x))) %>%
    mutate(sample = sub("(.*)\\.alt_bwamem_GRCh38DH.20181023\\..*", "\\1", sample)) %>%
    select(sample, x1, x2)

  d2 <-
    data.table::fread(cmd = glue("tail -n6 {x}"), sep = "\t", header = FALSE,
                      col.names = c("stat", "var", "value"), data.table = FALSE) %>%
    mutate(sample = sub("(.*)\\.frags\\.tsv", "\\1", basename(x))) %>%
    mutate(sample = sub("(.*)\\.alt_bwamem_GRCh38DH.20181023\\..*", "\\1", sample)) %>%
    dplyr::select(sample, var, value)

  list(d1 = d1, d2 = d2)
}

d <- purrr::map(fn, read_frags)
d1 <- d %>% purrr::map_df("d1")
d2 <- d %>% purrr::map_df("d2")

d2 %>%
  mutate(sample2 = if_else(sample == "NA12878-HIGH", "NA12878", "HGDP")) %>%
  ggplot(aes(x = "", y = value, fill = sample2)) +
  geom_point(position = position_jitter(seed = 42, width = 0.05), shape = 21) +
  scale_color_manual(values = c("NA12878" = "blue", "HGDP" = "red")) +
  scale_y_continuous(labels = scales::comma, breaks = scales::breaks_pretty(8)) +
  facet_wrap(~var, nrow = 3, scales = "free") +
  theme_bw() +
  ggtitle("Megadepth fragment size distribution results")

# COUNT
COUNT <- d1 %>%
  group_by(sample) %>%
  summarise(sum2 = sum(x2))
d2 %>%
  filter(var == "COUNT") %>%
  left_join(COUNT, by = "sample") %>%
  mutate(x = value == sum2) %>%
  count(x)

MEAN_LENGTH <- d1 %>%
  group_by(sample) %>%
  summarise(mean1 = mean(x1),
            mean2 = mean(x2))
