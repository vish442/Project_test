function RayNormalsNx3=SurfNormals_Plane(PlanePointsNx3,PlaneNormal1x3)
PlaneNormal1x3=PlaneNormal1x3./norm(PlaneNormal1x3);%make sure the plane normal is normalized
RayNormalsNx3=ones(size(PlanePointsNx3,1),1)*PlaneNormal1x3;%duplicate into Nx3 and save for output
end