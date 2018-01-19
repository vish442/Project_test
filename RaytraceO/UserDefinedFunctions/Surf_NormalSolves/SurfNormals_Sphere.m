function RayNormalsNx3=SurfNormals_Sphere(SpherePointsNx3,SphereCenter1x3)
N=size(SpherePointsNx3,1);
RayNormalsNx3=SpherePointsNx3-ones(N,1)*SphereCenter1x3;
RayNormalsNx3=RayNormalsNx3./(sqrt(sum(RayNormalsNx3.^2,2))*ones(1,3));
end