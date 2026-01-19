
# I am going to get an unique Cell ID in a raster, so it is easy to extract the data for u

pacman::p_load(readxl, dplyr, ggplot2, tidyr, stringr, data.table, readr, countrycode)
source("./Codes/functions.r")

df = read.csv('C:/Users/IsmaSA/Desktop/Databases/SInAS_3.1.1.csv', sep =' ') # si quieres la meto aqui
head(df)
table(df$establishmentMeans)
table(df$habitat)

df = df[df$establishmentMeans != 'native', ]  
df <- df[grepl("freshwater", df$habitat), ]


glimpse(df)

df$CountryCode <- countrycode(df$location, origin = 'country.name', destination = 'iso3c',  custom_match = c(
"Azores" = "PRT",
"Balearic Islands" = "ESP",
"Canary Islands" = "ESP",
"Corsica" = "FRA",
"Madeira" = "PRT",
"Shetland Islands" = "GBR",
"Sicily" = "ITA" ))

eu <- codelist %>% filter(continent == "Europe") %>% pull(iso3c) %>% unique()

df1 = df[df$CountryCode  %in% eu , ]
nrow(df1)

spn = unique(df1$taxon)

spn1 <- sapply(spn, clean.sp)
s= spn1[50]

species_lookup <- data.frame(original_name = spn,cleaned_name = spn1, stringsAsFactors = FALSE)

gbif_keys <- data.frame(
  original_name = character(),
  cleaned_name = character(),
  specieskey = integer(),
  usagekey = integer(),
  status = character(),
  rank = character(),
  matchType = character(),
  stringsAsFactors = FALSE)

for(i in seq_along(spn1)) {
  s <- spn1[i]
  original <- spn[i]
  
  print(paste("P:", original, "->", s))
  
  tryCatch({
    dat <- rgbif::name_backbone(s)
    
    is_accepted_species <- !is.null(dat$status) && dat$status == "ACCEPTED"
    
    if(is_accepted_species) {
      specieskey <- ifelse(is.null(dat$speciesKey), NA, dat$speciesKey)
      usagekey <- ifelse(is.null(dat$usageKey), NA, dat$usageKey)
    } else {
      specieskey <- NA
      usagekey <- NA
    }
    
    gbif_keys <- rbind(gbif_keys,
                       data.frame(
                         original_name = original,
                         cleaned_name = s,
                         specieskey = specieskey,
                         usagekey = usagekey,
                         status = ifelse(is.null(dat$status), NA, dat$status),
                         rank = ifelse(is.null(dat$rank), NA, dat$rank),
                         matchType = ifelse(is.null(dat$matchType), NA, dat$matchType)
                       ))
    
  }, error = function(e){
    message(paste("Error with species:", original, "->", s))
    gbif_keys <<- rbind(gbif_keys,
                        data.frame(
                          original_name = original,
                          cleaned_name = s,
                          specieskey = NA,
                          usagekey = NA,
                          status = NA,
                          rank = NA,
                          matchType = NA
                        ))
  })
}

nas <- gbif_keys %>% filter(is.na(usagekey))
writexl::write_xlsx(gbif_keys, './Databases/Species.key.xlsx')

df1_with_keys <- df1 %>% left_join(gbif_keys, by = c("taxon" = "original_name"))

writexl::write_xlsx(df1_with_keys, './Databases/Species.full.xlsx')
