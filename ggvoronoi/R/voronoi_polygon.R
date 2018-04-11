#' Voronoi chloropleth through geom_polygon
#'
#' Wrapper on geom_polygon using deldir
#' @param x numeric vector (for example longitude)
#' @param y numeric vector (for example latitude)
#' @param fill numeric vector of polygon colors (map chloropleth variable here)
#' @param color line color (see ggplot2)
#' @param size line size (see ggplot2)
#' @param linetype see ggplot2
#' @param alpha see ggplot2
#' @keywords voronoi, chloropleth
#' @export
#' @examples ggplot()+voronoi_polygon(x=1:5,y=sample(1:5,5),fill=1:5,color=NA,size=1)
#' voronoi_polygon()

voronoi_polygon = function(x = sample(1:100,100), y = sample(1:100,100),
                           color = "black", fill = "white", size = NA, 
                           linetype = 1, alpha = NA){
  
  data = data.frame(x,y,fill,alpha)
  
  pts = SpatialPointsDataFrame(
    cbind(x, y), data, match.ID = T)
  
  
  #https://github.com/ryantimpe/AgeOfReptiles/blob/master/4_Voronoi.R
  vor_desc = tile.list(deldir(pts@coords[,1], pts@coords[,2]))
  
  lapply(1:(length(vor_desc)), 
         function(i) {
           tmp <- cbind(vor_desc[[i]]$x, vor_desc[[i]]$y)
           tmp <- rbind(tmp, tmp[1,])
           Polygons(list(Polygon(tmp)), ID=i)
         }
  ) -> vor_polygons
  
  rownames(pts@data) = sapply(slot(SpatialPolygons(vor_polygons),'polygons'),slot, 'ID')
  #back to my own code
  
  voronoi = fortify(SpatialPolygonsDataFrame(SpatialPolygons(vor_polygons),data=pts@data))
  data$id = 1:nrow(data)
  voronoi = merge(voronoi, data, by = "id", all.x = TRUE)
  
  
  if(length(fill)>1){
    if(length(alpha)>1){
      return(geom_polygon(data=voronoi,aes(x=voronoi$long,y=voronoi$lat,group=voronoi$group,fill=voronoi$fill,alpha=voronoi$alpha),size = size,color = color,linetype =linetype))
    }else{
      return(geom_polygon(data=voronoi,aes(x=voronoi$long,y=voronoi$lat,group=voronoi$group,fill=voronoi$fill),size=size,color=color,linetype = linetype,alpha=alpha))
    }
  }else{
    if(length(alpha)>1){
      return(geom_polygon(data=voronoi,aes(x=voronoi$long,y=voronoi$lat,group=voronoi$group,alpha=voronoi$alpha),size=size,color=color,linetype = linetype,fill=fill))
    }else{
      return(geom_polygon(data=voronoi,aes(x=voronoi$long,y=voronoi$lat,group=voronoi$group),fill=fill,size=size,color=color,linetype = linetype,alpha=alpha))
    }
  }
}
