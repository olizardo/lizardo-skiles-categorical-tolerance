# Tables 1 and 2: two-sided t-tests of differences in (a) the probability of
# expressing no dislikes and (b) the mean number of dislikes, by binary
# socio-demographic predictors and survey year. R port of the Table 1-2
# blocks in analysis.do. Output: plain CSV (no xlsx dependencies).
suppressMessages({
  library(dplyr)
  library(purrr)
  library(tidyr)
})

merged <- readRDS("data/gss-ssi-merged.rds")

preds <- c("women", "white", "black", "hs", "bc", "pg",
           "cohortcat1", "cohortcat2", "cohortcat3", "cohortcat4")

# ttest y, by(g): mean of y in the g == 0 group (mu1) and g == 1 group (mu2)
ttest_row <- function(dat, y, g, yr, variable) {
  d <- dat |>
    filter(year == yr, !is.na(.data[[g]]), !is.na(.data[[y]]))
  g0 <- d[[y]][d[[g]] == 0]
  g1 <- d[[y]][d[[g]] == 1]
  t <- t.test(g0, g1, var.equal = TRUE)
  tibble(variable = variable, mu1 = mean(g0), mu2 = mean(g1), p = t$p.value)
}

make_table <- function(dat, f) {
  # f(yr, pred) -> ttest_row(...) call for each year x predictor combination
  expand_grid(year = c(1993, 2012), pred = preds) |>
    mutate(res = pmap(list(year, pred), f)) |>
    unnest(res) |>
    mutate(
      p = signif(p, 3),
      across(c(mu1, mu2), ~ round(.x, 2))
    ) |>
    pivot_wider(
      names_from = year,
      values_from = c(mu1, mu2, p),
      names_vary = "slowest"
    ) |>
    select(variable,
           mu1_93 = mu1_1993, mu2_93 = mu2_1993, p93 = p_1993,
           mu1_12 = mu1_2012, mu2_12 = mu2_2012, p12 = p_2012) |>
    mutate(across(-variable, ~ round(.x, 3)))
}

fs::dir_create("output/tables")

merged_cattol <- merged |> mutate(cattol = ifelse(numdislikes == 0, 1, 0))

# Table 1: mean of each predictor by categorical-tolerance status
make_table(merged_cattol, function(yr, pred) {
  ttest_row(merged_cattol, y = pred, g = "cattol", yr, variable = pred)
}) |>
  write.csv("output/tables/table1.csv", row.names = FALSE, na = "")

# Table 2: mean number of dislikes by predictor, among those with >= 1 dislike
merged_pos <- merged |> filter(numdislikes > 0)
make_table(merged_pos, function(yr, pred) {
  ttest_row(merged_pos, y = "numdislikes", g = pred, yr, variable = pred)
}) |>
  write.csv("output/tables/table2.csv", row.names = FALSE, na = "")

cat("Tables 1 and 2 written to output/tables\n")
