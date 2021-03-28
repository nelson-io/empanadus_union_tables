#connect to google drive
library(tidyverse)
library(googledrive)
library(lubridate)

drive_auth(email = 'nelsonshilman@gmail.com',cache = gargle::gargle_oauth_cache())

drive_find(n_max = 10)


d_list <- drive_ls(path = as_id('1F7mN09qyRou609ao7uStAtmKGwpDr2VK')) %>% 
  filter(str_detect(name, 'csv'))

d_list_2 <- drive_ls(path = as_id('1dQf0Md-2ncd3MKWWm6nceOl9cWKAJfOB')) %>% 
  filter(str_detect(name, 'csv'))


# create tempdir
dir.create(paste0(tempdir(),'/files_0'))
dir.create(paste0(tempdir(),'/files_1'))
#download files

walk(1:nrow(d_list), ~ drive_download(as_id(d_list$id[.x]),path = paste0(tempdir(),'/files_0/',d_list$name[.x])))
walk(1:nrow(d_list), ~ drive_download(as_id(d_list_2$id[.x]),path = paste0(tempdir(),'/files_1/',d_list_2$name[.x])))

# generate df

read_empanadus <- function(name,store){
  x <- read_csv(name) %>% 
    mutate(store = store,
           start_date = name %>% str_sub(-35,-28) %>% ymd(),
           end_date = name %>% str_sub(-26, -19) %>% ymd())
  
  return(x)
  
}

lagrange_list <- map(list.files(paste0(tempdir(),'/files_0'),full.names = T), ~ read_empanadus(.x, store = 'La Grange')) 
riverside_list <- map(list.files(paste0(tempdir(),'/files_0'),full.names = T), ~ read_empanadus(.x, store = 'Riverside'))

lagrange_df <- do.call('rbind', lagrange_list)
riverside_df <- do.call('rbind', riverside_list)

df <- rbind(lagrange_df, riverside_df)
write_csv(df, 'data/df.csv')
# drive_upload('data/df.csv')

drive_update(as_id('1G1ElH2hCn4gmMM83NUX4axacvjegyV3M'),'data/df.csv')

               