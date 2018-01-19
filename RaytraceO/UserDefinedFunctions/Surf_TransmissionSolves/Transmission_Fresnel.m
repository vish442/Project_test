

function TransmittedRaysetOobj = Transmission_Fresnel(IncidentRaysetOobj,incidentSurfaceNormalsNx3,PendingRefractiveIndicesNx1)
ni=IncidentRaysetOobj.RAYnS;
nt=PendingRefractiveIndicesNx1;
IdotN=sum(IncidentRaysetOobj.RayDirections.*incidentSurfaceNormalsNx3,2)*[1,1,1];
CosThetai=abs(IdotN(:,1));
SinThetai=sqrt(1-CosThetai.^2);
CosThetat=sqrt(1-(ni./nt.*SinThetai).^2);
%ni, nt, CosThetai, SinThetai, CosThetat all have dimension Nx1
Rs=abs((ni.*CosThetai-nt.*CosThetat)./(ni.*CosThetai+nt.*CosThetat)).^2;
Rp=abs((ni.*CosThetat-nt.*CosThetai)./(ni.*CosThetat+nt.*CosThetai)).^2;
transmissionCoefficientsNx1=1-(Rs/2+Rp/2);

%the following lines could be made slightly more efficient in terms of data
%computing demand:
RefrPerpToSurfNormNx3=((ni./nt)*[1,1,1]).*(IncidentRaysetOobj.RayDirections-IdotN.*incidentSurfaceNormalsNx3);

TransmittedRaysetOobj=RaysetO();
TransmittedRaysetOobj.RayDirections=RefrPerpToSurfNormNx3 + (sqrt(1-sum(RefrPerpToSurfNormNx3.^2,2))*[1,1,1]).*incidentSurfaceNormalsNx3.*sign(IdotN);
TransmittedRaysetOobj.NumRays=length(transmissionCoefficientsNx1);
TransmittedRaysetOobj.RAYnS=PendingRefractiveIndicesNx1; 
TransmittedRaysetOobj.RayPowers=IncidentRaysetOobj.RayPowers.*transmissionCoefficientsNx1;
TransmittedRaysetOobj.RayPositions=IncidentRaysetOobj.RayPositions;
TransmittedRaysetOobj.RayWavelengths=IncidentRaysetOobj.RayWavelengths;
TransmittedRaysetOobj.RayOpticalPathlengths=IncidentRaysetOobj.RayOpticalPathlengths;
TransmittedRaysetOobj.WaveCountMod1=IncidentRaysetOobj.WaveCountMod1;

end

        