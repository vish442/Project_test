function ViewDetectedPower(DetO)
if isempty(DetO.DetectedPositions), errordlg('This detector currently has no rays collected on its face'); return; end

fh=figure('NumberTitle','off','Name',DetO.Name);
ah=axes;hold on;axis equal;
if nargin==0
    DetectedPositions=rand(10,3)-.5;
    DetectedPowers=rand(10,1);
    [X,Y]=meshgrid(1:10,1:10);
    surfh=surf(ah,X/10,Y/10,rand(10,10)/10,'ButtonDownFcn',@(hobj,evd)interactiveSurfOpacity(fh,hobj));
else
    surfh=surf(ah,DetO.SurfaceXYZForVisual{:},'CData',DetO.VisColorData,'ButtonDownFcn',@(hobj,evd)interactiveSurfOpacity(fh,hobj));
    DetectedPositions=DetO.DetectedPositions;
    DetectedPowers=DetO.DetectedPowers;
end


fh.WindowScrollWheelFcn=@(hobj,evd)scrllzoom(evd,ah);
    function scrllzoom(evd,ax)
        if (-evd.VerticalScrollCount/15+1>0)
            camzoom(ax,-evd.VerticalScrollCount/15+1);
        end
    end
ucmPan=uicontextmenu(fh);
up1=uipanel(fh,'Position',[0,0,.24,.1],'UIContextMenu',ucmPan);
up2=uipanel(fh,'Position',[.24,0,.26,.1],'UIContextMenu',ucmPan);
up3=uipanel(fh,'Position',[.5,0,.5,.1],'UIContextMenu',ucmPan);
uicontrol(up1,'Style','Text','Units','normalized','Position',[.01,.5,.98,.5],'String','RayCount:','Tag','SP1','HitTest','off','HorizontalAlignment','left');
uicontrol(up1,'Style','Text','Units','normalized','Position',[.01,0,.98,.5],'String','TotalPwr:','Tag','SP2','HitTest','off','HorizontalAlignment','left');
uicontrol(up2,'Style','Text','Units','normalized','Position',[.01,.5,.98,.5],'String','PwrptSTDV:','Tag','SP3','HitTest','off','HorizontalAlignment','left');
uicontrol(up2,'Style','Text','Units','normalized','Position',[.01,0,.98,.5],'String','RayptSTDV:','Tag','SP4','HitTest','off','HorizontalAlignment','left');
uicontrol(up3,'Style','Text','Units','normalized','Position',[.01,.5,.98,.5],'String','PwrCentroid:','Tag','SP5','HitTest','off','HorizontalAlignment','left');
uicontrol(up3,'Style','Text','Units','normalized','Position',[.01,0,.98,.5],'String','RayCentroid:','Tag','SP6','HitTest','off','HorizontalAlignment','left');

uimenu(ucmPan,'Label','Copy stats to clipboard','Callback',@(hobj,evd)StatsPanel_toclipbrd(fh));
    function StatsPanel_toclipbrd(fh)
        clipboard('copy',[get(findobj(fh,'Tag','SP1'),'String'),', ',get(findobj(fh,'Tag','SP2'),'String'),', ',get(findobj(fh,'Tag','SP3'),'String'),', ',get(findobj(fh,'Tag','SP4'),'String'),', ',get(findobj(fh,'Tag','SP5'),'String'),', ',get(findobj(fh,'Tag','SP6'),'String')]);
    end

plot3(DetectedPositions(:,1),DetectedPositions(:,2),DetectedPositions(:,3),'LineStyle','none','Marker','.','MarkerSize',30);
fh.WindowButtonDownFcn=@(hobj,evd)growshrnksphere(hobj,ah,DetectedPositions,DetectedPowers);

fh.UIContextMenu=uicontextmenu(fh);
ah.UIContextMenu=uicontextmenu(fh);
uimenu(fh.UIContextMenu,'Label','Toggle detector surface','Callback',@(hobj,evd)togglesurfvis(surfh));
uimenu(ah.UIContextMenu,'Label','Toggle detector surface','Callback',@(hobj,evd)togglesurfvis(surfh));
uimenu(fh.UIContextMenu,'Label','Toggle enveloping surface','Callback',@(hobj,evd)togglebubblevis(fh));
uimenu(ah.UIContextMenu,'Label','Toggle enveloping surface','Callback',@(hobj,evd)togglebubblevis(ah));

                    function togglesurfvis(surfH)
                        if strcmpi(surfH.Visible,'on'), surfH.Visible='off'; else surfH.Visible='on'; end
                    end
                    function togglebubblevis(hobj)
                        a=findobj(hobj,'Tag','blpts','Type','Surface');
                        if ~isempty(a) && strcmpi(a(1).Visible,'on'), set(a,'Visible','off'); else set(a,'Visible','on'); end
                    end

end


%resize the selection sphere, this happens when a datatip exists in the axes and the user clicks anywhere else in the axes   

function growshrnksphere(figh,ah,DataPoints,DataPowers)
%if there is a datatip, draw a sphere around it, then change the
%windowbuttonmotionfcn to grow and shrink the sphere.
%
if strcmpi(figh.SelectionType,'normal')
    axis equal; ah.CameraViewAngleMode='manual'; ah.CameraPositionMode='manual'; ah.CameraTargetMode='manual';
    dcmobj=datacursormode(figh);
    CI=getCursorInfo(dcmobj);
    if isempty(CI)
        delete(findobj(ah,'Tag','blpts'))
    elseif any(size(CI)>[1,1])
        errordlg('Only one datatip can be in the figure to use the sphere selector. There are currently multiple datatips. Delete unwanted ones and retry.')
        return;
    end
    if all(size(CI)==[1,1])
        delete(findobj(ah,'Tag','blpts'))
        
        center=CI.Position;
        r=sqrt(sum((sum(ah.CurrentPoint,1)/2-center).^2));
        rr=0:r/7:r;
        phi=0:2*pi/15:2*pi;
        y=sin(phi)';
        x=cos(phi)';
        X=x*rr;
        Y=y*rr;
        Z=real(sqrt(r^2-X.^2-Y.^2));
        SurfHtop=mesh(X+center(1),Y+center(2),Z+center(3),'Tag','blpts');SurfHtop.FaceAlpha=.7;
        SurfHbot=mesh(X+center(1),Y+center(2),-Z+center(3),'Tag','blpts');SurfHbot.FaceAlpha=.7;
        hlghtthese=(sum((DataPoints-ones(size(DataPoints,1),1)*center).^2,2).^(1/2))<r;
        plot3(ah,DataPoints(hlghtthese,1),DataPoints(hlghtthese,2),DataPoints(hlghtthese,3),'Marker','.','MarkerSize',30,'MarkerEdgeColor','g','Tag','blpts')
        
N=sum(hlghtthese);
set(findobj(figh,'Tag','SP1'),'String',['RayCount:  ',num2str(N)]);
RayCentroid=sum(DataPoints(hlghtthese,:),1)/N;
set(findobj(figh,'Tag','SP6'),'String',['RayCentroid: [',num2str(RayCentroid),']']);
RayptSTDV=sqrt(sum(sum((DataPoints(hlghtthese,:)-ones(N,1)*RayCentroid).^2))/N);
set(findobj(figh,'Tag','SP4'),'String',['RayptSTDV:   ',num2str(RayptSTDV)]);

totalpower=sum(DataPowers(hlghtthese),1);
set(findobj(figh,'Tag','SP2'),'String',['TotalPwr:  ',num2str(totalpower)]);
%to do power distributions, treat a ray with power of 2 as two rays, etc., and then use the original methods for average and stdv 
PwrCentroid=sum(DataPoints(hlghtthese,:).*(DataPowers(hlghtthese)*ones(1,3)),1)/totalpower;
set(findobj(figh,'Tag','SP5'),'String',['PwrCentroid: [',num2str(PwrCentroid),']']);
PwrptSTDV=sqrt(  sum(   DataPowers(hlghtthese).*sum(( DataPoints(hlghtthese,:)-ones(sum(hlghtthese),1)*PwrCentroid ).^2,2)   )   /totalpower);
set(findobj(figh,'Tag','SP3'),'String',['PwrptSTDV:  ',num2str(PwrptSTDV)]);

        
        
        figh.UserData=figh.CurrentPoint;
        ah.UserData=r;
        set(figh,'WindowButtonUpFcn',@clearWBMotion);
        set(figh,'WindowButtonMotionFcn',@(hobj,evd)resizesphere(hobj,ah,center,DataPoints,DataPowers))
        
    end

end

end


function resizesphere(figh,ah,center,DataPoints,DataPowers)
delete(findobj(ah,'Tag','blpts'))
step=figh.CurrentPoint(2)-figh.UserData(2);
figh.UserData=figh.CurrentPoint;
ah.UserData=ah.UserData*(1+step/50);
r=ah.UserData;

rr=0:r/7:r;
phi=0:2*pi/15:2*pi;
y=sin(phi)';
x=cos(phi)';
X=x*rr;
Y=y*rr;
Z=real(sqrt(r^2-X.^2-Y.^2));
SurfHtop=mesh(X+center(1),Y+center(2),Z+center(3),'Tag','blpts');SurfHtop.FaceAlpha=.7;
SurfHbot=mesh(X+center(1),Y+center(2),-Z+center(3),'Tag','blpts');SurfHbot.FaceAlpha=.7;
hlghtthese=(sum((DataPoints-ones(size(DataPoints,1),1)*center).^2,2).^(1/2))<r;
if any(size(DataPoints(hlghtthese,1))~=size(DataPoints(hlghtthese,3)))
    disp hey
end
plot3(ah,DataPoints(hlghtthese,1),DataPoints(hlghtthese,2),DataPoints(hlghtthese,3),'Marker','.','MarkerSize',30,'MarkerEdgeColor','g','Tag','blpts')

N=sum(hlghtthese);
set(findobj(figh,'Tag','SP1'),'String',['RayCount:  ',num2str(N)]);
RayCentroid=sum(DataPoints(hlghtthese,:),1)/N;
set(findobj(figh,'Tag','SP6'),'String',['RayCentroid: [',num2str(RayCentroid),']']);
RayptSTDV=sqrt(sum(sum((DataPoints(hlghtthese,:)-ones(N,1)*RayCentroid).^2))/N);
set(findobj(figh,'Tag','SP4'),'String',['RayptSTDV:   ',num2str(RayptSTDV)]);

totalpower=sum(DataPowers(hlghtthese),1);
set(findobj(figh,'Tag','SP2'),'String',['TotalPwr:  ',num2str(totalpower)]);
%to do power distributions, treat a ray with power of 2 as two rays, etc., and then use the original methods for average and stdv 
PwrCentroid=sum(DataPoints(hlghtthese,:).*(DataPowers(hlghtthese)*ones(1,3)),1)/totalpower;
set(findobj(figh,'Tag','SP5'),'String',['PwrCentroid: [',num2str(PwrCentroid),']']);
PwrptSTDV=sqrt(  sum(   DataPowers(hlghtthese).*sum(( DataPoints(hlghtthese,:)-ones(sum(hlghtthese),1)*PwrCentroid ).^2,2)   )   /totalpower);
set(findobj(figh,'Tag','SP3'),'String',['PwrptSTDV:  ',num2str(PwrptSTDV)]);

end

function clearWBMotion(fgr,~)
set(fgr,'WindowButtonMotionFcn','')
end


