classdef EnvironmentO < handle
    properties
        SpaceList % a SpaceO array
        SurfaceList % a SurfaceO array, includes all surfaces and detectors
        SourceList % a SourceO array
        DetectorList % a DetectorO array of just detectors
        EnvironmentDS
        
        ZoomedObjectsList %This is a cell array 
        EnvZoomVars %an array of numbers where all array elemets are between 0 and 1
        CurrentZoomColorChoice=1;
        ZoomColors = [0  0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250; 0.4940    0.1840    0.5560; 0.4660    0.6740    0.1880; 0.3010    0.7450    0.9330; 0.6350    0.0780    0.1840;
                            0  0  1; 0  .5  0; 1 0 0;   0    0.7500    0.7500; 0.75 0 0.75; 0.7500    0.7500         0; 0.2500    0.2500    0.2500];
        ZoomAdjButtongroup
                        
        EnvFig;  %handle to the figure that holds the system view
        EnvAxes;  %handle to the axes that holds the system view
        EnvTTBo;  %this is the handle to the TextTreeBox object that holds the lists
        
        Unit %a place where the user can note what the unit of distance is for their setup
        
        WeakRayThreshold=1e-10; %the power at which rays are removed from the system
        PowerFromSources=0;  %This tracks power the sources give to the system
        MinDistanceForReintersect=1e-9; %in millimeters or whatever unit the user decides to operate in.  If this is set to 0, problems may occur.  Sometimes ray intersect solves put rays on the wrong side of the surface due to precision error.  These rays then end up re-intersecting the surface they are supposed to be leaving from.  That is why this value should be something greater than 1e-13 (the surface solves try to get precision better than 4e-14).
        MinDistanceForNonEdgyIntersect=1e-8;
        NonIntersectingRayset
        
        WeakRayLosses=0;
        EdgyRayLosses=0;
        NonIntersectingRayLosses=0;
        
        rayDrawingEnabled=true;
    end
    

    methods
        function EnvO = EnvironmentO()
            EnvO.EnvironmentDS=DeadSpaceO(); EnvO.EnvironmentDS.Environment=EnvO;
            EnvO.NonIntersectingRayset=RaysetO();
        end
        
        function moveraysthrough(EnvO,varargin) %varargin allows zoom automation - the additional arguments are value pairs of the form: EnvZoomVar#, step# ... repeated for as many UNIQUE EnvZoomVar# you want to use, no repeats allowed 
            thislevel=0;
            if isempty(guidata(EnvO.EnvFig))
                hd=helpdlg('Tracing rays...');
                guidata(EnvO.EnvFig,hd)
                thislevel=1;
            end
            lv=length(varargin);
            if lv>1
                if varargin{2}<1, error('You need to specify each number of zoom steps to be an integer greater than 1'); end
                %Take one step
                for nn=0:1/(varargin{2}-1):1 %go through the 
                    %set the new zoom, perform the trace
                    EnvO.EnvZoomVars(varargin{1})=nn; %update the zoom variable
                    UpdateSurfZooms(EnvO,0,varargin{1}); %zoom the surfaces associated with the EnvZoomVar# in varargin{1}, but not the visuals - that's the 0
                    if lv>2 %perform the next nested group of zooms - thereby getting to the bottom level before doing any raytracing
                        moveraysthrough(EnvO,varargin{3:lv});
                    end
                    if EnvO.rayDrawingEnabled
                        runfulltrace(EnvO,EnvO.EnvAxes,EnvO.ZoomColors(EnvO.CurrentZoomColorChoice,:)) %do the raytrace
                        EnvO.CurrentZoomColorChoice=mod(EnvO.CurrentZoomColorChoice,14)+1;
                    else
                        runfulltrace(EnvO)
                    end
                end
                %then call the function recursively if the next function is not
                %spent
            else
                if EnvO.rayDrawingEnabled
                    runfulltrace(EnvO,EnvO.EnvAxes)
                else
                    runfulltrace(EnvO)
                end
            end
            %-----
            %end of main function body
            
                        function runfulltrace(EnvO,varargin) %the varargin is passed to the SpaceO function propagateRayset (2 optional args - axHndl and ColorSpec).  If varargin is empty, then propagateRayset will not visualize the rays
                            availablesources=false;
                            for n=1:length(EnvO.SourceList) %go through all the sources and set them off
                                if EnvO.SourceList(n).enabled %check that the source is enabled (toggled by the checkbox next to it in the EnvTTBo)
                                    makeRaysetAndGiveToSpace(EnvO.SourceList(n));
                                    availablesources=true;
                                end
                            end
                            if ~availablesources  %if no sources were fired, then don't do the rest of the raytracing
                                delete(hd)
                                uiwait(helpdlg('No sources available for raytracing.  Either add sources to the system, or enable one or more by clicking their checkboxes in the list.'));
                                return;
                            end
                            stillhasrays=true;
                            while stillhasrays
                                %go through all the spaces and propagate the rays
            %                     disp('ENVIRONMENT IS GOING THROUGH ALL SPACES')
                                for n=1:length(EnvO.SpaceList)
            %                         disp(['CHECKING SPACE ',EnvO.SpaceList(n).Name])
                                    if ~isempty(varargin)
            %                             disp(['AND PROPAGATING ANY RAYS (IF ANY) (1) IN ',EnvO.SpaceList(n).Name])
                                        propagateRayset(EnvO.SpaceList(n),varargin{:}); %This prompts the space to draw the rays as they are traced
                                    else
            %                             disp(['AND PROPAGATING ANY RAYS (IF ANY) (2) IN ',EnvO.SpaceList(n).Name])
                                        propagateRayset(EnvO.SpaceList(n));
                                    end
                                end
                                %go through all the surfaces and interact the rays - this puts rays back into spaces, if any rays make it back to spaces    
            %                     disp('ENVIRONMENT IS GOING THROUGH ALL SURFACES')
                                for n=1:length(EnvO.SurfaceList)
            %                         disp(['SURFACE ',EnvO.SurfaceList(n).Name,' INTERACTING ANY RAYS (IF ANY)'])
                                    interactRays(EnvO.SurfaceList(n));
            %                         disp(['CHECK --- ',EnvO.SurfaceList(n).Name,' hasrays: ',num2str(EnvO.SurfaceList(n).hasrays)]);
            %                         disp(['      --- and has ',num2str(EnvO.SurfaceList(n).IncidentRaysetA.NumRays),' on side A.']);
            %                         disp(['      --- and has ',num2str(EnvO.SurfaceList(n).IncidentRaysetB.NumRays),' on side B.']);
                                end
                                %go through all the detectors and interact the rays - this puts rays back into spaces, if any rays make it back to spaces    
                                for n=1:length(EnvO.DetectorList)
            %                         disp('DETECTOR ',EnvO.DetectorList(n).Name,' INTERACTING ANY RAYS (IF ANY)')
                                    interactRays(EnvO.DetectorList(n));
                                end
                                %check the spaces now to see if there are rays
            %                     disp('CHECKING THE SPACES FOR RAYS')
                                stillhasrays=false;
                                for n=1:length(EnvO.SpaceList)
                                    stillhasrays=EnvO.SpaceList(n).hasRays;
                                    if stillhasrays, break; end
                                end
                            end
                        end 
                if thislevel        
                    delete(hd); %hd is just a little box that stays open until the raytracing finishes, then this line gets rid of it.
                    guidata(EnvO.EnvFig,[])
                end
        end
        
        function startautozoom(EnvO) %this function gives the GUI for the user to enter the parameters for automating zooms, which parameters get passed right onto the function moveraysthrough
            numzoomvars=length(EnvO.EnvZoomVars);
            if numzoomvars<1, errordlg('You don''t have any zooms to automate.'); return; end
            EnvZmStep={};
            if numzoomvars<6
                prompt=cell(1,numzoomvars);      prompt{1}= sprintf('On each line, enter how many steps you want the automated zoom to take for each Environment Zoom variable.  A value of 1 leaves the zoom unchanged \n\nStep # for Environment Zoom Var. 1');
                def=cell(1,numzoomvars);       def{1}='1';
                for n=2:numzoomvars %start from 2 since I wanted an explanation on the first string of prompt, then automated the rest.
                    prompt{n}=['Step # for Environment Zoom Var. ',num2str(n)];
                    def{n}='1';
                end
                dlg_title = 'Steps for each Env. Var.';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                for n=1:numzoomvars
                    userinput=str2double(answer{n});
                    if userinput>1
                        EnvZmStep=[EnvZmStep,{n,userinput}]; %#ok<AGROW>
                    end
                end
                moveraysthrough(EnvO,EnvZmStep{:})  %EnvZmStep allows zoom automation - the additional arguments are value pairs of the form: EnvZoomVar#, step#
            else
                prompt= {'Since you have many zoom variables in your environment, put the zoom variable numbers you want to auto-zoom on the first line. They are put there in order for your convenience, but you can remove the ones you don''t want to auto zoom.','On this line, enter how many steps you want to automatically step through corresponding to the zooms you listed on the first line.  Remember, a value less than 2 leaves the zoom unchanged.'};
                def={num2str(1:numzoomvars),num2str(ones(1,numzoomvars))};
                dlg_title = 'Steps for each Env. Var.';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                pairs=str2num(char(answer)); %#ok<ST2NM>
                for n=1:size(pairs,2)
                    if pairs(2,n)>1
                        EnvZmStep=[EnvZmStep,{pairs(1,n),pairs(2,n)}]; %#ok<AGROW>
                    end
                end
                moveraysthrough(EnvO,EnvZmStep{:})  %EnvZmStep allows zoom automation - the additional arguments are value pairs of the form: EnvZoomVar#, step#
            end
        end

        
        function clearItems(EnvO) % RayVisuals, Detectors, PowerMonitoring, CrashRemains, 
            fh=figure('MenuBar','none');
            tfset=true(4,1); %this keeps the states for the following checkmark boxes (in order starting with 'Ray visuals')
            uicontrol(fh,'Style','text','Units','normalized','Position',[.2,.8,.6,.1],'String','Select the items you want to clear from the system')
            chcks(1)=uicontrol(fh,'Style','check','Units','normalized','Position',[.2,.6,.6,.1],'String','Ray visuals');
            chcks(2)=uicontrol(fh,'Style','check','Units','normalized','Position',[.2,.5,.6,.1],'String','Detectors');
            chcks(3)=uicontrol(fh,'Style','check','Units','normalized','Position',[.2,.4,.6,.1],'String','Surface/space/environment absorption monitors');
            chcks(4)=uicontrol(fh,'Style','check','Units','normalized','Position',[.2,.3,.6,.1],'String','The remains from a crash');
            chcks(5)=uicontrol(fh,'Style','check','Units','normalized','Position',[.2,.7,.6,.1],'String','All','Callback',@(hobj,cd)trnffn(hobj,chcks));
            uicontrol(fh,'Style','pushbutton','Units','normalized','Position',[.2,.2,.6,.1],'String','Accept and close','Callback',@(hobj,cd)update_tfset(chcks,fh))
                function trnffn(hobj,chcks)
                    for nn=1:4, chcks(nn).Value=hobj.Value; end
                end
                function update_tfset(chcks,fh)
                    for nn=1:4, tfset(nn)=chcks(nn).Value; end
                    delete(fh)
                end
            uiwait(fh)
            %surfaces
            for n=1:length(EnvO.SurfaceList)
                if tfset(4)
                clearAllRays(EnvO.SurfaceList(n).IncidentRaysetA);
                clearAllRays(EnvO.SurfaceList(n).IncidentRaysetB);
                EnvO.SurfaceList(n).IncidentNormalsA=[];
                EnvO.SurfaceList(n).IncidentNormalsB=[];
                EnvO.SurfaceList(n).hasrays=false;
                end
                if tfset(3)
                EnvO.SurfaceList(n).AbsorbedPower=[];
                end
            end
            
            %detectors
            for n=1:length(EnvO.DetectorList)
                if tfset(4)
                clearAllRays(EnvO.DetectorList(n).IncidentRaysetA);
                clearAllRays(EnvO.DetectorList(n).IncidentRaysetB);
                EnvO.DetectorList(n).IncidentNormalsA=[];
                EnvO.DetectorList(n).IncidentNormalsB=[];
                EnvO.DetectorList(n).hasrays=false;
                end
                if tfset(3)
                EnvO.DetectorList(n).AbsorbedPower=[];
                end
                if tfset(2)
                EnvO.DetectorList(n).DetectedPositions=[];
                EnvO.DetectorList(n).DetectedPowers=[];
                EnvO.DetectorList(n).PhasePositions=[];
                EnvO.DetectorList(n).DetectedOpticalPathlengths=[];
                EnvO.DetectorList(n).DetectedWaveCountMod1=[];
                end
            end
            
            %sources - nothing
            
            %spaces
            for n=1:length(EnvO.SpaceList)
                if tfset(3)
                EnvO.SpaceList(n).VolumeAbsorbedPower=0;
                end
                if tfset(4)
                clearAllRays(EnvO.SpaceList(n).SpcRayset);
                EnvO.SpaceList(n).FromWhichSurfaces=[];
                EnvO.SpaceList(n).hasRays=false;
                end
            end
            
            %environment
            if tfset(3)
            EnvO.NonIntersectingRayset=RaysetO;
            EnvO.WeakRayLosses=0;
            EnvO.EdgyRayLosses=0;
            EnvO.NonIntersectingRayLosses=0;
            %environment dead space
            EnvO.EnvironmentDS.SpcRayset=RaysetO;
            end
            
            %Environment visual figure
            if tfset(1)
            delete(findobj(EnvO.EnvFig,'Tag','SpaceTrace'));
            end
            
        end
        
        function UpdateSurfZooms(EnvO,booleanUpdateVisual,UpdateOnlyforTheseEnvZoomVars)  %goes through all the zoomed objects in EnvO.ZoomedObjectsList and updates geometric solves AND views (if desired - see 2nd argument)
            % UpdateOnlyforTheseEnvZoomVars should be a numeric array
            UpdateOnlyforTheseEnvZoomVars=round(UpdateOnlyforTheseEnvZoomVars);
            if any([~isnumeric(UpdateOnlyforTheseEnvZoomVars),min(UpdateOnlyforTheseEnvZoomVars)<1,max(UpdateOnlyforTheseEnvZoomVars)>length(EnvO.EnvZoomVars)]), error('UpdateSurfZooms was given an incorrect 3rd parameter'); end
            
            for n=1:length(EnvO.ZoomedObjectsList) %go through the zoomed objects
                if isa(EnvO.ZoomedObjectsList{n},'SurfaceO') %check that it's a surface
                    if ~isempty(intersect(UpdateOnlyforTheseEnvZoomVars,usesEvnZooms(EnvO.ZoomedObjectsList{n}))) %if the surface uses any of the EnvZoomVars specified in UpdateOnlyforTheseEnvZoomVars
                        updateGeometricSolves(EnvO.ZoomedObjectsList{n}); %update the geometric solve of that surface
                        if booleanUpdateVisual
                            updateVisXYZpts(EnvO.ZoomedObjectsList{n});%Use the SurfaceO updateVisXYZpts function to update the visual surface by rotating or translating it 
                            UpdateSurfView(EnvO,EnvO.ZoomedObjectsList{n}); %now get the rendering updated in the environment window
                        end
                    end
                end
            end
        end
        
        
        
        function UpdateSurfView(EnvO,varargin) %varargin are SurfaceO or DetectorO objects to be redrawn.  If they are not specified, all are redrawn
            %TheSurfaceO objects should already have
            %updated SurfaceXYZForVisual and VisColorData properties.
            if isempty(varargin) %if varargin is emtpy, update views for all surfaces and detectors
                for n=1:length(EnvO.SurfaceList)
                    EnvO.SurfaceList(n).SurfVisHndl.XData=EnvO.SurfaceList(n).SurfaceXYZForVisual{1};
                    EnvO.SurfaceList(n).SurfVisHndl.YData=EnvO.SurfaceList(n).SurfaceXYZForVisual{2};
                    EnvO.SurfaceList(n).SurfVisHndl.ZData=EnvO.SurfaceList(n).SurfaceXYZForVisual{3};
                    EnvO.SurfaceList(n).SurfVisHndl.CData=EnvO.SurfaceList(n).VisColorData{1};
                end
                for n=1:length(EnvO.DetectorList)
                    EnvO.DetectorList(n).SurfVisHndl.XData=EnvO.DetectorList(n).SurfaceXYZForVisual{1};
                    EnvO.DetectorList(n).SurfVisHndl.YData=EnvO.DetectorList(n).SurfaceXYZForVisual{2};
                    EnvO.DetectorList(n).SurfVisHndl.ZData=EnvO.DetectorList(n).SurfaceXYZForVisual{3};
                    EnvO.DetectorList(n).SurfVisHndl.CData=EnvO.DetectorList(n).VisColorData{1};
                end
            else %otherwise just update the view for just the surfaces/detectors specified
                for n=1:length(varargin)
                    if isa(varargin{n},'SurfaceO')
                        varargin{n}.SurfVisHndl.XData=varargin{n}.SurfaceXYZForVisual{1};
                        varargin{n}.SurfVisHndl.YData=varargin{n}.SurfaceXYZForVisual{2};
                        varargin{n}.SurfVisHndl.ZData=varargin{n}.SurfaceXYZForVisual{3};
                        varargin{n}.SurfVisHndl.CData=varargin{n}.VisColorData;
                    end
                end
            end
        end
        
        
        function removeWeakRays(EnvO,RaysO) %used in SpaceO and SurfaceO whenever rays are added to either
            Indices=RaysO.RayPowers<EnvO.WeakRayThreshold;
            EnvO.WeakRayLosses= EnvO.WeakRayLosses+sum(RaysO.RayPowers(Indices));
            removeRays(RaysO,Indices);
        end
        
        function removeTheseEdgyRays(EnvO,RaysO,Indices)
            EnvO.EdgyRayLosses=EnvO.EdgyRayLosses+sum(RaysO.RayPowers(Indices));
            removeRays(RaysO,Indices);
        end
        
        function accountNonIntersectingRays(EnvO,RaysO,Indices)
            EnvO.NonIntersectingRayLosses=EnvO.NonIntersectingRayLosses+sum(RaysO.RayPowers(Indices));
            joinRaysetsAndSaveInFirst(EnvO.NonIntersectingRayset,makeSubRayset(RaysO,Indices));
        end
        
        
        function success = checkName_and_Space_surfediting(EnvO,SurfO,repeatcheck) %this just runs a few checks when you add or edit a surface
            success=false;
            %Check and ensure the surface name is unique among the surfaces and detectors present in the environment before adding this surface to the lists
            repeat=true;
            while repeat
                repeat=false;
                for ncn=1:length(EnvO.SurfaceList)
                    if strcmp(SurfO.Name,EnvO.SurfaceList(ncn).Name)
                        if repeatcheck && SurfO==EnvO.SurfaceList(ncn), errordlg('Adding the same surface multiple times is not allowed.'); return; end
                        if SurfO~=EnvO.SurfaceList(ncn), SurfO.Name=[SurfO.Name,'|+']; repeat=true; end  %alter the name matches that of another surface
                    end
                end
                for ncn=1:length(EnvO.DetectorList)
                    if strcmp(SurfO.Name,EnvO.DetectorList(ncn).Name)
                        if repeatcheck && SurfO==EnvO.DetectorList(ncn), errordlg('Adding the same detector multiple times is not allowed.'); return; end 
                        if SurfO~=EnvO.DetectorList(ncn), SurfO.Name=[SurfO.Name,'|+']; repeat=true; end  %alter the name matches that of another detector
                    end
                end
            end
            
            %add this surface to the surface list of SpaceA, if SpaceA doesn't already have it listed
            if ~isa(SurfO.SpaceA,'DeadSpaceO') && ~isempty(SurfO.SpaceA)
                addsurface=true;
                for np=1:length(SurfO.SpaceA.Surfaces)
                    if strcmp(SurfO.SpaceA.Surfaces{np}.Name,SurfO.Name), addsurface=false; break; end
                end
                if addsurface
                    SurfO.SpaceA.Surfaces{length(SurfO.SpaceA.Surfaces)+1}=SurfO;
                end
            end
            %add this surface to the surface list of SpaceB, if SpaceB doesn't already have it listed
            if ~isa(SurfO.SpaceB,'DeadSpaceO') && ~isempty(SurfO.SpaceB)
                addsurface=true;
                for np=1:length(SurfO.SpaceB.Surfaces)
                    if strcmp(SurfO.SpaceB.Surfaces{np}.Name,SurfO.Name), addsurface=false; break; end
                end
                if addsurface
                    SurfO.SpaceB.Surfaces{length(SurfO.SpaceB.Surfaces)+1}=SurfO;
                end
            end
            success=true;
        end
        
        
        function addSurfaceO(EnvO,varargin) %can accept one or more args, the additional args being SurfaceO objects
            if nargin==1 %If only EnvO was given as an argument then use the surface editor to make a new surface
                addSO=SurfaceO(); addSO.isPerfectAbsorber=true; addSO.Environment=EnvO;
                addSurfaceO(EnvO,EditSurfMain(addSO));
            else
                for n=1:length(varargin) %if other surfaces were included, then simply add the surfaces to the list in EnvO
                    %check that it is the correct type of object - terminate if not
                    if ~isa(varargin{n},'SurfaceO'), errordlg('addSurfaceO was given a non-SurfaceO argument. No surface added'); return; end
                    varargin{n}.Environment=EnvO;
                    
                    success=checkName_and_Space_surfediting(EnvO,varargin{n},true);
                    if ~success, return; end
                    
                    %now add this surface to the list
                    addtolists(EnvO,varargin{n});
                    %and take care of the visualization
                    if ~isempty(varargin{n}.SurfaceXYZForVisual) %if there is existing visualization data
                        startingvisibility='on';
                        if ~isempty(varargin{n}.SurfVisHndl) && strcmpi(varargin{n}.SurfVisHndl.Visible,'off'), startingvisibility='off'; end
                        %then render the surface and attach the right-click interactive surface opacity function 
                        varargin{n}.SurfVisHndl=surf(EnvO.EnvAxes,varargin{n}.SurfaceXYZForVisual{:},'CData',varargin{n}.VisColorData,'ButtonDownFcn',@(hobj,evd)interactiveSurfOpacity(EnvO.EnvFig,hobj),'Visible',startingvisibility);
                    else
                        varargin{n}.SurfVisHndl=surf(EnvO.EnvAxes,inf(2),inf(2),inf(2),'ButtonDownFcn',@(hobj,evd)interactiveSurfOpacity(EnvO.EnvFig,hobj));
                    end
                end
            end
        end
        
        
        
        function addDetectorO(EnvO,varargin) %can accept one or more args, the additional args being DetectorO objects
            if nargin==1 %If only EnvO was given as an argument then use the surface editor to make a new surface
                addDO=DetectorO(); addDO.isPerfectAbsorber=true;  addDO.Environment=EnvO;
                addDetectorO(EnvO,EditSurfMain(addDO));
            else
                for n=1:length(varargin) %if other surfaces were included, then simply add the surfaces to the list in EnvO
                    %check that it is the correct type of object - terminate if not
                    if ~isa(varargin{n},'DetectorO'), errordlg('addDetectorO was given a non-DetectorO argument. No detector added.'); return; end
                    varargin{n}.Environment=EnvO;
                    
                    success=checkName_and_Space_surfediting(EnvO,varargin{n},true);
                    if ~success, return; end
                    
                    %now add this detector to the list
                    addtolists(EnvO,varargin{n});
                    %and take care of the visualization
                    if ~isempty(varargin{n}.SurfaceXYZForVisual)
                        startingvisibility='on';
                        if ~isempty(varargin{n}.SurfVisHndl) && strcmpi(varargin{n}.SurfVisHndl.Visible,'off'), startingvisibility='off'; end
                        %this is where the surface opacity or alpha value is altered in the gui
                        varargin{n}.SurfVisHndl=surf(EnvO.EnvAxes,varargin{n}.SurfaceXYZForVisual{:},'CData',varargin{n}.VisColorData,'ButtonDownFcn',@(hobj,evd)interactiveSurfOpacity(EnvO.EnvFig,hobj),'Visible',startingvisibility);
                    else
                        varargin{n}.SurfVisHndl=surf(EnvO.EnvAxes,inf(2),inf(2),inf(2),'ButtonDownFcn',@(hobj,evd)interactiveSurfOpacity(EnvO.EnvFig,hobj));
                    end
                end
            end
        end
        
        
        function addSourceO(EnvO,varargin)
            if nargin==1 %If only EnvO was given as an argument then use the surface editor to make a new surface
                AddScO=SourceO();AddScO.Environment=EnvO;
                addSourceO(EnvO,EditSourceMain(AddScO));
            else
                for n=1:length(varargin) %if other surfaces were included, then simply add the surfaces to the list in EnvO
                    if ~isa(varargin{n},'SourceO'), errordlg('addSourceO was given a non-SourceO argument. No source added'); return; end
                    varargin{n}.Environment=EnvO;
                    
                    %Check and ensure the name is unique among the sources present in the environment before adding this source to the lists 
                    repeat=true;
                    while repeat
                        repeat=false;
                        for ncn=1:length(EnvO.SourceList)
                            if strcmp(varargin{n}.Name,EnvO.SourceList(ncn).Name)
                                if varargin{n}==EnvO.SourceList(ncn), errordlg('Adding the same source multiple times is not allowed.'); return; end
                                varargin{n}.Name=[varargin{n}.Name,'|+']; repeat=true; %alter the name if there is a match
                            end  
                        end
                    end
                    
                    %add the source to the environment
                    addtolists(EnvO,varargin{n});
                    
                    %visualize the source
                    if all([varargin{n}.isVisualized,~isempty(varargin{n}.RayStartingPoints),any([~isempty(varargin{n}.PointSourceLocations),~isempty(varargin{n}.CollimatedSourceCosines)])]) %if you have sufficient parameters in the SourceO object to do a visualization, then do so
                        linstl='-';
                        if ~varargin{n}.enabled, linstl=':'; end
                        visualizeRays(varargin{n},EnvO.EnvAxes,'LineStyle',linstl)
                    end
                end
            end
        end
        
        
        function addSpaceO(EnvO,varargin)
            if nargin==1 %If only EnvO was given as an argument then use the surface editor to make a new surface
                AddSpO=SpaceO(); AddSpO.Environment=EnvO;
                addSpaceO(EnvO,EditSpaceMain(AddSpO));
            else
                for n=1:length(varargin) %if other surfaces were included, then simply add the surfaces to the list in EnvO
                    if ~isa(varargin{n},'SpaceO'), errordlg('addSpaceO was given a non-SpaceO argument. No space added'); return; end
                    varargin{n}.Environment=EnvO;
                    
                    %Check and ensure the name is unique among the sources present in the environment before adding this source to the lists 
                    repeat=true;
                    while repeat
                        repeat=false;
                        for ncn=1:length(EnvO.SpaceList)
                            if strcmp(varargin{n}.Name,EnvO.SpaceList(ncn).Name) 
                                if varargin{n}==EnvO.SpaceList(ncn), errordlg('Adding the same space multiple times is not allowed.'); return; end
                                varargin{n}.Name=[varargin{n}.Name,'|+']; repeat=true; %alter the name if there is a match
                            end
                        end
                    end
                    
                    %add the source to the environment\
                    addtolists(EnvO,varargin{n});
                end
            end
        end
        
        
        
        function editsurfCB(EnvO,SurfObj,TTBr)
            EditSurfMain(SurfObj); %open the surface editing gui
            UpdateSurfView(EnvO,SurfObj); %update the view, regardless of if it actually changed or not
            %determine if the updated surface has changed its zoom status, and if so, update the EnvO.ZoomedObjectsList 
            isonZoomedObjectsList=false; whichn=[];
            for n=1:length(EnvO.ZoomedObjectsList)
                if EnvO.ZoomedObjectsList{n}==SurfObj, isonZoomedObjectsList=true; whichn=n; break; end
            end
            if xor(~isempty(SurfObj.RotationAndTranslationZoomsCellArray),isonZoomedObjectsList) %if the zoom status has changed
                if isempty(whichn), EnvO.ZoomedObjectsList=[EnvO.ZoomedObjectsList,{SurfObj}]; else EnvO.ZoomedObjectsList(whichn)=[]; end   %then take it on or off the environment ZoomedObjectsList
            end
            checkName_and_Space_surfediting(EnvO,SurfObj,false);
            if ~strcmp(TTBr.String,SurfObj.Name) %update the name if the name changes
                TTBr.String=SurfObj.Name;
                drawTextTreeBox(EnvO.EnvTTBo);
            end
        end
        
        function editsourceCB(EnvO,SrcObj,TTBr)
            EditSourceMain(SrcObj); %open the source editing gui
            if ~strcmp(TTBr.String,SrcObj.Name) %update the name if the name changes
                TTBr.String=SrcObj.Name;
                drawTextTreeBox(EnvO.EnvTTBo);
            end
            %visualize the source according to its updated settings
            if all([SrcObj.isVisualized,~isempty(SrcObj.RayStartingPoints),any([~isempty(SrcObj.PointSourceLocations),~isempty(SrcObj.CollimatedSourceCosines)])]) %if you have sufficient parameters in the SourceO object to do a visualization, then do so
                linstl='-';
                if ~SrcObj.enabled, linstl=':'; end
                visualizeRays(SrcObj,EnvO.EnvAxes,'LineStyle',linstl)
            else
                delete(SrcObj.Plot3Displayhandle); SrcObj.Plot3Displayhandle=plot3(EnvO.EnvAxes,inf,inf,inf); %give SrcO.Plot3Displayhandle a valid handle, but one that won't be visualized in the axes
            end
        end
        
        function editspaceCB(EnvO,SpcObj,TTBr)
            EditSpaceMain(SpcObj); %open the space editing gui
            if ~strcmp(TTBr.String,SpcObj.Name) %update the name if the name changes
                TTBr.String=SpcObj.Name;
                drawTextTreeBox(EnvO.EnvTTBo);
            end
        end
        
        
        
        
        
        function DeleteROobj(EnvO,ObjO,TTBr)
            if strcmpi('yes',questdlg('Are you sure you want to delete this?'))
                EnvO.SpaceList(ObjO==EnvO.SpaceList) =[];
                EnvO.SurfaceList(ObjO==EnvO.SurfaceList) =[];
                EnvO.SourceList(ObjO==EnvO.SourceList) =[];
                EnvO.DetectorList(ObjO==EnvO.DetectorList) =[];
                for n=1:length(EnvO.ZoomedObjectsList)
                    if EnvO.ZoomedObjectsList{n}==ObjO, EnvO.ZoomedObjectsList(n)=[]; end
                end
                if isa(ObjO,'SurfaceO')
                    if ~isempty(ObjO.SurfVisHndl)
                        delete(ObjO.SurfVisHndl); %get rid of the shared handles (the figure shares this one with ObjO)
                    end
                    %go through the spaces
                    for n=1:length(EnvO.SpaceList)
                        m=1;
                        while ~(m>length(EnvO.SpaceList(n).Surfaces))
                            %remove this surface from the spaces that have this surface 
                            if EnvO.SpaceList(n).Surfaces{m}==ObjO,      EnvO.SpaceList(n).Surfaces(m)=[];    else m=m+1; end
                        end
                    end
                end
                
                if isa(ObjO,'SpaceO')
                    %then remove this space from sources, detectors and surfaces that use this space 
                    for n=1:length(EnvO.SurfaceList)
                        %remove this space from the surfaces that were associated with this space 
                        if EnvO.SurfaceList(n).SpaceA==ObjO, EnvO.SurfaceList(n).SpaceA=[]; end
                        if EnvO.SurfaceList(n).SpaceB==ObjO, EnvO.SurfaceList(n).SpaceB=[]; end
                    end
                    for n=1:length(EnvO.DetectorList)
                        %remove this space from the detectors that were associated with this space 
                        if EnvO.DetectorList(n).SpaceA==ObjO, EnvO.DetectorList(n).SpaceA=[]; end
                        if EnvO.DetectorList(n).SpaceB==ObjO, EnvO.DetectorList(n).SpaceB=[]; end
                    end
                    for n=1:length(EnvO.SourceList)
                        %remove this space from the sources that were in this space
                        if EnvO.SourceList(n).StartSpace==ObjO, EnvO.SourceList(n).StartSpace=[]; end
                    end
                end
                
                if isa(ObjO,'SourceO'), delete(ObjO.Plot3Displayhandle); end %remove any shared handles (the figure shares this one with ObjO)
                delete(ObjO);
                parentTTBr=TTBr.CellArrayOfAllImmediateParents{1};
                removeChildrenBranches(parentTTBr,{TTBr});
                UpdateAllCurrents(EnvO.EnvTTBo);
                drawTextTreeBox(EnvO.EnvTTBo);
            end
        end
        
        function addtolists(EnvO,ObjO) %this is where the TextTreeBranch checked/unchecked and selected/deselected callbacks are assigned as event listeners
            newTTBr=TextTreeBranch(ObjO.Name); newTTBr.RepresentedObjectHndl=ObjO;
            addTTBrEventListeners(EnvO,newTTBr);
            newTTBr.UIContextMenu=uicontextmenu(EnvO.EnvTTBo.ParentFigure);
            
            switch class(ObjO)
                case 'SurfaceO'
                    EnvO.SurfaceList=[EnvO.SurfaceList,ObjO];
                    parentTTBr=findobj([EnvO.EnvTTBo.PrimaryBranchesCellArray{:}],'String','Surfaces');
                    uimenu(newTTBr.UIContextMenu,'Label','Edit SurfaceO','Callback',@(TTBr,evd)editsurfCB(EnvO,ObjO,newTTBr));
                    uimenu(newTTBr.UIContextMenu,'Label','Remove SurfaceO','Callback',@(TTBr,evd)DeleteROobj(EnvO,ObjO,newTTBr));                    
                    if ~isempty(usesEvnZooms(ObjO)), EnvO.ZoomedObjectsList=[EnvO.ZoomedObjectsList,{ObjO}]; end
                    if ~isempty(ObjO.SurfVisHndl) && strcmpi(ObjO.SurfVisHndl.Visible,'off'), newTTBr.isChecked=false; end 
                case 'DetectorO'
                    EnvO.DetectorList=[EnvO.DetectorList,ObjO];
                    parentTTBr=findobj([EnvO.EnvTTBo.PrimaryBranchesCellArray{:}],'String','Detectors');
                    uimenu(newTTBr.UIContextMenu,'Label','Edit DetectorO','Callback',@(hobj,evd)editsurfCB(EnvO,ObjO,newTTBr));
                    uimenu(newTTBr.UIContextMenu,'Label','View detected rays','Callback',@(hobj,evd)ViewDetectedPower(ObjO));
                    uimenu(newTTBr.UIContextMenu,'Label','Remove DetectorO','Callback',@(TTBr,evd)DeleteROobj(EnvO,ObjO,newTTBr));
                    if ~isempty(usesEvnZooms(ObjO)), EnvO.ZoomedObjectsList=[EnvO.ZoomedObjectsList,{ObjO}]; end
                    if ~isempty(ObjO.SurfVisHndl) && strcmpi(ObjO.SurfVisHndl.Visible,'off'), newTTBr.isChecked=false; end 
                case 'SourceO'
                    EnvO.SourceList=[EnvO.SourceList,ObjO];
                    parentTTBr=findobj([EnvO.EnvTTBo.PrimaryBranchesCellArray{:}],'String','Sources');
                    uimenu(newTTBr.UIContextMenu,'Label','Edit SourceO','Callback',@(TTBr,evd)editsourceCB(EnvO,ObjO,newTTBr));
                    uimenu(newTTBr.UIContextMenu,'Label','Remove SourceO','Callback',@(TTBr,evd)DeleteROobj(EnvO,ObjO,newTTBr));
                    if ~ObjO.enabled, newTTBr.isChecked=false; end
                case 'SpaceO'
                    EnvO.SpaceList=[EnvO.SpaceList,ObjO];
                    parentTTBr=findobj([EnvO.EnvTTBo.PrimaryBranchesCellArray{:}],'String','Spaces');
                    uimenu(newTTBr.UIContextMenu,'Label','Edit SpaceO','Callback',@(TTBr,evd)editspaceCB(EnvO,ObjO,newTTBr));
                    uimenu(newTTBr.UIContextMenu,'Label','Remove SpaceO','Callback',@(TTBr,evd)DeleteROobj(EnvO,ObjO,newTTBr));
                otherwise
                    error('Error adding branch to the environment TTBox');
            end
            addChildrenBranches(parentTTBr,{newTTBr});
            UpdateAllCurrents(EnvO.EnvTTBo);
            drawTextTreeBox(EnvO.EnvTTBo);
            
        end
        

            
        
        %VERY IMPORTANT: This function is responsible for restoring event listeners when a system is loaded from a saved file 
        function addTTBrEventListeners(EnvO,varargin) %varargin is all the TextTreeBranch objects to add listeners to.  If it is empty, the function uses EnvO.EnvTTBo to find the TextTreeBranches
            if isempty(varargin)
                Branches={};
                for n=1:length(EnvO.EnvTTBo.PrimaryBranchesCellArray)
                    Branches=[Branches,EnvO.EnvTTBo.PrimaryBranchesCellArray{n}.ChildrenBranches]; %#ok<AGROW>
                end
            else
                Branches=varargin;
            end
            for n=1:length(Branches)
                switch class(Branches{n}.RepresentedObjectHndl)
                    case {'SurfaceO','DetectorO'}
                        addlistener(Branches{n},'gotSelected',@(hobj,evd)highltsurf(hobj,[.7,.7,1]));     addlistener(Branches{n},'gotDeselected',@(hobj,evd)highltsurf(hobj,[0,0,0]));
                        addlistener(Branches{n},'gotChecked',@(hobj,evd)showsrf(hobj,'yes'));     addlistener(Branches{n},'gotUnchecked',@(hobj,evd)showsrf(hobj,'no'));
                    case 'SourceO'
                        addlistener(Branches{n},'gotSelected',@(hobj,evd)highltsrc(hobj,'.'));      addlistener(Branches{n},'gotDeselected',@(hobj,evd)highltsrc(hobj,'none'));
                        addlistener(Branches{n},'gotChecked',@(hobj,evd)allowsrc(hobj,true));      addlistener(Branches{n},'gotUnchecked',@(hobj,evd)allowsrc(hobj,false));
                    case 'SpaceO'
                    otherwise
                        error('Error adding listeners to the environment branches');
                end
            end
            %these are the functions for the interactive checkboxes and
            %highlight controls in the TextTreeBox - makes the surfaces
            %and sources get highlighted or disappear
                    function highltsurf(TTBr,colr)
                        TTBr.RepresentedObjectHndl.SurfVisHndl.EdgeColor=colr;
                    end
                    
                    function showsrf(TTBr,yesno)
                        if strcmpi(yesno,'yes'), TTBr.RepresentedObjectHndl.SurfVisHndl.Visible='on'; else TTBr.RepresentedObjectHndl.SurfVisHndl.Visible='off'; end
                    end
                    
                    function highltsrc(TTBr,MarkerType)
                        if TTBr.RepresentedObjectHndl.isVisualized
                            for n1=1:length(TTBr.RepresentedObjectHndl.Plot3Displayhandle), TTBr.RepresentedObjectHndl.Plot3Displayhandle(n1).Marker=MarkerType;  TTBr.RepresentedObjectHndl.Plot3Displayhandle(n1).MarkerSize=23; end
                        end
                    end
                    
                    function allowsrc(TTBr,enable)
                        if enable,
                            if TTBr.RepresentedObjectHndl.isVisualized
                                for n1=1:length(TTBr.RepresentedObjectHndl.Plot3Displayhandle), TTBr.RepresentedObjectHndl.Plot3Displayhandle(n1).LineStyle='-'; end
                            end
                            TTBr.RepresentedObjectHndl.enabled=true;
                        else
                            if TTBr.RepresentedObjectHndl.isVisualized
                                for n1=1:length(TTBr.RepresentedObjectHndl.Plot3Displayhandle), TTBr.RepresentedObjectHndl.Plot3Displayhandle(n1).LineStyle=':'; end
                            end
                            TTBr.RepresentedObjectHndl.enabled=false;
                        end
                    end
        end
        
        
        function EnvOdupl=duplicate(EnvO) 
            EnvOdupl=EnvironmentO();
            EnvOdupl.EnvZoomVars=                   EnvO.EnvZoomVars;
            EnvOdupl.CurrentZoomColorChoice=        EnvO.CurrentZoomColorChoice;
            EnvOdupl.ZoomColors=                    EnvO.ZoomColors;
            EnvOdupl.EnvTTBo=                       EnvO.EnvTTBo;
            EnvOdupl.Unit=                          EnvO.Unit;
            EnvOdupl.WeakRayThreshold=              EnvO.WeakRayThreshold;
            EnvOdupl.PowerFromSources=              EnvO.PowerFromSources;
            EnvOdupl.MinDistanceForReintersect=     EnvO.MinDistanceForReintersect;
            EnvOdupl.MinDistanceForNonEdgyIntersect=EnvO.MinDistanceForNonEdgyIntersect;
            EnvOdupl.WeakRayLosses=                 EnvO.WeakRayLosses;
            EnvOdupl.EdgyRayLosses=                 EnvO.EdgyRayLosses;
            EnvOdupl.NonIntersectingRayLosses=      EnvO.NonIntersectingRayLosses;
        end
        
        
        function reloadEnvO(EnvO)
            if strcmpi(questdlg('Are you sure you want to reload the system?  The reloaded system should be a reinstated copy of the current one. This is useful to update an older saved system to a newer version of the code.  Sometimes this helps clear up memory.'),'yes')
                newEnvO=startRaytraceO(duplicate(EnvO));
                
                for n=1:length(EnvO.SurfaceList)
                    addSurfaceO(newEnvO,EnvO.SurfaceList(n));
                end
                
                for n=1:length(EnvO.DetectorList)
                    addDetectorO(newEnvO,EnvO.DetectorList(n));
                end
                
                for n=1:length(EnvO.SourceList)
                    addSourceO(newEnvO,EnvO.SourceList(n));
                end
                
                for n=1:length(EnvO.SpaceList)
                    addSpaceO(newEnvO,EnvO.SpaceList(n));
                end
                
                if ~isempty(newEnvO.EnvZoomVars)
                    newEnvO.ZoomAdjButtongroup.Visible='on';
                end
                %remove EnvO??
                    delete(EnvO.EnvFig);
                    delete(EnvO.EnvTTBo.ParentFigure);
                    delete(EnvO);
            end
            
        end
        
        
    end
    
    events
        emptied
    end
end