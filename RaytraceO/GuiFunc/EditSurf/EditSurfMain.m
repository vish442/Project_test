%EditSurfMain(EnvO,varargin)
%varargin is either empty or contains a SurfaceO

function SurfOorDetO_h=EditSurfMain(surf2edit) %surf2edit contains a SurfaceO that should already be associated with an environment

%main editing figure controls

SurfOorDetO_h=false;
fh=figure('MenuBar','none','Toolbar','none');
EnvO=surf2edit.Environment;

MainPan{1}=uipanel(fh,'Position',[.3,.05,.65,.9],'Title','Surface Name','Visible','on');
MainPan{2}=uipanel(fh,'Position',[.3,.05,.65,.9],'Title','Surface Geometry Settings','Visible','off');
MainPan{3}=uipanel(fh,'Position',[.3,.05,.65,.9],'Title','Surface Windowing (Limiting the surface extent)','Visible','off');
MainPan{4}=uipanel(fh,'Position',[.3,.05,.65,.9],'Title','Identifying the spaces that connect to this surface','Visible','off');
MainPan{5}=uipanel(fh,'Position',[.3,.05,.65,.9],'Title','Defining what occurs when a ray reaches the surface','Visible','off');
MainPan{6}=uipanel(fh,'Position',[.3,.05,.65,.9],'Title','Surface visualization (visual representation only)','Visible','off');
MainPan{7}=uipanel(fh,'Position',[.3,.05,.65,.9],'Title','Zooms: Allowing the surface to shift/rotate','Visible','off');
uicontrol(fh,'Units','Normalized', 'Position', [.05,.85,.2,.07],'String','Name','Callback',@(hobj,cbd)makePanelCurrent(MainPan,1))
uicontrol(fh,'Units','Normalized', 'Position', [.05,.78,.2,.07],'String','Geometry','Callback',@(hobj,cbd)makePanelCurrent(MainPan,2))
uicontrol(fh,'Units','Normalized', 'Position', [.05,.71,.2,.07],'String','Windows','Callback',@(hobj,cbd)makePanelCurrent(MainPan,3))
uicontrol(fh,'Units','Normalized', 'Position', [.05,.64,.2,.07],'String','Spaces','Callback',@(hobj,cbd)makePanelCurrent(MainPan,4))
uicontrol(fh,'Units','Normalized', 'Position', [.05,.57,.2,.07],'String','Ray Interactions','Callback',@(hobj,cbd)makePanelCurrent(MainPan,5))
uicontrol(fh,'Units','Normalized', 'Position', [.05,.5,.2,.07],'String','Visualization','Callback',@(hobj,cbd)makePanelCurrent(MainPan,6))
uicontrol(fh,'Units','Normalized', 'Position', [.05,.43,.2,.07],'String','Zooms','Callback',@(hobj,cbd)makePanelCurrent(MainPan,7))
uicontrol(fh,'Units','Normalized', 'Position', [.05,.15,.2,.07],'String','Close','Callback',@(hobj,cbd)closeoutSurfGui())


%name controls
uicontrol(MainPan{1},'Style','text','Units','normalized','Position',[.1,.74,.5,.06],'String','Choose a name for this surface');
uicontrol(MainPan{1},'Style','Edit','Units','normalized','Tag','namebox','Position',[.1,.7,.5,.06]);

%GeoPan controls
GeoSub1=uipanel(MainPan{2},'Position',[.01,.01,.98,.9],'Title','Surface Intersect Solve','Visible','on','TitlePosition','centertop');
GeoSub2=uipanel(MainPan{2},'Position',[.01,.01,.98,.9],'Title','Surface Normal Solve','Visible','off','TitlePosition','centertop');
uicontrol(MainPan{2},'Units','Normalized', 'Position', [.05,.91,.4,.06],'String','Intersect Solve','Callback',@(hobj,cbd)makePanelCurrent({GeoSub1,GeoSub2},1),'TooltipString',sprintf('Every surface needs an intersect-solve function of the form\n [IntersectPointsNx3]= IntrsctSlvFcn (RayPositionsNx3, RayDirectionsNx3, WindowingFcnHndl, AddtnlGeomtryParams...)'));
uicontrol(MainPan{2},'Units','Normalized', 'Position', [.55,.91,.4,.06],'String','Normal Solve','Callback',@(hobj,cbd)makePanelCurrent({GeoSub1,GeoSub2},2),'TooltipString','Every surface needs a normal-solve function of the form [SurfNormalDirectns]= NormSlvFcn (SurfacePositionsNx3, AddtnlGeomtryParams...)');
%GeoSub1 controls
%get the pixel height of GeoSub1
GeoSub1.Units='pixels'; GeoSub1.UserData=GeoSub1.Position(4); GeoSub1.Units='normalized';ioldh=GeoSub1.UserData;
%make the uicontrols
uicontrol(GeoSub1,'Style','Text','Position',[36,ioldh-56,280,16],'HorizontalAlignment','left','String','Name of intersect solve function for this surface');
ilev1e=uicontrol(GeoSub1,'Style','Edit','Position',[36,ioldh-72,280,19],'HorizontalAlignment','left','String','Put your function name here (leave off .m extension)');
ipb=uicontrol(GeoSub1,'Style','pushbutton','Position',[18,ioldh-93,15,15],'String','+','UserData',0);
imb=uicontrol(GeoSub1,'Style','pushbutton','Position',[18,ioldh-68,15,15],'Visible','off','String','--','Callback',@(hobj,evd)minlev(GeoSub1,ipb.UserData,34,ipb,hobj,'i'));
ipb.Callback=@(hobj,evd)addlev(GeoSub1,hobj.UserData,34,hobj,imb,'i');
uicontrol(GeoSub1,'Style','Text','Position',[36,ioldh-93,280,15],'String','Add a geometric parameter','HorizontalAlignment','left')
GeoSub1.SizeChangedFcn=@(hobj,evd)knncatt(hobj);
%GeoSub2 controls
%get the pixel height of GeoSub2
GeoSub2.Units='pixels'; GeoSub2.UserData=GeoSub2.Position(4); GeoSub2.Units='normalized';noldh=GeoSub2.UserData;
%make the uicontrols
uicontrol(GeoSub2,'Style','Text','Position',[36,noldh-56,280,16],'HorizontalAlignment','left','String','Name of intersect solve function for this surface');
nlev1e=uicontrol(GeoSub2,'Style','Edit','Position',[36,noldh-72,280,19],'HorizontalAlignment','left','String','Put your function name here (leave off .m extension)');
npb=uicontrol(GeoSub2,'Style','pushbutton','Position',[18,noldh-93,15,15],'String','+','UserData',0);
nmb=uicontrol(GeoSub2,'Style','pushbutton','Position',[18,noldh-68,15,15],'Visible','off','String','--','Callback',@(hobj,evd)minlev(GeoSub2,npb.UserData,34,npb,hobj,'n'));
npb.Callback=@(hobj,evd)addlev(GeoSub2,hobj.UserData,34,hobj,nmb,'n');
uicontrol(GeoSub2,'Style','Text','Position',[36,noldh-93,280,15],'String','Add a geometric parameter','HorizontalAlignment','left')
GeoSub2.SizeChangedFcn=@(hobj,evd)knncatt(hobj);
%GeoSub1 and GeoSub2 pushbuttons - do the same work
uicontrol(GeoSub2,'Style','pushbutton','Position',[36,noldh-37,140,25],'String','Use standard surface','Callback',@(hbj,evd)moduifor(ilev1e,nlev1e,GeoSub1,GeoSub2,ipb.UserData,npb.UserData,34,ipb,npb,imb,nmb))
uicontrol(GeoSub1,'Style','pushbutton','Position',[36,ioldh-37,140,25],'String','Use standard surface','Callback',@(hbj,evd)moduifor(ilev1e,nlev1e,GeoSub1,GeoSub2,ipb.UserData,npb.UserData,34,ipb,npb,imb,nmb))

%Windowing controls
MainPan{3}.Units='pixels'; MainPan{3}.UserData=MainPan{3}.Position(4); MainPan{3}.Units='normalized';Woldh=MainPan{3}.UserData;
MainPan{3}.SizeChangedFcn=@(hobj,evd)knncatt(hobj);
Wmb=uicontrol(MainPan{3},'Style','pushbutton','Position',[18,Woldh,15,15],'Visible','off','String','--');
Wpb=uicontrol(MainPan{3},'Style','pushbutton','Position',[18,Woldh-65,15,15],'String','+','UserData',0,'Callback',@(hobj,evd)Waddlev(MainPan{3},hobj.UserData,65,hobj,Wmb));
Wmb.Callback=@(hobj,evd)Wminlev(MainPan{3},Wpb.UserData,65,Wpb,hobj);
%Space ID panel
uicontrol(MainPan{4},'Style','text','Units','normalized','Position',[.03,.7,.3,.05],'String','Space_A Name','HorizontalAlignment','right');
uicontrol(MainPan{4},'Style','edit','Tag','se1','Units','normalized','Position',[.35,.7,.4,.08],'HorizontalAlignment','left','TooltipString',sprintf('Identify the name given to one of the spaces for which this surface is partially or wholly a boundary.\nIf this is left blank, the environment deadspace will be applied.\nRays go to the deadspace to simply be collected.'));
uicontrol(MainPan{4},'Style','text','Units','normalized','Position',[.03,.6,.3,.05],'String','Space_B Name','HorizontalAlignment','right');
uicontrol(MainPan{4},'Style','edit','Tag','se2','Units','normalized','Position',[.35,.6,.4,.08],'HorizontalAlignment','left','TooltipString',sprintf('Identify the name given to the other space for which this surface is partially or wholly a boundary.\nNo surface operates between more than two spaces.  If you have a surface that requires you\n to break this rule, then create more surfaces or dummy surfaces in order to meet this requirement.\nIf this is left blank, the environment deadspace will be applied.\nRays go to the deadspace to simply be collected.'));

%Ray Interaction Controls
    %Detector gui
mp4d{1}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.63,.86,.37,.065],'String','Detection Function Name:','HorizontalAlignment','left');
mp4d{2}=uicontrol(MainPan{5},'Style','edit','Units','normalized','Position',[.63,.82,.32,.06],'String','leave off .m','HorizontalAlignment','left','TooltipString', sprintf('Only put the name here, but the function should follow the following format:\n [DetectedPositionsNx3, DetectedPowersNx1]= DetctrFcn (RaysetOobj, DetectorSurfaceNormalsForRayset,\n ... + any additional arguments for your function (if needed)).\nDetection of rays is completely passive. The incident rayset is not altered by detection alone.'));
mp4d{3}=uicontrol(MainPan{5},'Style','pushbutton','Units','normalized','Position',[.95,.82,.04,.06],'String','...','HorizontalAlignment','left','Callback',{@addparams});
mp4d{4}=uicontrol(MainPan{5},'Style','check','Units','normalized','Position',[.63,.77,.23,.04],'String','Track phases','HorizontalAlignment','left','Value',0,'TooltipString', sprintf('Exact ray positions along with their phase data\n will be recorded in the DetectorO object.'));
mp4d{5}=uicontrol(MainPan{5},'Style','check','Units','normalized','Position',[.63,.93,.3,.04],'String','Is a detector','HorizontalAlignment','left','Callback',[{@togglevis},mp4d(1:4)]);

    %complex surface interactions
mp4c{6}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.03,.65,.5,.04],'String','Absorption function name:','HorizontalAlignment','Right');
mp4c{7}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.03,.5,.5,.04],'String','Transmission function name:','HorizontalAlignment','Right');
mp4c{8}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.15,.35,.5,.04],'String','Forward scattering function name:','HorizontalAlignment','Right');
mp4c{9}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.03,.2,.5,.04],'String','Reflection function name:','HorizontalAlignment','Right');
mp4c{10}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.15,.05,.5,.04],'String','Backscattering function name:','HorizontalAlignment','Right');
mp4c{11}=uicontrol(MainPan{5},'Style','edit','Units','normalized','Position',[.53,.65,.3,.06],'String','leave off .m','HorizontalAlignment','left','TooltipString', sprintf('Only put the name here, but the function should follow the following format:\n [absorptionCoefficientsNx1]= AbsFunc (incidentRaysetOobj, incidentSurfaceNormalsNx3,\n ... + any additional arguments for your function (if needed))'));
mp4c{12}=uicontrol(MainPan{5},'Style','edit','Units','normalized','Position',[.53,.5,.3,.06],'String','leave off .m','HorizontalAlignment','left','TooltipString',sprintf('Only put the name here, but the function should follow the following format:\n [transmittedRayDirectionsNx3,transmissionCoefficientsNx1]= TransFunc... \n(incidentRaysetOobj, incidentSurfaceNormalsNx3, PendingRefractiveIndicesNx1,\n ... + any additional arguments for your function (if needed))'));
mp4c{13}=uicontrol(MainPan{5},'Style','edit','Units','normalized','Position',[.65,.35,.3,.06],'String','leave off .m','HorizontalAlignment','left','TooltipString',sprintf('Only put the name here, but the function should follow the following format:\n [fs_RaysetO]= FScatFunc (RefractedRaysetOobj, SurfaceNormalsNx3,\n ... + any additional arguments for your function (if needed))'));
mp4c{14}=uicontrol(MainPan{5},'Style','edit','Units','normalized','Position',[.53,.2,.3,.06],'String','leave off .m','HorizontalAlignment','left','TooltipString',sprintf('Only put the name here, but the function should follow the following format:\n [reflectedRayDirectionsNx3,reflectionCoefficientsNx1]= ReflFunc... \n(incidentRaysetOobj, incidentSurfaceNormalsNx3, reflectOffOfIndicesNx1,\n ... + any additional arguments for your function (if needed))'));
mp4c{15}=uicontrol(MainPan{5},'Style','edit','Units','normalized','Position',[.65,.05,.3,.06],'String','leave off .m','HorizontalAlignment','left','TooltipString',sprintf('Only put the name here, but the function should follow the following format:\n [bs_RaysetO]= BScatFunc( ReflectedRaysetOobj, SurfaceNormalsNx3,\n ... + any additional arguments for your function (if needed))'));
mp4c{16}=uicontrol(MainPan{5},'Style','pushbutton','Units','normalized','Position',[.83,.65,.04,.06],'String','...','HorizontalAlignment','left','Callback',{@addparams});
mp4c{17}=uicontrol(MainPan{5},'Style','pushbutton','Units','normalized','Position',[.83,.5,.04,.06],'String','...','HorizontalAlignment','left','Callback',{@addparams});
mp4c{18}=uicontrol(MainPan{5},'Style','pushbutton','Units','normalized','Position',[.95,.35,.04,.06],'String','...','HorizontalAlignment','left','Callback',{@addparams});
mp4c{19}=uicontrol(MainPan{5},'Style','pushbutton','Units','normalized','Position',[.83,.2,.04,.06],'String','...','HorizontalAlignment','left','Callback',{@addparams});
mp4c{20}=uicontrol(MainPan{5},'Style','pushbutton','Units','normalized','Position',[.95,.05,.04,.06],'String','...','HorizontalAlignment','left','Callback',{@addparams});

mp4c{1}=uicontrol(MainPan{5},'Style','check','Units','normalized','Position',[.03,.7,.5,.04],'String','Has absorption','HorizontalAlignment','Right');
mp4c{3}=uicontrol(MainPan{5},'Style','check','Units','normalized','Position',[.15,.4,.5,.04],'String','Has forward scattering','HorizontalAlignment','Right');
mp4c{2}=uicontrol(MainPan{5},'Style','check','Units','normalized','Position',[.03,.55,.5,.04],'String','Has transmission','HorizontalAlignment','Right','Callback',[{@togglevis},mp4c([3,8,13,18])]);
mp4c{5}=uicontrol(MainPan{5},'Style','check','Units','normalized','Position',[.15,.1,.5,.04],'String','Has backscattering','HorizontalAlignment','Right');
mp4c{4}=uicontrol(MainPan{5},'Style','check','Units','normalized','Position',[.03,.25,.5,.04],'String','Has backreflection','HorizontalAlignment','Right','Callback',[{@togglevis},mp4c([5,10,15,20])]);

    %simple reflector
mp4r{1}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.1,.68,.3,.04],'String','Use this reflectance:','HorizontalAlignment','Right');
mp4r{2}=uicontrol(MainPan{5},'Style','text','Units','normalized','Position',[.1,.64,.3,.04],'String','(between 0 and 1)  ','HorizontalAlignment','Right');
mp4r{3}=uicontrol(MainPan{5},'Style','edit','Units','normalized','Position',[.43,.64,.07,.06],'HorizontalAlignment','Right');

    %top radiobutton controls on 
RIbg=uibuttongroup(MainPan{5},'Position',[.1,.8,.5,.15]);
toggleontoggleoff(1,1,[],[mp4r,mp4c,mp4d(1:4)]);
uicontrol(RIbg,'Style','Radiobutton','Units','normalized','Tag','PA','Position',[.1,.7,1,.3],'String','Perfect Absorber','Callback',{@toggleontoggleoff,[],[mp4r,mp4c]});
uicontrol(RIbg,'Style','Radiobutton','Units','normalized','Tag','SR','Position',[.1,.35,1,.3],'String','Simple Reflector','Callback',{@toggleontoggleoff,mp4r,mp4c});
uicontrol(RIbg,'Style','Radiobutton','Units','normalized','Tag','CS','Position',[.1,0,1,.3],'String','Complex Surface','Callback',{@toggleontoggleoff,mp4c([1,2,4,6,7,9,11,12,14,16,17,19]),mp4r});



%Visualizer
VisC{1}=uicontrol(MainPan{6},'Style','text','Units','normalized','Position',[.03,.83,.94,.15],'String','Instructions: 1)Make sure your surface has the intersect solve defined.  2)Pick an illumination point.  3)Pick an illumination symmetrical axis direction. 4)Initiate the visualizer.','HorizontalAlignment','Left');
VisC{2}=uicontrol(MainPan{6},'Style','text','Units','normalized','Position',[.03,.7,.3,.05],'String','Illumination point','HorizontalAlignment','right');
VisC{3}=uicontrol(MainPan{6},'Style','edit','Units','normalized','Position',[.35,.7,.4,.05],'HorizontalAlignment','left','TooltipString',sprintf('Rays are sent out in all directions from this point and will render the surface wherever they intersect the surface.\nA good choice for a sphere is the sphere center, for a paraboloid is the focus,\n for a cylinder is on the axis nearest the windowed surface, and for a plane is away from the plane\n somewhere around a distance of the span of the windowed surface.'));
VisC{4}=uicontrol(MainPan{6},'Style','text','Units','normalized','Position',[.03,.6,.3,.07],'String','Illumination axis of symmetry','HorizontalAlignment','right');
VisC{5}=uicontrol(MainPan{6},'Style','edit','Units','normalized','Position',[.35,.6,.4,.05],'HorizontalAlignment','left','TooltipString',sprintf('Rays are sent from the illumination point following a direction order using spherical coordinates.\nThis allows you to define what direction to put the axis of zenithAngle=0, or the axis of rotational symmetry for the illumination directions.'));
VisC{6}=uicontrol(MainPan{6},'Style','pushbutton','Units','normalized','Position',[.2,.3,.3,.15],'String','Initiate Visualizer','Callback',@(hobj,evd)CheckGeoWinAndBeginVislzr());
VisC{7}=uicontrol(MainPan{6},'Style','text','Units','normalized','Position',[.03,.1,.4,.1],'String','Specify a group name here, if you want the surface to be identified with other surfaces:','HorizontalAlignment','left');
VisC{8}=uicontrol(MainPan{6},'Style','edit','Units','normalized','Position',[.46,.12,.3,.06],'String','Group name','HorizontalAlignment','left','String','not utilized yet');


%Zooms
MainPan{7}.Units='pixels'; MainPan{7}.UserData=MainPan{7}.Position(4); MainPan{7}.Units='normalized';Zoldh=MainPan{7}.UserData;
MainPan{7}.SizeChangedFcn=@(hobj,evd)knncatt(hobj);
Zmb=uicontrol(MainPan{7},'Style','pushbutton','Position',[1,Zoldh,15,15],'Visible','off','String','--');
Zpb=uicontrol(MainPan{7},'Style','pushbutton','Position',[18,Zoldh-65,15,15],'String','+','UserData',0,'Callback',@(hobj,evd)Zaddlev(MainPan{7},hobj.UserData,65,hobj,Zmb,EnvO));
Zmb.Callback=@(hobj,evd)Zminlev(MainPan{7},Zpb.UserData,65,Zpb,hobj);


    if isempty(surf2edit.Name)
        if isa(surf2edit,'DetectorO'), surf2edit.Name='New Detector'; else surf2edit.Name='New Surface'; end
    end
    fh.NumberTitle='off'; fh.Name=surf2edit.Name;
%     surf2edit.Environment=EnvO; % this is probably not necessary to have
    %check that the 2nd argument is a surfaceO or detectorO
    if ~isa(surf2edit,'SurfaceO'), error('The second argument of EditSurfMain must be a SurfaceO or a DetectorO object'); end
    %check that the 2nd argument is a part of the environment
    loadsurface2gui(surf2edit)
    mp4d{5}.Enable='off';
    if isa(surf2edit,'DetectorO')
        mp4d{5}.Value=1;
        toggleontoggleoff(1,1,mp4d,[]);
    else
        mp4d{5}.Value=0;
        toggleontoggleoff(1,1,[],mp4d(1:4));
    end
        


uiwait(fh)

%%
%Save the parameters to the Surface object

    function passfail=savetosurf(SurfO)
passfail=0;
%save surface name
nmstr=strtrim(get(findobj(MainPan{1},'Tag','namebox'),'String'));
if isempty(nmstr), errordlg('The name entry box is empty. The surface still needs a name.'); return; end
SurfO.Name = nmstr;


%save Geometry stuff and Windows stuff
succeeded=saveSurfGeoWinsZooms(SurfO);
if ~succeeded, return; end
%%
%update space settings
SurfO.SpaceA=  findobj(EnvO.SpaceList,'Name',   strtrim(get(findobj(MainPan{4},'Tag','se1'),'String')) );
if isempty(SurfO.SpaceA),SurfO.SpaceA=EnvO.EnvironmentDS;end
SurfO.SpaceB=  findobj(EnvO.SpaceList,'Name',   strtrim(get(findobj(MainPan{4},'Tag','se2'),'String')) );
if isempty(SurfO.SpaceB),SurfO.SpaceB=EnvO.EnvironmentDS; end


%%
%Save ray interaction settings to the SurfO
if isa(SurfO,'DetectorO')
    if mp4d{5}.Value~=1
        error('your code is contradicting itself about whether the surface is a detector')
    end
    mp4d{2}.String=strtrim(mp4d{2}.String);
    if exist(mp4d{2}.String,'file')~=2 %check that the detection function is valid
        if exist(mp4d{2}.String,'builtin')==5
            warndlg('You might not want to use a standard matlab function for your detection function');
        else
            errordlg('You need to specify a detection solve that exists on the path','Bad Detection Function')
            return;
        end
    end
    %get any additional arguments
    addarg={};
    for n=1:size(mp4d{3}.String,1)
        addval=str2num(mp4d{3}.String(n,:)); %#ok<ST2NM>
        if ~isempty(addval)
            addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
        end
    end
    SurfO.DetectRaysFcn=str2func(['@(incRaysetOobj,RaysSurfNorms)',mp4d{2}.String,'(incRaysetOobj,RaysSurfNorms',cell2comStr(addarg),')']);
    %Save the detectsPhase setting in the DetectorO
    SurfO.detectsPhase=mp4d{4}.Value;
end

switch RIbg.SelectedObject.Tag
    case 'PA'
        SurfO.isPerfectAbsorber=true;SurfO.isSimpleReflector=false;
    case 'SR'
        SurfO.isPerfectAbsorber=false;SurfO.isSimpleReflector=true; SurfO.SimpleReflectance=str2double(mp4r{3}.String);
        if isnan(SurfO.SimpleReflectance), errordlg('The simple reflector reflectance you entered is invalid. Enter a new reflectance.'); return; end
    case 'CS'
        SurfO.isPerfectAbsorber=false;SurfO.isSimpleReflector=false;
        if mp4c{1}.Value==1 %if the checkbox is checked
            SurfO.hasAbsorption=true; %then it has absorption
            mp4c{11}.String=strtrim(mp4c{11}.String);
            if exist(mp4c{11}.String,'file')~=2 %check that the absorption function is valid
                if exist(mp4c{11}.String,'builtin')==5
                    warndlg('You might not want to use a standard matlab function for your absorption solve');
                else
                    errordlg('You need to specify an absorption solve that exists on the path','Bad Absorption Function')
                    return;
                end
            end
            %get any additional arguments
            addarg={};
            for n=1:size(mp4c{16}.String,1)
                addval=str2num(mp4c{16}.String(n,:)); %#ok<ST2NM>
                if ~isempty(addval)
                    addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
                end
            end
            SurfO.AbsorptionSolveFcn=str2func(['@(incRaysetO,incNrm)',mp4c{11}.String,'(incRaysetO,incNrm',cell2comStr(addarg),')']);
        else
            SurfO.hasAbsorption=false; %we don't bother clearing the absorption function. If a function was entered before then it will be populated for convenience in case the user changes their mind.  The code should test that SurfO.hasAbsorption before running the absorption function.
        end
        %------------------------------------------
        %------------------------------------------
        if mp4c{2}.Value==1 %if the checkbox is checked
            SurfO.hasTransmission=true; %then it has refraction
            mp4c{12}.String=strtrim(mp4c{12}.String);
            if exist(mp4c{12}.String,'file')~=2 %check that the refraction function is valid
                if exist(mp4c{12}.String,'builtin')==5
                    warndlg('You might not want to use a standard matlab function for your refraction solve');
                else
                    errordlg('You need to specify a refraction solve that exists on the path','Bad Refraction Function')
                    return;
                end
            end
            %get any additional arguments
            addarg={};
            for n=1:size(mp4c{17}.String,1)
                addval=str2num(mp4c{17}.String(n,:)); %#ok<ST2NM>
                if ~isempty(addval)
                    addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
                end
            end
            SurfO.RefractSolveDirTransFcn=str2func(['@(incRaysetO,surfNrms,IndP)',mp4c{12}.String,'(incRaysetO,surfNrms,IndP',cell2comStr(addarg),')']);
        else
            SurfO.hasTransmission=false;
            SurfO.hasForwardScattering=false;
        end
        %------------------------------------------
        %------------------------------------------
        if mp4c{3}.Value==1 && strcmpi(mp4c{3}.Visible,'on') %if the checkbox is checked and it's visible
            SurfO.hasForwardScattering=true; %then it has forward scattering
            mp4c{13}.String=strtrim(mp4c{13}.String);
            if exist(mp4c{13}.String,'file')~=2 %check that the forward scattering function is valid
                if exist(mp4c{13}.String,'builtin')==5
                    warndlg('You might not want to use a standard matlab function for your forward scattering solve');
                else
                    errordlg('You need to specify a forward scattering solve that exists on the path','Bad Forward Scattering Function')
                    return;
                end
            end
            %get any additional arguments
            addarg={};
            for n=1:size(mp4c{18}.String,1)
                addval=str2num(mp4c{18}.String(n,:)); %#ok<ST2NM>
                if ~isempty(addval)
                    addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
                end
            end
            SurfO.ForwardScatteredRaysFcn=str2func(['@(refrRaysetO,srfNrmls)',mp4c{13}.String,'(refrRaysetO,srfNrmls',cell2comStr(addarg),')']);
        else
            SurfO.hasForwardScattering=false;
        end
        %------------------------------------------
        %------------------------------------------
        if mp4c{4}.Value==1 %if the checkbox is checked
            SurfO.hasBackreflections=true; %then it has reflections
            mp4c{14}.String=strtrim(mp4c{14}.String);
            if exist(mp4c{14}.String,'file')~=2 %check that the reflections function is valid
                if exist(mp4c{14}.String,'builtin')==5
                    warndlg('You might not want to use a standard matlab function for your reflections solve');
                else
                    errordlg('You need to specify a reflections solve that exists on the path','Bad Reflections Function')
                    return;
                end
            end
            %get any additional arguments
            addarg={};
            for n=1:size(mp4c{19}.String,1)
                addval=str2num(mp4c{19}.String(n,:)); %#ok<ST2NM>
                if ~isempty(addval)
                    addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
                end
            end
            SurfO.ReflectSolveDirReflFcn=str2func(['@(incRaysetO,surfNrms,IndRO)',mp4c{14}.String,'(incRaysetO,surfNrms,IndRO',cell2comStr(addarg),')']);
        else
            SurfO.hasBackreflections=false;
            SurfO.hasBackscattering=false;
        end
        %------------------------------------------
        %------------------------------------------
        if mp4c{5}.Value==1 && strcmpi(mp4c{5}.Visible,'on') %if the checkbox is checked and it's visible
            SurfO.hasBackscattering=true; %then it has backscattering
            mp4c{15}.String=strtrim(mp4c{15}.String);
            if exist(mp4c{15}.String,'file')~=2 %check that the backscattering function is valid
                if exist(mp4c{15}.String,'builtin')==5
                    warndlg('You might not want to use a standard matlab function for your backscattering solve');
                else
                    errordlg('You need to specify a backscattering solve that exists on the path','Bad Backscattering Function')
                    return;
                end
            end
            %get any additional arguments
            addarg={};
            for n=1:size(mp4c{20}.String,1)
                addval=str2num(mp4c{20}.String(n,:)); %#ok<ST2NM>
                if ~isempty(addval)
                    addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
                end
            end
            SurfO.BackscatteredRaysFcn=str2func(['@(reflRaysetO,srfNrmls)',mp4c{15}.String,'(reflRaysetO,srfNrmls',cell2comStr(addarg),')']);
        else
            SurfO.hasBackscattering=false;
        end
    otherwise
        error('you have an error in the save interation settings')
end
    
%%
%The visualization page
%Save the group name
SurfO.GroupName=strtrim(VisC{8}.String);

%Check that the surface rendering was completed
updateVisXYZpts(SurfO); %this is where the actual surface visualization data is updated and held (zooms applied), later to be rendered within EnvironmentO
if isempty(SurfO.SurfaceXYZForVisual), errordlg('You need to run the surface visualizer and create a surface rendering before completing the surface'); return; end
if isempty(SurfO.SurfaceXYZForVisual{1}), errordlg('It appears your surface rendering has not succeeded. A reattempt at the surface visualization needs to be performed.  This error may be due to not correctly illuminating the surface in the Visualizer, or it may be due to the surface windowing excluding all possible intersection points for the surface.'); return; end


passfail=1;
    end






%%
    function passfail=saveSurfGeoWinsZooms(SurfO)
        passfail=false;
%save surface intersect solve parameters
ilev1e.String=strtrim(ilev1e.String);
if exist(ilev1e.String,'file')~=2
    if exist(ilev1e.String,'builtin')==5
        warndlg('You might not want to use a standard matlab function for your intersectsolve');
    else
        errordlg('You need to specify an intersect solve that exists on the path','Bad IntersectSolve Function')
        return;
    end
end
SurfO.IntersectSolveGeometryParams={};%clear the parameters to start with
SurfO.IntersectSolveGeometryParams{1}=ilev1e.String;
IntSlvObjlist=findobj(MainPan{2},'-regexp','Tag','isGe');
for n=1:length(IntSlvObjlist)
    SurfO.IntersectSolveGeometryParams{n+1}=str2num(get(findobj(IntSlvObjlist,'Tag',['isGe',num2str(n)]),'String')); %#ok<ST2NM>
    if isempty(SurfO.IntersectSolveGeometryParams{n+1})
        errordlg('All additional arguments of your intersect solve need to be numerical values. One or more of the additional arguments of the intersect solve need to be revised.','Intersect solve Arg Error')
        return;
    end
end

%save normal solve parameters
nlev1e.String=strtrim(nlev1e.String);
if exist(nlev1e.String,'file')~=2 
    if exist(nlev1e.String,'builtin')==5
        warndlg('You might not want to use a standard matlab function for your normalsolve');
    else
        errordlg('You need to specify an normalsolve that exists on the path','Bad NormalSolve Function')
        return;
    end
end
SurfO.NormalSolveGeometryParams={};%clear the parameters to start with
SurfO.NormalSolveGeometryParams{1}=nlev1e.String;
NrmlSlvObjlist=findobj(MainPan{2},'-regexp','Tag','nsGe');
for n=1:length(NrmlSlvObjlist)
    SurfO.NormalSolveGeometryParams{n+1}=str2num(get(findobj(NrmlSlvObjlist,'Tag',['nsGe',num2str(n)]),'String')); %#ok<ST2NM>
    if isempty(SurfO.NormalSolveGeometryParams{n+1})
        errordlg('All additional arguments of your normal solve need to be numerical values. One or more of the additional arguments of the normal solve need to be revised.','Normalsolve Arg Error')
        return;
    end
end
%%
%Save the windows (put into WindowGeometryCellArray)
wsbglvs=findobj(MainPan{3},'-regexp','Tag','WL'); %get the primary buttongroup objects, this could be empty if no windows are there
SurfO.WindowGeometryCellArray=cell(1,length(wsbglvs)*5);%multiply by 5 since it is the max gui input group size of any one window.  Downsize at the end - the WindowGeometryCellArray should not have empty cells
wIdx=1;
for n=1:length(wsbglvs)
    radiobuttonbox=findobj(wsbglvs,'Tag',['WL',num2str(n)]);
    switch lower(radiobuttonbox.SelectedObject.String)
        case 'plane'
            SurfO.WindowGeometryCellArray{wIdx}='plane';wIdx=wIdx+1;
            SurfO.WindowGeometryCellArray{wIdx}=str2num(get(findobj(MainPan{3},'Tag',['WP',num2str(n),'pt']),'String'));wIdx=wIdx+1;%#ok<ST2NM>
            if ~all(size(SurfO.WindowGeometryCellArray{wIdx-1})==[1,3]), errordlg('One of your plane windows has an invalid plane point. Fix the plane point entry','Plane window error'); return; end
            SurfO.WindowGeometryCellArray{wIdx}=str2num(get(findobj(MainPan{3},'Tag',['WP',num2str(n),'dir']),'String'));wIdx=wIdx+1;%#ok<ST2NM>
            if ~all(size(SurfO.WindowGeometryCellArray{wIdx-1})==[1,3]), errordlg('One of your plane windows has an invalid direction point. Fix the plane direction entry','Plane window error'); return; end
        case 'cylinder'
            SurfO.WindowGeometryCellArray{wIdx}='cylinder';wIdx=wIdx+1; %it's a cylinder window
            SurfO.WindowGeometryCellArray{wIdx}=get(get(findobj(MainPan{3},'Tag',['WC',num2str(n),'IorO']),'SelectedObject'),'String');wIdx=wIdx+1; %inner or outer
            SurfO.WindowGeometryCellArray{wIdx}=str2num(get(findobj(MainPan{3},'Tag',['WC',num2str(n),'axpt']),'String'));wIdx=wIdx+1;%#ok<ST2NM>    the axis point
            if ~all(size(SurfO.WindowGeometryCellArray{wIdx-1})==[1,3]), errordlg('One of your cylinder windows has an invalid axis point. Fix the axis point entry','Cylinder window error'); return; end
            SurfO.WindowGeometryCellArray{wIdx}=str2num(get(findobj(MainPan{3},'Tag',['WC',num2str(n),'axdir']),'String'));wIdx=wIdx+1;%#ok<ST2NM>   the axis direction
            if ~all(size(SurfO.WindowGeometryCellArray{wIdx-1})==[1,3]), errordlg('One of your cylinder windows has an invalid axis direction point. Fix the cylinder axis direction entry','Cylinder window error'); return; end
            SurfO.WindowGeometryCellArray{wIdx}=str2num(get(findobj(MainPan{3},'Tag',['WC',num2str(n),'CylR']),'String'));wIdx=wIdx+1;%#ok<ST2NM>   the cylinder radius
            if ~all(size(SurfO.WindowGeometryCellArray{wIdx-1})==[1,1]), errordlg('One of your cylinder windows has an invalid radius. Fix the cylinder radius entry','Cylinder window error'); return; end
        case 'sphere'
            SurfO.WindowGeometryCellArray{wIdx}='sphere';wIdx=wIdx+1; %it's a sphere window
            SurfO.WindowGeometryCellArray{wIdx}=get(get(findobj(MainPan{3},'Tag',['WS',num2str(n),'IorO']),'SelectedObject'),'String');wIdx=wIdx+1; %inner or outer
            SurfO.WindowGeometryCellArray{wIdx}=str2num(get(findobj(MainPan{3},'Tag',['WS',num2str(n),'cent']),'String'));wIdx=wIdx+1;%#ok<ST2NM>    the sphere center point
            if ~all(size(SurfO.WindowGeometryCellArray{wIdx-1})==[1,3]), errordlg('One of your sphere windows has an invalid center point. Fix the center point entry','Sphere window error'); return; end
            SurfO.WindowGeometryCellArray{wIdx}=str2num(get(findobj(MainPan{3},'Tag',['WS',num2str(n),'SphR']),'String'));wIdx=wIdx+1;%#ok<ST2NM>   the sphere radius
            if ~all(size(SurfO.WindowGeometryCellArray{wIdx-1})==[1,1]), errordlg('One of your sphere windows has an invalid radius. Fix the sphere radius entry','Sphere window error'); return; end
        otherwise
            error('you have a code error - each radiobuttonbox should have ''plane'' ''cylinder'' or ''sphere''');
    end
end

if length(SurfO.WindowGeometryCellArray)>=wIdx %downsize the WindowGeometryCellArray by removing unused cells
    SurfO.WindowGeometryCellArray(wIdx:length(SurfO.WindowGeometryCellArray))=[];
end


%%
%Save the zooms
zlclvs=findobj(MainPan{7},'-regexp','Tag','ZLc'); %get the primary buttongroup objects, this could be empty if no windows are there
SurfO.ZoomDataForAddZoomsFcn=cell(1,length(zlclvs)*5);%multiply by 5 since it is the number of inputs for the gui for any one zoom
for n=1:length(zlclvs)
    radiobuttonbox=findobj(zlclvs,'Tag',['ZLc',num2str(n)]);%you have to find each one specifically since their order can change using findobj
    SurfO.ZoomDataForAddZoomsFcn{n*5-4}=radiobuttonbox.SelectedObject.String;
    SurfO.ZoomDataForAddZoomsFcn{n*5-3}=str2num(get(findobj(MainPan{7},'Tag',['ZL',num2str(n),'axpt']),'String')); %#ok<ST2NM>
    if ~all(size(SurfO.ZoomDataForAddZoomsFcn{n*5-3})==[1,3]), errordlg('One of your zooms has an invalid axis point entry. Enter a valid axis point.'); return; end
    SurfO.ZoomDataForAddZoomsFcn{n*5-2}=str2num(get(findobj(MainPan{7},'Tag',['ZL',num2str(n),'axdir']),'String')); %#ok<ST2NM>
    if ~all(size(SurfO.ZoomDataForAddZoomsFcn{n*5-2})==[1,3]), errordlg('One of your zooms has an invalid axis direction entry. Enter a valid axis direction.'); return; end
    SurfO.ZoomDataForAddZoomsFcn{n*5-1}=get(findobj(MainPan{7},'Tag',['ZL',num2str(n),'enVar']),'Value');
    Zfcnstr=get(findobj(MainPan{7},'Tag',['ZL',num2str(n),'ezfcn']),'String');
    if exist(Zfcnstr,'file')~=2
        if exist(Zfcnstr,'builtin')==5
            warndlg('You might not want to use a standard matlab function for your EnvVar2Zoom function');
        else
            errordlg('You need to specify an intersect solve that exists on the path','Bad IntersectSolve Function')
            return;
        end
    end
    adrgZ=findobj(MainPan{7},'Tag',['ZL',num2str(n),'addparams']);
    
    addarg={};
    for nn=1:size(adrgZ.String,1) %in case the string is a char array that has more than one row
        addval=str2num(adrgZ.String(nn,:)); %#ok<ST2NM>
        if ~isempty(addval)
            addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
        end
    end
    SurfO.ZoomDataForAddZoomsFcn{n*5}=str2func(['@(EnVar)',Zfcnstr,'(EnVar',cell2comStr(addarg),')']);
end
%% Get GUI info turned into the correct zoom solves and geometric solves in the SurfO
SurfO.RotationAndTranslationZoomsCellArray={};
if ~isempty(SurfO.ZoomDataForAddZoomsFcn)
    for n=1:(length(SurfO.ZoomDataForAddZoomsFcn)/5)
        addZoom(SurfO,SurfO.ZoomDataForAddZoomsFcn{(n*5-4):(n*5)})
    end
end

if isempty(SurfO.IntersectSolveZOOMSETTINGS) && ~isempty(SurfO.RotationAndTranslationZoomsCellArray)
    uiwait(specifyParamsZooms(SurfO));
end
updateGeometricSolves(SurfO);

passfail=true;
    end


%%
%This is for the visualizer
    function CheckGeoWinAndBeginVislzr()
        succeeded=saveSurfGeoWinsZooms(surf2edit);
        if succeeded
            makeSurfaceVisualization(surf2edit,str2num(VisC{3}.String),str2num(VisC{5}.String)); %#ok<ST2NM>
        end
    end
%%
%Load name from SurfaceO to gui

    function loadsurface2gui(SurfO)
%load surface name
set(findobj(MainPan{1},'Tag','namebox'),'String',SurfO.Name);

%load surface intersect solve parameters
if ~isempty(SurfO.IntersectSolveGeometryParams), ilev1e.String=SurfO.IntersectSolveGeometryParams{1}; end
for n=2:length(SurfO.IntersectSolveGeometryParams)
    addlev(GeoSub1,ipb.UserData,34,ipb,imb,'i');
    set(findobj(GeoSub1,'Tag',['isGe',num2str(ipb.UserData)]),'String',num2str(SurfO.IntersectSolveGeometryParams{n}));
end

%load normal intersect solve parameters
if ~isempty(SurfO.NormalSolveGeometryParams), nlev1e.String=SurfO.NormalSolveGeometryParams{1}; end
for n=2:length(SurfO.NormalSolveGeometryParams)
    addlev(GeoSub2,npb.UserData,34,npb,nmb,'n');
    set(findobj(GeoSub2,'Tag',['nsGe',num2str(npb.UserData)]),'String', num2str(SurfO.NormalSolveGeometryParams{n}));
end

%load the windows (put into WindowGeometryCellArray)
if ~isempty(SurfO.WindowGeometryCellArray)
    counter=1;
    while counter<=length(SurfO.WindowGeometryCellArray)
        switch lower(SurfO.WindowGeometryCellArray{counter})
            case 'plane'
                Waddlev(MainPan{3},Wpb.UserData,65,Wpb,Wmb);
                bg=findobj(MainPan{3},'Tag',['WL',num2str(Wpb.UserData)]);
                set(findobj(bg,'String','Plane'),'Value',1);
                addWPlnSphCyl(1,1,MainPan{3},'Plane',Wpb.UserData);
                set(findobj(MainPan{3},'Tag',['WP',num2str(Wpb.UserData),'pt']),'String',num2str(SurfO.WindowGeometryCellArray{counter+1}));
                set(findobj(MainPan{3},'Tag',['WP',num2str(Wpb.UserData),'dir']),'String',num2str(SurfO.WindowGeometryCellArray{counter+2}));
                counter=counter+3;
            case 'cylinder'
                Waddlev(MainPan{3},Wpb.UserData,65,Wpb,Wmb);
                bg=findobj(MainPan{3},'Tag',['WL',num2str(Wpb.UserData)]);
                set(findobj(bg,'String','Cylinder'),'Value',1);
                addWPlnSphCyl(1,1,MainPan{3},'Cylinder',Wpb.UserData);
                set(findobj(findobj(MainPan{3},'Tag',['WC',num2str(Wpb.UserData),'IorO']),'String',SurfO.WindowGeometryCellArray{counter+1}),'Value',1); %inner or outer
                set(findobj(MainPan{3},'Tag',['WC',num2str(Wpb.UserData),'axpt']),'String',num2str(SurfO.WindowGeometryCellArray{counter+2})); %the axis point
                set(findobj(MainPan{3},'Tag',['WC',num2str(Wpb.UserData),'axdir']),'String',num2str(SurfO.WindowGeometryCellArray{counter+3})); %the axis direction
                set(findobj(MainPan{3},'Tag',['WC',num2str(Wpb.UserData),'CylR']),'String',num2str(SurfO.WindowGeometryCellArray{counter+4})); %the cylinder radius
                counter=counter+5;
            case 'sphere'
                Waddlev(MainPan{3},Wpb.UserData,65,Wpb,Wmb);
                bg=findobj(MainPan{3},'Tag',['WL',num2str(Wpb.UserData)]);
                set(findobj(bg,'String','Sphere'),'Value',1);
                addWPlnSphCyl(1,1,MainPan{3},'Sphere',Wpb.UserData);
                set(findobj(findobj(MainPan{3},'Tag',['WS',num2str(Wpb.UserData),'IorO']),'String',SurfO.WindowGeometryCellArray{counter+1}),'Value',1); %inner or outer
                set(findobj(MainPan{3},'Tag',['WS',num2str(Wpb.UserData),'cent']),'String',num2str(SurfO.WindowGeometryCellArray{counter+2})); %the sphere center point
                set(findobj(MainPan{3},'Tag',['WS',num2str(Wpb.UserData),'SphR']),'String',num2str(SurfO.WindowGeometryCellArray{counter+3})); %the sphere radius
                counter=counter+4;
            otherwise
                error('code case mismatch problem in loading windows')
        end
    end
end


%%
%load space settings
if ~isempty(SurfO.SpaceA) && isvalid(SurfO.SpaceA), set(findobj(MainPan{4},'Tag','se1'),'String',SurfO.SpaceA.Name); end
if ~isempty(SurfO.SpaceB) && isvalid(SurfO.SpaceB), set(findobj(MainPan{4},'Tag','se2'),'String',SurfO.SpaceB.Name); end

    
%%
%load ray interaciton settings
if isa(SurfO,'DetectorO')
    mp4d{5}.Value=1;
    mp4d{4}.Value=SurfO.detectsPhase;
    togglevis(mp4d{5},1,mp4d{1:3});
    if ~isempty(SurfO.DetectRaysFcn)
        str=func2str(SurfO.DetectRaysFcn);
        Cpr=strfind(str,')');
        Opr=strfind(str,'(');
        mp4d{2}.String=str(Cpr(1)+1:Opr(2)-1);
        Cbr=strfind(str,']');
        Obr=strfind(str,'[');
        addargcell=cell(1,length(Cbr));
        for n=1:length(Cbr)
            addargcell{n}=str(Obr(n):Cbr(n));
        end
        mp4d{3}.String=char(addargcell);
    end
end
if SurfO.isPerfectAbsorber
    set(findobj(RIbg,'String','Perfect Absorber'),'Value',1);
    toggleontoggleoff(1,1,[],[mp4r,mp4c]);
elseif SurfO.isSimpleReflector
    set(findobj(RIbg,'String','Simple Reflector'),'Value',1);
    mp4r{3}.String=num2str(SurfO.SimpleReflectance);
    toggleontoggleoff(1,1,mp4r,mp4c);
else
    set(findobj(RIbg,'String','Complex Surface'),'Value',1);
    toggleontoggleoff(1,1,mp4c([1,2,4,6,7,9,11,12,14,16,17,19]),mp4r);
    
    if SurfO.hasAbsorption %then load absorption parameters
        mp4c{1}.Value=1; %check the checkbox
        str=func2str(SurfO.AbsorptionSolveFcn);
        Cpr=strfind(str,')');
        Opr=strfind(str,'(');
        mp4c{11}.String=str(Cpr(1)+1:Opr(2)-1);
        Cbr=strfind(str,']');
        Obr=strfind(str,'[');
        addargcell=cell(1,length(Cbr));
        for n=1:length(Cbr)
            addargcell{n}=str(Obr(n):Cbr(n));
        end
        mp4c{16}.String=char(addargcell);
    end

    if SurfO.hasTransmission %then load Transmission parameters
        mp4c{2}.Value=1; %check the checkbox
        togglevis(mp4c{2},1,mp4c{[3,8,13,18]});
        str=func2str(SurfO.RefractSolveDirTransFcn);
        Cpr=strfind(str,')');
        Opr=strfind(str,'(');
        mp4c{12}.String=str(Cpr(1)+1:Opr(2)-1);
        Cbr=strfind(str,']');
        Obr=strfind(str,'[');
        addargcell=cell(1,length(Cbr));
        for n=1:length(Cbr)
            addargcell{n}=str(Obr(n):Cbr(n));
        end
        mp4c{17}.String=char(addargcell);
    end

    if SurfO.hasForwardScattering %then load ForwardScattering parameters
        mp4c{3}.Value=1; %check the checkbox
        str=func2str(SurfO.ForwardScatteredRaysFcn);
        Cpr=strfind(str,')');
        Opr=strfind(str,'(');
        mp4c{13}.String=str(Cpr(1)+1:Opr(2)-1);
        Cbr=strfind(str,']');
        Obr=strfind(str,'[');
        addargcell=cell(1,length(Cbr));
        for n=1:length(Cbr)
            addargcell{n}=str(Obr(n):Cbr(n));
        end
        mp4c{18}.String=char(addargcell);
    end

    if SurfO.hasBackreflections %then load Backreflections parameters
        mp4c{4}.Value=1; %check the checkbox
        togglevis(mp4c{4},1,mp4c{[5,10,15,20]});
        str=func2str(SurfO.ReflectSolveDirReflFcn);
        Cpr=strfind(str,')');
        Opr=strfind(str,'(');
        mp4c{14}.String=str(Cpr(1)+1:Opr(2)-1);
        Cbr=strfind(str,']');
        Obr=strfind(str,'[');
        addargcell=cell(1,length(Cbr));
        for n=1:length(Cbr)
            addargcell{n}=str(Obr(n):Cbr(n));
        end
        mp4c{19}.String=char(addargcell{n});
    end

    if SurfO.hasBackscattering %then load Backscattering parameters
        mp4c{5}.Value=1; %check the checkbox
        str=func2str(SurfO.BackscatteredRaysFcn);
        Cpr=strfind(str,')');
        Opr=strfind(str,'(');
        mp4c{15}.String=str(Cpr(1)+1:Opr(2)-1);
        Cbr=strfind(str,']');
        Obr=strfind(str,'[');
        addargcell=cell(1,length(Cbr));
        for n=1:length(Cbr)
            addargcell{n}=str(Obr(n):Cbr(n));
        end
        mp4c{20}.String=char(addargcell);
    end
end


%%
%load the group name
VisC{8}.String=SurfO.GroupName;
        

%%
%load the zooms 

for n=1:(length(SurfO.ZoomDataForAddZoomsFcn)/5)
    Zaddlev(MainPan{7},Zpb.UserData,65,Zpb,Zmb,EnvO);
    
    radiobuttonbox=findobj(MainPan{7},'Tag',['ZLc',num2str(Zpb.UserData)]);
    set(findobj(radiobuttonbox,'String',SurfO.ZoomDataForAddZoomsFcn{n*5-4}),'Value',1)
    set(findobj(MainPan{7},'Tag',['ZL',num2str(Zpb.UserData),'axpt']),'String',num2str(SurfO.ZoomDataForAddZoomsFcn{n*5-3}));
    set(findobj(MainPan{7},'Tag',['ZL',num2str(Zpb.UserData),'axdir']),'String',num2str(SurfO.ZoomDataForAddZoomsFcn{n*5-2}));
    set(findobj(MainPan{7},'Tag',['ZL',num2str(Zpb.UserData),'enVar']),'Value',SurfO.ZoomDataForAddZoomsFcn{n*5-1});
    
    str=func2str(SurfO.ZoomDataForAddZoomsFcn{n*5});
        Cpr=strfind(str,')');
        Opr=strfind(str,'(');
        set(findobj(MainPan{7},'Tag',['ZL',num2str(Zpb.UserData),'ezfcn']),'String',str(Cpr(1)+1:Opr(2)-1));
        Cbr=strfind(str,']');
        Obr=strfind(str,'[');
        addargcell=cell(1,length(Cbr));
        for nn=1:length(Cbr)
            addargcell{nn}=str(Obr(nn):Cbr(nn));
        end
        set(findobj(MainPan{7},'Tag',['ZL',num2str(n),'addparams']),'String',char(addargcell));
end
    
    end   
 
%%
    function closeoutSurfGui()
        savesucceeded=savetosurf(surf2edit); %Save the parameters to the SurfO
        if savesucceeded %Get the save to succeed
            SurfOorDetO_h=surf2edit; %pass the object we've been editing to the output
            delete(fh);%and delete the figure now that the surface is saved and part of the environment
            
        else
            %do nothing if the save failed, just let the function return and the figure
            %remains open
        end
    end
end

