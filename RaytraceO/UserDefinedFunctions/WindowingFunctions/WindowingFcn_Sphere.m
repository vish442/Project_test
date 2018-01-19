function inWindow = WindowingFcn_Sphere(SpatialPointsNx3,SphereCenter1x3,SphereRadius)
inWindow=sum((SpatialPointsNx3-repmat(SphereCenter1x3,[size(SpatialPointsNx3,1),1])).^2,2)<SphereRadius^2;
end