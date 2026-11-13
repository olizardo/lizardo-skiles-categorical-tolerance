# Table 3 (zero-inflated Poisson models) and Figures 3, 4, 5.
# R port of the model blocks in analysis.do.
#
# Stata's `zip` corresponds to pscl::zeroinfl(dist = "poisson"); robust
# standard errors use sandwich::vcovHC (HC1, matching Stata vce(robust)).
# Figure 3 and 4 use Stata zip's `predict, p` (probability of a zero count,
# i.e. categorical tolerance) and `predict, pr(a,b)` (probability that the
# count falls in a range), both computed here from the model coefficients.
suppressMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(pscl)
  library(sandwich)
  library(ggplot2)
})

merged <- readRDS("data/gss-ssi-merged.rds")
ssi <- readRDS("data/ssi-working.rds")

# Robust (sandwich) standard errors, matching Stata's vce(robust);
# pscl supplies the estimating functions for zeroinfl models.
robust_se <- function(fit) {
  sqrt(diag(sandwich::sandwich(fit)))
}

# Fit a zero-inflated Poisson; if the optimizer fails from default starting
# values (happens with the interaction model), restart from GLM estimates.
zip_fit <- function(count_f, zero_f, data) {
  one_line <- function(f) paste(deparse(f), collapse = " ")
  f <- as.formula(paste(one_line(count_f), "|", sub("^\\s*~\\s*", "", one_line(zero_f))))
  fit <- tryCatch(zeroinfl(f, dist = "poisson", data = data), error = function(e) NULL)
  if (is.null(fit)) {
    gc <- glm(count_f, family = poisson, data = data)
    gz <- glm(update(zero_f, I(numdislikes == 0) ~ .), family = binomial, data = data)
    fit <- zeroinfl(f, dist = "poisson", data = data,
                    start = list(count = coef(gc), zero = coef(gz)))
  }
  fit
}

fmt_stars <- function(p) {
  dplyr::case_when(p < 0.05 ~ "*", TRUE ~ "")
}

# ------------------------------------------------------------------ Table 3 --
# Stata: zip numdislikes i.year ib3.cohortrec4 i.white i.sex i.bc i.pg,
#        inflate(i.year c.cohort [i.black] [i.bc]), vce(robust)
# Model 5 adds year##(bc pg) interactions in the count component.
d_t3 <- merged |> mutate(cohortrec4 = relevel(factor(cohortrec4), 3), year = factor(year))
mods <- list(
  mod0 = glm(numdislikes ~ year + cohortrec4 + white + sex + bc + pg,
             family = poisson, data = d_t3),
  mod1 = zip_fit(numdislikes ~ year + cohortrec4 + white + sex + bc + pg,
                 ~ year + cohort, d_t3),
  mod2 = zip_fit(numdislikes ~ year + cohortrec4 + white + sex + bc + pg,
                 ~ year + cohort + black, d_t3),
  mod3 = zip_fit(numdislikes ~ year + cohortrec4 + white + sex + bc + pg,
                 ~ year + cohort + black + bc, d_t3),
  mod5 = zip_fit(numdislikes ~ year + cohortrec4 + white + sex + year * bc + year * pg,
                 ~ year + cohort + black + bc, d_t3)
)

table3 <- map_dfr(names(mods), function(m) {
  fit <- mods[[m]]
  b <- coef(fit)
  se <- robust_se(fit)
  tibble(
    model = m,
    term = names(b),
    estimate = unname(b),
    se = unname(se),
    stars = fmt_stars(2 * pnorm(-abs(b / se)))
  )
}) |>
  mutate(
    model = factor(model, levels = c("mod0", "mod1", "mod2", "mod3", "mod5"),
                   labels = c("Model 1: Poisson", "Model 2: ZIP", "Model 3: ZIP + Black (inflate)",
                              "Model 4: ZIP + Black & College (inflate)", "Model 5: ZIP, interactions")),
    label = sprintf("%.3f%s\n(%.4f)", estimate, stars, se)
  )

fs::dir_create("output/tables")
table3 |>
  select(model, term, estimate, se, stars) |>
  write.csv("output/tables/table3.csv", row.names = FALSE)

# ------------------------------------------------------------- ZIP utilities --
# P(Y = y) under a zero-inflated Poisson, given count-part lambda and
# zero-part probability of an "excess zero" pi.
zip_p0 <- function(lambda, pi) pi + (1 - pi) * exp(-lambda)
zip_prange <- function(lambda, pi, lo, hi) {
  p0 <- zip_p0(lambda, pi)
  s <- if (lo == 0) p0 else 0
  s + (1 - pi) * (ppois(hi, lambda) - ppois(max(lo, 1) - 1, lambda))
}

# Poisson pmf/cdf helpers for the range probability
pois_s <- function(lam, lo, hi) {
  # sum of Poisson(lam) over k in [max(lo,1), hi]
  k <- max(lo, 1)
  (1 - ppois(k - 1, lam)) - (1 - ppois(hi, lam))
}
pois_s_grad <- function(lam, lo, hi) {
  # d/dlam of the sum above, vectorized over lam
  k <- max(lo, 1):hi
  if (!length(k)) return(rep(0, length(lam)))
  sapply(lam, function(l) sum((k / l - 1) * dpois(k, l)))
}

# Point prediction and delta-method SE for P(Y = 0) or P(lo <= Y <= hi)
predict_zip <- function(fit, newdata, what = c("p0", "pr"), lo = 0, hi = 0, level = 0.90) {
  what <- match.arg(what)
  V <- sandwich::sandwich(fit)
  cf <- coef(fit)
  nc <- length(fit$coefficients$count)
  b_count <- cf[seq_len(nc)]; b_zero <- cf[-seq_len(nc)]
  Xc <- model.matrix(delete.response(fit$terms$count),
                     model.frame(delete.response(fit$terms$count), newdata, na.action = na.pass))
  Xz <- model.matrix(delete.response(fit$terms$zero),
                     model.frame(delete.response(fit$terms$zero), newdata, na.action = na.pass))
  lam <- exp(as.vector(Xc %*% b_count))
  pi0 <- plogis(as.vector(Xz %*% b_zero))
  a0 <- what == "p0" || lo == 0
  s <- if (what == "p0") 0 else pois_s(lam, lo, hi)
  e0 <- exp(-lam)
  est <- if (what == "p0") zip_p0(lam, pi0) else zip_prange(lam, pi0, lo, hi)
  # dP/dbeta_count and dP/dbeta_zero (vectors per row)
  g_count <- if (what == "p0") {
    -(1 - pi0) * e0 * Xc
  } else {
    (1 - pi0) * (-a0 * e0 + pois_s_grad(lam, lo, hi)) * Xc
  }
  g_zero <- if (what == "p0") {
    (1 - e0) * pi0 * (1 - pi0) * Xz
  } else {
    ((a0 * (1 - e0) - s) * pi0 * (1 - pi0)) * Xz
  }
  n_c <- ncol(Xc); n_z <- ncol(Xz)
  se <- sqrt(rowSums((g_count %*% V[seq_len(n_c), seq_len(n_c), drop = FALSE]) * g_count) +
             rowSums((g_zero %*% V[(n_c + 1):(n_c + n_z), (n_c + 1):(n_c + n_z), drop = FALSE]) * g_zero) +
             2 * rowSums((g_count %*% V[seq_len(n_c), (n_c + 1):(n_c + n_z), drop = FALSE]) * g_zero))
  z <- qnorm(1 - (1 - level) / 2)
  tibble(est = est, lwr = pmax(est - z * se, 0), upr = pmin(est + z * se, 1))
}

# ------------------------------------------------------------------ Figure 3 --
# zip numdislikes i.year i.cohortrec i.white i.sex i.year##i.bc i.year##i.pg,
#     inflate(i.year i.cohortrec4 i.black i.bc), vce(robust)
# margins, at(cohortrec4 = 1..4) within(year black), predict(p), level(90)
dat3 <- merged |>
  mutate(
    cohortrec = factor(cohortrec),
    cohortrec4 = factor(cohortrec4),
    year = factor(year)
  )
fit3 <- zip_fit(numdislikes ~ year + cohortrec + white + sex + year * bc + year * pg,
                ~ year + cohortrec4 + black + bc, dat3)

dat3 <- merged |>
  mutate(
    cohortrec = factor(cohortrec),
    cohortrec4 = factor(cohortrec4),
    year = factor(year)
  )

# margins within(year black): for each cohort level, average predictions over
# the observed covariate distribution within each year x black subsample.
grid3 <- map_dfr(1:4, function(l) {
  map_dfr(c("1993", "2012"), function(yr) {
    map_dfr(c(0, 1), function(bl) {
      d <- dat3 |> filter(year == yr, black == bl)
      d$cohortrec4 <- factor(l, levels = levels(dat3$cohortrec4))
      pred <- predict_zip(fit3, d, what = "p0")
      tibble(cohortrec4 = l, year = yr, black = bl,
             est = mean(pred$est, na.rm = TRUE),
             lwr = mean(pred$lwr, na.rm = TRUE),
             upr = mean(pred$upr, na.rm = TRUE))
    })
  })
}) |>
  mutate(
    black = factor(black, labels = c("Not Black", "Black")),
    cohortrec4 = factor(cohortrec4, levels = 1:4,
                        labels = c("before 1936", "between 1936 and 1954",
                                   "between 1955 and 1968", "after 1968"))
  )

p3 <- ggplot(grid3, aes(year, est, color = black, group = black)) +
  geom_point(size = 4, shape = 18) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.05, linewidth = 0.6) +
  facet_wrap(~ cohortrec4) +
  geom_hline(yintercept = 93 / 1606, linetype = "dashed", color = "blue") +
  geom_hline(yintercept = 373 / 2276, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("Not Black" = "blue", "Black" = "red")) +
  labs(y = "Prob. of Categorical Tolerance", x = "Survey Year", color = NULL) +
  theme_minimal() +
  theme(legend.position = "top")

ggsave("output/figures/Figure3.png", p3, width = 6.5, height = 3, dpi = 200)

# ------------------------------------------------------------------ Figure 4 --
dat4 <- merged |>
  mutate(cohortrec4 = factor(cohortrec4), year = factor(year))
fit4 <- zip_fit(numdislikes ~ year + cohortrec4 + white + sex + year * bc + year * pg,
                ~ year + cohortrec4 + black + bc, dat4)

ranges <- list(Low = c(1, 3), Moderate = c(4, 8), High = c(9, 15))
grid4 <- imap_dfr(ranges, function(rng, lab) {
  # margins over(year): average predictions over each year's subsample
  map_dfr(1:4, function(l) {
    map_dfr(c("1993", "2012"), function(yr) {
      d <- dat4 |> filter(year == yr)
      d$cohortrec4 <- factor(l, levels = levels(dat4$cohortrec4))
      pred <- predict_zip(fit4, d, what = "pr", lo = rng[1], hi = rng[2])
      tibble(cohortrec4 = l, year = yr,
             est = mean(pred$est, na.rm = TRUE),
             lwr = mean(pred$lwr, na.rm = TRUE),
             upr = mean(pred$upr, na.rm = TRUE))
    })
  }) |>
    mutate(intensity = factor(lab, levels = names(ranges)))
})

p4 <- ggplot(grid4, aes(cohortrec4, est, color = year, group = year)) +
  geom_point(size = 3, shape = 18) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.05, linewidth = 0.6) +
  facet_wrap(~ intensity, ncol = 1, scales = "free_y") +
  scale_color_manual(values = c(`1993` = "blue", `2012` = "red")) +
  labs(x = "Birth Cohort Group", y = "Prob. of Symbolic Exclusion Intensity", color = NULL) +
  theme_minimal() +
  theme(legend.position = "top")

ggsave("output/figures/Figure4.png", p4, width = 5, height = 8, dpi = 200)

# ------------------------------------------------------------------ Figure 5 --
# zip numdislikes c.agemid##c.agemid race1-race6 degree2-5,
#     inflate(agemid race1-race6 degree4), vce(robust)  [SSI data only]
d_ssi <- readRDS("data-raw/ssi2012_cleaned.rds") |>
  (\(s) {
    s[] <- lapply(s, function(x) if (inherits(x, "haven_labelled")) as.numeric(unclass(x)) else x)
    s
  })()
taste_names <- c(
  "classical", "opera", "jazz", "bwayst", "moodez", "country", "blueg",
  "folk", "hymgos", "latspsal", "raphiphop", "blurb", "reggae",
  "controck", "hvymtl"
)
d_ssi <- d_ssi |>
  mutate(
    degree = case_when(
      nodipdeg == 1 ~ 0,
      (hsged == 1 | somcol == 1) & aadeg == 0 & bach == 0 & ma == 0 & docprof == 0 ~ 1,
      aadeg == 1 & bach == 0 & ma == 0 & docprof == 0 ~ 2,
      bach == 1 & ma == 0 & docprof == 0 ~ 3,
      ma == 1 | docprof == 1 ~ 4
    ),
    agemid = dplyr::recode(as.integer(age), `2` = 18.5, `3` = 22, `4` = 27,
                           `5` = 32, `6` = 37, `7` = 42, `8` = 47, `9` = 52,
                           `10` = 57, `11` = 62, `12` = 67, `13` = 72,
                           `14` = 77, `15` = 87),
    # count of disliked genres (taste codes: 1 like, 2 dislike, 3 mixed, 4 dk)
    numdislikes = rowSums(across(all_of(paste0(taste_names, "taste"))) == 2,
                          na.rm = FALSE)
  ) |>
  mutate(
    race1 = as.numeric(raceeth == 1), race2 = as.numeric(raceeth == 2),
    race3 = as.numeric(raceeth == 3), race4 = as.numeric(raceeth == 4),
    race5 = as.numeric(raceeth == 5), race6 = as.numeric(raceeth == 6),
    # Stata tab degree, g(degree): degree2-degree5 = degree values 1-4
    # (baseline = less than high school)
    degree2 = as.numeric(degree == 1), degree3 = as.numeric(degree == 2),
    degree4 = as.numeric(degree == 3), degree5 = as.numeric(degree == 4)
  )
fit5 <- zip_fit(numdislikes ~ agemid + I(agemid^2 / 100) + race1 + race2 + race3 + race5 + race6 +
                  degree2 + degree3 + degree4 + degree5,
                ~ agemid + race1 + race2 + race3 + race5 + race6 + degree4, d_ssi)

coefs <- tibble(term = names(coef(fit5)), b = coef(fit5), se = robust_se(fit5))
race_labs <- c(race1 = "Asian", race2 = "Black", race3 = "Hispanic",
               race5 = "Mixed", race6 = "Other")
panel5 <- function(part, color, title) {
  n_count <- length(fit5$coefficients$count)
  idx <- if (part == "count") seq_len(n_count) else seq_len(n_count) + n_count
  coefs |>
    filter(row_number() %in% idx,
           sub("^(count|zero)_", "", term) %in% names(race_labs)) |>
    transmute(term = recode(sub("^(count|zero)_", "", term), !!!race_labs),
              b, se, component = title, color)
}
plot5 <- bind_rows(panel5("zero", "blue", "Categorical Tolerance Effect"),
                   panel5("count", "red", "Symbolic Exclusion Effect"))

p5 <- ggplot(plot5, aes(b, term, color = component)) +
  geom_vline(xintercept = 0, linetype = "solid", color = "grey50") +
  geom_point(size = 4, shape = 18) +
  geom_errorbarh(aes(xmin = b - 1.96 * se, xmax = b + 1.96 * se), height = 0.1) +
  facet_wrap(~ component, nrow = 1) +
  scale_color_manual(values = c("Categorical Tolerance Effect" = "blue",
                                "Symbolic Exclusion Effect" = "red")) +
  labs(x = "Coefficient Estimate", y = NULL, color = NULL) +
  theme_minimal() +
  theme(legend.position = "top")

ggsave("output/figures/Figure5.png", p5, width = 6.5, height = 3, dpi = 200)

cat("Table 3 and Figures 3-5 written\n")
