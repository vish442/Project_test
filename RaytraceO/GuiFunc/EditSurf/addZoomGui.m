%this is the code for the box that appears in the EnvO list GUI when an
%environment zoom variable is added to the system
function addZoomGui(EnvO)
bg=uibuttongroup(EnvO.EnvTTBo.ParentFigure);
bg.Position=[.8,.4,.15,.5];
sliderh=uicontrol(bg,'Style','slider','Units','normalized','Position',[.75,.15,.2,.7],'Value',0);

uicontrol(bg,'Style','text','Units','normalized','Position',[.1,.85,.8,.1],'String','Adjust Zoom');

uicontrol(bg,'Style','text','Units','normalized','Position',[.07,.55,.5,.2],'String','Which Env. Var.');

EnvZoomBox=uicontrol(bg,'Style','edit','Units','normalized','Position',[.15,.4,.3,.15],'String','1');

uicontrol(bg,'Style','text','Units','normalized','Position',[.07,.2,.5,.15],'String','Current Value');

CurrValBox=uicontrol(bg,'Style','edit','Units','normalized','Position',[.12,.06,.5,.12],'String','0');

EnvZoomBox.UIContextMenu=uicontextmenu(EnvO.EnvTTBo.ParentFigure);
uimenu(EnvZoomBox.UIContextMenu,'Label','Alter this zoom''s tooltipstring','Callback',@(hobj,evd)ChangeEnvZoomVarTooltip(EnvZoomBox));

sliderh.Callback=@(hobj,evd)ZoomSliderAdjust(EnvO,hobj,EnvZoomBox,CurrValBox);
CurrValBox.Callback=@(hobj,evd)ZoomCurrvalboxAdjust(EnvO,sliderh,EnvZoomBox,hobj);
EnvZoomBox.Callback=@(hobj,evd)ZoomEnvVarChange(EnvO,hobj,sliderh,CurrValBox);

bg.Visible='off';
EnvO.ZoomAdjButtongroup=bg;


    function ZoomSliderAdjust(EnvO,sliderh,EnvZoomBox,CurrValBox)
        CurrValBox.String=num2str(sliderh.Value);
        EnvZoomVarNum=round(str2double(EnvZoomBox.String));
        EnvO.EnvZoomVars(EnvZoomVarNum)=sliderh.Value;
        UpdateSurfZooms(EnvO,1,EnvZoomVarNum);
    end
    function ZoomCurrvalboxAdjust(EnvO,sliderh,EnvZoomBox,currvalbox)
        newEnvZoomVarVal=str2double(currvalbox.String);
        if newEnvZoomVarVal<=1 && newEnvZoomVarVal>=0
            sliderh.Value=newEnvZoomVarVal;
            EnvZoomVarNum=round(str2double(EnvZoomBox.String));
            EnvO.EnvZoomVars(EnvZoomVarNum)=newEnvZoomVarVal;
            UpdateSurfZooms(EnvO,1,EnvZoomVarNum);
        end
    end
    function ZoomEnvVarChange(EnvO,EnvZoomBox,sliderh,currvalbox)
        %go and get from the environment the value of that env zoom var
        EnvZoomVarNum=round(str2double(EnvZoomBox.String));
        if EnvZoomVarNum<=length(EnvO.EnvZoomVars) && EnvZoomVarNum>.5%check the environment to see if it has that value
            sliderh.Value=EnvO.EnvZoomVars(EnvZoomVarNum);%and set the value at the slider
            currvalbox.String=num2str(EnvO.EnvZoomVars(EnvZoomVarNum));%then set the value at the box
            if length(EnvZoomBox.UserData)>=EnvZoomVarNum && ~isempty(EnvZoomBox.UserData{EnvZoomVarNum}) %if there is a valid string in the UserData of EnvZoomBox
                 EnvZoomBox.TooltipString=EnvZoomBox.UserData{EnvZoomVarNum};%then make it the tooltip string
            end
        end
    end
    function ChangeEnvZoomVarTooltip(EnvZoomBox)
        EnvZoomVarNum=round(str2double(EnvZoomBox.String));
        if EnvZoomVarNum>.5
            strout=inputdlg('Write the help description you want for this Environment Zoom Variable.  It will thenceforth appear as a tooltip string.');
            EnvZoomBox.TooltipString=strout{1}; %update the tooltip string
            EnvZoomBox.UserData{EnvZoomVarNum}=strout{1}; %keep the strings in UserData
        end
    end

end


