# Rebuild data/weather_circuit.csv from the Open-Meteo archive API
#
# Why this exists: the original working session assembled weather_circuit.csv
# once but never exported it, so this script regenerates it from the project's
# documented weather source (Open-Meteo). Output format matches exactly what
# 01_data-prep-and-modeling.Rmd parses:
#
#   line 1        : location_id,latitude,longitude,elevation,utc_offset_seconds,
#                   timezone,timezone_abbreviation
#   lines 2..78   : one metadata row per circuit, same order as circuits.csv,
#                   location_id = row index - 1 (0..76)
#   blank line    : skipped by read.csv
#   hourly header : location_id,time,temperature_2m (°C),rain (mm),
#                   wind_speed_10m (km/h),,   (read back as a data row; becomes
#                   colnames(weather_table) after the Rmd's split_row logic)
#   data rows     : <location_id>,<ISO hour>,<temp>,<rain>,<wind>,,
#
# Every line has exactly 7 comma-separated fields so read.csv never needs to
# pad, and the two trailing empty fields make the Rmd's
# `colnames(weather_table) != ""` filter drop them cleanly.
#
# Hours are fetched in UTC (timezone omitted = GMT), which is the convention of
# the committed raw extracts in data/weather/ and lines up with the Ergast
# race date/time fields (UTC) used to build race_start/race_end in the Rmd.
#
# Run from this project's root:
#   Rscript code/build_weather_circuit.R

circuits <- read.csv("data/ergast/circuits.csv", stringsAsFactors = FALSE)
races    <- read.csv("data/ergast/races.csv",    stringsAsFactors = FALSE)
races$date <- as.Date(races$date, tryFormats = c("%Y-%m-%d", "%d/%m/%Y"))

# The Rmd filters f1_dat to year >= 2010, so every race from 2010 on needs
# a weather window around it.
r <- races[!is.na(races$date) & races$date >= as.Date("2010-01-01"),
           c("circuitId", "date")]
r <- r[order(r$date), ]
cat(sprintf("races to fetch: %d\n", nrow(r)), file = stderr())

fetch_lines <- function(cid, d, tries = 3) {
  i <- match(cid, circuits$circuitId)
  u <- sprintf(paste0("https://archive-api.open-meteo.com/v1/archive?",
                      "latitude=%s&longitude=%s&start_date=%s&end_date=%s",
                      "&hourly=temperature_2m,rain,wind_speed_10m&format=csv"),
               circuits$lat[i], circuits$lng[i],
               format(d - 3, "%Y-%m-%d"), format(d + 3, "%Y-%m-%d"))
  for (k in seq_len(tries)) {
    ln <- tryCatch(readLines(u, warn = FALSE), error = function(e) character(0))
    if (length(ln) && any(grepl("^time,temperature_2m", ln))) return(ln)
    Sys.sleep(1.5 * k)
  }
  character(0)
}

data_rows <- character(0)
meta_vals <- setNames(vector("list", nrow(circuits)), circuits$circuitId)
header    <- NULL
missed    <- character(0)

for (k in seq_len(nrow(r))) {
  cid <- r$circuitId[k]
  ln  <- fetch_lines(cid, r$date[k])
  if (!length(ln)) {
    missed <- c(missed, sprintf("%s@%s", cid, r$date[k]))
    cat(sprintf("[miss] circuit %s on %s\n", cid, r$date[k]), file = stderr())
  } else {
    h <- grep("^time,temperature_2m", ln)[1]
    if (is.null(meta_vals[[as.character(cid)]])) meta_vals[[as.character(cid)]] <- ln[2]
    if (is.null(header)) header <- paste0("location_id,", ln[h])
    idx  <- match(cid, circuits$circuitId) - 1L      # 0-based location_id
    body <- ln[(h + 1):length(ln)]
    body <- body[nzchar(body)]
    data_rows <- c(data_rows, paste0(idx, ",", body, ",,"))  # -> 7 fields
  }
  if (k %% 25 == 0) cat(sprintf("  fetched %d/%d\n", k, nrow(r)), file = stderr())
  Sys.sleep(0.12)
}

data_rows <- unique(data_rows)
if (is.null(header) || !length(data_rows)) stop("no weather data fetched")
if (length(missed) > 50) stop(sprintf("too many failed fetches: %d", length(missed)))

lines <- "location_id,latitude,longitude,elevation,utc_offset_seconds,timezone,timezone_abbreviation"
for (i in seq_len(nrow(circuits))) {
  m   <- meta_vals[[as.character(circuits$circuitId[i])]]
  idx <- i - 1L
  if (is.null(m)) {
    # circuits with no 2010+ races: real coordinates from Ergast, empty tz block
    lines <- c(lines, sprintf("%d,%s,%s,%s,,,", idx,
                              circuits$lat[i], circuits$lng[i], circuits$alt[i]))
  } else {
    lines <- c(lines, paste0(idx, ",", m))
  }
}
lines <- c(lines, "", paste0(header, ",,"), data_rows)

con <- file("data/weather_circuit.csv", open = "wb")
writeLines(lines, con, useBytes = TRUE)   # keep the API's UTF-8 bytes verbatim
close(con)

cat(sprintf("wrote data/weather_circuit.csv: %d location rows, %d weather rows, %d missed races\n",
            nrow(circuits), length(data_rows), length(missed)), file = stderr())
