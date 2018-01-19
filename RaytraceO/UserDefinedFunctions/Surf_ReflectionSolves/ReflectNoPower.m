function ReflectedRaysetOobj = ReflectNoPower(IncidentRaysetOobj,incidentSurfaceNormalsNx3,~)

ReflectedRaysetOobj=RaysetO();

ReflectedRaysetOobj.RAYnS=            IncidentRaysetOobj.RAYnS;
ReflectedRaysetOobj.NumRays=          IncidentRaysetOobj.NumRays;
ReflectedRaysetOobj.RayPositions=     IncidentRaysetOobj.RayPositions;
ReflectedRaysetOobj.RayWavelengths=   IncidentRaysetOobj.RayWavelengths;
ReflectedRaysetOobj.RayOpticalPathlengths=IncidentRaysetOobj.RayOpticalPathlengths;
ReflectedRaysetOobj.WaveCountMod1=    IncidentRaysetOobj.WaveCountMod1;


%remove the power
ReflectedRaysetOobj.RayPowers=0*IncidentRaysetOobj.RayPowers;
%reflect the rays
    %Flip the components of the direction vectors that
    %are parallel to the surface normals
ReflectedRaysetOobj.RayDirections=IncidentRaysetOobj.RayDirections-(2*sum(IncidentRaysetOobj.RayDirections.*incidentSurfaceNormalsNx3,2)*[1,1,1]).*incidentSurfaceNormalsNx3; 


end