# Process the SSI 2012 survey.
# R port of dataproc-ssi.do. Source data: public SSI-2012 release
# (https://olizardo.github.io/SSI-2012/, CC BY 4.0).
#
# Note: the public release contains 2,275 records; the original analysis used
# the 2,276-record internal file, so counts differ by one case. Taste codes are
# already 1 = like, 2 = dislike, 3 = mixed feelings, 4 = not familiar (dk).
suppressMessages({
  library(dplyr)
  library(purrr)
  library(tibble)
})

ssi <- readRDS("data-raw/ssi2012_cleaned.rds")
# strip haven labels (values are used as raw numeric codes, as in the Stata code)
ssi[] <- lapply(ssi, function(x) if (inherits(x, "haven_labelled")) as.numeric(unclass(x)) else x)

taste_names <- c(
  "classical", "opera", "jazz", "bwayst", "moodez", "country", "blueg",
  "folk", "hymgos", "latspsal", "raphiphop", "blurb", "reggae",
  "controck", "hvymtl"
)

# Education level from degree indicators (mirrors the Stata construction)
agemid_map <- setNames(c(18.5, 22, 27, 32, 37, 42, 47, 52, 57, 62, 67, 72, 77, 87),
                       as.character(2:15))
ssi <- ssi |>
  mutate(
    degree = case_when(
      nodipdeg == 1 ~ 0,
      (hsged == 1 | somcol == 1) & aadeg == 0 & bach == 0 & ma == 0 & docprof == 0 ~ 1,
      aadeg == 1 & bach == 0 & ma == 0 & docprof == 0 ~ 2,
      bach == 1 & ma == 0 & docprof == 0 ~ 3,
      ma == 1 | docprof == 1 ~ 4
    ),
    # raceeth codes match the original SSI raw coding
    black = as.numeric(raceeth == 2),
    white = as.numeric(raceeth == 4),
    # original: female (0/1) recoded to sex 1 = men, 2 = women
    sex = ifelse(female == 1, 2, 1),
    agecat = as.integer(age),
    agemid = unname(agemid_map[as.character(agecat)]),
    year = 2012
  )

dummies <- map(taste_names, function(g) {
  t <- ssi[[paste0(g, "taste")]]
  tibble(
    "{g}like" := as.numeric(t == 1),
    "{g}dis" := as.numeric(t == 2),
    "{g}meh" := as.numeric(t == 3),
    "{g}dk" := as.numeric(t == 4)
  )
}) |>
  bind_cols()

ssi <- bind_cols(
  ssi |> select(year, degree, agecat, agemid, sex, black, white),
  dummies
)

fs::dir_create("data")
saveRDS(ssi, "data/ssi-working.rds")
cat("SSI 2012 processed:", nrow(ssi), "rows\n")
