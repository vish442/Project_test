% [transmittedRayDirectionsNx3,transmissionCoefficientsNx1] = Reflection_TIRonly(RaysetOobj,incidentSurfaceNormalsNx3,PendingRefractiveIndicesNx1)

function ReflectedRaysetOobj = Reflection_TIRonly(IncidentRaysetOobj,incidentSurfaceNormalsNx3,PendingRefractiveIndicesNx1)
IncidentDirDottedWithSurfNormNx1=sum(IncidentRaysetOobj.RayDirections.*incidentSurfaceNormalsNx3,2);
TIRindices=(sqrt(1-IncidentDirDottedWithSurfNormNx1.^2).*(IncidentRaysetOobj.RAYnS./PendingRefractiveIndicesNx1))>1;
reflectionCoefficientsNx1=zeros(length(TIRindices),1);
reflectionCoefficientsNx1(TIRindices)=1;

ReflectedRaysetOobj=RaysetO();
ReflectedRaysetOobj.RayDirections=IncidentRaysetOobj.RayDirections-2*(IncidentDirDottedWithSurfNormNx1*[1,1,1]).*incidentSurfaceNormalsNx3;
ReflectedRaysetOobj.NumRays=length(reflectionCoefficientsNx1);
ReflectedRaysetOobj.RAYnS=IncidentRaysetOobj.RAYnS;
ReflectedRaysetOobj.RayPowers=IncidentRaysetOobj.RayPowers.*reflectionCoefficientsNx1;
ReflectedRaysetOobj.RayPositions=IncidentRaysetOobj.RayPositions;
ReflectedRaysetOobj.RayWavelengths=IncidentRaysetOobj.RayWavelengths;
ReflectedRaysetOobj.RayOpticalPathlengths=IncidentRaysetOobj.RayOpticalPathlengths;
ReflectedRaysetOobj.WaveCountMod1=IncidentRaysetOobj.WaveCountMod1;

end 
