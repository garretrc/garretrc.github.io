#' Voronoi tesselation through geom_path
#'
#' Wrapper on geom_path using deldir
#' @param x numeric vector (for example longitude)
#' @param y numeric vector (for example latitude)
#' @param color line color (see ggplot2)
#' @param size line size (see ggplot2)
#' @param linetype see ggplot2
#' @param alpha see ggplot2
#' @keywords voronoi
#' @export
#' @examples ggplot()+voronoi_path(x=1:5,y=sample(1:5,5),color="darkblue",size=1)
#' voronoi_path()

voronoi_path = function(x = sample(1:100,100), y = sample(1:100,100),
                        color = "black", size = 0.5, 
                        linetype = 1, alpha = NA){
  data=data.frame(x,y)
  
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
  
  geom_path(data=voronoi,aes(x=long,y=lat,group=group),size=size,color=color,linetype = linetype,alpha=alpha)
}
