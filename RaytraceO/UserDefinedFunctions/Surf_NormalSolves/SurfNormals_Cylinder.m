function RayNormalsNx3=SurfNormals_Cylinder(CylinderPointsNx3,CylinderAxisPoint1x3,CylinderDirection1x3)
N=size(CylinderPointsNx3,2);
CP=CylinderPointsNx3;
AP=ones(N,1)*CylinderAxisPoint1x3;
CD=ones(N,1)*CylinderDirection1x3;
  %calculation normaldirection = CP-(AP+dot(CP-AP,CD)*CD/dot(CD,CD))
RayNormalsNx3=CP-(sum((CP-AP).*CD,2)*ones(1,3)).*CD./(sum(CD.*CD,2)*ones(1,3)) - AP;
%normalize the lengths of the surface normals
RayNormalsNx3=RayNormalsNx3./(ones(N,1)*sqrt(sum(RayNormalsNx3.^2,2)));
end