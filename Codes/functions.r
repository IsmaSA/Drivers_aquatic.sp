
# fucntions 

clean.sp <- function(name) {
  name <- str_trim(name)
  name <- str_replace(name, "\\s*\\([^)]+\\)", "")  
  name <- str_replace(name, "\\s+[A-Z][a-z]+,.*$", "")  
  name <- str_replace(name, "\\s+\\d{4}.*$", "")  
  name <- str_replace(name, " x ", " × ")  
  name <- str_replace(name, " f\\. ", " ")  
  name <- iconv(name, from = "UTF-8", to = "ASCII//TRANSLIT")
 
  words <- str_split(name, "\\s+")[[1]]
 # if (length(words) >= 3) {
  #  name <- paste(words[1:3], collapse = " ")
  #}
  return(str_trim(name))
}
