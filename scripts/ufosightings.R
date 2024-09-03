library(tidytuesdayR)
library(tidyverse)
library(leaflet)
library(cpaltemplates)
library(sf)

tuesdata <- tidytuesdayR::tt_load('2023-06-20')
tuesdata <- tidytuesdayR::tt_load(2023, week = 25)

ufo_sightings <- tuesdata$`ufo_sightings`

state_coords <- read.csv("data/states.csv")

place <- tuesdata$`places`

us_sightings <- ufo_sightings[(ufo_sightings$country_code == 'US'), c(1:12)]

us_place <- place[(place$country_code == 'US'), c(1:10)]

us_sightings_joined <- merge(us_sightings, us_place, by = "city")

us_sightings_joined <- us_sightings_joined %>%
  mutate(reported_date_time = as.Date(reported_date_time, origin = "1970-01-01"))

unique_sightings <- distinct(us_sightings_joined, us_sightings_joined$reported_date_time, .keep_all = TRUE)

ufo_sf <- unique_sightings %>%
  st_as_sf(coords = c("longitude","latitude"), crs=4326)

min(us_sightings$reported_date_time)
max(us_sightings$reported_date_time)

leaflet(data = ufo_sf) %>%
  addTiles(urlTemplate = cpaltemplates::cpal_mapbox_color,
           attribution = cpaltemplates::cpal_leaflet) %>%
  addCircleMarkers(
    lng = ~st_coordinates(ufo_sf)[,1],
    lat = ~st_coordinates(ufo_sf)[,2],
    radius = 5,
    color = palette_cpal_main[6],
    fillOpacity = 0.5,
  ) 

st_write(ufo_sf, "data/ufolocation.gpkg", layer = "geocoded_addresses", delete_layer = TRUE)

