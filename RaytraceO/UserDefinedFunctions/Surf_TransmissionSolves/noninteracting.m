%  TransmittedRaysetOobj = noninteractive(IncidentRaysetOobj,~,~)

function TransmittedRaysetOobj = noninteracting(IncidentRaysetOobj,~,~)
TransmittedRaysetOobj=RaysetO();

TransmittedRaysetOobj.RayDirections =   IncidentRaysetOobj.RayDirections;
TransmittedRaysetOobj.RAYnS=            IncidentRaysetOobj.RAYnS;
TransmittedRaysetOobj.NumRays=          IncidentRaysetOobj.NumRays;
TransmittedRaysetOobj.RayPowers=        IncidentRaysetOobj.RayPowers;
TransmittedRaysetOobj.RayPositions=     IncidentRaysetOobj.RayPositions;
TransmittedRaysetOobj.RayWavelengths=   IncidentRaysetOobj.RayWavelengths;
TransmittedRaysetOobj.RayOpticalPathlengths=IncidentRaysetOobj.RayOpticalPathlengths;
TransmittedRaysetOobj.WaveCountMod1=    IncidentRaysetOobj.WaveCountMod1;
end