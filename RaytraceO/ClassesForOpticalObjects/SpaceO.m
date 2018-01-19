classdef SpaceO < handle
    properties
        Name
        Environment %the environment to which this space belongs
        Surfaces % a cell array containing both surfaces and detectors
        VolumeAbsorbedPower=0;
        SpcRayset
        FromWhichSurfaces %keeps track of the surface index from which rays were added to the space
        RefractiveIndxFcn %input RaysetO object, output refractive indices column vector
        hasRays=false;
        %VolumeScattering - To come later - not needed for my initial
        %models - same approach of user function input will be used and
        %more code is needed in the propagateRayset function to use it.
        %VolumeAbsorption - ditto to just above
        
        
    end
    
    methods
        function SpcO = SpaceO()
            SpcO.SpcRayset=RaysetO();
        end
        
        %this function does the math and ray passing, but only does the
        %drawing if an axes is specified to draw to
        function propagateRayset(SpcO,varargin) %2nd argument - optional - an axes handle.  3rd argument - optional - a color specification that can be recognized by the built-in function plot3
            
            if SpcO.hasRays
%                 disp([SpcO.Name,' is propagating rays with rayset size of ',num2str(SpcO.SpcRayset.NumRays)])
%                 disp(['A ray in ',SpcO.Name,' is starting  at a distance ',num2str(norm(SpcO.SpcRayset.RayPositions(1,:)-[1,1,1])),' from [1,1,1]'])
                if SpcO.SpcRayset.NumRays==0, error('The space.hasrays=1 while while the rayset.numrays=0'); end
                
                AllSurfaceIntersects=inf(SpcO.SpcRayset.NumRays,3,length(SpcO.Surfaces));
                AllIntersectDistances=inf(SpcO.SpcRayset.NumRays,length(SpcO.Surfaces));
                for n=1:length(SpcO.Surfaces)%go through the surfaces
                    AllSurfaceIntersects(:,:,n)=SpcO.Surfaces{n}.IntersectSolveFcn(SpcO.SpcRayset.RayPositions, SpcO.SpcRayset.RayDirections, @(ptset)applyWindowsToPointset(SpcO.Surfaces{n},ptset));
                    AllIntersectDistances(:,n)=sqrt(sum((AllSurfaceIntersects(:,:,n)-SpcO.SpcRayset.RayPositions).^2,2));
                end
%                 if max(SpcO.FromWhichSurfaces)==4 && sum(SpcO.FromWhichSurfaces==4)>5
%                     a=1; %and put a breakpoint here
%                 end
                %sort the distances
                [SD,SurfsInOrder]=sort(AllIntersectDistances,2);
                %for later use, expand SD and SurfsInOrder
                expandby=(3-size(SD,2));
                if expandby>0, SD=[SD,inf(size(SD,1),expandby)]; SurfsInOrder=[SurfsInOrder,inf(size(SD,1),expandby)]; end
                
                %Check for rays that re-intersect the point they are trying to leave from 
                        %(this happens because rays will start slightly on the wrong side of a surface due to numerical rounding error) 
                Reintersected=all([ SD(:,1)<SpcO.Environment.MinDistanceForReintersect,  SurfsInOrder(:,1)==SpcO.FromWhichSurfaces   ],2);
                
                if any(Reintersected)
                    %Advance the rays beyond their intersect point
                    SpcO.SpcRayset.RayDirections(Reintersected,:)=SpcO.SpcRayset.RayDirections(Reintersected,:)./(sqrt(sum(SpcO.SpcRayset.RayDirections(Reintersected,:).^2,2))*ones(1,3)); %make sure the ray directions are normalized
                    TranslateRayPositionsByThisMuch=1/2*SpcO.Environment.MinDistanceForReintersect;% 2*SD(Reintersected,1)*ones(1,3); %arbitrarily chose a factor of 2 for multiplying the reintersect distance by - it is intended to shift the ray past the reintersect point 
                    SpcO.SpcRayset.RayPositions(Reintersected,:)=SpcO.SpcRayset.RayPositions(Reintersected,:)+TranslateRayPositionsByThisMuch*SpcO.SpcRayset.RayDirections(Reintersected,:);
                    %initialize new distances
                    NewDistances=inf(sum(Reintersected),1);
                    %go through the surfaces again and collect the real intersects that the rays would have hit on the surfaces they started on (it is possible that they hit the surface they started on, but at a different location) 
                    for n=1:length(SpcO.Surfaces)
                        TheseRays=Reintersected;
                        ofsmallersize=SurfsInOrder(Reintersected,1)==n; %the rays to retrace on a logic index of size=[sum(Reintersected,1),1]
                        TheseRays(TheseRays)=ofsmallersize; %the rays to retrace on a logic index of size=[length(Reintersected),1]
                        AllSurfaceIntersects(TheseRays,:,n)=SpcO.Surfaces{n}.IntersectSolveFcn(SpcO.SpcRayset.RayPositions(TheseRays,:), SpcO.SpcRayset.RayDirections(TheseRays,:), @(ptset)applyWindowsToPointset(SpcO.Surfaces{n},ptset));
                        NewDistances(ofsmallersize,:)=sqrt(sum((AllSurfaceIntersects(TheseRays,:,n)-SpcO.SpcRayset.RayPositions(TheseRays,:)).^2,2));
                    end
                
                    newcloserthan2nd=NewDistances<SD(Reintersected,2);
                    newcloserthan3rd=NewDistances<SD(Reintersected,3);
                    TheseRays=Reintersected;%restart TheseRays 
                    TheseRays(TheseRays)=newcloserthan2nd;
                        SD(TheseRays,1)=NewDistances(newcloserthan2nd); %and SurfsInOrder still has the correct surface numbers in place
                    TheseRays=Reintersected;%restart TheseRays 
                    cameinthird=all([newcloserthan3rd,~newcloserthan2nd],2);
                    TheseRays(TheseRays)=cameinthird;
                        SD(TheseRays,3)=NewDistances(cameinthird);
                        SD(TheseRays,:)=circshift(SD(TheseRays,:),[0,-1]);
                        SurfsInOrder(TheseRays,3)=SurfsInOrder(TheseRays,1);
                        SurfsInOrder(TheseRays,:)=circshift(SurfsInOrder(TheseRays,:),[0,-1]);
                    TheseRays=Reintersected;%restart TheseRays 
                    not2ndor3rd=all([~newcloserthan3rd,~newcloserthan2nd],2);
                    TheseRays(TheseRays)=not2ndor3rd;
                        SD(TheseRays,:)=circshift(SD(TheseRays,:),[0,-1]); %just move the rays down this time
                        SurfsInOrder(TheseRays,:)=circshift(SurfsInOrder(TheseRays,:),[0,-1]); %do the same for the ray to surface order tracker
                end
                %Now, having updated for all rays that needed to be re-intersected, 
                %we check for ray removal - didn't hit anything
                NonIntersecting=~isfinite(SD(:,1));
                if any(NonIntersecting)
                    SD(NonIntersecting,:)=[];
                    SurfsInOrder(NonIntersecting,:)=[];
                    AllSurfaceIntersects(NonIntersecting,:,:)=[];
                    accountNonIntersectingRays(SpcO.Environment,SpcO.SpcRayset,NonIntersecting);
                    removeRays(SpcO.SpcRayset,NonIntersecting);
                end
                %continuing ray removal - didn't travel far enough
                InsufficientTravel=SD(:,1)<SpcO.Environment.MinDistanceForReintersect;
                if any(InsufficientTravel)
                    disp([num2str(sum(InsufficientTravel)),' rays have been removed in ',SpcO.Name,' for not traveling far enough before intersecting the next surface.']);
                    %remove them
                    SD(InsufficientTravel,:)=[];
                    SurfsInOrder(InsufficientTravel,:)=[];
                    AllSurfaceIntersects(InsufficientTravel,:,:)=[];
                    accountNonIntersectingRays(SpcO.Environment,SpcO.SpcRayset,InsufficientTravel);
                    removeRays(SpcO.SpcRayset,InsufficientTravel);
                end
                %continuing ray removal - Edgy rays
                EdgyRays=(SD(:,2)-SD(:,1))<SpcO.Environment.MinDistanceForNonEdgyIntersect;
                if any(EdgyRays)
                    disp([num2str(sum(EdgyRays)),' rays removed after encountering 2 very close surfaces while propagating through space ',SpcO.Name])
                    removeTheseEdgyRays(SpcO.Environment,SpcO.SpcRayset,EdgyRays);
                    SD(EdgyRays,:)=[];
                    SurfsInOrder(EdgyRays,:)=[];
                    AllSurfaceIntersects(EdgyRays,:,:)=[];
                end
                %end of ray removal
                
                %do a check
                if size(AllSurfaceIntersects,1)~=SpcO.SpcRayset.NumRays, error('Somehow you haven''t removed equal numbers of rays during ray removal in SpaceO - check your programming'); end
                
                if SpcO.SpcRayset.NumRays>0 %do the visualizing, updating of positions, giving to surfaces etc, given that there are rays still continuing on
                    %where are the current positions?
                    priorpositionsNx3=SpcO.SpcRayset.RayPositions;
                    %where are the next positions?
                    newpositionsNx3=zeros(SpcO.SpcRayset.NumRays,3);
                    for n=1:SpcO.SpcRayset.NumRays
                        newpositionsNx3(n,:)=AllSurfaceIntersects(n,:,SurfsInOrder(n,1));%... but only the ones for SurfsInOrder(:,1)
                    end

                    %VISUALIZE THE RAYS THROUGH THE SPACE
                    if ~isempty(varargin)
                        if length(varargin)>1
                            plot3(varargin{1},[priorpositionsNx3(:,1),newpositionsNx3(:,1)]',[priorpositionsNx3(:,2),newpositionsNx3(:,2)]',[priorpositionsNx3(:,3),newpositionsNx3(:,3)]','Color',varargin{2},'Tag','SpaceTrace');
                        else
                            plot3(varargin{1},[priorpositionsNx3(:,1),newpositionsNx3(:,1)]',[priorpositionsNx3(:,2),newpositionsNx3(:,2)]',[priorpositionsNx3(:,3),newpositionsNx3(:,3)]','Tag','SpaceTrace');
                        end
                    end

                    %now update the rays, positions, OPD, etc
                    SpcO.SpcRayset.RayPositions=newpositionsNx3;%update the new positions in the rayset
                    additionalOPD=SD(:,1).*SpcO.SpcRayset.RAYnS; %find how much OPD was traveled in this space
                    SpcO.SpcRayset.WaveCountMod1=mod(SpcO.SpcRayset.WaveCountMod1+additionalOPD./SpcO.SpcRayset.RayWavelengths,1);
                    SpcO.SpcRayset.RayOpticalPathlengths=SpcO.SpcRayset.RayOpticalPathlengths+additionalOPD;

                    %now add the rays to the correct surfaces
                    for n=1:length(SpcO.Surfaces)%go through the surfaces again
                        partOfSpcRayset=makeSubRayset(SpcO.SpcRayset,SurfsInOrder(:,1)==n);
                        if partOfSpcRayset.NumRays>0
                            addIncidentRays(SpcO.Surfaces{n},partOfSpcRayset,SpcO)
                            %this display line says what rays got added to what surface    
    %                         disp([SpcO.Name,' just added ',num2str(partOfSpcRayset.NumRays),' rays to ',SpcO.Surfaces{n}.Name]);
                        end
                    end
                end
                
                clearAllRays(SpcO.SpcRayset);
                SpcO.FromWhichSurfaces=[];
                SpcO.hasRays=false;
            end
        end
        
        function Indices=FindIndicesForRayset(SpcO,RaysO)
            Indices=SpcO.RefractiveIndxFcn(RaysO);
        end
        
        function addRaysToSpace(SpcO,RaysO,varargin) %varargin is available to input which surface the rays are coming from.  Varargin should be a SurfaceO object if it is used.
            removeWeakRays(SpcO.Environment, RaysO);
            if RaysO.NumRays>0
                joinRaysetsAndSaveInFirst(SpcO.SpcRayset,RaysO)
                SpcO.hasRays=1;
                if isempty(varargin)
                    SpcO.FromWhichSurfaces=[SpcO.FromWhichSurfaces;nan(RaysO.NumRays,1)];
                else
                    SN=getSurfaceNumber(SpcO,varargin{1});
                    if SN==-1, warningdlg(['Surface ',varargin{1}.Name,', not being associated with ',SpcO.Name,', has added rays to ',SpcO.Name,'.']); end
                    SpcO.FromWhichSurfaces=[SpcO.FromWhichSurfaces;ones(RaysO.NumRays,1)*SN];
                end
            end
        end
        
        function surfNum=getSurfaceNumber(SpcO,SurfO)
            surfNum=-1;
            for n=1:length(SpcO.Surfaces)
                if SpcO.Surfaces{n}==SurfO
                    surfNum=n;
                end
            end
        end
        
        function SpcOdupl = duplicate(SpcO) %duplicates all non-handle properties (function_handles excepted)
            SpcOdupl=SpaceO();
            SpcOdupl.Name=Spco.Name;
            SpcOdupl.VolumeAbsorbedPower=Spco.VolumeAbsorbedPower;
            SpcOdupl.RefractiveIndxFcn=SpcO.RefractiveIndxFcn; %input RaysetO object, output refractive indices column vector
        end
    end
    
    events
        
    end
end