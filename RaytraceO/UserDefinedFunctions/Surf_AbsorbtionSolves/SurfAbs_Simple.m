%[absorptionCoefficientsNx1]= SurfAbs_Simple (incidentRaysetO, incidentSurfaceNormalsNx3, UniformAbsorptionCoefficient1x1)
function [absorptionCoefficientsNx1]=SurfAbs_Simple(RaysetOobj,~,absCoeff)
absorptionCoefficientsNx1=ones(size(RaysetOobj.RayPositions,2),1)*absCoeff;
end