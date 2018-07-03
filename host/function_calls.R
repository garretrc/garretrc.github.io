##########################################################
# Parameterization and Comparison of ggvoronoi functions #
# July 3, 2018                                           #
##########################################################

####Setup####

#first, reinstall ggvoronoi
devtools::install_github("garretrc/ggvoronoi")
library(ggvoronoi)
library(ggplot2)

#grab some fake data
x=sample(1:100,50)
y=sample(1:100,50)
fill = sqrt((x-50)^2 + (y-50)^2) #distance form the center
points = data.frame(x=x,y=y,fill=fill)

circle = data.frame(x = 50*(1+cos(seq(0, 2*pi, length.out = 1000))), 
                    y = 50*(1+sin(seq(0, 2*pi, length.out = 1000))),
                    group=rep(1,1000))

####Paths####
#There are multiple ways to do this:

#with geom_voronoi
ggplot(points)+
  geom_voronoi(aes(x,y),fill=NA,color="black",outline=circle)

#This works, but geom_voronoi is tied to geom_polygon! 
#We can allow the user to specify geom_polygon or path here
#but then geom_voronoi isn't really a geom anymore


#with stat_voronoi
ggplot(points)+
  stat_voronoi(aes(x,y),geom="path",outline=circle)

#This seems more technically natural in ggplot but not
#as user friendly


#with geom_path
ggplot(points)+
  geom_path(aes(x,y),stat="voronoi",outline=circle)

#Don't think anyone will ever use that call, but it
#shows how the stat is what matters in the code 


#And we can plot after creating a SpatialPolygonsDataFrame for analysis
vor_spdf=voronoi_polygon(points,x="x",y="y",outline=circle)
vor_df=fortify_voronoi(vor_spdf)

ggplot(vor_df)+
  geom_path(aes(x,y,group=group))
#Note with fortify_voronoi we may be better off just having the user
#do the left join and fortify themselves
#getAnywhere("fortify_voronoi")


####Polygons####

#geom_voronoi
ggplot(points)+
  geom_voronoi(aes(x,y,fill=fill),outline=circle)

#stat_voronoi
ggplot(points)+
  stat_voronoi(aes(x,y,fill=fill),outline=circle)

#Identical calls!


#geom_polygon
ggplot(points)+
  geom_polygon(aes(x,y,fill=fill),stat="voronoi",outline=circle)


#And we can create our own SPDF:
vor_spdf=voronoi_polygon(points,x="x",y="y",outline=circle)
vor_df=fortify_voronoi(vor_spdf)

ggplot(vor_df)+
  geom_polygon(aes(x,y,fill=fill,group=group))
