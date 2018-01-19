classdef SourceO < handle
    properties
        Name
        Environment
        RayStartingPoints
        StartSpace
        
        %code has not been added for zooming sources, though it isn't very needed, but could be added (refer to the zooming code in SurfaceO for ideas)
        
        PointSourceLocations %this gives the rays their direction when they emerge from the RayStartingPoints
        sourcesBecomeTargets %Boolean T/F - reverses the directions of the rays coming from point sources
        PointSourcePowers
        PointSourceWavelengths
        
        CollimatedSourceCosines %infinietly distant point sources characterized by their ray direction (thus these are vectors pointing in the direction of the rays)
        CollimatedSourcePowers
        CollimatedSourceWavelengths
        
        RaydataForPlot3Display={}; %
        Plot3Displayhandle
        isVisualized=true;
        VisualLength
        enabled=true;
        
    end
    
    methods
        function SrcO = SourceO()
        end
        
        function addPointSourceLocations(SrcO,X,Y,Z)
            if size(X,2)~=1, error('Column vector needed for X'), end 
            if size(Y,2)~=1, error('Column vector needed for Y'), end 
            if size(Z,2)~=1, error('Column vector needed for Z'), end 
            SrcO.PointSourceLocations=[SrcO.PointSourceLocations;[X,Y,Z]];
        end
        function addPointSourcePowers(SrcO,P)
            if size(P,2)~=1, error('Column vector needed for P'), end 
            SrcO.PointSourcePowers=[SrcO.PointSourcePowers;P];
        end
        function addPointSourceWavelengths(SrcO,W)
            if size(W,2)~=1, error('Column vector needed for W'), end 
            SrcO.PointSourceWavelengths=[SrcO.PointSourceWavelengths;W];
        end
        
        function addCollimatedSourceCosines(SrcO,X,Y,Z)
            if size(X,2)~=1, error('Column vector needed for X'), end 
            if size(Y,2)~=1, error('Column vector needed for Y'), end 
            if size(Z,2)~=1, error('Column vector needed for Z'), end 
            SrcO.CollimatedSourceCosines=[SrcO.CollimatedSourceCosines;[X,Y,Z]];
        end
        function addCollimatedSourcePowers(SrcO,P)
            if size(P,2)~=1, error('Column vector needed for P'), end 
            SrcO.CollimatedSourcePowers=[SrcO.CollimatedSourcePowers;P];
        end
        function addCollimatedSourceWavelengths(SrcO,W)
            if size(W,2)~=1, error('Column vector needed for P'), end 
            SrcO.CollimatedSourceWavelengths=[SrcO.CollimatedSourceWavelengths;W];
        end
        
        
        function addRayStartingPoints(SrcO,X,Y,Z)
            if size(X,2)~=1, error('Column vector needed for X'), end 
            if size(Y,2)~=1, error('Column vector needed for Y'), end 
            if size(Z,2)~=1, error('Column vector needed for Z'), end 
            SrcO.RayStartingPoints=[SrcO.RayStartingPoints;[X,Y,Z]];
        end
    
        function clearPointSources(SrcO)
            SrcO.PointSourceLocations=[];
            SrcO.PointSourcePowers=[];
            SrcO.PointSourceWavelengths=[];
        end
        
        function clearCollimatedSources(SrcO)
            SrcO.CollimatedSourceCosines=[];
            SrcO.CollimatedSourcePowers=[];
            SrcO.CollimatedSourceWavelengths=[];
        end
        
        function clearTargets(SrcO)
            SrcO.RayStartingPoints=[];
        end
        
        function visualizeRays(SrcO,axh,varargin) %this displays the rays in the given axes axh.  Varargin holds extra arguments for plot3 visualization arguments and is GIVEN DIRECTLY to the plot3 command within
            if isempty(SrcO.isVisualized) || ~SrcO.isVisualized, return; end %if isVisualized is not defined or is false, then end the visualization without rendering anything
            RaySet=RaysetO(); %make a dummy raysetO object
            thePointSourceOneset=ones(size(SrcO.PointSourceLocations,1),1);
            allPointSourceXpos=thePointSourceOneset*(SrcO.RayStartingPoints(:,1)'); % thus, allPointSourceXpos(:) cycles slowly through starting points, must go through the sources quickly
            allPointSourceYpos=thePointSourceOneset*(SrcO.RayStartingPoints(:,2)');
            allPointSourceZpos=thePointSourceOneset*(SrcO.RayStartingPoints(:,3)');
            
            theCollimatedSourceOneset=ones(size(SrcO.CollimatedSourceCosines,1),1);
            allCollimatedSourceXpos=theCollimatedSourceOneset*(SrcO.RayStartingPoints(:,1)');
            allCollimatedSourceYpos=theCollimatedSourceOneset*(SrcO.RayStartingPoints(:,2)');
            allCollimatedSourceZpos=theCollimatedSourceOneset*(SrcO.RayStartingPoints(:,3)');
            
            directionsflipped=1;
            if SrcO.sourcesBecomeTargets, directionsflipped=-1; end
            
            RaySet.RayPositions=[[allPointSourceXpos(:),allPointSourceYpos(:),allPointSourceZpos(:)] ; [allCollimatedSourceXpos(:),allCollimatedSourceYpos(:),allCollimatedSourceZpos(:)]];
            VectorsFromPOINTSourcesToStartPts= directionsflipped*(RaySet.RayPositions(1:(size(SrcO.PointSourceLocations,1)*size(SrcO.RayStartingPoints,1)),1:size(SrcO.PointSourceLocations,2))-repmat(SrcO.PointSourceLocations,size(SrcO.RayStartingPoints,1),1));
            RaySet.RayDirections=[VectorsFromPOINTSourcesToStartPts; repmat(SrcO.CollimatedSourceCosines,size(SrcO.RayStartingPoints,1),1)];
            removethese=normalizeRayDirectionVectors(RaySet);
            if ~isempty(removethese)
                removeRays(RaySet,removethese);
            end
            
            if isempty(SrcO.VisualLength)
                VisL=inf;
                while ~isfinite(VisL)
                    ansout=inputdlg('How long would you like the visualized source rays to be?');
                    VisL=str2double(ansout{1});
                end
                SrcO.VisualLength=VisL;
            end
            SrcO.RaydataForPlot3Display={[RaySet.RayPositions(:,1)';(RaySet.RayPositions(:,1)+RaySet.RayDirections(:,1)*SrcO.VisualLength)'],[RaySet.RayPositions(:,2)';(RaySet.RayPositions(:,2)+RaySet.RayDirections(:,2)*SrcO.VisualLength)'],[RaySet.RayPositions(:,3)';(RaySet.RayPositions(:,3)+RaySet.RayDirections(:,3)*SrcO.VisualLength)']};
            delete(SrcO.Plot3Displayhandle);
            if isempty(varargin)
                SrcO.Plot3Displayhandle=plot3(axh,SrcO.RaydataForPlot3Display{:});
            else
                SrcO.Plot3Displayhandle=plot3(axh,SrcO.RaydataForPlot3Display{:},varargin{:});
            end
        end
        
        function makeRaysetAndGiveToSpace(SrcO)
%             disp(['The source is making rays and giving them to ',SrcO.StartSpace.Name])
            %this makes a rayset
            %The point sources are first in the rayset list
            %followed by the collimated sources
            %Rayset is organized by cycling repeatedly through the sources,
            %first the point sources followed by the collimated sources
            if ~all([size(SrcO.PointSourceLocations,1)==size(SrcO.PointSourcePowers,1),size(SrcO.PointSourcePowers,1)==size(SrcO.PointSourceWavelengths,1)]), error('Size mismatch in point sources arrays'); end
            if ~all([size(SrcO.CollimatedSourceCosines,1)==size(SrcO.CollimatedSourcePowers,1),size(SrcO.CollimatedSourcePowers,1)==size(SrcO.CollimatedSourceWavelengths,1)]), error('Size mismatch in collimated sources arrays'); end
            RaySet=RaysetO();
            RaySet.NumRays= size(SrcO.PointSourceLocations,1)*size(SrcO.RayStartingPoints,1) + size(SrcO.CollimatedSourceCosines,1)*size(SrcO.RayStartingPoints,1);
            
            RaySet.RayPowers=[repmat(SrcO.PointSourcePowers,size(SrcO.RayStartingPoints,1),1);repmat(SrcO.CollimatedSourcePowers,size(SrcO.RayStartingPoints,1),1)];
            RaySet.RayWavelengths=[repmat(SrcO.PointSourceWavelengths,size(SrcO.RayStartingPoints,1),1);repmat(SrcO.CollimatedSourceWavelengths,size(SrcO.RayStartingPoints,1),1)];
            
            %to make the ray positions, it's tricky since the positions are
            %at the targets while the natural index cycling goes through
            %the sources.  We therefore have to use a bit of special matrix
            %multiplications and matrix concatenation
            thePointSourceOneset=ones(size(SrcO.PointSourceLocations,1),1);
            allPointSourceXpos=thePointSourceOneset*(SrcO.RayStartingPoints(:,1)'); % thus, allPointSourceXpos(:) cycles slowly through starting points, must go through the sources quickly
            allPointSourceYpos=thePointSourceOneset*(SrcO.RayStartingPoints(:,2)');
            allPointSourceZpos=thePointSourceOneset*(SrcO.RayStartingPoints(:,3)');
            
            theCollimatedSourceOneset=ones(size(SrcO.CollimatedSourceCosines,1),1);
            allCollimatedSourceXpos=theCollimatedSourceOneset*(SrcO.RayStartingPoints(:,1)');
            allCollimatedSourceYpos=theCollimatedSourceOneset*(SrcO.RayStartingPoints(:,2)');
            allCollimatedSourceZpos=theCollimatedSourceOneset*(SrcO.RayStartingPoints(:,3)');
            
            RaySet.RayPositions=[[allPointSourceXpos(:),allPointSourceYpos(:),allPointSourceZpos(:)] ; [allCollimatedSourceXpos(:),allCollimatedSourceYpos(:),allCollimatedSourceZpos(:)]];
            
            
            
            %put in the directions from point sources (using differences)
            %followed by the collimated sources
            directionsflipped=1;
            if SrcO.sourcesBecomeTargets, directionsflipped=-1; end
            
            VectorsFromPOINTSourcesToStartPts=directionsflipped*(RaySet.RayPositions(1:(size(SrcO.PointSourceLocations,1)*size(SrcO.RayStartingPoints,1)),1:size(SrcO.PointSourceLocations,2))-repmat(SrcO.PointSourceLocations,size(SrcO.RayStartingPoints,1),1));
            RaySet.RayDirections=[VectorsFromPOINTSourcesToStartPts; repmat(SrcO.CollimatedSourceCosines,size(SrcO.RayStartingPoints,1),1)];
            removethese=normalizeRayDirectionVectors(RaySet);
            if ~all([size(RaySet.RayPositions,1)==size(RaySet.RayDirections,1),size(RaySet.RayDirections,1)==RaySet.NumRays]), error('You have a mismatch between the number of rays generated and the number of rays expected'); end
            %now remove rays that had source points occupying the same
            %space as starting points (this would ruin directionality)
            if ~isempty(removethese)
                warning('Source rays removed due to being too close to starting positions');
                removeRays(RaySet,removethese);
                removethese(removethese>size(VectorsFromPOINTSourcesToStartPts,2))=[]; %We are reducing the index span of removethese, which is a set of indices, not a logical array.  We want to reduce VectorsFromPOINTSourcesToStartPts too using removethese, but it's a shorter vector so we are reducing the size of removethese accordingly.
                VectorsFromPOINTSourcesToStartPts(removethese)=[];
            end
            
            RaySet.RAYnS=FindIndicesForRayset(SrcO.StartSpace,RaySet);
            
            %Get the optical path lengths correct.  These make it so that
            %rays start with the correct RELATIVE phases.
            RaySet.WaveCountMod1=zeros(RaySet.NumRays,1);
            RaySet.RayOpticalPathlengths=zeros(RaySet.NumRays,1);
            %--------
            %FOR POINT SOURCES  - (distance from pt source to start pos)*refractiveindex/wavelength 
            pntvecindx=(1:size(VectorsFromPOINTSourcesToStartPts,1))';
            RaySet.RayOpticalPathlengths(pntvecindx)=sqrt(sum(VectorsFromPOINTSourcesToStartPts.^2,2)).*RaySet.RAYnS(pntvecindx);
            %Perform this and the next line for hopefully greater precision (taking off the whole number count from OPD first)
            RaySet.WaveCountMod1(pntvecindx)=mod((RaySet.RayOpticalPathlengths(pntvecindx)-min(RaySet.RayOpticalPathlengths(pntvecindx)))./RaySet.RayWavelengths(pntvecindx),1);
            
            %FOR COLLIMATED SOURCES
            collvecindx=(length(pntvecindx)+1):RaySet.NumRays; %indices in the rayset for the collimated sources
            if size(collvecindx,2)~=(size(SrcO.CollimatedSourceCosines,1)*size(SrcO.RayStartingPoints,1)), disp(size(collvecindx,1)); disp((size(SrcO.CollimatedSourceCosines,1)*size(SrcO.RayStartingPoints,1))); error('Unexpected size mismatch in your code'); end
            RaySet.RayOpticalPathlengths(collvecindx)=sum(RaySet.RayPositions(collvecindx,:).*RaySet.RayDirections(collvecindx,:),2).*RaySet.RAYnS(collvecindx);
            %Perform this and the next line for hopefully greater precision (taking off the whole number count from OPD first)
            RaySet.WaveCountMod1(collvecindx)=mod((RaySet.RayOpticalPathlengths(collvecindx)-min(RaySet.RayOpticalPathlengths(collvecindx)))./RaySet.RayWavelengths(collvecindx),1);
            %--------
            addRaysToSpace(SrcO.StartSpace,RaySet);
            SrcO.StartSpace.Environment.PowerFromSources=SrcO.StartSpace.Environment.PowerFromSources+sum(RaySet.RayPowers);
        end
        
        
        function SrcOdupl=duplicate(SrcO) %this function is unused
            SrcOdupl=SourceO();
            SrcOdupl.Name=                          SrcO.Name;
            SrcOdupl.RayStartingPoints=             SrcO.RayStartingPoints;
            SrcOdupl.PointSourceLocations=         	SrcO.PointSourceLocations;
            SrcOdupl.sourcesBecomeTargets=          SrcO.sourcesBecomeTargets;
            SrcOdupl.PointSourcePowers=            	SrcO.PointSourcePowers;
            SrcOdupl.PointSourceWavelengths=       	SrcO.PointSourceWavelengths;
            SrcOdupl.CollimatedSourceCosines=      	SrcO.CollimatedSourceCosines;
            SrcOdupl.CollimatedSourcePowers=      	SrcO.CollimatedSourcePowers;
            SrcOdupl.CollimatedSourceWavelengths= 	SrcO.CollimatedSourceWavelengths;
            SrcOdupl.RaydataForPlot3Display=        SrcO.RaydataForPlot3Display;
            SrcOdupl.VisualLength=                  SrcO.VisualLength;
            SrcOdupl.enabled=                       SrcO.enabled;
        end
    end
    
    events
        launched
    end
end