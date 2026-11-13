# Project: lizardo-skiles-categorical-tolerance (2026-11-13)

Reproduction repo for Lizardo & Skiles, "refusal to dislike" paper
(SocSci_v3_85to108.pdf, pages 85–108): Figures 1–5 and Tables 1–3.

## Goal and decisions
- Port the original Stata analysis (`original-stata/*.do`, from the
  lizardo-skiles-refusal-to-dislike-americans zip) to open-source R.
- Tables are plain CSV (`output/tables/table*.csv`) — no xlsx dependencies.
- No raw data committed: GSS 1993 comes from `gssr` (gss_all), SSI 2012
  downloaded from https://olizardo.github.io/SSI-2012/
  (data/clean/ssi2012_cleaned.rds, CC BY 4.0).
- GitHub: user `olizardo` is authenticated via `gh`; repo planned public.

## Repo layout
- `R/01-download-data.R` … `R/07-models-table3-figures3-5.R` (numbered pipeline)
- `original-stata/` — original .do files kept as provenance
- `data/` — derived .rds (gitignored); `data-raw/` — downloaded SSI rds (gitignored)
- `output/figures/`, `output/tables/`

## Key reproduction facts (validated against shipped gss-ssi-merged.dta)
- Merged data: 3,882 rows in paper (1,606 GSS 1993 + 2,276 SSI 2012).
  Public SSI release has 2,275 records → 2012 numbers differ by one case
  (small shifts in numlikes/dislikes means, ~0.02–0.03); 1993 matches.
- The analysis uses **15 genres** (no bigband/big band; dataproc.do renames it
  but the dummy loop omits it — so `bband*` columns never enter the merged data).
- GSS taste recode: 1/2→like, 3→mixed, 4/5→dislike, 8/9→dk. gssr stores GSS
  8/9 codes as tagged NAs (.d/.n) — must restore them (8/9) before recoding.
- agemid mapping (both surveys): agecat 2–15 → 18.5,22,27,…,77,87
  (agecat = cut at c(17,19,24,…,79,100); `as.integer(cut())` drops labels —
  use as.numeric(as.character())).
- SSI raceeth codes match original raw coding: 1 Asian, 2 Black, 3 Hispanic,
  4 White (baseline), 5 Mixed, 6 Other. female 0/1 → sex 1/2.
- Degree built from nodipdeg/hsged/somcol/aadeg/bach/ma/docprof (0–4).
- Tables 1 & 2 validated against shipped ttest-table xlsx values; Table 2
  (mean dislikes among those with ≥1 dislike) matches exactly; Table 1 close
  (tiny 2012 diffs from the one-record difference).
- Stata `zip` → `pscl::zeroinfl(dist="poisson")`; robust SEs via
  `sandwich::sandwich()` (pscl provides estfun; vcovHC does NOT work on
  zeroinfl). Some specs (e.g. year##bc/pg interactions) need GLM-based
  starting values (`zip_fit()` helper handles this). Formulas must be
  single-line before paste-deparse; prefer pre-factored data (year as factor)
  over factor() inside the formula.
- Figure 3 y-axis = Stata zip `predict, p` = P(numdislikes == 0) including the
  zero-inflation mass (categorical tolerance); sample-mean reference lines at
  93/1606 (1993) and 373/2276 (2012).
- Figure 4 = `predict, pr(lb,ub)` ranges: Low 1–3, Moderate 4–8, High 9–15.
- Figure 5 uses SSI-only data (raw ssi2012_cleaned.rds), coefplots of race
  dummies only (do-file drops age*/degree*), inflate panel blue, count panel red.

## Status (2026-11-13)
- 01–06 run clean; Figures 1–2 and Tables 1–2 produced.
- 07 (Table 3, Figures 3–5) fits all models but still errors near the end:
  "Error in taste_names : The pipe operator requires a function call as RHS"
  — a stray pipe after the d_ssi block needs fixing; figures 3–5 warnings show
  some points dropped (scale ranges) to review.

## Conventions
- Install R packages only via `Rscript --no-save --no-restore -e
  'options(install.packages.compile.from.source="always"); install.packages(...) "`
  (console installs can hang).
- pscl, sandwich, gssr, haven, dplyr, tidyr, purrr, tibble, ggplot2 installed.
