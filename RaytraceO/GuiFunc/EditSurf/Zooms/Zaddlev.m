

function Zaddlev(guiP,Zcurrlevel,levelheight,pb,mb,EnvO)
guiP.Units='pixels'; currheight=guiP.Position(4);guiP.Units='normalized';
atlevel=Zcurrlevel+1;

bg=uibuttongroup(guiP,'Tag',['ZLc',num2str(atlevel)],'Units','pixels','Position',[18,currheight-Zcurrlevel*65-71,80,28]);
uicontrol(bg,'Style','radiobutton','String','Translation','Units','normalized','Position',[.01 .6 1 .4],'TooltipString','Allow surface points that are on one side of the plane, designated by which side the normal vector points into.')
uicontrol(bg,'Style','radiobutton','String','Rotation','Units','normalized','Position',[.01 .1 1 .4],'TooltipString','Allow only surface points that are within or without the cylinder specified')

uicontrol(guiP,'Tag',['ZL',num2str(atlevel)],'Style','Text','Position',[115-18,currheight-Zcurrlevel*65-50,70,20],'String','Axis Point');
uicontrol(guiP,'Tag',['ZL',num2str(atlevel),'axpt'],'Style','Edit','Position',[115-18,currheight-Zcurrlevel*65-70,70,24]);

uicontrol(guiP,'Tag',['ZL',num2str(atlevel)],'Style','Text','Position',[185-18,currheight-Zcurrlevel*65-50,70-3,33],'String','Axis Direction');
uicontrol(guiP,'Tag',['ZL',num2str(atlevel),'axdir'],'Style','Edit','Position',[185-18,currheight-Zcurrlevel*65-70,70-3,24]);

uicontrol(guiP,'Tag',['ZL',num2str(atlevel)],'Style','Text','Position',[255-23,currheight-Zcurrlevel*65-50,35,33],'String','Env Var');
uicontrol(guiP,'Tag',['ZL',num2str(atlevel),'enVar'],'Style','popup','Position',[255-23,currheight-Zcurrlevel*65-63,35,15],'String',makepopupstr(length(EnvO.EnvZoomVars)),'Callback',{@popupclicked,EnvO},'TooltipString',sprintf('Each translation distance or rotation angle is obtained by using an environment variable\n that ranges from 0-1. Tie this zoom to one of the environment variables.\nThis allows multiples zooms to respond to a change in a single environment variable.'));

uicontrol(guiP,'Tag',['ZL',num2str(atlevel)],'Style','Text','Position',[277,currheight-Zcurrlevel*65-50,70,33],'String','Env Var to Zoom Fcn');
uicontrol(guiP,'Tag',['ZL',num2str(atlevel),'ezfcn'],'Style','Edit','Position',[265,currheight-Zcurrlevel*65-70,80,24],'TooltipString',sprintf('Only enter the function name here. This function converts the chosen \nenvironment variable (that, by design, varies from 0-1) into the\n actual zoom translation distance or rotation angle.\nThe format should be  [Zoom]= YourFcn (EnvironmentVar(required),\n ...+any additional arguments (if needed))'));
uicontrol(guiP,'Tag',['ZL',num2str(atlevel),'addparams'],'Style','pushbutton','Units','pixels','Position',[345,currheight-Zcurrlevel*65-70,15,24],'String','...','HorizontalAlignment','left','Callback',{@addparams});


pb.Position(2)=pb.Position(2)-levelheight;
mb.Position(2)=mb.Position(2)-levelheight;
if (currheight-mb.Position(2))>5
    mb.Visible='on';
end
pb.UserData=atlevel;


    function outptcellstr=makepopupstr(numEvars) %creates lines in the popup menu according to the number of EnvZoomVars there are in the EnvO
        outptcellstr=cell(numEvars+1,1);
        for n=1:numEvars
            outptcellstr{n}=['Environment Variable ',num2str(n)];
        end
        outptcellstr{numEvars+1}='Add Environment Variable';
    end

    function popupclicked(hobj,~,EnvO) %The callback to use if the last line of the popupmenu is clicked (the line should say 'Add Environment Variable') 
        if hobj.Value==length(hobj.String)
            EnvO.EnvZoomVars=[EnvO.EnvZoomVars,0];
            EnvO.ZoomAdjButtongroup.Visible='on';
            hobj.String=makepopupstr(length(EnvO.EnvZoomVars));
        end
    end


end
