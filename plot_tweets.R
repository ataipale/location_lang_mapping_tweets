library(readr)
library(dplyr)
library(ggplot2)
library(ISOcodes)
library(ggmap)
# library(leaflet)
# library(RColorBrewer)

tweets <- read_csv("lang-long-lat.csv",
  col_names=c("language", "longitude", "latitude"))

data(ISO_639_2)
ISO_639_2 <- tbl_df(ISO_639_2)

tweets <- left_join(tweets, ISO_639_2, by=c("language"="Alpha_2"))

tweets$Name[tweets$language == "in"] <- "Indonesian"
tweets$Name[tweets$language == "iw"] <- "Hebrew"
tweets$Name[tweets$language == "und"] <- "Undetermined"

tweets <- tweets %>%
  mutate(language = Name) %>%
  select(-Alpha_3_B, -Alpha_3_T, -Name)

make_plot <- function(tweets, city, top=20) {
  map <- get_map(city)

  tweets <- tweets %>%
    filter(
      latitude > attr(map, "bb")[1, "ll.lat"],
      latitude < attr(map, "bb")[1, "ur.lat"],
      longitude > attr(map, "bb")[1, "ll.lon"],
      longitude < attr(map, "bb")[1, "ur.lon"])

  languages <- tweets %>%
    group_by(language) %>%
    summarise(count=n()) %>%
    arrange(desc(count))

  tweets$language[!tweets$language %in% languages$language[1:top]] <- "Other"
  tweets$language <- factor(tweets$language,
    levels=c(languages$language[1:top], "Other"), ordered=TRUE)
  
  #ggplot
  # ggplot(tweets, aes(x=longitude, y=latitude, color=language)) + geom_point()

  # ggmap
  ggmap(map, extent="device") +
    geom_point(data=tweets, aes(x=longitude, y=latitude, color=language))
  
  # leaflet
  # check that top+1 >= 12 or given an error
  # col <- brewer.pal(top+1, "Paired")
  # p <- leaflet() %>%
  #   addTiles()
  # for (i in seq_along(levels(tweets$language)))
  #   p <- p %>% addCircles(
  #     data=tweets[tweets$language == levels(tweets$language)[i],],
  #     ~longitude, ~latitude, col=col[i], weight=10, opacity=1,
  #     popup=levels(tweets$language)[i])
  # p
}

make_plot(tweets, "New York", top=10)
make_plot(tweets, "London", top=10)
make_plot(tweets, "Helsinki", top=10)
make_plot(tweets, "Los Angeles", top=10)
make_plot(tweets, "Seattle", top=10)
make_plot(tweets, "San Francisco", top=10)
make_plot(tweets, "Toronto", top=10)
make_plot(tweets, "Montreal", top=10)
make_plot(tweets, "Denver", top=10)
make_plot(tweets, "Vancouver, BC", top=10)

