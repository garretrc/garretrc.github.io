####Bikes Wrangling####
library(dplyr)

campus=read.csv("http://garretrc.github.io/host/BikeRack_Survey_data.csv",stringsAsFactors = F)
downtown=read.csv("http://garretrc.github.io/host/downtownracks.csv",stringsAsFactors = F)

oxford_bikes = dplyr::bind_rows(
  campus %>% dplyr::select(x,y,name=Building),
  downtown %>% dplyr::select(x=POINT_X,y=POINT_Y,name=Rack_Name)
) %>% distinct(x,y,.keep_all=T)

write.csv(oxford_bikes,file="oxford_bikes.csv",row.names = F)
