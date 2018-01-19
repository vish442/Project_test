%  TransmittedRaysetOobj = Transmission_Snell(RaysetOobj,incidentSurfaceNormalsNx3,PendingRefractiveIndicesNx1)
% This function REQUIRES normalized vectors on the inputs:  for both
% direction vectors and surface normal vectors.
function TransmittedRaysetOobj = Transmission_Snell(IncidentRaysetOobj,incidentSurfaceNormalsNx3,PendingRefractiveIndicesNx1)
TransmittedRaysetOobj=RaysetO();

IncidentDirDottedWithSurfNormNx3=sum(IncidentRaysetOobj.RayDirections.*incidentSurfaceNormalsNx3,2)*[1,1,1];
RefrPerpToSurfNormNx3=((IncidentRaysetOobj.RAYnS./PendingRefractiveIndicesNx1)*[1,1,1]).*(IncidentRaysetOobj.RayDirections-IncidentDirDottedWithSurfNormNx3.*incidentSurfaceNormalsNx3);
TransmittedRaysetOobj.RayDirections = RefrPerpToSurfNormNx3 + (sqrt(1-sum(RefrPerpToSurfNormNx3.^2,2))*[1,1,1]).*incidentSurfaceNormalsNx3.*sign(IncidentDirDottedWithSurfNormNx3);
transmissionCoefficientsNx1=ones(size(TransmittedRaysetOobj.RayDirections,1),1);
transmissionCoefficientsNx1(any(imag(TransmittedRaysetOobj.RayDirections)~=0,2))=0; %set any TIR rays transmission to 0  (they are purely reflective - no transmission)
TransmittedRaysetOobj.RAYnS=PendingRefractiveIndicesNx1;  
TransmittedRaysetOobj.NumRays=length(transmissionCoefficientsNx1);
TransmittedRaysetOobj.RayPowers=IncidentRaysetOobj.RayPowers.*transmissionCoefficientsNx1;
TransmittedRaysetOobj.RayPositions=IncidentRaysetOobj.RayPositions;
TransmittedRaysetOobj.RayWavelengths=IncidentRaysetOobj.RayWavelengths;
TransmittedRaysetOobj.RayOpticalPathlengths=IncidentRaysetOobj.RayOpticalPathlengths;
TransmittedRaysetOobj.WaveCountMod1=IncidentRaysetOobj.WaveCountMod1;
end