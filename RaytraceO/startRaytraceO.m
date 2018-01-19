%This function uses the command cd, so the "current directory" of Matlab
%needs to be the folder containing this function file, which should be the
%main RaytraceO folder.

function EnvOmain=startRaytraceO(varargin)

%get all the subfolders of RaytraceO onto the search path for execution
%purposes
addpath(genpath(cd));

%get directory slash directions correct for later in the code
if ispc, ds='\'; else ds='/'; end

if ~isempty(varargin) && isa(varargin{1},'EnvironmentO')
    EnvOmain=varargin{1};
else
    EnvOmain=EnvironmentO();
end

%make the control figure (with the buttons for adding surfaces etc.)
EnvOmain.EnvFig=figure('MenuBar','none','ToolBar','figure','NumberTitle','off','Name','Optical System View','WindowButtonDownFcn',@setmotion);
uicontrol(EnvOmain.EnvFig,'Style','check','Units','normalized','Position',[0,.94,.3,.06],'String','Draw rays during raytrace','HorizontalAlignment','left','Callback',@(hobj,evd)drawEnableDisable(hobj,EnvOmain),'Value',1);

EnvOmain.EnvAxes=axes('CameraViewAngleMode','manual');hold on; axis equal; xlabel('x');ylabel('y');zlabel('z');
EnvOmain.EnvFig.WindowScrollWheelFcn=@(hobj,evd)scrllzoom(evd,EnvOmain.EnvAxes);

EnvOmain.EnvAxes.UIContextMenu=uicontextmenu(EnvOmain.EnvFig);
uimenu(EnvOmain.EnvAxes.UIContextMenu,'Label','Set view pivot point','Callback',@(hobj,evd)newpivot(EnvOmain.EnvAxes));
uimenu(EnvOmain.EnvAxes.UIContextMenu,'Label','Set datatip to pivot point','Callback',@(hobj,evd)tip2pivot(EnvOmain.EnvFig,EnvOmain.EnvAxes));



% MainFig_h=1;
% %get rid of the standard 'save', 'open', and 'new' buttons
% delete(findall(MainFig_h,'Tag','Standard.FileOpen'));
% delete(findall(MainFig_h,'Tag','Standard.NewFigure'));

%Add buttons for making surfaces etc
p1=uipushtool('TooltipString','Add Surface','ClickedCallback',@(hobj,evd)addSurfaceO(EnvOmain));
p1.CData = imread([cd,ds,'Images4program',ds,'AddSurf_icon.jpg']);

p2=uipushtool('TooltipString','Add Detector','ClickedCallback',@(hobj,evd)addDetectorO(EnvOmain));
p2.CData = imread([cd,ds,'Images4program',ds,'AddDetector_icon.tif']);

p3=uipushtool('TooltipString','Add Source','ClickedCallback',@(hobj,evd)addSourceO(EnvOmain));
p3.CData = imread([cd,ds,'Images4program',ds,'AddSource_icon.jpg']);

p4=uipushtool('TooltipString','Add Space','ClickedCallback',@(hobj,evd)addSpaceO(EnvOmain));
p4.CData = imread([cd,ds,'Images4program',ds,'AddSpace_icon.tif']);

p5=uitoggletool('TooltipString','Pivot Optical System','ClickedCallback',@(hobj,cbd)camorbit2(EnvOmain.EnvFig,hobj.State));
p5.CData = imread([cd,ds,'Images4program',ds,'CamOrbit2_icon.jpg']);

p6=uipushtool('TooltipString','Single Raytrace','ClickedCallback',@(hobj,cbd)moveraysthrough(EnvOmain));
p6.CData = imread([cd,ds,'Images4program',ds,'Raytrace_icon.tif']);

p7=uipushtool('TooltipString','Multi-Zoom Raytrace','ClickedCallback',@(hobj,cbd)startautozoom(EnvOmain));
p7.CData = imread([cd,ds,'Images4program',ds,'RaysWzooms_icon.tif']);

p8=uipushtool('TooltipString','Clear rays','ClickedCallback',@(hobj,evd)clearItems(EnvOmain));
p8.CData = imread([cd,ds,'Images4program',ds,'ClearRays_icon.tif']);

p9=uipushtool('TooltipString','Save Optical System','ClickedCallback',@(hobj,cbd)savethings(EnvOmain));
p9.CData = imread([cd,ds,'Images4program',ds,'SaveO_icon.jpg']);

p10=uipushtool('TooltipString','Open Optical System','ClickedCallback',@(hobj,cbd)loadthings());
p10.CData = imread([cd,ds,'Images4program',ds,'OpenO_icon.jpg']);

p11=uipushtool('TooltipString','Reload Optical System','ClickedCallback',@(hobj,cbd)reloadEnvO(EnvOmain));
p11.CData = imread([cd,ds,'Images4program',ds,'ReloadO_icon.tif']);


EnvOmain.EnvTTBo=TextTreeBox();
EnvOmain.EnvTTBo.ParentFigure.Name='RaytraceO objects';EnvOmain.EnvTTBo.ParentFigure.NumberTitle='off';
LLTB=cell(4,1); %initialize

set(EnvOmain.EnvTTBo.ParentFigure,'CloseRequestFcn',@(hobj,evd)closeEnvO(EnvOmain));
set(EnvOmain.EnvFig,'CloseRequestFcn',@(hobj,evd)closeEnvO(EnvOmain));

%add zoom control
addZoomGui(EnvOmain);

LLTB{1}=TextTreeBranch('Surfaces');
LLTB{1}.UIContextMenu=uicontextmenu(EnvOmain.EnvTTBo.ParentFigure);
uimenu(LLTB{1}.UIContextMenu,'Label','Add Surface','Callback',@(hobj,evd)addSurfaceO(EnvOmain));

LLTB{2}=TextTreeBranch('Detectors');
LLTB{2}.UIContextMenu=uicontextmenu(EnvOmain.EnvTTBo.ParentFigure);
uimenu(LLTB{2}.UIContextMenu,'Label','Add Detector','Callback',@(hobj,evd)addDetectorO(EnvOmain));

LLTB{3}=TextTreeBranch('Sources');
LLTB{3}.UIContextMenu=uicontextmenu(EnvOmain.EnvTTBo.ParentFigure);
uimenu(LLTB{3}.UIContextMenu,'Label','Add Source','Callback',@(hobj,evd)addSourceO(EnvOmain));

LLTB{4}=TextTreeBranch('Spaces');
LLTB{4}.UIContextMenu=uicontextmenu(EnvOmain.EnvTTBo.ParentFigure);
uimenu(LLTB{4}.UIContextMenu,'Label','Add Space','Callback',@(hobj,evd)addSpaceO(EnvOmain));

addPrimaryBranches(EnvOmain.EnvTTBo,LLTB)


        
        
end
