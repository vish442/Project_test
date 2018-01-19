function BackscatteredRaysetO = RBS2(ReflectedRaysO,Normalvecs,ScatterRingRadius,EnvZoom3Value,EnvZoom4Value,EnvZoom5Value,EnvZoom9Value)
%We assume that only one ray is input, so size(ReflectedRaysO) returns [1,3]

%Make two grids, one around the intersect point, and one around the iris of the eye 
%You need the normal vector at the intersect point so that you can line up the circle grid correctly 
%We need the iris centerpoint, the iris normal vec, and the iris diameter
%Ways to get those

%We will start by assuming that size(ReflectedRaysO) returns [1,3]


%Let's start with the ring of sources, the ScatterRing
%the actual center point of the ScatterRing is above the retinal surface by
%this amount:
shiftamount=16.5-sqrt(16.5^2-ScatterRingRadius^2)+.001; %we add the .001 to make the ring slightly above the retina surface for non-reintersecting purposes

%let's make sure that NormalVecs points into the eye (from the retina surface) - we'll assume that
%the eye is pointed pretty much in the +y direction, so if Normalvecs has a
%negative y value, it should probably be flipped
Normalvecs=sign(Normalvecs(2))*Normalvecs;
%and normalize normalvecs
Normalvecs=Normalvecs/norm(Normalvecs);
ScatterRingCenterPoint=shiftamount*Normalvecs+ReflectedRaysO.RayPositions;
%here are the source points
ScatterRingPts=makeringpts(ScatterRingCenterPoint,Normalvecs,ScatterRingRadius);

%now let's get the starting position points - these should be over by the
%posterior lens surface
angle=(EnvZoom3Value-.5)*.7;
shiftX=(EnvZoom4Value-.5)*20;
shiftY=(EnvZoom5Value-.5)*60;
shiftX9=(EnvZoom9Value-.5)*30;

STRTcenterpoint=[3.77*sin(angle)+shiftX+shiftX9,-258.52-3.77*cos(angle)+shiftY,0]; %we used 3.77 instead of 3.767 to put the grid a little behind the posterior lens
STRTnormalvec=[sin(angle),-cos(angle),0];

backscatteringstartpoints=makeROXstrtgrid(STRTcenterpoint,STRTnormalvec);

%make a source to use copied code from SourceO.m to make the backscattered rayset we want
NPS=size(ScatterRingPts,1);
ROXeyeSource=SourceO();
ROXeyeSource.PointSourcePowers=ones(NPS,1);
ROXeyeSource.PointSourceLocations=ScatterRingPts;
ROXeyeSource.RayStartingPoints=backscatteringstartpoints;
ROXeyeSource.PointSourceWavelengths=ones(NPS,1)*ReflectedRaysO.RayWavelengths;


BackscatteredRaysetO=makeRoxBRraysetO(ROXeyeSource,ReflectedRaysO.RAYnS); %assumes ReflectedRaysO.RAYnS is only a single value

end



    function ScatterRingPts=makeringpts(centerpoint,surfacenormal,radius)
            RingCount=4;
            thetarray=0:2*pi/RingCount:(2*pi-2*pi/RingCount);

            surfacenormal=surfacenormal/sqrt(sum(surfacenormal.^2));
            horzvec=cross(surfacenormal,[0 0 1]);
            horzveclength=sqrt(sum(horzvec.^2));
            if horzveclength>1e-9
                horzvec=horzvec/horzveclength;
            else
                horzvec=[1,0,0];
            end
            Vvec=cross(horzvec,surfacenormal); Vvec=Vvec/sqrt(sum(Vvec.^2));

            allpts=ones(length(thetarray),1)*centerpoint + radius*cos(thetarray)'*horzvec + radius*sin(thetarray)'*Vvec;
            Xcol=allpts(:,1);
            Ycol=allpts(:,2);
            Zcol=allpts(:,3);
            ScatterRingPts=[Xcol,Ycol,Zcol];

    end
    
    
    
    
    
    function backscatteringstartpoints=makeROXstrtgrid(centerpoint,surfacenormal)
    
        Aspacing=.5;
        Bspacing=.5;
        SemiAcount=7;
        SemiBcount=7;
        
        surfacenormal=surfacenormal/sqrt(sum(surfacenormal.^2));
        horzvec=cross(surfacenormal,[0 0 1]);
        horzveclength=sqrt(sum(horzvec.^2));
        if horzveclength>1e-9
            horzvec=horzvec/horzveclength;
        else
            horzvec=[1,0,0];
        end
        Vvec=cross(horzvec,surfacenormal); Vvec=Vvec/sqrt(sum(Vvec.^2));

        gspine=ones(2*SemiAcount+1,1)*centerpoint+Aspacing*((-SemiAcount:SemiAcount)')*Vvec; %A is spaced along the Vvec direction 
        Xv=gspine(:,1)*ones(1,2*SemiBcount+1);%h and v stand for horizontal and vertical.  Horizontal should only have XY directionality
        Yv=gspine(:,2)*ones(1,2*SemiBcount+1);
        Zv=gspine(:,3)*ones(1,2*SemiBcount+1);

        crossbar=(horzvec')*Bspacing*(-SemiBcount:SemiBcount); %B is spaced along the horzvec direction
        Xh=ones(2*SemiAcount+1,1)*crossbar(1,:);
        Yh=ones(2*SemiAcount+1,1)*crossbar(2,:);
        Zh=ones(2*SemiAcount+1,1)*crossbar(3,:);

        X=Xv+Xh;
        Y=Yv+Yh;
        Z=Zv+Zh;
        
        Xcol=X(:);
        Ycol=Y(:);
        Zcol=Z(:);
        
        
            %Make the grid circular by shaving off the corners
            %keep only those in the ellipse
            %x^2/A^2+y^2/B^2<=1
            dotPtsVvec=sum([Xcol-centerpoint(1),Ycol-centerpoint(2),Zcol-centerpoint(3)].*(ones((2*SemiAcount+1)*(2*SemiBcount+1),1)*Vvec),2);
            dotPtsHorzvec=sum([Xcol-centerpoint(1),Ycol-centerpoint(2),Zcol-centerpoint(3)].*(ones((2*SemiAcount+1)*(2*SemiBcount+1),1)*horzvec),2);
            removethese=dotPtsVvec.^2/(SemiAcount*Aspacing)^2+dotPtsHorzvec.^2/(SemiBcount*Bspacing)^2>1;
            Xcol(removethese)=[];
            Ycol(removethese)=[];
            Zcol(removethese)=[];
        
        backscatteringstartpoints=[Xcol,Ycol,Zcol];

    end
    
    
    
    
    
    
    
    function RaySet=makeRoxBRraysetO(SrcO,startspaceUniformindex)
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
            VectorsFromPOINTSourcesToStartPts=RaySet.RayPositions(1:(size(SrcO.PointSourceLocations,1)*size(SrcO.RayStartingPoints,1)),1:size(SrcO.PointSourceLocations,2))-repmat(SrcO.PointSourceLocations,size(SrcO.RayStartingPoints,1),1);
            
%             a=findobj('Type','Surf');
%             plot3(a(1).Parent,[(RaySet.RayPositions(:,1))'; (RaySet.RayPositions(:,1)-VectorsFromPOINTSourcesToStartPts(:,1))'],[(RaySet.RayPositions(:,2))'; (RaySet.RayPositions(:,2)-VectorsFromPOINTSourcesToStartPts(:,2))'],[(RaySet.RayPositions(:,3))'; (RaySet.RayPositions(:,3)-VectorsFromPOINTSourcesToStartPts(:,3))'],'Tag','SpaceTrace')
            
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
            
            %Get the optical path lengths correct.  These make it so that
            %rays start with the correct RELATIVE phases.
            RaySet.WaveCountMod1=zeros(RaySet.NumRays,1);
            RaySet.RayOpticalPathlengths=zeros(RaySet.NumRays,1);
            %--------
            %FOR POINT SOURCES  - (distance from pt source to start pos)*refractiveindex/wavelength 
            pntvecindx=(1:size(VectorsFromPOINTSourcesToStartPts,1))';
            RaySet.RAYnS=startspaceUniformindex*ones(RaySet.NumRays,1);
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
    end