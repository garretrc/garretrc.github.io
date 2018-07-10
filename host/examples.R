devtools::install_github("garretrc/ggvoronoi")
library(ggvoronoi)
library(tidyverse)

####Example 1: Voronoi Diagram Simulation####

#start with some simulated data, keep n at 100 to start
n=5000
x=sample(1:n,n/2)
y=sample(1:n,n)
fill = sqrt((x-n/2)^2 + (y-n/2)^2) #distance form the center
points = data.frame(x=x,y=y,fill=fill)

#ggvoronoi allows us to draw voronoi diagram heatmaps.
#What does this mean? 
#a Voronoi Diagram draws the nearest neighbor regions around a set of points
#and by specifying a fill argument we can turn that into a heatmap!
ggplot(points,aes(x,y))+
  geom_voronoi(aes(fill=fill))

#or we can draw the points with the region boundaries!
ggplot(points,aes(x,y))+
  geom_path(stat="voronoi")+
  geom_point()

#these plots rely on our newly created ggplot stat, stat_voronoi
#stat_voronoi allows us to use the functions in the deldir package
#to visualize as well are more easily manipulate voronoi diagrams
#You can use stat_voronoi as its own layer, use it with geom_path or geom_polygon,
#or use our geom_voronoi function for convenience

#But what if we want the diagram drawn in a pre-defined region? deldir doesn't help with this
#the outline argument can take any dataframe with the following structure:
#first column is x/longitude
#second column is y/latitude
#optional column "group"
#Or you can feed it any SpatialPolygonsDataFrame!

circle = data.frame(x = (n/2)*(1+cos(seq(0, 2*pi, length.out = 2500))), 
                    y = (n/2)*(1+sin(seq(0, 2*pi, length.out = 2500))),
                    group=rep(1,2500))

ggplot(data=points, aes(x=x, y=y, fill=fill)) + 
  geom_voronoi(outline = circle,color="black",size=.05)

#And with more knowledge of ggplot2 we can add more:
ggplot(points,aes(x,y))+
  geom_voronoi(aes(fill=fill),outline=circle)+
  scale_fill_gradient(low="#4dffb8",high="black",guide=F)+
  theme_void()+
  coord_fixed()

#If you found this example interesting, go back up and set n=5000 and run these again!
#Make sure to re-run the circle data if you do this

#Now these circles look pretty, but what are some actual applications?

####Example 2: Oxford Bikes Dataset####

#For this example, we'll be using the locations of each bike rack in Oxford, Ohio
#Note that ggvoronoi at the moment is limited to euclidean distance calculations.
#As such, using longitude and latitude will result in approximate Voronoi regions,
#But with high sample size or a small area on the globe (such as one small town),
#ggvoronoi still produces a useful (and near-exact) result!
bikes = read.csv("http://garretrc.github.io/host/oxford_bikes.csv",stringsAsFactors = F)

#first build the base map
library(ggmap)
library(ggthemes)

ox_map = get_map(location = c(-84.7398373,39.507306),zoom = 15)
bounds = as.numeric(attr(ox_map,"bb"))

map=
  ggmap(ox_map,base_layer = ggplot(data=bikes,aes(x,y)))+ #map of oxford
  xlim(-85,-84)+ylim(39,40)+                              #adjust plot limits
  coord_map(ylim=bounds[c(1,3)],xlim=bounds[c(2,4)])      #adjust plot zoom

#Now lets take a look!
map + geom_path(stat="voronoi",alpha=.085,size=1)+
      geom_point(color="blue",size=.9)
    
#Here we can visually see each bike rack along with the Voronoi Region.
#So, given a bike rack, the region surrounding it is the area in Oxford for
#which that is the closest bike rack. 
#But what if we want to utilize this, not just look at it?

#First, we can build a voronoi diagram as a SpatialPolygonsDataFrame
#The voronoi_polygon function takes in:
#data: a data frame (will need at least 2 numeric columns)
#x: dataframe column name or index for the x variable
#y: dataframe column name or index for the y variable
#outline: a data.frame or SpatialPolygonsDataFrame witha  map outline

ox_diagram = voronoi_polygon(bikes,x="x",y="y")

#now, lets take a point of interest in Oxford, say Mac & Joes, a popular restuarant/bar.
#Google Maps can give me directions there, but there is no place to chain up a bike.
#So, lets use the diagram!

library(sp)
#create a point with Mac & Joes' location
mac_joes = SpatialPointsDataFrame(cbind(long=-84.7418,lat=39.5101),
                                  data=data.frame(name="Mac & Joes"))

#overlay the point on our voronoi diagram
mac_joes %over% ox_diagram
#nd there we have the coordinates of the closest bike rack to Mac & Joes!

#Let's plot the map again.
#First, plot he voronoi regions using the SpatialPolygonsDataFrame
#Next, zoom into the area of interest (Uptown Oxford)
#Then, plot Mac & Joes with a red point
#Find the closest bike rack and drop a blue point
#Lastly, plot the rest of the racks for visual comparison
map + geom_path(data=fortify_voronoi(ox_diagram),aes(x,y,group=group),alpha=.1,size=1)+
      coord_map(xlim=c(-84.747,-84.737),ylim=c(39.5075,39.515))+
      geom_point(data=data.frame(mac_joes),aes(long,lat),color="red",size=4)+
      geom_point(data=mac_joes %over% ox_diagram,aes(x,y),color="blue",size=4)+
      geom_point(size=2)

#So, we can see if you're headed to Mac & Joes for lunch you're better off
#using the bike rack across High Street than the one on South Poplar
