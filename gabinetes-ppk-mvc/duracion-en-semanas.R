library(tidyverse)
library(lubridate)

gabinetes <- read_csv("gabinetes-ppk-mvc/gabinetes-ppk-mvc.csv") %>%
  mutate(
    semanas = as.duration(inicio %--% fin) / dweeks(1)
  )
sumario <- gabinetes %>%
  filter(!is.na(semanas)) %>%  # filtrar quienes están aún en el cargo
  group_by(ministerio, titular) %>%
  summarise(
    semanas_tot = sum(semanas)
  ) %>%
  ungroup() %>%
  summarise(
    n = n(),
    promedio = mean(semanas_tot, na.rm = T),
    desv_std = sd(semanas_tot, na.rm = T),
    mediana = median(semanas_tot, na.rm = T),
    mínimo = min(semanas_tot, na.rm = T),
    máximo = max(semanas_tot, na.rm = T)
  )

knitr::kable(
  sumario,
  format = "pandoc",
  digits = 2,
  caption = "Duración en semanas de un titular ministerial (PPK + MVC)"
  )

# Table: Duración en semanas de un titular ministerial (PPK + MVC)
#
#   n   promedio   desv_std   mediana   mínimo   máximo
# ---  ---------  ---------  --------  -------  -------
#  82      37.67      26.46     33.57     1.43   163.43

df <- gabinetes %>%
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
    title = "Duración de periodos ministeriales en el gobierno actual (en semanas, Perú)",
    subtitle = "Fuentes: https://es.wikipedia.org/wiki/Gobierno_de_Pedro_Pablo_Kuczynski#Ministros\nhttps://es.wikipedia.org/wiki/Gobierno_de_Mart%C3%ADn_Vizcarra#Ministros_de_Estado",
    caption = "No incluye titulares en ejercicio en la actualidad\nActualizado el 2020-02-12T11:20 // @jmcastagnetto, Jesús M. Castagnetto",
    y = "",
    x = ""
  ) +
  theme(
    plot.margin = unit(rep(1, 4), "cm")
  )

ggsave(
  filename = "gabinetes-ppk-mvc/duracion-en-semanas.png",
  width = 12,
  height = 18
)
