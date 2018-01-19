%This opens the main GUI for editing a SourceO object within an
%EnvironmentO

function SrcO=EditSourceMain(source2edit)
SrcO=0;
EnvO=source2edit.Environment;
fh=figure('MenuBar','none','NumberTitle','off');



%% SOURCE NAME AND SPACE
uicontrol(fh,'Style','text','String','Source Name','Units','Normalized','Position',[.05,.93,.2,.05],'BackgroundColor',[1,1,.85])
namestr=uicontrol(fh,'Style','edit','String','','Units','Normalized','Position',[.05,.88,.2,.05]);

uicontrol(fh,'Style','text','String','Starting Space','Units','Normalized','Position',[.05,.8,.2,.05],'BackgroundColor',[1,1,.85])
spcstr=uicontrol(fh,'Style','edit','String','','Units','Normalized','Position',[.05,.75,.2,.05]);

%% RAY STARTING POINTS
uicontrol(fh,'Style','text','String','Ray Starting Positions','Units','Normalized','Position',[.3,.93,.2,.05],'BackgroundColor',[1,1,.85])
strtptgrid=uicontrol(fh,'Style','pushbutton','String','Use Grid','Units','Normalized','Position',[.5,.93,.1,.03]);

uicontrol(fh,'Style','text','String','X positions','Units','Normalized','Position',[.3,.88,.1,.03],'HorizontalAlignment','left')
rpop1e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.4,.88,.1,.03]);
rpop1=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.3,.87,.2,.01]);
rpop1e.Callback=@(hobj,evd)editlistCB(rpop1,'Input X position values');

uicontrol(fh,'Style','text','String','Y positions','Units','Normalized','Position',[.53,.88,.1,.03],'HorizontalAlignment','left')
rpop2e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.63,.88,.1,.03]);
rpop2=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.53,.87,.2,.01]);
rpop2e.Callback=@(hobj,evd)editlistCB(rpop2,'Input X position values');

uicontrol(fh,'Style','text','String','Z positions','Units','Normalized','Position',[.77,.88,.1,.03],'HorizontalAlignment','left')
rpop3e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.87,.88,.1,.03]);
rpop3=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.77,.87,.2,.01]);
rpop3e.Callback=@(hobj,evd)editlistCB(rpop3,'Input X position values');

strtptgrid.Callback=@(hobj,evd)placegridANDupdatestrings(rpop1,rpop2,rpop3);

%% POINT SOURCE POSITIONS
uicontrol(fh,'Style','text','String','Point Source Positions','Units','Normalized','Position',[.3,.73,.2,.05],'BackgroundColor',[1,1,.85])
srcposgrid=uicontrol(fh,'Style','pushbutton','String','Use Grid','Units','Normalized','Position',[.5,.73,.1,.03]);
revrsd=uicontrol(fh,'Style','check','String','Change sources into targets','Units','Normalized','Position',[.65,.73,.34,.03],'TooltipString',sprintf('This makes the rays point toward the source\n locations instead of away from them.'));

uicontrol(fh,'Style','text','String','X positions','Units','Normalized','Position',[.3,.68,.1,.03],'HorizontalAlignment','left')
spop1e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.4,.68,.1,.03]);
spop1=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.3,.67,.2,.01]);
spop1e.Callback=@(hobj,evd)editlistCB(spop1,'Input X position values');

uicontrol(fh,'Style','text','String','Y positions','Units','Normalized','Position',[.53,.68,.1,.03],'HorizontalAlignment','left')
spop2e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.63,.68,.1,.03]);
spop2=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.53,.67,.2,.01]);
spop2e.Callback=@(hobj,evd)editlistCB(spop2,'Input X position values');

uicontrol(fh,'Style','text','String','Z positions','Units','Normalized','Position',[.77,.68,.1,.03],'HorizontalAlignment','left')
spop3e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.87,.68,.1,.03]);
spop3=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.77,.67,.2,.01]);
spop3e.Callback=@(hobj,evd)editlistCB(spop3,'Input X position values');

srcposgrid.Callback=@(hobj,evd)placegridANDupdatestrings(spop1,spop2,spop3);

%% COSINE DIRECTIONS
uicontrol(fh,'Style','text','String','Source Direction Cosines (collimated sources)','Units','Normalized','Position',[.3,.53,.3,.06],'BackgroundColor',[1,1,.85])

uicontrol(fh,'Style','text','String','X positions','Units','Normalized','Position',[.3,.48,.1,.03],'HorizontalAlignment','left')
dpop1e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.4,.48,.1,.03]);
dpop1=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.3,.47,.2,.01]);
dpop1e.Callback=@(hobj,evd)editlistCB(dpop1,'Input X position values');

uicontrol(fh,'Style','text','String','Y positions','Units','Normalized','Position',[.53,.48,.1,.03],'HorizontalAlignment','left')
dpop2e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.63,.48,.1,.03]);
dpop2=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.53,.47,.2,.01]);
dpop2e.Callback=@(hobj,evd)editlistCB(dpop2,'Input X position values');

uicontrol(fh,'Style','text','String','Z positions','Units','Normalized','Position',[.77,.48,.1,.03],'HorizontalAlignment','left')
dpop3e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.87,.48,.1,.03]);
dpop3=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.77,.47,.2,.01]);
dpop3e.Callback=@(hobj,evd)editlistCB(dpop3,'Input X position values');

%% Ray POWER &   Ray WAVELENGTH & VISUALIZATION LENGTH
uicontrol(fh,'Style','text','String','All ray powers','Units','Normalized','Position',[.3,.33,.2,.05],'BackgroundColor',[1,1,.85])
pwrbox=uicontrol(fh,'Style','edit','String','','Units','Normalized','Position',[.51,.33,.07,.05]);

uicontrol(fh,'Style','text','String','Wavelength for all rays','Units','Normalized','Position',[.3,.25,.25,.05],'BackgroundColor',[1,1,.85])
wvlbox=uicontrol(fh,'Style','edit','String','','Units','Normalized','Position',[.56,.25,.07,.05]);

uicontrol(fh,'Style','text','String','Ray Visualization Length','Units','Normalized','Position',[.3,.17,.23,.05],'BackgroundColor',[1,1,.85])
visLbox=uicontrol(fh,'Style','edit','String','','Units','Normalized','Position',[.54,.17,.07,.05]);

%% The close button
uicontrol(fh,'Units','Normalized', 'Position', [.05,.15,.2,.2],'String','Save & Close','Callback',@(hobj,cbd)savcloseSrcGui())

visYN=uicontrol(fh,'Style','Check','Units','normalized','Position',[.3,.07,.4,.05],'String','Allow source to be visualized','Value',1);

%% ADDITIONAL STUFF THAT HELPS CORRECT FLOW
 

    if isempty(source2edit.Name), source2edit.Name='New Source'; end
    fh.Name=source2edit.Name;
    fh.NumberTitle='off';
    loadSrcGui()



uiwait(fh)


%%    ONLY NESTED FUNCTIONS FOLLOW

    function editlistCB(obj,tytle)
        strout=inputdlg('Input one value per line',tytle,5,{obj.String});
        if ~isempty(strout), obj.String=strout{1}; end
    end

    function placegridANDupdatestrings(container1,container2,container3)
            [xpos,ypos,zpos]=makePlaneGrid(EnvO.EnvAxes);
            container1.String=num2str(xpos);
            container2.String=num2str(ypos);
            container3.String=num2str(zpos);
    end



%% 
    function loadSrcGui()
        
        %Load the name string
        if ~isempty(source2edit.Name)
        namestr.String=source2edit.Name;
        end
        
        %Load the space
        if ~isempty(source2edit.StartSpace)
            if isvalid(source2edit.StartSpace)
                spcstr.String=source2edit.StartSpace.Name;
            end
        end
        
        %Load the RayStartingPoints
        if ~isempty(source2edit.RayStartingPoints)
            rpop1.String=num2str(source2edit.RayStartingPoints(:,1));   rpop2.String=num2str(source2edit.RayStartingPoints(:,2));   rpop3.String=num2str(source2edit.RayStartingPoints(:,3));
        end
        
        %Load the PointSourceLocations
        if ~isempty(source2edit.PointSourceLocations)
            spop1.String=num2str(source2edit.PointSourceLocations(:,1));   spop2.String=num2str(source2edit.PointSourceLocations(:,2));   spop3.String=num2str(source2edit.PointSourceLocations(:,3));
        end
        
        %load if sourcesBecomeTargets
        if ~isempty(source2edit.sourcesBecomeTargets)
            revrsd.Value=source2edit.sourcesBecomeTargets;
        end
        
        %Load the CollimatedSourceCosines
        if ~isempty(source2edit.CollimatedSourceCosines)
            dpop1.String=num2str(source2edit.CollimatedSourceCosines(:,1));   dpop2.String=num2str(source2edit.CollimatedSourceCosines(:,2));   dpop3.String=num2str(source2edit.CollimatedSourceCosines(:,3));
        end
        
        %Load the RayPower
        if ~isempty(source2edit.PointSourcePowers) || ~isempty(source2edit.CollimatedSourcePowers)
            pwrbox.String=num2str(mean([source2edit.PointSourcePowers;source2edit.CollimatedSourcePowers]));
        end
        
        %Load the wavelength
        if ~isempty(source2edit.PointSourceWavelengths) || ~isempty(source2edit.CollimatedSourceWavelengths)
            wvlbox.String=num2str(mean([source2edit.PointSourceWavelengths;source2edit.CollimatedSourceWavelengths]));
        end
        
        %Load the visualization length
        if ~isempty(source2edit.VisualLength)
            visLbox.String=num2str(source2edit.VisualLength);
        end
        
        %Load the isVisualized status
        if ~isempty(source2edit.isVisualized) && source2edit.isVisualized
            visYN.Value=1;
        else
            visYN.Value=0;
        end
        
    end

%%
    function savesuccessful = saveSrcGui()
        savesuccessful=false;
        
        %Save the name string
        namestr.String=strtrim(namestr.String);
        if isempty(namestr.String), errordlg('The name entry box is empty. The source still needs a name.'); return; end
        for n=1:length(EnvO.SourceList)
            if source2edit~=EnvO.SourceList(n) && strcmp(namestr.String,EnvO.SourceList(n).Name)
                errordlg('The entered source name is already being used in the environment. Enter a unique name in the name box.'); return;
            end
        end
        source2edit.Name=namestr.String;
        
        %save the space
        spcstr.String=strtrim(spcstr.String);%trim down any leading or trailing white space
        source2edit.StartSpace = findobj(EnvO.SpaceList,'Name', spcstr.String);
        if isempty(source2edit.StartSpace), source2edit.StartSpace=EnvO.EnvironmentDS; end
        
        %save the RayStartingPoints
        source2edit.RayStartingPoints=[str2num(rpop1.String),str2num(rpop2.String),str2num(rpop3.String)]; %#ok<ST2NM>
        
        %save the PointSourceLocations
        source2edit.PointSourceLocations=[str2num(spop1.String),str2num(spop2.String),str2num(spop3.String)]; %#ok<ST2NM>
        %save if sourcesBecomeTargets;
        source2edit.sourcesBecomeTargets=revrsd.Value;
        %save the PointSourcePowers
        pwr=str2double(pwrbox.String); if ~isfinite(pwr), errordlg('The power entry has an error'); return; end
        source2edit.PointSourcePowers=pwr*ones(size(source2edit.PointSourceLocations,1),1);
        %save the PointSourceWavelengths
        wvl=str2double(wvlbox.String); if ~isfinite(wvl), errordlg('The wavelength entry has an error'); return; end
        source2edit.PointSourceWavelengths=wvl*ones(size(source2edit.PointSourceLocations,1),1);
        
        %save the CollimatedSourceCosines
        source2edit.CollimatedSourceCosines=[str2num(dpop1.String),str2num(dpop2.String),str2num(dpop3.String)]; %#ok<ST2NM>
        %save the CollimatedSourcePowers
        source2edit.CollimatedSourcePowers=pwr*ones(size(source2edit.CollimatedSourceCosines,1),1);
        %save the CollimatedSourceWavelengths
        source2edit.CollimatedSourceWavelengths=wvl*ones(size(source2edit.CollimatedSourceCosines,1),1);
        %save the visualization length
        source2edit.VisualLength=str2double(visLbox.String);
        %save the visualization status
        source2edit.isVisualized=visYN.Value;
        
        SrcO=source2edit;
        savesuccessful=true;
    end


%%    

    function savcloseSrcGui()
         savesuccessful=saveSrcGui();
         if savesuccessful
             %then close
             delete(fh);
         end
    end
end