# Replication: "The End of Symbolic Exclusion? The Rise of 'Categorical Tolerance' in the Musical Tastes of Americans: 1993–2012"

Open-source R reproduction of the figures and tables in Lizardo & Skiles,
*Sociological Science* 3: 85–108, originally estimated in Stata (the original
`.do` files are preserved in `original-stata/` for provenance).

## Citations

Original publication:

> Lizardo, Omar, and Sara Skiles. 2016. "The End of Symbolic Exclusion? The
> Rise of 'Categorical Tolerance' in the Musical Tastes of Americans:
> 1993–2012." *Sociological Science* 3: 85–108.
> https://doi.org/10.15195/v3.a5

Data:

> Lizardo, Omar, and Sara Skiles. 2012. *Survey Sample International (SSI)
> Cultural Tastes Survey* [Dataset]. Distributed by GitHub at
> https://github.com/olizardo/SSI-2012. CC BY 4.0.
> Documentation: https://olizardo.github.io/SSI-2012/

> Smith, Tom W., Michael Davern, Jeremy Freese, and Michael Hout. *General
> Social Surveys, 1972–2022: Cumulative Codebook / Data File*. Chicago: NORC
> at the University of Chicago. [Producer and distributor of the 1993 data.]
> Accessed in R via the `gssr` package.

Software:

> Healy, Kieran. *gssr: General Social Survey Data*. R package.
> https://github.com/kjhealy/gssr.

## Outputs reproduced

| Output | Script | File |
|--------|--------|------|
| Figure 1 — distribution of dislikes | `R/05-figures-1-2.R` | `output/figures/Figure1.png` |
| Figure 2 — distribution of likes | `R/05-figures-1-2.R` | `output/figures/Figure2.png` |
| Table 1 — t-tests, probability of no dislikes | `R/06-tables-1-2.R` | `output/tables/table1.csv` |
| Table 2 — t-tests, mean dislikes (>= 1 dislike) | `R/06-tables-1-2.R` | `output/tables/table2.csv` |
| Table 3 — zero-inflated Poisson models | `R/07-models-table3-figures3-5.R` | `output/tables/table3.csv` |
| Figure 3 — categorical tolerance by cohort/race | `R/07-models-table3-figures3-5.R` | `output/figures/Figure3.png` |
| Figure 4 — symbolic exclusion intensity | `R/07-models-table3-figures3-5.R` | `output/figures/Figure4.png` |
| Figure 5 — race coefficients (SSI only) | `R/07-models-table3-figures3-5.R` | `output/figures/Figure5.png` |

## Data

No raw data is committed. The scripts fetch both sources:

- **GSS 1993** musical taste module, via the [`gssr`](https://github.com/kjhealy/gssr)
  package (`gss_all`).
- **SSI 2012** (`ssi2012_cleaned.rds`), downloaded from
  https://olizardo.github.io/SSI-2012/ (Lizardo & Skiles, CC BY 4.0).

**Note on the SSI data.** The published release contains 2,275 records; the
original analysis used a 2,276-record internal file. Estimates for 2012
therefore differ by a small amount (typically in the second decimal); the 1993
results match the published tables closely.

## How to run

```r
# from the repo root, in order:
source("R/01-download-data.R")         # fetches SSI-2012
source("R/02-process-gss-1993.R")      # builds data/gss-working.rds
source("R/03-process-ssi-2012.R")      # builds data/ssi-working.rds
source("R/04-build-analysis-data.R")   # builds data/gss-ssi-merged.rds
source("R/05-figures-1-2.R")
source("R/06-tables-1-2.R")
source("R/07-models-table3-figures3-5.R")
```

Requires R >= 4.2 and the packages: `gssr`, `haven`, `dplyr`, `tidyr`, `purrr`,
`tibble`, `ggplot2`, `fs`, `pscl`, `sandwich`.

## Method notes

- Stata's `zip` is estimated with `pscl::zeroinfl(dist = "poisson")`; robust
  standard errors use `sandwich::sandwich()` (pscl supplies the estimating
  functions). Model 5 (year x education interactions) needs GLM-based starting
  values; `zip_fit()` handles the restart automatically.
- Figures 3 and 4 use Stata `zip`'s `predict, p` (probability of a zero count,
  i.e. categorical tolerance) and `predict, pr(a,b)` (probability that the
  count falls in a range). These are computed from the model coefficients with
  delta-method standard errors; dashed reference lines are the sample shares
  with zero dislikes (93/1606 in 1993, 373/2276 in 2012).
- Figure 5 plots only the ethnoracial dummy coefficients (the original
  `coefplot` calls drop the age and degree terms), from an SSI-only model.
- All tables are plain CSVs; there are no xlsx dependencies.

## License

Code: MIT. The SSI-2012 dataset is distributed by its authors under CC BY 4.0;
GSS data are subject to the GSS terms of use (NORC).
