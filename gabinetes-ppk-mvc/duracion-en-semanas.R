library(tidyverse)
library(lubridate)

sumario <- read_csv("gabinetes-ppk-mvc/gabinetes-ppk-mvc.csv") %>%
  mutate(
    semanas = as.duration(inicio %--% fin) / dweeks(1)
  ) %>%
  summarise(
    n = sum(!is.na(semanas)),
    promedio = mean(semanas, na.rm = T),
    desv_std = sd(semanas, na.rm = T),
    mediana = median(semanas, na.rm = T),
    mínimo = min(semanas, na.rm = T),
    máximo = max(semanas, na.rm = T)
  )

knitr::kable(
  sumario,
  format = "pandoc",
  digits = 2,
  caption = "Duración en semanas de un titular ministerial (PPK + MVC)"
  )

df <- gabs %>%
  mutate(semanas = as.duration(inicio %--% fin) / dweeks(1)) %>%
  filter(!is.na(semanas)) %>%
  group_by(ministerio, titular) %>%
  summarise(
    semanas_tot = sum(semanas)
  ) %>%
  ungroup() %>%
  arrange(ministerio, semanas_tot) %>%
  mutate(order = factor(row_number()))

ggplot(df, aes(color = ministerio)) +
  geom_segment(aes(x = order, y = 0,
                   xend = order, yend = semanas_tot),
               show.legend = FALSE) +
  geom_point(aes(x = order,
                 y = semanas_tot),
             show.legend = FALSE) +
  scale_x_discrete(
    breaks = df$order,
    labels = df$titular
  ) +
  coord_flip() +
  theme_minimal(12) +
  facet_wrap(~ministerio, scales = "free", ncol = 2) +
  labs(
    title = "Duración de periodos ministeriales (en semanas)",
    y = "",
    x = ""
  )

ggsave(
  filename = "gabinetes-ppk-mvc/duracion-en-semanas.png",
  width = 10,
  height = 16
)
