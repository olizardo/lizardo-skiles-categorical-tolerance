# Build the merged GSS 1993 / SSI 2012 analysis dataset.
# R port of the second half of dataproc.do.
suppressMessages({
  library(dplyr)
  library(tidyr)
})

gss <- readRDS("data/gss-working.rds")
ssi <- readRDS("data/ssi-working.rds")

merged <- bind_rows(gss, ssi)

# Counts of liked / disliked / mixed / not-familiar genres (row sums)
merged <- merged |>
  mutate(
    numlikes = rowSums(across(ends_with("like")), na.rm = FALSE),
    numdislikes = rowSums(across(ends_with("dis")), na.rm = FALSE),
    nummeh = rowSums(across(ends_with("meh")), na.rm = FALSE),
    numdk = rowSums(across(ends_with("dk")), na.rm = FALSE),
    college = ifelse(degree > 2, 1, 0),
    women = as.numeric(sex == 2),
    # birth cohort (5-year bins collapsed to decades; gaps keep raw value,
    # matching the Stata recode ... , g(cohortrec))
    cohort = round(year - agemid),
    cohortrec = dplyr::case_match(
      cohort,
      1905:1915 ~ 1910, 1920:1925 ~ 1920, 1930:1935 ~ 1930, 1940:1945 ~ 1940,
      1950:1955 ~ 1950, 1960:1965 ~ 1960, 1970:1975 ~ 1970, 1980:1985 ~ 1980,
      1990:1995 ~ 1990,
      .default = cohort
    ),
    # Stata recode cohorts: 1905/1915=1910 1920/1925=1920 ... gaps left missing
    cohortrec4 = cut(cohort, breaks = c(0, 1935, 1954, 1968, 2000),
                     labels = 1:4),
    cohortrec5 = cut(cohort, breaks = c(0, 1935, 1946, 1964, 1975, 2000),
                     labels = 1:5),
    cohortrec6 = cut(cohort, breaks = c(0, 1935, 1946, 1954, 1964, 1975, 2000),
                     labels = 1:6),
    # counts top-coded at 12
    numdislikes12 = pmin(numdislikes, 12),
    numlikes12 = pmin(numlikes, 12),
    nummeh12 = pmin(nummeh, 12),
    prop = ifelse(year == 1993, 100 / sum(year == 1993), 100 / sum(year == 2012)),
    nodis = as.numeric(numdislikes == 0),
    hs = as.numeric(degree %in% c(1, 2)),
    bc = as.numeric(degree == 3),
    pg = as.numeric(degree == 4)
  )

cohortrec4 <- as.numeric(merged$cohortrec4)
for (i in 1:4) {
  merged[[paste0("cohortcat", i)]] <- as.numeric(cohortrec4 == i)
}

merged <- merged |>
  mutate(cohortrec = as.numeric(as.character(cohortrec)),
         cohortrec4 = as.numeric(as.character(cohortrec4)),
         cohortrec5 = as.numeric(as.character(cohortrec5)),
         cohortrec6 = as.numeric(as.character(cohortrec6)))

fs::dir_create("data")
saveRDS(merged, "data/gss-ssi-merged.rds")
cat("Merged analysis data:", nrow(merged), "rows\n")
