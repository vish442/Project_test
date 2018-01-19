function addWPlnSphCyl(~,~,guiP,wintypstring,Wcurrlevel)

guiP.Units='pixels'; currheight=guiP.Position(4);guiP.Units='normalized';
remtags({['WP',num2str(Wcurrlevel)],['WS',num2str(Wcurrlevel)],['WC',num2str(Wcurrlevel)]},guiP);

switch lower(wintypstring)
    case 'cylinder'
% %Cylinder
bgSC=uibuttongroup(guiP,'Tag',['WC',num2str(Wcurrlevel),'IorO'],'Units','pixels','Position',[110,currheight-(Wcurrlevel-1)*65-80,70,48],'Title','Allow points');
uicontrol(bgSC,'Style','radiobutton','String','Inside','Units','normalized','Position',[.1 .6 1 .3],'TooltipString','Allow only surface points that are within the cylinder specified')
uicontrol(bgSC,'Style','radiobutton','String','Outside','Units','normalized','Position',[.1 .14 1 .3],'TooltipString','Allow only surface points that are without the cylinder specified')

uicontrol(guiP,'Tag',['WC',num2str(Wcurrlevel)],'Style','Text','Position',[185,currheight-(Wcurrlevel-1)*65-50,70,18],'String','Axis Point');
uicontrol(guiP,'Tag',['WC',num2str(Wcurrlevel),'axpt'],'Style','Edit','Position',[185,currheight-(Wcurrlevel-1)*65-70,70,24]);

uicontrol(guiP,'Tag',['WC',num2str(Wcurrlevel)],'Style','Text','Position',[255,currheight-(Wcurrlevel-1)*65-50,70,18],'String','Axis Direction');
uicontrol(guiP,'Tag',['WC',num2str(Wcurrlevel),'axdir'],'Style','Edit','Position',[255,currheight-(Wcurrlevel-1)*65-70,70,24]);

uicontrol(guiP,'Tag',['WC',num2str(Wcurrlevel)],'Style','Text','Position',[325,currheight-(Wcurrlevel-1)*65-50,35,18],'String','Radius');
uicontrol(guiP,'Tag',['WC',num2str(Wcurrlevel),'CylR'],'Style','Edit','Position',[325,currheight-(Wcurrlevel-1)*65-70,35,24]);
    case 'sphere'
%Sphere
bgSC=uibuttongroup(guiP,'Tag',['WS',num2str(Wcurrlevel),'IorO'],'Units','pixels','Position',[110,currheight-(Wcurrlevel-1)*65-80,70,48],'Title','Allow points');
uicontrol(bgSC,'Style','radiobutton','String','Inside','Units','normalized','Position',[.1 .6 1 .3],'TooltipString','Allow only surface points that are within the sphere specified')
uicontrol(bgSC,'Style','radiobutton','String','Outside','Units','normalized','Position',[.1 .14 1 .3],'TooltipString','Allow only surface points that are without the sphere specified')

uicontrol(guiP,'Tag',['WS',num2str(Wcurrlevel)],'Style','Text','Position',[185,currheight-(Wcurrlevel-1)*65-50,70,18],'String','Sphere Center');
uicontrol(guiP,'Tag',['WS',num2str(Wcurrlevel),'cent'],'Style','Edit','Position',[185,currheight-(Wcurrlevel-1)*65-70,70,24]);

uicontrol(guiP,'Tag',['WS',num2str(Wcurrlevel)],'Style','Text','Position',[265,currheight-(Wcurrlevel-1)*65-50,35,18],'String','Radius');
uicontrol(guiP,'Tag',['WS',num2str(Wcurrlevel),'SphR'],'Style','Edit','Position',[265,currheight-(Wcurrlevel-1)*65-70,35,24]);
    case 'plane'
%Plane
uicontrol(guiP,'Tag',['WP',num2str(Wcurrlevel)],'Style','Text','Position',[115,currheight-(Wcurrlevel-1)*65-65,70,25],'String','Plane Point');
uicontrol(guiP,'Tag',['WP',num2str(Wcurrlevel),'pt'],'Style','Edit','Position',[115,currheight-(Wcurrlevel-1)*65-80,70,25])

uicontrol(guiP,'Tag',['WP',num2str(Wcurrlevel)],'Style','Text','Position',[195,currheight-(Wcurrlevel-1)*65-65,70,35],'String','Plane Normal Direction');
uicontrol(guiP,'Tag',['WP',num2str(Wcurrlevel),'dir'],'Style','Edit','Position',[195,currheight-(Wcurrlevel-1)*65-80,70,25])
    otherwise
        error('addWcomps received unrecognized surface string')
end
end
