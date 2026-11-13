# Figures 1 and 2: univariate distribution of the number of dislikes and likes
# by survey year. R port of the Figures 1-2 block in analysis.do.
suppressMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyr)
})

merged <- readRDS("data/gss-ssi-merged.rds")

# Replicate the Stata economist scheme look
theme_economist <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.y = element_line(color = "grey90"),
    panel.grid.major.x = element_blank(),
    legend.position = "top",
    plot.title = element_text(face = "plain")
  )

plot_dist <- function(var, title) {
  dat <- merged |>
    group_by(year, .abb = .data[[var]]) |>
    summarise(prop = sum(prop), .groups = "drop")

  ggplot(dat, aes(.abb, prop, color = factor(year), group = factor(year))) +
    geom_point(size = 2.5) +
    geom_line(linewidth = 1) +
    scale_x_continuous(breaks = seq(0, 15, 1)) +
    scale_y_continuous(limits = c(0, 18), breaks = seq(0, 18, 2)) +
    scale_color_manual(values = c(`1993` = "blue", `2012` = "red"),
                       labels = c("1993", "2012")) +
    labs(x = paste("Number of", title), y = "% of Respondents",
         color = NULL) +
    theme_economist
}

fs::dir_create("output/figures")

p1 <- plot_dist("numdislikes", "Dislikes")
ggsave("output/figures/Figure1.png", p1, width = 6.5, height = 4, dpi = 200)

p2 <- plot_dist("numlikes", "Likes")
ggsave("output/figures/Figure2.png", p2, width = 6.5, height = 4, dpi = 200)

cat("Figures 1 and 2 written to output/figures\n")
