

function Waddlev(guiP,Wcurrlevel,levelheight,pb,mb)
guiP.Units='pixels'; currheight=guiP.Position(4);guiP.Units='normalized';
atlevel=Wcurrlevel+1;

% uicontrol(guiP,'Tag',['WL',num2str(atlevel)],'Style','Text','Position',[39,currheight-Wcurrlevel*65-27,100,10],'String','Window 1','HorizontalAlignment','left')
bg=uibuttongroup(guiP,'Tag',['WL',num2str(atlevel)],'Units','pixels','Position',[35,currheight-Wcurrlevel*65-80,70,48]);
uicontrol(bg,'Style','radiobutton','String','Plane','Units','normalized','Position',[.1 .66 1 .33],'TooltipString','Allow surface points that are on one side of the plane, designated by which side the normal vector points into.','Callback',{@addWPlnSphCyl,guiP,'Plane',atlevel})
uicontrol(bg,'Style','radiobutton','String','Cylinder','Units','normalized','Position',[.1 .33 1 .33],'TooltipString','Allow only surface points that are within or without the cylinder specified','Callback',{@addWPlnSphCyl,guiP,'Cylinder',atlevel})
uicontrol(bg,'Style','radiobutton','String','Sphere','Units','normalized','Position',[.1 0 1 .33],'TooltipString','Allow only surface points that are within or without the sphere specified','Callback',{@addWPlnSphCyl,guiP,'Sphere',atlevel})

addWPlnSphCyl(1,1,guiP,'Plane',atlevel)

pb.Position(2)=pb.Position(2)-levelheight;
mb.Position(2)=mb.Position(2)-levelheight;
if (currheight-mb.Position(2))>5
    mb.Visible='on';
end
pb.UserData=atlevel;
end
