classdef DetectorO < SurfaceO
    properties
%         Name
%         Environment %the environment to which this detector belongs
%         IncidentRayset
%         DetectedPower=0
%         
%         %code has not been added for zooming sources, but could be added (refer to the zooming code in SurfaceO for ideas) (
% 
%         IntersectSolveFcn %input rayset and output intersect positions
%         NormalSolveFcn %input intersect positions and output normal vectors the the detector surface at those intersect positions
        
        DetectRaysFcn %Inputs are (IncidentRaysetOobj, DetectorSurfaceNormalsForRayset) and outputs are: [DetectedPositionsNx3, DetectedPowersNx1].  The rows of the output arrays correspond to each other
        DetectedPositions=[];
        DetectedPowers=[];
        
        detectsPhase=false;
        PhasePositions=[];
        DetectedOpticalPathlengths=[];
        DetectedWaveCountMod1=[];
        
        Figh
        Axh
        InitialVisualizationGain=100;
        
        
    end
    
    methods
        function DetO=DetectorO()
        end
        
        %This function collects only rays that are currently on the surface of the detector.
        %It is called from within SurfaceO within the function interactRays
        function detectRays(DetO,RaysetOobj,DetectorSurfaceNormalsForRayset) %adds data to DetectedPositions and DetectedPowers
            [posnsNx3,pwrsNx1]=DetO.DetectRaysFcn(RaysetOobj,DetectorSurfaceNormalsForRayset);
            DetO.DetectedPositions=[DetO.DetectedPositions;posnsNx3];
            DetO.DetectedPowers=[DetO.DetectedPowers;pwrsNx1];
            if DetO.detectsPhase
                DetO.PhasePositions=[DetO.PhasePositions;RaysetOobj.RayPositions];
                DetO.DetectedOpticalPathlengths=[DetO.DetectedOpticalPathlengths;RaysetOobj.RayOpticalPathlengths];
                DetO.DetectedWaveCountMod1=[DetO.DetectedWaveCountMod1;RaysetOobj.WaveCountMod1];
            end
        end
        
        %this function is called from the environment
        function gatherDetectedRaysForDisplay(DetO) %creates a scatter3 plot from DetectedPositions and DetectedPowers, adds it to the DetObj.Axh, then clears DetectedPositions and DetectedPowers
            detRaysSorted=sortrows([DetO.DetectedPositions,DetO.DetectedPowers],[1,2,3]);
            hasSamePositionAsrowafter=all(diff(detRaysSorted(:,1:3))==0,2);
            counter=2;
            
            %combine powers from rays that landed on the same detector
            %element
            while counter<=length(DetO.DetectedPowers)
                if hasSamePositionAsrowafter(counter-1)
                    detRaysSorted(counter,4)=detRaysSorted(counter,4)+detRaysSorted(counter-1,4);
                end
                counter=counter+1;
            end
            detRaysSorted=detRaysSorted(hasSamePositionAsrowafter==0,:);
            %Select the axes and make the scatter3 plot
            axes(DetO.Axh);
            s3=scatter3(detRaysSorted(1,:),detRaysSorted(2,:),detRaysSorted(3,:),DetO.InitialVisualizationGain*detRaysSorted(4,:));
            s3.MarkerEdgeColor=DetO.Environment.CurrentZoomColor;
            %Clear the Positions and Powers on the detector
            DetO.DetectedPositions=[];
            DetO.DetectedPowers=[];
        end
        
        %this function is called at the user's desire, usually from within
        %the gui for the RaytraceO
        function toggleDetectorDisplay(DetO) %simply enables the window to be seen that shows the detector points and corresponding powers detected
            states={'on','off'};
            DetO.FigH.Visible=states(srtcmpi(DetO.FigH.Visible,'on')+1);
        end
        
        
        function copyDetectorPropertiesfromSecondToFirst(CopyToDetO,DetO)
            CopyToDetO.DetectRaysFcn=            DetO.DetectRaysFcn;
            CopyToDetO.DetectedPositions=        DetO.DetectedPositions;
            CopyToDetO.DetectedPowers=           DetO.DetectedPowers;
            CopyToDetO.detectsPhase=             DetO.detectsPhase;
            CopyToDetO.PhasePositions=           DetO.PhasePositions;
            CopyToDetO.DetectedOpticalPathlengths=DetO.DetectedOpticalPathlengths;
            CopyToDetO.DetectedWaveCountMod1=    DetO.DetectedWaveCountMod1;
            CopyToDetO.InitialVisualizationGain= DetO.InitialVisualizationGain;
        end
        
    end
    
    events
        saturated
    end
end