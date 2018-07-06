library(ggvoronoi)
library(ggplot2)

####Example 1: Voronoi Diagram Simulation####

#start with some simulated data and drawing the path only
n=100
x=sample(1:n,n/2)
y=sample(1:n,n)
fill = sqrt((x-n/2)^2 + (y-n/2)^2) #distance form the center
points = data.frame(x=x,y=y,fill=fill)

#ggvoronoi allows us to draw voronoi diagram heatmaps.
#What does this mean? 
#a Voronoi Diagram draws the nearest neighbor regions around a set of points
#and by specifying a fill argument we can turn that into a heatmap!
ggplot(points)+
  geom_voronoi(aes(x,y,fill=fill))+
  theme_minimal()

#or we can draw only the region boundaries!
ggplot(points)+
  geom_path(aes(x,y),stat="voronoi")+
  theme_minimal()

#these plots rely on our newly created ggplot stat, stat_voronoi
#stat_voronoi allows us to use the functions in the deldir
#package to visualize as well are more easily manipulate voronoi diagrams
#You can use stat_voronoi as its own layer, use it with geom_path or geom_polygon,
#or use our geom_voronoi function for convenience


#But what if we want the diagram drawn in a predefined region? deldir doesn't help with this
#the outline argument can take any dataframe with the following structure:
#first column is x/longitude
#second column is y/latitude
#optional column "group"
#Or you can feed it any spatial polygons dataframe!

circle = data.frame(x = (n/2)*(1+cos(seq(0, 2*pi, length.out = 1000))), 
                    y = (n/2)*(1+sin(seq(0, 2*pi, length.out = 1000))),
                    group=rep(1,1000))

ggplot(data=points, aes(x=x, y=y, fill=fill)) + 
  geom_voronoi(outline = circle)+
  theme_minimal()

#And with more knowlege of ggplot we can add more:
ggplot(points,aes(x,y))+
  geom_voronoi(aes(fill=fill),outline=circle)+
  scale_fill_gradient(low="#4dffb8",high="black",guide=F)+
  geom_point(color="white",alpha=.15)+
  geom_path(stat="voronoi",color="white",alpha=.15,size=1.25)+
  theme_void()

#Now these circles look pretty, but what re some actual applications?

####Example 2: Oxford Bikes Dataset####

#For this example, we'll be using the locations of each bike rack in Oxford, Ohio
bikes = read.csv("http://garretrc.github.io/host/oxford_bikes.csv",stringsAsFactors = F)

#first build the base map
library(ggmap)
library(ggthemes)

ox_map = get_map(location = c(-84.7398373,39.507306),zoom = 15)
bounds = as.numeric(attr(ox_map,"bb"))

map=ggmap(ox_map,base_layer = ggplot(data=bikes,aes(x,y)))+xlim(-85,-84)+ylim(39,40)+coord_map(ylim=bounds[c(1,3)],xlim=bounds[c(2,4)])

#Now lets take a look!
map + geom_path(stat="voronoi",alpha=.085,size=1)+
      geom_point(color="blue",size=.9)
    
  

#Here we can visually see each bike rack along with the Voronoi Region.
#So, given a bike rack, the region surrounding it is the are in Oxford for
#which that is the closest bike rack. 
#But what if we want to utilize this, not just look at it?

#First, we can build a voronoi diagram as a SpatialPolygonsDataFrame

ox_diagram = voronoi_polygon(bikes,x="x",y="y")

#now, lets take a point of interest in Oxford, say Starbucks.
#Google Maps can give me directions there, but there is no place to chain up a bike.
#So, lets use the diagram!

library(sp)
#create a point with Starbucks' location
ox_starbucks = SpatialPoints(cbind(-84.7432478,39.509924))

#overlay the point on our voronoi diagram
ox_starbucks %over% ox_diagram

map + geom_path(data=fortify_voronoi(ox_diagram),aes(x=x,y=y,group=group),alpha=.1,size=1)+
      geom_point(data=ox_starbucks %over% ox_diagram,aes(x,y),color="blue",size=2)

####North America Example####

#This example will be using multiple maps, and is a bit more complicated!
us_cont = map_data(map = "usa")
mexico = map_data("world", "mexico")

outlines = rbind(us_cont, mexico)
outlines = outlines %>% 
  mutate(group = paste(region, subregion, group, sep = '.')) %>% # Need 'group' variable to be a unique variable now, wasn't from rbinding multiple together
  filter(long < 100) # Just to ignore that little Alaskan island that is on other side of 180/-180 line

cities = world.cities %>% filter(country.etc %in% c('USA', 'Mexico') & pop > 100000)

ggplot() + 
  geom_voronoi(data=cities, 
               aes(long, lat, fill = log(pop)),
               outline = outlines)+
  scale_fill_gradient(high="darkgreen",low="gray90")+
  geom_path(data=outlines, 
            aes(x=long,y=lat,group=group))+
  theme_minimal()+
  coord_map(projection = "gilbert")


####To be finished####

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
  geom_point(data = pop, aes(x=long,y=lat))+
  coord_map()

#Before we use the outline argument of voronoi_polygon, we need to make sure:
#First column is x/longitude
#Second column is y/latitude
#pieces of the map are denoted in the group column
names(USarea)

#now plot the voronoi regions with outline as the USarea dataframe
map = ggplot()+
  voronoi_polygon(x=pop$long, y=pop$lat, fill=log(pop$population),outline = USarea)+
  geom_path(data=USarea,aes(x=long,y=lat,group=group))+
  geom_point(data=pop,aes(x=long,y=lat))+
  scale_fill_gradient(low="white",high="darkgreen",guide=F)+
  coord_map()
map

#And if you have ggthemes installed you can theme_map it!
map+ggthemes::theme_map()

#Along with this, we can use voronoi_polygons to see the population of every us city at the same time!
#This makes voronoi diagrams a powerful tool for interpolation

#need to make sure to remove duplicate points!
all_cities = cities %>% filter(!is.na(population)) %>% distinct(long,lat,.keep_all = T) 

#caution: this might take a minute!
big.map = ggplot()+
  voronoi_polygon(x=all_cities$long,y=all_cities$lat,fill=log(all_cities$population),outline=USarea)+
  geom_path(data=USarea,aes(x=long,y=lat,group = group))+
  scale_fill_gradient(low="white",high="darkgreen",guide=F)+
  coord_quickmap()
big.map