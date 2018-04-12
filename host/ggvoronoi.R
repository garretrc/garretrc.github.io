devtools::install_github("garretrc/ggvoronoi")
library(ggvoronoi) #also loads dplyr, ggplot2, sp, deldir

#start with some simulated data and drawing the path only
x=sample(1:100,50)
y=sample(1:100,50)

?voronoi_path
ggplot()+voronoi_path(x,y)

#now add a simple fill component and turn these into polygons!
?voronoi_polygon
ggplot()+voronoi_polygon(x=x,y=y,fill=1:50)

#sweet! of course we can get fancy with this since we're using ggplot2
#base fill on distance from the center
fill = sqrt((x-50)^2 + (y-50)^2)

ggplot()+
  voronoi_polygon(x,y,fill=fill)+
  scale_fill_gradient(low="white",high="red")+
  geom_point(aes(x,y),alpha=.2)

#Now for an actual use case, maps!

USarea = map_data("usa") %>% filter(region == "main")

#grab some quick data on us cities from https://simplemaps.com/data/us-cities

#takes ~10 seconds
cities = read.csv("https://simplemaps.com/static/data/us-cities/uscitiesv1.4.csv")

#grab only states in the continental US
cities = cities %>%
  filter(!(state_name %in% c("Alaska","Hawaii","Puerto Rico"))) %>%
  mutate(long=lng) %>% dplyr::select(-lng) %>% filter(lat>20)

#grab highest population sity in each state
pop = cities %>% group_by(state_id) %>% arrange(-population) %>% slice(1)

#plot the cities
ggplot()+
  geom_path(data = USarea, aes(x=long,y=lat))+
  geom_point(data = pop, aes(x=long,y=lat))

#now plot the voronoi regions
ggplot()+
  voronoi_polygon(x=pop$long, y=pop$lat, fill=log(pop$population))+
  geom_path(data=USarea,aes(x=long,y=lat))+
  geom_point(data=pop,aes(x=long,y=lat))+
  scale_fill_gradient(low="white",high="darkgreen",guide=F)

#Looks good... but theres one last issue. Voronoi Diagrams don't inherently like borders
#time for our last R function

#We create a "cookie cutter" shape of the US
?mask_map
ggplot()+
  geom_polygon(data=mask_map(USarea),aes(x=long,y=lat))

#now throw this on top of our chloropleth!
map = ggplot()+
  voronoi_polygon(x=pop$long, y=pop$lat, fill=log(pop$population))+
  geom_polygon(data=mask_map(USarea),aes(x=long,y=lat),fill="white",color=NA)+
  geom_path(data=USarea,aes(x=long,y=lat))+
  geom_point(data=pop,aes(x=long,y=lat))+
  scale_fill_gradient(low="white",high="darkgreen",guide=F)
map

#And if you have ggthemes installed you can theme_map it!
map+ggthemes::theme_map()
