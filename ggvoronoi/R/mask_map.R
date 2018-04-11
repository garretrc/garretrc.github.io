#' Invert a sp polygon
#'
#' invert a map you want to use voronoi_polygon() on to hide voronoi lines
#' @param map SpatialPolygonsDataFrame with lat and long
#' @param width mask border size
#' @param piece if your SPDF has pieces choose which one to mask
#' @keywords mask
#' @export
#' @examples ggplot+geom_polygon(mask_map(map),aes(x=long,y=lat))
#' mask_map()

mask_map = function(map,width=5,piece=1){
  map = fortify(map)
  
  if(!is.null(map$piece)){
    map = map[which(map$piece==piece),]
  }
  
  top = max(map$lat) + width# north lat
  left = min(map$long) - width # west long
  right = max(map$long) + width # east long
  bottom = min(map$lat) - width# south lat
  mid = left+right / 2
  
  map = rbind(map, map[1,])
  rim = data.frame(X = c(left, right, right, left, left), Y = c(top, top, bottom, bottom, top) )
  
  mask <- rbind(rim,map %>% select(X = long, Y = lat)) %>% as.data.frame()
  names(mask) <- c("long","lat")
  
  mask
}
