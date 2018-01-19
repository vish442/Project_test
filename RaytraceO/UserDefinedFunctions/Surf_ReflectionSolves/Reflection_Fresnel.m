

function ReflectedRaysetOobj = Reflection_Fresnel(IncidentRaysetOobj,incidentSurfaceNormalsNx3,PendingRefractiveIndicesNx1)
ni=IncidentRaysetOobj.RAYnS;
nt=PendingRefractiveIndicesNx1;
IdotN=sum(IncidentRaysetOobj.RayDirections.*incidentSurfaceNormalsNx3,2);
CosThetai=abs(IdotN);
SinThetai=sqrt(1-CosThetai.^2);
CosThetat=sqrt(1-(ni./nt.*SinThetai).^2);
%ni, nt, CosThetai, SinThetai, CosThetat all have dimension Nx1

Rs=abs((ni.*CosThetai-nt.*CosThetat)./(ni.*CosThetai+nt.*CosThetat)).^2;
Rp=abs((ni.*CosThetat-nt.*CosThetai)./(ni.*CosThetat+nt.*CosThetai)).^2;
reflectionCoefficientsNx1=Rs/2+Rp/2; %the average reflection between the two

ReflectedRaysetOobj=RaysetO();
ReflectedRaysetOobj.RayDirections=IncidentRaysetOobj.RayDirections-2*(IdotN*[1,1,1]).*incidentSurfaceNormalsNx3;
ReflectedRaysetOobj.NumRays=length(reflectionCoefficientsNx1);  
ReflectedRaysetOobj.RAYnS=IncidentRaysetOobj.RAYnS;  
ReflectedRaysetOobj.RayPowers=IncidentRaysetOobj.RayPowers.*reflectionCoefficientsNx1;
ReflectedRaysetOobj.RayPositions=IncidentRaysetOobj.RayPositions;
ReflectedRaysetOobj.RayWavelengths=IncidentRaysetOobj.RayWavelengths;
ReflectedRaysetOobj.RayOpticalPathlengths=IncidentRaysetOobj.RayOpticalPathlengths;
ReflectedRaysetOobj.WaveCountMod1=IncidentRaysetOobj.WaveCountMod1;

end
