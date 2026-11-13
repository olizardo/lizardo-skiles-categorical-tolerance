# Download the public SSI-2012 cleaned dataset.
# GSS 1993 data is obtained from the gssr package (Kieran Healy), see 02-process-gss-1993.R.
# SSI-2012: Lizardo & Skiles (2012), https://olizardo.github.io/SSI-2012/ (CC BY 4.0)

fs::dir_create("data-raw")

ssi_url <- "https://raw.githubusercontent.com/olizardo/SSI-2012/master/data/clean/ssi2012_cleaned.rds"
ssi_path <- "data-raw/ssi2012_cleaned.rds"
if (!file.exists(ssi_path)) {
  download.file(ssi_url, ssi_path, mode = "wb")
}
cat("SSI-2012 downloaded to", ssi_path, "\n")
