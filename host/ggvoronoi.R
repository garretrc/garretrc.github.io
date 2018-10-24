#### ggvoronoi for STA 404 ####
#Robert Garrett
#October 24th, 2018

#### Setup ####
install.packages("ggmap")
install.packages("ggvoronoi")
install.packages("gridExtra")
install.packages("sp")

library(ggmap)
library(ggvoronoi)
library(gridExtra)
library(dplyr)

#Tutorial for ggvoronoi
vignette("ggvoronoi")

#### Basic Example ####

#Random points
x <- sample(1:200,100)
y <- sample(1:200,100)

#Put the points in a data frame and add distance from the center as a variable
points <- data.frame(x, y,
                     distance = sqrt((x-100)^2 + (y-100)^2))

#And now we have the outline of a circle that contains some of our points
circle <- data.frame(x = 100*(1+cos(seq(0, 2*pi, length.out = 2500))),
                     y = 100*(1+sin(seq(0, 2*pi, length.out = 2500))),
                     group = rep(1,2500))

#Here is our set of points! Theres a lot of blank space in the plot
base = ggplot(points) + coord_fixed()

base+
  geom_point(aes(x,y,color=distance))

#what if we want to approximate the value of the fill variable for areas where there are no points?
#In this case theres a nice formula, but in general we will need some sort of model.
#As our model, consider the value of the closest point:
base +
  geom_point(aes(x,y,color=distance))+
  geom_path(aes(x,y),stat="voronoi")

#Now that we have nearest neighbor regions, all we need to do is fill them in with the corresponding color!
base +
  geom_voronoi(aes(x,y,fill=distance))

#And lastly if we have a boundary to put around our data, such as a geographic border,
#we can use the outline argument
base +
  geom_voronoi(aes(x,y,fill=distance),outline=circle)

#Fun idea I had: the last plot reminded me of a flower so here is the rose colored version
base +
  geom_voronoi(aes(x,y,fill=distance),outline=circle)+
  scale_fill_gradient(low="#510013",high="#ff2a5c",guide=F)+
  theme_void()

#As you can see, anything you've learned in ggplot2 can be applied to geom_voronoi

#Where could the nearest neighbor diagram be useful?

#Finding the closest...
#Hospital
#Gas Station
#Bird Scooter
#Bike Rack

#Nearest Neighbor heatmaps:
#Pollutants in the air
#Cell signal strength in a city
#Elevation of weather stations
#Interpolate Spatial Modeling predictions


#### Elevation of California ####
#Get to know the dataset
head(ncdc_locations)
?ncdc_locations

#Get outline of California
california <- map_data("state") %>% filter(region == "california")

#Get weather stations in California
ncdc_cali <- ncdc_locations %>% filter(state=="CA")

#Plot California with weather station locations
ggplot()+
  geom_path(data=california,aes(x=long,y=lat,group=group))+
  geom_point(data=ncdc_cali,aes(long,lat))

#Now color the points by elevation
ggplot()+
  geom_path(data=california,aes(x=long,y=lat,group=group))+
  geom_point(data=ncdc_cali,aes(long,lat,color=elev))

#The aesthetic mapping are off but our color scheme and plot scaling is lackluster.
#Lets make a base ggplot object to get rid of all the theme code
elevation_plot = ggplot()+
  scale_fill_gradientn("Elevation\n(meters)", 
                        colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
                        values=scales::rescale(c(-60,0,1000,2000,3000,4000))) + 
  scale_color_gradientn("Elevation\n(meters)", 
                         colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
                         values=scales::rescale(c(-60,0,1000,2000,3000,4000))) + 
  coord_quickmap() + 
  theme_minimal()+
  theme(axis.text = element_blank(),axis.title = element_blank())+
  ggtitle("Elevation of Weather Stations in California")

#Now use our base plot to make the map of california!
color_points = 
  elevation_plot+
    geom_path(data=california,aes(x=long,y=lat,group=group))+
    geom_point(data=ncdc_cali,aes(long,lat,color=elev),size=.9)

color_points

#The colors are much better, but we have the same basic plot here.
#What are some potential weaknesses of this plot?

#Now we'll make the same plot and compare it to the corresponding Voronoi heatmap
color_voronoi = 
  elevation_plot+
    geom_voronoi(data=ncdc_cali,aes(long,lat,fill=elev),outline=california)

grid.arrange(color_points,color_voronoi,nrow=1)

#You can use this code to make the same type of plot for any state


#### Oxford Bike Racks ####

#Get to know the dataset
head(oxford_bikes)
?oxford_bikes

#Download google map image of Oxford, OH
oxford_map <- get_googlemap(center = c(-84.7398373,39.507306),
                            zoom = 15,key="AIzaSyBWqYmcoGtgogsGOi50-gVEMNUNlXJ7RNg")

ggmap(oxford_map)

#Again, we set up a plot skeleton (no data is going on the plot yet!)
bounds <- as.numeric(attr(oxford_map,"bb"))

map <- ggmap(oxford_map,base_layer = ggplot(data=oxford_bikes,aes(x=x,y=y))) +
    xlim(-85,-84)+ylim(39,40)+
    coord_map(ylim=bounds[c(1,3)],xlim=bounds[c(2,4)]) +
    theme_minimal() +
    theme(axis.text=element_blank(),
          axis.title=element_blank())

#Now show a scatter plot of bike rack locations
map+
  geom_point(color="blue")+
  labs(title="Bike Racks in Oxford, OH",x=NULL,y=NULL)

#Now we have the basic idea down, and we can easily swap the points for
#a voronoi diagram
map+
  geom_point(color="blue")+
  geom_path(stat="voronoi",alpha=.4)

#Now how do we use this to find nearest neighbors?
#Well, first we want to build the diagram as a spatial object within R
ox_diagram <- voronoi_polygon(oxford_bikes,x="x",y="y")

#Then we want to get locations of interest in spatial format
library(sp)
mac_joes <- SpatialPointsDataFrame(cbind(long=-84.7418,lat=39.5101),
                                   data=data.frame(name="Mac & Joes"))

#From here we simply overlay the new data on the diagram
#this returns the location of the nearest bike rack to Mac and Joes
mac_joes %over% ox_diagram

#Same plot as before, but we zoom in.
#We place a red point at Mac and Joes,
#and a blue point at the nearest bike rack
map + 
  geom_path(data=fortify_voronoi(ox_diagram),aes(x,y,group=group),alpha=.1,size=2) +
  coord_map(xlim=c(-84.746,-84.739),ylim=c(39.508,39.514)) +
  geom_point(data=data.frame(mac_joes),aes(long,lat),color="red",size=4) +
  geom_point(size=3,stroke=1, shape=21,color="black",fill="white") +
  geom_point(data=mac_joes %over% ox_diagram,aes(x,y),color="blue",size=5)
