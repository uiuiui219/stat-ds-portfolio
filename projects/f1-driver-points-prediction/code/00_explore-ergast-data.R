library(tools)

# setwd() removed — run with the project root as working directory

extract_dir <- tempdir() 
unzip("data/ergast-f1-data.zip", exdir = extract_dir)
csv_files <- unzip("data/ergast-f1-data.zip", list = TRUE, exdir = extract_dir)[,1]

csv_files

f1_data <- lapply(csv_files, function(file) {
  read.csv(file.path(extract_dir, file))
})

names(f1_data) <- file_path_sans_ext(csv_files)
names(f1_data)
list2env(f1_data, envir = .GlobalEnv)

rm(f1_data)


dat <- left_join(races,circuits, by = "circuitId")
kkk <- left_join(dat, results, by = "raceId")

View(kkk |> filter(statusId == 3, year > 2018)|> group_by(circuitRef)|> 
       summarise(kuy = sum(statusId), n()))
#--------------------------------


library(dplyr)

lap_times %>%
  group_by(raceId, driverId) %>%
  arrange(lap) %>%
  mutate(cumulative_time = cumsum(milliseconds)) %>%
  ungroup()

View(constructor_results)

races |> group_by(year) |> count() |> arrange(desc(n))

dat <- left_join(results, 
                 races, 
                 by = "raceId")


pairs(dat |> 
        mutate(driverId = as.factor(driverId),
                    circuitId = as.factor(circuitId)) |> 
        select(positionOrder,
              driverId,
              circuitId,
              grid))

library(randomForest)
rf_mod <- randomForest(x = dat |> select(driverId, 
                               circuitId,
                               grid),
             y = dat |> pull(points))

summary(rf_mod)
sqrt(mean((dat$points - rf_mod$predicted)^2))

lm_mod <- lm(positionOrder ~ driverId + circuitId + grid, data = dat)
sqrt(mean(dat$points - lm_mod$residuals)^2)



dat |> select(circuitId, statusId)
