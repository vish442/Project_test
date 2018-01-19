function RayNormalsNx3=SurfNormals_ParabaloidSymmetric(ParabaloidPointsNx3,ParabaloidVertex1x3,ParabaloidFocus1x3)
N=size(ParabaloidPointsNx3,1);
PmV=ParabaloidPointsNx3-ones(N,1)*ParabaloidVertex1x3;
FmV=ones(N,1)*(ParabaloidFocus1x3-ParabaloidVertex1x3);
%solve for ray normals - this line really is this simple, but the derivation is a little less so
RayNormalsNx3= PmV - ((sum(PmV.*FmV,2)./sum(FmV.^2,2))*ones(1,3)).*FmV - 2*FmV;
%normalize the ray normals
RayNormalsNx3=RayNormalsNx3./(sqrt(sum(RayNormalsNx3.^2,2))*ones(1,3));

%Uncomment the next line to see the surface normals
% plot3([ParabaloidPointsNx3(:,1),ParabaloidPointsNx3(:,1)+5*RayNormalsNx3(:,1)]',[ParabaloidPointsNx3(:,2),ParabaloidPointsNx3(:,2)+5*RayNormalsNx3(:,2)]',[ParabaloidPointsNx3(:,3),ParabaloidPointsNx3(:,3)+5*RayNormalsNx3(:,3)]','Color','b','Tag','SpaceTrace')
end