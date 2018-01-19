classdef SurfaceO < handle
    properties
        Name %String for any identification purpose
        GroupName %String to identify the group to which this and potentially other surfaces belong (groups only exist in name, not as separate programming objects)
        Environment %the environment to which this surface belongs
        IntersectSolveGeometryParams={}; %these are used to generate IntersectSolveFcn (see below).  The first parameter is a string containing the name of the function that will perform the intersect solves.  This function needs to be on the Matlab search path (see addpath and genpath).  The rest of the parameters are the geometry inputs specifically needed by the function to perform the intersect solves particular to your surface.  It is possible that no additional geometry parameters need to be entered if the function specified is already uniquely programmed to represent the surface.
        %Format: {'yourIntrsctSlvFcn', Addtnl_arg1, Addtnl_arg2,...}, where Addtnl_arg1 is the third argument of yourIntrsctSlvFcn, and so on with additional args.  Examples: {'RayIntersects_Sphere', SphereCenterPoint1x3, Radius}  OR {'RayIntersects_ParabaloidSymmetric', vertexpoint1x3, focuspoint1x3}  OR  {'RayIntersects_Cylinder', axispoint1x3, axisdirection1x3, cylinderRadius}   ETC  
        IntersectSolveZOOMSETTINGS={}; %A cell array the same length as IntersectSolveGeometryParams.  It designates what zooms are applied to the geometric parameters at the corresponding indices.  The following strings are used to specify: 'N' for none, 'F' for full, and 'R' for rotations only
        %Example: {'N','F','N'} , which could correspond to the first example shown above for the cell array IntersectSolveGeometryParams     
        NormalSolveGeometryParams={}; %these are used to generate NormalSolveFcn (see below).  The first parameter is a string containing the name of the function that will perform the surface normal vector solves.  This function needs to be on the Matlab search path (see addpath and genpath).  The rest of the parameters are the geometry inputs specifically needed by the function to perform the normal solves particular to your surface.  It is possible that no additional geometry parameters need to be entered if the function specified is already uniquely programmed to represent the surface.
        %Format: {'yourNormlSlvFcn', Addtnl_arg1, Addtnl_arg2,...}, where Addtnl_arg1 is the 2nd argument of yourNormlSlvFcn, and so on with additional args.  Examples: {'RayIntersects_Sphere', SphereCenterPoint1x3, Radius}  OR {'RayIntersects_ParabaloidSymmetric', vertexpoint1x3, focuspoint1x3}  OR  {'RayIntersects_Cylinder', axispoint1x3, axisdirection1x3, cylinderRadius}   ETC  
        NormalSolveZOOMSETTINGS={}; %A cell array the same length as NormalSolveGeometryParams.  It designates what zooms are applied to the geometric parameters at the corresponding indices.  The following strings are used to specify: 'N' for none, 'F' for full, and 'R' for rotations only
        %Example: {'N','F','R','N'} , which could correspond to the fourth example shown above for the cell array NormalSolveGeometryParams     
        WindowGeometryCellArray={}; %these are used to generate WindowFcnsCellArray (see below).  Currently there are only 5 types of windowing styles:  Sphere-inside, Sphere-outside, Cylinder-inside, Cylinder-outside, and Plane (accepting points on only the side that the specified normal vector points into).    
        %i.e. {'sphere','inside', spherecenterpoint1x3, sphereradius, 'cylinder','outside', axispoint1x3, axisdirection1x3, cylinderRadius, 'plane', planepoint1x3, planeNormal1x3, ... REPEAT AS MANY OR AS FEW WINDOWS AS YOU WANT }  
        ZoomDataForAddZoomsFcn={}; %this was added for utility purposes as the gui was formed for RaytraceO.  The function AddZoom should be used to load each group of 5 parameters in this array and transform them into groups of 3 parameters in the RotationAndTranslationZoomsCellArray
        % ZoomType(either translation or rotation), AxisPoint1x3, AxisDirection1x3, TieToWhichEnvironmentZoom, EnvZoomToActualZoom_FcnHndl... repeat this set of 5 for each zoom
        RotationAndTranslationZoomsCellArray={}; %this stores zoom types along with the corresponding environment variables and zoom 4x4 matrix-functions (look up 4x4 translation matrix).  It is populated by the function addZoom.  The zooms are used in the order they are added.  The array is then used by updateGeometricSolves to transform geometric parameters just as they are used to generate the solve functions.
        %i.e. 'translation', 1, ZoomMatrxFcn4x4(envZm), 'rotation', 3, ZoomMatrxFcn4x4(envZm), REPEAT THESE SETS OF 3 FOR AS MANY ZOOMS AS YOU WANT...   (the numbers 1 and 3 are example indices of SurfObj.Environment.EnvZoomVars(indices) that correspond to the zooms.
        
        
        %Here is where we store the solve functions, once they have been generated using the above IntersectSolveGeometryParams, NormalSolveGeometryParams, and  ge
        %the geometry particular to the surface (as defined by the user).
        IntersectSolveFcn %inputArgs:(rayPositionsNx3,rayDirectionsNx3) output = intersectPointsNx3 (where the rays hit the surface, if anywhere)
        NormalSolveFcn %inputArgs:(intersectPointsNx3) ouput = normalVectorsNx3
        WindowFcnsCellArray %Cell array of windowing functions.  Each window function takes PointsNx3 and outputs logicalNx1 whether the Points are within the window
        
        
        AbsorbedPower=0;
        
        hasrays=false;
        
        IncidentRaysetA %rays in SpaceA that impinge on the surface
        IncidentRaysetB %rays in SpaceB that impinge on the surface
        SpaceA
        SpaceB
        
        IncidentNormalsA %put here by the SurfaceO
        IncidentNormalsB %put here by the SurfaceO
        
        %The functions that follow for surface interactions need some work.
        %They are too narrow for the inputs listed as required below.  At
        %some future point, many of the functions below need to be made to
        %take the whole RaysetO and corresponding surface normal vectors,
        %rather than breaking down the RaysetO into the various parts asked
        %for below.  This enables greater flexibility and expandability in
        %the future.
        
        %for simplified surfaces
        isPerfectAbsorber=false;
        isSimpleReflector=false;
        SimpleReflectance=1;%can be changed after instantiation of course
        
        %for regular, non-simplified surfaces
            hasAbsorption=false;
            AbsorptionSolveFcn %inputArgs:(incidentRaysetO, incidentSurfaceNormalsNx3) output= absorptionCoefficientsNx1
            
            hasTransmission=false;
            RefractSolveDirTransFcn %inputArgs:(incidentRaysetOobj, incidentSurfaceNormalsNx3, PendingRefractiveIndices) output= TransmittedRaysetOobj
            
            hasBackreflections=false;
            ReflectSolveDirReflFcn  %inputArgs:(incidentRaysetOobj, incidentSurfaceNormalsNx3,reflectOffOfIndicesNx1) output= ReflectedRaysetObj
            
            %the scattering functions may receive rays with zero power as
            %inputs, so include quick ways to ignore these zero power rays
            %when writing the scattering functions.
            hasBackscattering=false; %backreflections must be allowed to enable the backscattering
            BackscatteredRaysFcn %inputArgs:(ReflectedRaysetOobj, SurfaceNormalsNx3) output= RaysetO of new backscattered rays
            
            hasForwardScattering=false;
            ForwardScatteredRaysFcn %inputArgs:(RefractedRaysetOobj, SurfaceNormalsNx3) output= RaysetO of new forward scattered rays
        %-----
        
        %Purely Visualization Properties
        OriginalSurfaceXYZstorage={};
        SurfaceXYZForVisual={};  %this becomes a 1x3 cell array containing the X Y Z matrices for generating the surface visualization.  Each matrix is 2 dimensional having equal sizes
        VisColorData=[];
        SurfVisHndl=[];
        %-----
    end
    
    methods
        
        function SurfO = SurfaceO() %CONSTRUCTOR
            SurfO.IncidentRaysetA=RaysetO(); %rays in SpaceA that impinge on the surface
            SurfO.IncidentRaysetB=RaysetO(); %rays in SpaceB that impinge on the surface
        end
        

        function updateGeometricSolves(SurfO) %this should be used every time a new zoom is applied OR when a surface is being initiated or updated
            fullzoom4x4=diag([1,1,1,1],0);
            rotationsonly4x4=diag([1,1,1,1],0);
            %use the 4x4 matrix functions stored in SurfO.RotationAndTranslationZoomsCellArray to generate the fullzoom and rotation_only_zoom 4x4 zoom matrices    }
            if ~isempty(SurfO.RotationAndTranslationZoomsCellArray)
                for n=1:floor(length(SurfO.RotationAndTranslationZoomsCellArray)/3)
                    %matrix that applies all the zooms
                    ZoomMatrix4x4=SurfO.RotationAndTranslationZoomsCellArray{n*3}(SurfO.Environment.EnvZoomVars(SurfO.RotationAndTranslationZoomsCellArray{n*3-1}));
                    fullzoom4x4=ZoomMatrix4x4*fullzoom4x4;
                    if strcmpi('rotation',SurfO.RotationAndTranslationZoomsCellArray{n*3-2})
                        ZoomMatrix4x4(1:3,4)=0; %make the 4th column numbers all zero (except the last, leave it at 1) to make the rotation just a rotation about the origin, with the same rotation axis direction though.
                        rotationsonly4x4=ZoomMatrix4x4*rotationsonly4x4;
                    end
                end
            
                
                if isempty(SurfO.IntersectSolveZOOMSETTINGS)
                    uiwait(specifyParamsZooms(SurfO));
                end
                %Zoom the IntersectSolveParameters
                zoomedIntersectSolveGeometryParams=cell(1,length(SurfO.IntersectSolveZOOMSETTINGS));
                for n=1:length(SurfO.IntersectSolveZOOMSETTINGS)
                    switch lower(SurfO.IntersectSolveZOOMSETTINGS{n})
                        case 'r', zoomedIntersectSolveGeometryParams{n}=ZMfcn(rotationsonly4x4,SurfO.IntersectSolveGeometryParams{n});
                        case 'f', zoomedIntersectSolveGeometryParams{n}=ZMfcn(fullzoom4x4,SurfO.IntersectSolveGeometryParams{n});
                        otherwise, zoomedIntersectSolveGeometryParams{n}=SurfO.IntersectSolveGeometryParams{n};
                    end
                end
                %Zoom the NormalSolveParameters
                zoomedNormalSolveGeometryParams=cell(1,length(SurfO.NormalSolveZOOMSETTINGS));
                for n=1:length(SurfO.NormalSolveZOOMSETTINGS)
                    switch lower(SurfO.NormalSolveZOOMSETTINGS{n})
                        case 'r', zoomedNormalSolveGeometryParams{n}=ZMfcn(rotationsonly4x4,SurfO.NormalSolveGeometryParams{n});
                        case 'f', zoomedNormalSolveGeometryParams{n}=ZMfcn(fullzoom4x4,SurfO.NormalSolveGeometryParams{n});
                        otherwise, zoomedNormalSolveGeometryParams{n}=SurfO.NormalSolveGeometryParams{n};
                    end
                end
                
            else
                zoomedIntersectSolveGeometryParams=SurfO.IntersectSolveGeometryParams;
                zoomedNormalSolveGeometryParams=SurfO.NormalSolveGeometryParams;
            end
            
            %Update the IntersectSolveFcn and the NormalSolveFcn
            IntrsctSolvFull=str2func(zoomedIntersectSolveGeometryParams{1}); zoomedIntersectSolveGeometryParams(1)=[];
            NormSolvFull=str2func(zoomedNormalSolveGeometryParams{1}); zoomedNormalSolveGeometryParams(1)=[];
            SurfO.IntersectSolveFcn=@(rayposNx3,raydirNx3,winFcnHdl)IntrsctSolvFull(rayposNx3,raydirNx3,winFcnHdl,zoomedIntersectSolveGeometryParams{:});
            SurfO.NormalSolveFcn=@(SurfacePointsNx3)NormSolvFull(SurfacePointsNx3,zoomedNormalSolveGeometryParams{:});
            
            
            %update window solves
            WGCAcounter=1; %WindowGeometryCellArray counter
            WFsCAcounter=1; %WindowFcnsCellArray counter
            WGCA=SurfO.WindowGeometryCellArray;
            SurfO.WindowFcnsCellArray={}; %reinitialize just before loading
            while WGCAcounter<=length(SurfO.WindowGeometryCellArray)
                switch lower(WGCA{WGCAcounter})
                    case 'plane' %Expects SurfO.GeometryParametersCellArray{2} to be a plane point 1x3, and SurfO.GeometryParametersCellArray{3} to be a plane surface normal vector 1x3
                        param2=ZMfcn(fullzoom4x4,WGCA{WGCAcounter+1});
                        param3=ZMfcn(rotationsonly4x4,WGCA{WGCAcounter+2});
                        SurfO.WindowFcnsCellArray{WFsCAcounter}=@(pointsNx3)WindowingFcn_Plane(pointsNx3,param2,param3);   WGCAcounter=WGCAcounter+3;  WFsCAcounter=WFsCAcounter+1;
                    case 'sphere' %Expects SurfO.GeometryParametersCellArray{2} to be the sphere center point 1x3, and SurfO.GeometryParametersCellArray{3} to be the sphere radius 1x1
                        param2=ZMfcn(fullzoom4x4,WGCA{WGCAcounter+2});
                        param3=WGCA{WGCAcounter+3};
                        if strcmpi(WGCA{WGCAcounter+1},'inside'), SurfO.WindowFcnsCellArray{WFsCAcounter}=@(pointsNx3)WindowingFcn_Sphere(pointsNx3,param2,param3);
                        else SurfO.WindowFcnsCellArray{WFsCAcounter}=@(pointsNx3)WindowingFcn_ExoSphere(pointsNx3,param2,param3); end
                        WGCAcounter=WGCAcounter+4;  WFsCAcounter=WFsCAcounter+1;
                    case 'cylinder' %Expects SurfO.GeometryParametersCellArray{2} to be a cylinder axis point 1x3, and SurfO.GeometryParametersCellArray{3} to be the cylinder axis direction vector 1x3, and SurfO.GeometryParametersCellArray{4} to be the cylinder radius 1x1
                        param2=ZMfcn(fullzoom4x4,WGCA{WGCAcounter+2});
                        param3=ZMfcn(rotationsonly4x4,WGCA{WGCAcounter+3});
                        param4=WGCA{WGCAcounter+4};
                        if strcmpi(WGCA{WGCAcounter+1},'inside'), SurfO.WindowFcnsCellArray{WFsCAcounter}=@(pointsNx3)WindowingFcn_Cylinder(pointsNx3,param2,param3,param4);
                        else SurfO.WindowFcnsCellArray{WFsCAcounter}=@(pointsNx3)WindowingFcn_ExoCylinder(pointsNx3,param2,param3,param4); end
                        WGCAcounter=WGCAcounter+5;  WFsCAcounter=WFsCAcounter+1;
                    otherwise
                        error('An unidentified window type was encountered')
                end
            end
            
            function zoomedVec1x3=ZMfcn(matrix4x4,Vec1x3) %Apply Zoom function for multiplying a 4x4 with a 1x3
                if ~all(size(Vec1x3)==[1,3]), error('Zooming only works with 3-dimensional direction or position vectors.  Check your IntersectSolve or NormalSolve geometric parameters for this surface.  All position and direction vectors should have size==[1,3].'); end
                zoomedVec1x3=matrix4x4*[Vec1x3,1]';%turn the 3 vector into a 4 vector
                zoomedVec1x3=zoomedVec1x3(1:3)';
            end
        end
        
        function updateVisXYZpts(SurfO) %this should be used every time a new zoom is applied
            if ~isempty(SurfO.OriginalSurfaceXYZstorage)
                fullzoom4x4=diag([1,1,1,1],0);
                %use the 4x4 matrix functions stored in SurfO.RotationAndTranslationZoomsCellArray to generate the fullzoom and rotation_only_zoom 4x4 zoom matrices    }
                if ~isempty(SurfO.RotationAndTranslationZoomsCellArray)
                    for n=1:floor(length(SurfO.RotationAndTranslationZoomsCellArray)/3)
                        %matrix that applies all the zooms
                        fullzoom4x4=SurfO.RotationAndTranslationZoomsCellArray{n*3}(SurfO.Environment.EnvZoomVars(SurfO.RotationAndTranslationZoomsCellArray{n*3-1}))*fullzoom4x4;
                    end
                end
                X=SurfO.OriginalSurfaceXYZstorage{1};Y=SurfO.OriginalSurfaceXYZstorage{2};Z=SurfO.OriginalSurfaceXYZstorage{3};
                sz=size(X);
                newXYZ=fullzoom4x4*([X(:),Y(:),Z(:),ones(numel(X),1)]');
                SurfO.SurfaceXYZForVisual{1}=reshape(newXYZ(1,:),sz);
                SurfO.SurfaceXYZForVisual{2}=reshape(newXYZ(2,:),sz);
                SurfO.SurfaceXYZForVisual{3}=reshape(newXYZ(3,:),sz);
            end
        end
        
        function newfig=specifyParamsZooms(SurfO) %this function brings up a UI that is designed to get the user to populate the SurfaceO properties IntersectSolveZOOMSETTINGS and NormalSolveZOOMSETTINGS
            newfig=figure('MenuBar','none');
            entries=cell(1);
            displayed=cell(1);
            introto=uicontrol(newfig,'Style','text','Units','normalized','Position',[.26,.77,.4,.075],'String',[char(9660),' Your IntersectSolve function for this surface and the geometrical parameters you specified']);
            
            savedscriptPopup=uicontrol(newfig,'Style','text','Units','normalized','Position',[.3,.03,.4,.05],'String','Parameters saved to IntersectSolveZOOMSETTINGS','Visible','off');
            uicontrol(newfig,'Style','text','Units','normalized','Position',[.1,.87,.8,.12],'String','FOR ZOOMING PURPOSES, please specify which parameters are specifically DIRECTION parameters by putting a D next to them. Specify those that are POSITION parameters by putting an P next to them. Leave the rest blank or put N.');
            
            saveentries=uicontrol(newfig,'Style','Pushbutton','String','Submit Entries','Units','normalized','Position',[.3,.1,.2,.15],'Callback',{@righthere,SurfO,1});
                                function righthere(~,~,SurfO,IntersectsOrNormals) %this is the first pushbutton that saves the entries you type to the left of the shown geometric parameters.  IntersectsOrNormals is just there to tell the program whether to use SurfO.IntersectSolveZOOMSETTINGS or SurfO.NormalSolveZOOMSETTINGS for the updating
                                    for p=1:length(entries)
                                        switch lower(entries{p}.String)
                                            case 'p', ssss='F'; case 'd', ssss='R'; otherwise, ssss='N';
                                        end
                                        if IntersectsOrNormals==1, SurfO.IntersectSolveZOOMSETTINGS{p}=ssss; else SurfO.NormalSolveZOOMSETTINGS{p}=ssss; end
                                    end
                                    savedscriptPopup.Visible='on';
                                    pause(.5)
                                    savedscriptPopup.Visible='off';
                                end
            uicontrol(newfig,'Style','Pushbutton','String','Repeat for NormalSolves parameters','Units','normalized','Position',[.55,.1,.4,.15],'Callback',{@changeover,SurfO})
                                function changeover(PBobj,~,SurfO)
                                    if strcmpi(PBobj.String,'Repeat for NormalSolves parameters')   
                                        righthere(1,1,SurfO,1);
                                        saveentries.Callback={@righthere,SurfO,2};
                                        introto.String=[char(9660),' Your NormalSolve function for this surface and the geometrical parameters you specified'];
                                        savedscriptPopup.String='Parameters saved to NormalSolveZOOMSETTINGS';
                                        for n=1:length(displayed), delete(displayed{n}); delete(entries{n}); end
                                        DispNewParams(SurfO.NormalSolveGeometryParams);
                                        PBobj.String='Close window'; %Make it so that if this button is clicked again, the figure housing this gui will close, ending any further updating to the ZoomsParams cell arrays
                                    else
                                        righthere(1,1,SurfO,2);
                                        delete(newfig);
                                    end
                                end
            
            DispNewParams(SurfO.IntersectSolveGeometryParams);
            %DispNewParams is the nested function responsible for displaying the
            %geometric parameters and also putting the edit boxes to the
            %left for the user to put in entries.
            function DispNewParams(CA)
                lCA=length(CA);
                entries=cell(1,lCA);
                displayed=cell(1,lCA);
                uicontrol(newfig,'Style','text','Units','normalized','Position',[.72,.73,.26,.05],'String',[char(9664),' Function name'],'HorizontalAlignment','Left');
                for n=1:lCA
                    if isnumeric(CA{n}), str=num2str(CA{n});
                    elseif ischar(CA{n}), str=CA{n};
                    else str=''; 
                    end
                    displayed{n}=uicontrol(newfig,'Style','text','Units','normalized','Position',[.21,.8-n*.07,.5,.05],'String',str,'BackgroundColor',[.9,.98,.99]/1.005);
                    
                    if n>1, uicontrol(newfig,'Style','text','Units','normalized','Position',[.72,.79-n*.07,.26,.065],'String',[char(9664),' Parameter ',num2str(n-1),'. Is it a direction, point or neither?'],'HorizontalAlignment','Left'); 
                    uicontrol(newfig,'Style','text','Units','normalized','Position',[.03,.8-n*.07,.115,.07],'String',['Specify D,P,or N ',char(9654)],'HorizontalAlignment','Right'); 
                    entries{n}=uicontrol(newfig,'Style','edit','Units','normalized','Position',[.15,.8-n*.07,.05,.05]); else entries{n}=uicontrol(newfig,'Style','edit','Units','normalized','Position',[.15,.8-n*.07,.05,.05],'Visible','off');
                    end
                end
            end
            
        end
        
        function EvnZooms=usesEvnZooms(SurfO)
            EvnZooms=[];
            lrtz=length(SurfO.RotationAndTranslationZoomsCellArray);
            if ~isempty(SurfO.RotationAndTranslationZoomsCellArray)
                EvnZooms=[SurfO.RotationAndTranslationZoomsCellArray{2:3:lrtz}];
            end
        end
          
        
        function addIncidentRays(SurfO,RaysO,fromThisSpace)
%             disp([fromThisSpace.Name,' is adding rays to ',SurfO.Name])
            removeWeakRays(SurfO.Environment, RaysO);
            if fromThisSpace==SurfO.SpaceA
%                 disp([SurfO.Name,' is getting rays added to side A from ',fromThisSpace.Name])
                joinRaysetsAndSaveInFirst(SurfO.IncidentRaysetA,RaysO)
                if SurfO.IncidentRaysetA.NumRays>0, SurfO.hasrays=true; end
            elseif fromThisSpace==SurfO.SpaceB
%                 disp([SurfO.Name,' is getting rays added to side B from ',fromThisSpace.Name])
                joinRaysetsAndSaveInFirst(SurfO.IncidentRaysetB,RaysO)
                if SurfO.IncidentRaysetB.NumRays>0, SurfO.hasrays=true; end
            else
                warning(['Rays added to surface ',SurfO.Name,' by space ',fromThisSpace.Name,', but this space is not directly associated with the surface.  The rays will be counted as non-intersecting rays.'])
                SurfO.Environment.NonIntersectingRayLosses = SurfO.Environment.NonIntersectingRayLosses + sum(RaysO.RayPowers);
            end
        end
        
        
        function intersectionPoints=findIntersectionPoints(SurfO,RayPositionsNx3,RayDirectionsNx3)
            intersectionPoints=SurfO.IntersectSolveFcn(RayPositionsNx3,RayDirectionsNx3,@(ptset)applyWindowsToPointset(SurfO,ptset));
        end
      %might not be needed  
% % % % % % % %         function loadSurfaceNormalVectors(SurfO)
% % % % % % % %             if SurfO.IncidentRaysetA.Numrays>0
% % % % % % % %                 SurfO.IncidentNormalsA=SurfO.NormalSolveFcn(SurfO.IncidentRaysetA.RayPositions);%get the normal vectors to the surface
% % % % % % % %             end
% % % % % % % %             if SurfO.IncidentRaysetB.Numrays>0
% % % % % % % %                 SurfO.IncidentNormalsB=SurfO.NormalSolveFcn(SurfO.IncidentRaysetB.RayPositions);%get the normal vectors to the surface
% % % % % % % %             end
% % % % % % % %         end
        




        function interactRays(SurfO)
% The surface object tracks power absorbed in the AbsorbedPower property.
% Such tracking is done if the surface is a perfectabsorber or
% simplereflector or it tracks the power removed by
% AbsorptionSolveFcnabsorption.  If there are power losses/gains created by
% any of the following functions:
%     RefractSolveDirTransFcn
%     ReflectSolveDirReflFcn
%     BackscatteredRaysFcn
%     ForwardScatteredRaysFcn
% then such power changes will not be tracked by the code. It is
% completely up to the user to balance the power distributions applied by
% the above listed functions, to whatever end the user desires.
            
            %Check that there are incident rays
            if SurfO.hasrays
                    %this is the part where we take the incident rays and interact
                    %them with the surface

                if SurfO.IncidentRaysetA.NumRays>0 %Interact the rays on side A IF there are any
                    if isa(SurfO,'DetectorO')
                        SurfO.IncidentNormalsA=SurfO.NormalSolveFcn(SurfO.IncidentRaysetA.RayPositions);
                        detectRays(SurfO,SurfO.IncidentRaysetA,SurfO.IncidentNormalsA);
                    elseif ~SurfO.isPerfectAbsorber
                        SurfO.IncidentNormalsA=SurfO.NormalSolveFcn(SurfO.IncidentRaysetA.RayPositions);
                    end
                    %Absorb first
                    if SurfO.isPerfectAbsorber
%                         disp([SurfO.Name,' is perfectly absorbing ',num2str(SurfO.IncidentRaysetA.NumRays),' rays on side A'])
                        %track the absorbed power
                        SurfO.AbsorbedPower=SurfO.AbsorbedPower+sum(SurfO.IncidentRaysetA.RayPowers);

                    elseif SurfO.isSimpleReflector
%                         disp([SurfO.Name,' is simply reflecting ',num2str(SurfO.IncidentRaysetA.NumRays),' rays on side A'])
                        %Track the absorbed power
                        SurfO.AbsorbedPower=SurfO.AbsorbedPower+(1-SurfO.SimpleReflectance)*sum(SurfO.IncidentRaysetA.RayPowers);
                        %reduce the powers of the impinging rays
                        SurfO.IncidentRaysetA.RayPowers=SurfO.SimpleReflectance*SurfO.IncidentRaysetA.RayPowers;
                        %reflect the rays
                            %Flip the components of the direction vectors that
                            %are parallel to the surface normals
                        SurfO.IncidentRaysetA.RayDirections=SurfO.IncidentRaysetA.RayDirections-(2*sum(SurfO.IncidentRaysetA.RayDirections.*SurfO.IncidentNormalsA,2)*[1,1,1]).*SurfO.IncidentNormalsA; 
                        %and send them back to the same space
                        addRaysToSpace(SurfO.SpaceA,SurfO.IncidentRaysetA,SurfO)
%                         disp([SurfO.Name,' just added ',num2str(SurfO.IncidentRaysetA.NumRays),' rays to space ',SurfO.SpaceA.Name,' after reflecting them.']);


                    else
%                         disp([SurfO.Name,' is complexly interacting ',num2str(SurfO.IncidentRaysetA.NumRays),' rays on side A'])
                        %if there is some absorbing to do before all the other interactions
                        if SurfO.hasAbsorption
                            startpower=sum(SurfO.IncidentRaysetA.RayPowers);
                            SurfO.IncidentRaysetA.RayPowers=(1-SurfO.AbsorptionSolveFcn(SurfO.IncidentRaysetA,SurfO.IncidentNormalsA)).*SurfO.IncidentRaysetA.RayPowers; %inputArgs:(incidentRayPositionsNx3, incidentRayDirectionsNx3, incidentSurfaceNormalsNx3) output= absorptionCoefficientsNx1
                            SurfO.AbsorbedPower=SurfO.AbsorbedPower+(startpower-sum(SurfO.IncidentRaysetA.RayPowers));
                        end
                        
                        if SurfO.hasTransmission || SurfO.hasBackreflections
                            PendingRefractiveIndices=FindIndicesForRayset(SurfO.SpaceB,SurfO.IncidentRaysetA);
                        end

                        if SurfO.hasTransmission
                            RaysToBtrans=SurfO.RefractSolveDirTransFcn(SurfO.IncidentRaysetA,SurfO.IncidentNormalsA,PendingRefractiveIndices); 
%                         disp([SurfO.Name,' just added ',num2str(RaysToBtrans.NumRays),' rays to space ',SurfO.SpaceB.Name,' after transmitting them.']);
                            if SurfO.hasForwardScattering %transmission must be allowed to enable forward scattering
                                addRaysToSpace(SurfO.SpaceB,SurfO.ForwardScatteredRaysFcn(RaysToBtrans,SurfO.IncidentNormalsA),SurfO);
                            end
                            addRaysToSpace(SurfO.SpaceB,RaysToBtrans,SurfO);
                        end

                        if SurfO.hasBackreflections
                            RaysToArefl=SurfO.ReflectSolveDirReflFcn(SurfO.IncidentRaysetA,SurfO.IncidentNormalsA,PendingRefractiveIndices);
                            if SurfO.hasBackscattering %backreflections must be allowed to enable the backscattering
                                addRaysToSpace(SurfO.SpaceA,SurfO.BackscatteredRaysFcn(RaysToArefl,SurfO.IncidentNormalsA),SurfO);
                                %note here that the environment isn't
                                %tracking any power associated with the
                                %addition of backscattered rays - this
                                %happens with forward scattering too
                            end
                            addRaysToSpace(SurfO.SpaceA,RaysToArefl,SurfO);
                        end
                    end
                    %get rid of the rays that were incident on side A
%                     disp(['removing all rays from side A of ',SurfO.Name])
                    clearAllRays(SurfO.IncidentRaysetA);
                    SurfO.IncidentNormalsA=[];
                end
                %  REPEAT REPEAT REPEAT REPEAT REPEAT
                if SurfO.IncidentRaysetB.NumRays>0   %repeat for the rays on side B, IF there are any
                    if isa(SurfO,'DetectorO')
                        SurfO.IncidentNormalsB=SurfO.NormalSolveFcn(SurfO.IncidentRaysetB.RayPositions);%get the normal vectors to the surface
                        detectRays(SurfO,SurfO.IncidentRaysetB,SurfO.IncidentNormalsB);
                    elseif ~SurfO.isPerfectAbsorber
                        SurfO.IncidentNormalsB=SurfO.NormalSolveFcn(SurfO.IncidentRaysetB.RayPositions);%get the normal vectors to the surface
                    end
                    %Absorb first
                    if SurfO.isPerfectAbsorber
%                         disp([SurfO.Name,' is perfectly absorbing ',num2str(SurfO.IncidentRaysetB.NumRays),' rays on side B'])
                        %track the absorbed power
                        SurfO.AbsorbedPower=SurfO.AbsorbedPower+sum(SurfO.IncidentRaysetB.RayPowers);

                    elseif SurfO.isSimpleReflector
%                         disp([SurfO.Name,' is simply reflecting ',num2str(SurfO.IncidentRaysetB.NumRays),' rays on side B'])
                        %Track the absorbed power
                        SurfO.AbsorbedPower=SurfO.AbsorbedPower+(1-SurfO.SimpleReflectance)*sum(SurfO.IncidentRaysetB.RayPowers);
                        %reduce the powers of the impinging rays
                        SurfO.IncidentRaysetB.RayPowers=SurfO.SimpleReflectance*SurfO.IncidentRaysetB.RayPowers;
                        %reflect the rays
                            %Flip the components of the direction vectors that
                            %are parallel to the surface normals
                        SurfO.IncidentRaysetB.RayDirections=SurfO.IncidentRaysetB.RayDirections-(2*sum(SurfO.IncidentRaysetB.RayDirections.*SurfO.IncidentNormalsB,2)*[1,1,1]).*SurfO.IncidentNormalsB;
                        %and send them back to the same space
                        addRaysToSpace(SurfO.SpaceB,SurfO.IncidentRaysetB,SurfO)
%                         disp([SurfO.Name,' just added ',num2str(SurfO.IncidentRaysetB.NumRays),' rays to space ',SurfO.SpaceB.Name,' after reflecting them.']);

                    else
%                         disp([SurfO.Name,' is complexly interacting ',num2str(SurfO.IncidentRaysetB.NumRays),' rays on side B, and one of the rays is distance ', num2str(norm(SurfO.IncidentRaysetB.RayPositions(1,:)-[1,1,1])),' from [1,1,1]'])
                        %if there is some absorbing to do before all the other interactions
                        if SurfO.hasAbsorption
                            startpower=sum(SurfO.IncidentRaysetB.RayPowers);
                            SurfO.IncidentRaysetB.RayPowers=(1-SurfO.AbsorptionSolveFcn(SurfO.IncidentRaysetB,SurfO.IncidentNormalsB)).*SurfO.IncidentRaysetB.RayPowers; %inputArgs:(incidentRayPositionsNx3, incidentRayDirectionsNx3, incidentSurfaceNormalsNx3) output= absorptionCoefficientsNx1
                            SurfO.AbsorbedPower=SurfO.AbsorbedPower+(startpower-sum(SurfO.IncidentRaysetB.RayPowers));
                        end
                        
                        if SurfO.hasTransmission || SurfO.hasBackreflections
                            PendingRefractiveIndices=FindIndicesForRayset(SurfO.SpaceA,SurfO.IncidentRaysetB);
                        end
                        
                        if SurfO.hasTransmission
                            RaysToAtrans=SurfO.RefractSolveDirTransFcn(SurfO.IncidentRaysetB,SurfO.IncidentNormalsB,PendingRefractiveIndices);
%                         disp([SurfO.Name,' just added ',num2str(RaysToAtrans.NumRays),' rays to space ',SurfO.SpaceA.Name,' after transmitting them.']);
                            if SurfO.hasForwardScattering %transmission must be allowed to enable forward scattering
                                addRaysToSpace(SurfO.SpaceA,SurfO.ForwardScatteredRaysFcn(RaysToAtrans,SurfO.IncidentNormalsB),SurfO);
                            end
                            addRaysToSpace(SurfO.SpaceA,RaysToAtrans,SurfO);
                        end

                        if SurfO.hasBackreflections
                            RaysToBrefl=SurfO.ReflectSolveDirReflFcn(SurfO.IncidentRaysetB,SurfO.IncidentNormalsB,PendingRefractiveIndices);
                            if SurfO.hasBackscattering %backreflections must be allowed to enable the backscattering
                                addRaysToSpace(SurfO.SpaceB,SurfO.BackscatteredRaysFcn(RaysToBrefl,SurfO.IncidentNormalsB),SurfO);
                            end
                            addRaysToSpace(SurfO.SpaceB,RaysToBrefl,SurfO);
                        end
                    end
                    %get rid of the rays that were incident on side B
%                     disp(['removing all rays from side B of ',SurfO.Name])
                    clearAllRays(SurfO.IncidentRaysetB);
                    SurfO.IncidentNormalsB=[];
                end
                SurfO.hasrays=false;
            end
        end
        
        
        %addZoom is called by EditSurfMain after the gui loads parameters into ZoomDataForAddZoomsFcn.
        function addZoom(SurfO,ZoomType,AxisPoint1x3,AxisDirection1x3,TieToWhichEnvironmentZoom,EnvZoomToActualZoom_FcnHndl) % Translation zooms are always along a straight line in the direction specified by AxisDirection1x3 (AxisPoint1x3 isn't used for translations, so any point can be supplied).  Rotation zooms rotate points about the axis specified AxisPoint1x3 and AxisDirection1x3
            currzoomlength=length(SurfO.RotationAndTranslationZoomsCellArray);
            AxisDirection1x3=AxisDirection1x3/norm(AxisDirection1x3);
            switch lower(ZoomType)
                case 'translation'
                    SurfO.RotationAndTranslationZoomsCellArray{currzoomlength+1}='translation';
                    SurfO.RotationAndTranslationZoomsCellArray{currzoomlength+2}=TieToWhichEnvironmentZoom;
                    SurfO.RotationAndTranslationZoomsCellArray{currzoomlength+3}=@(envZm)[[1,0,0;0,1,0;0,0,1;0,0,0],[AxisDirection1x3*EnvZoomToActualZoom_FcnHndl(envZm),1]'];
                case 'rotation'
                    SurfO.RotationAndTranslationZoomsCellArray{currzoomlength+1}='rotation';
                    SurfO.RotationAndTranslationZoomsCellArray{currzoomlength+2}=TieToWhichEnvironmentZoom;
                    a=AxisPoint1x3(1);b=AxisPoint1x3(2);c=AxisPoint1x3(3);u=AxisDirection1x3(1);v=AxisDirection1x3(2);w=AxisDirection1x3(3);thet=@(envZm)EnvZoomToActualZoom_FcnHndl(envZm);OmC=@(envZm)1-cos(thet(envZm));
                    rotatn=@(envZm)[u^2+(v^2+w^2)*cos(thet(envZm)),     u*v*OmC(envZm)-w*sin(thet(envZm)),      u*w*OmC(envZm)+v*sin(thet(envZm)),   (a*(v^2+w^2)-u*(b*v+c*w))*OmC(envZm)+(b*w-c*v)*sin(thet(envZm));...                        
                    u*v*OmC(envZm)+w*sin(thet(envZm)),     v^2+(u^2+w^2)*cos(thet(envZm)),     v*w*OmC(envZm)-u*sin(thet(envZm)),   (b*(u^2+w^2)-v*(a*u+c*w))*OmC(envZm)+(c*u-a*w)*sin(thet(envZm)); ...                       
                    u*w*OmC(envZm)-v*sin(thet(envZm)),     v*w*OmC(envZm)+u*sin(thet(envZm)),        w^2+(u^2+v^2)*cos(thet(envZm)),   (c*(u^2+v^2)-w*(a*u+b*v))*OmC(envZm)+(a*v-b*u)*sin(thet(envZm));... 
                    0,0,0,1];
                    
                    SurfO.RotationAndTranslationZoomsCellArray{currzoomlength+3}=rotatn;
                
                otherwise
                    error('addZoom does not recognize the type of zoom requested (the second parameter needs to be ''translation'' or ''rotation'')');
            end
        end
        
        
        function PointsAllowedNx1_logical = applyWindowsToPointset(SurfO,PointsNx3)
            N=size(PointsNx3,1);
            PointsAllowedNx1_logical=true(N,1);
            for n=1:length(SurfO.WindowFcnsCellArray)
                PointsAllowedNx1_logical(PointsAllowedNx1_logical)= SurfO.WindowFcnsCellArray{n}(PointsNx3(PointsAllowedNx1_logical,:));
%                 disp(func2str(SurfO.WindowFcnsCellArray{n}))  % for debugging help to see the windowing function called
            end
        end
        
        
        
        %this function is currently not in use
        function SurfOdupl=duplicate(SurfO) %this copies all non-handle properties into a new SurfaceO (except function handles and .hasrays)
            errordlg('You should update the comment before this function about this function not being in use. Error 3p213124sf');
            if isa(SurfO,'DetectorO'), SurfOdupl=DetectorO(); else SurfOdupl=SurfaceO(); end
            SurfOdupl.Name=                         SurfO.Name;
            SurfOdupl.GroupName=                    SurfO.GroupName;
            SurfOdupl.IntersectSolveGeometryParams= SurfO.IntersectSolveGeometryParams; 
            SurfOdupl.IntersectSolveZOOMSETTINGS=   SurfO.IntersectSolveZOOMSETTINGS; 
            SurfOdupl.NormalSolveGeometryParams=    SurfO.NormalSolveGeometryParams;
            SurfOdupl.NormalSolveZOOMSETTINGS=      SurfO.NormalSolveZOOMSETTINGS; 
            SurfOdupl.WindowGeometryCellArray=      SurfO.WindowGeometryCellArray; 
            SurfOdupl.ZoomDataForAddZoomsFcn=       SurfO.ZoomDataForAddZoomsFcn; 
            SurfOdupl.RotationAndTranslationZoomsCellArray=SurfO.RotationAndTranslationZoomsCellArray; 
            SurfOdupl.IntersectSolveFcn=            SurfO.IntersectSolveFcn; 
            SurfOdupl.NormalSolveFcn=               SurfO.NormalSolveFcn; 
            SurfOdupl.WindowFcnsCellArray=          SurfO.WindowFcnsCellArray; 
            SurfOdupl.AbsorbedPower=                SurfO.AbsorbedPower;
            SurfOdupl.IncidentNormalsA=             SurfO.IncidentNormalsA; 
            SurfOdupl.IncidentNormalsB=             SurfO.IncidentNormalsB; 
            SurfOdupl.isPerfectAbsorber=            SurfO.isPerfectAbsorber;
            SurfOdupl.isSimpleReflector=            SurfO.isSimpleReflector;
            SurfOdupl.SimpleReflectance=            SurfO.SimpleReflectance;
            SurfOdupl.hasAbsorption=                SurfO.hasAbsorption;
            SurfOdupl.AbsorptionSolveFcn=           SurfO.AbsorptionSolveFcn; 
            SurfOdupl.hasTransmission=              SurfO.hasTransmission;
            SurfOdupl.RefractSolveDirTransFcn=      SurfO.RefractSolveDirTransFcn; 
            SurfOdupl.hasBackreflections=           SurfO.hasBackreflections;
            SurfOdupl.ReflectSolveDirReflFcn=       SurfO.ReflectSolveDirReflFcn;  
            SurfOdupl.hasBackscattering=            SurfO.hasBackscattering;
            SurfOdupl.BackscatteredRaysFcn=         SurfO.BackscatteredRaysFcn; 
            SurfOdupl.hasForwardScattering=         SurfO.hasForwardScattering;
            SurfOdupl.ForwardScatteredRaysFcn=      SurfO.ForwardScatteredRaysFcn; 
            SurfOdupl.OriginalSurfaceXYZstorage=    SurfO.OriginalSurfaceXYZstorage;
            SurfOdupl.SurfaceXYZForVisual=          SurfO.SurfaceXYZForVisual; 
            SurfOdupl.VisColorData=                 SurfO.VisColorData;
            if isa(SurfO,'DetectorO'), copyDetectorPropertiesfromSecondToFirst(SurfOdupl,SurfO); end
        end
    
    end
    
    
    events
    end
end