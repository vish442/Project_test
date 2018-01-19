function inWindow = WindowingFcn_Plane(SpatialPointsNx3,PlanePoint1x3,PlaneNormalVector1x3)
%keep the points that are on the side of the plane that PlaneNormalVector1x3 points into 
N=size(SpatialPointsNx3,1);
inWindow=sum((SpatialPointsNx3 - ones(N,1)*PlanePoint1x3).*(ones(N,1)*PlaneNormalVector1x3),2) > 0;
end