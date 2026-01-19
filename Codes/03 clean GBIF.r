
# Here lets clean all the data and maybe give 2pac only cellID for EU

pacman::p_load(readxl, dplyr, ggplot2, tidyr, stringr, data.table, readr, countrycode,rgbif)
source("./Codes/functions.r")


dat <- readRDS("Raw.occ.rds")
unique(dat$species)
nrow(dat)

i.care <- c("species", "basisOfRecord", "occurrenceStatus", "year" , "decimalLatitude", "decimalLongitude")

dat2 <- dat %>% select(all_of(i.care))
nrow(dat2)
head(dat2)
unique(dat2$species)
