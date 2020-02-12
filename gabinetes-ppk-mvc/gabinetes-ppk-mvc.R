library(tidyverse)

fix_content <- function(x) {
  str_replace(x, "\\*|†", "") %>%
  str_trim() %>%
    str_replace("^23 de marzo$", "23 de marzo de 2018") %>%
    str_replace("septiembre", "setiembre")
}

ppk <- read_csv("ppk-raw.csv") %>%
  janitor::clean_names() %>%
  separate_rows(
    titular, periodo,
    sep = "\n"
  ) %>%
  separate(
    col = periodo,
    into = c("inicio_str", "fin_str"),
    sep = "-"
  ) %>%
  mutate_at(
    vars(inicio_str, fin_str),
    fix_content
  ) %>%
  mutate(
    inicio = lubridate::dmy(inicio_str,
                                  locale = "es_PE.utf8"),
    fin = lubridate::dmy(fin_str,
                               locale = "es_PE.utf8")
  )

mvc <- read_csv("mvc-raw.csv") %>%
  janitor::clean_names() %>%
  separate_rows(
    titular, periodo,
    sep = "\n"
  ) %>%
  separate(
    col = periodo,
    into = c("inicio_str", "fin_str"),
    sep = "-"
  ) %>%
  mutate_at(
    vars(titular, inicio_str, fin_str),
    fix_content
  ) %>%
  mutate(
    inicio = lubridate::dmy(inicio_str,
                            locale = "es_PE.utf8"),
    fin = lubridate::dmy(fin_str,
                         locale = "es_PE.utf8")
  )

gabinetes_ppk_mvc <- bind_rows(ppk, mvc)

write_csv(ppk, path = "gabinetes-ppk.csv")
write_csv(mvc, path = "gabinetes-mvc.csv")
write_csv(gabinetes_ppk_mvc, path = "gabinetes-ppk-mvc.csv")
