%This opens the main GUI for editing a SourceO object within an
%EnvironmentO

function SpcO=EditSpaceMain(space2edit) %at this point, the user should have already filled the space2edit.Environment property with an EnvironmentO object
SpcO=0;
fh=figure('MenuBar','none','NumberTitle','off');
EnvO=space2edit.Environment;


%% SPACE NAME 
uicontrol(fh,'Style','text','String','Space Name','Units','Normalized','Position',[.05,.28,.2,.05],'Units','pixels','BackgroundColor',[1,1,.85])
namestr=uicontrol(fh,'Style','edit','String','','Units','Normalized','Position',[.05,.22,.2,.05],'Units','pixels');

% INPUT THE SURFACES THAT SHOULD BELONG TO THE SPACE
uicontrol(fh,'Style','text','String','Surfaces that bound this space','Units','Normalized','Position',[.3,.29,.3,.03],'Units','pixels','HorizontalAlignment','left')
rpop1e=uicontrol(fh,'Style','pushbutton','String','Edit','Units','Normalized','Position',[.5,.23,.1,.05],'Units','pixels');
surfsPop=uicontrol(fh,'Style','popup','String',' ','Units','Normalized','Position',[.3,.27,.2,.01],'Units','pixels');
rpop1e.Callback=@(hobj,evd)editlistCB(surfsPop,'Input surface names that bound this space - 1 per line:');

%Input the refractive index function 
uicontrol(fh,'Style','text','Units','normalized','Position',[.3,.15,.3,.03],'Units','pixels','String','Refractive Index Function Name:','HorizontalAlignment','left');
refrctvFcn{1}=uicontrol(fh,'Style','edit','Units','normalized','Position',[.3,.09,.2,.05],'Units','pixels','String','leave off .m','HorizontalAlignment','left','TooltipString', sprintf('Only put the function name here.  The function should follow the following format:\n(RefrctvIndicesNx1) = RefrctvIndxFcn (RaysetOobj ,\n ... + any additional arguments for your function (if needed)).'));
refrctvFcn{2}=uicontrol(fh,'Style','pushbutton','Units','normalized','Position',[.51,.09,.04,.05],'Units','pixels','String','...','HorizontalAlignment','left','Callback',{@addparams});

fh.Position(4)=150;


%% The close button
uicontrol(fh, 'Position', [40,20,90,50],'String','Save & Close','Callback',@(hobj,cbd)savcloseSpcGui())

%% ADDITIONAL STUFF THAT HELPS CORRECT FLOW


    if isempty(space2edit.Name), space2edit.Name='New Space'; end
    fh.Name=space2edit.Name;
    fh.NumberTitle='off';
    loadSpaceOtoGui()



uiwait(fh)


%%    ONLY NESTED FUNCTIONS FOLLOW

    function editlistCB(obj,tytle)
        strout=inputdlg('Input one value per line',tytle,5,{obj.String});
        if ~isempty(strout), obj.String=strout{1}; end
    end



%% 
    function loadSpaceOtoGui()
        
        %Load the name string
        if ~isempty(space2edit.Name)
        namestr.String=space2edit.Name;
        end

        %Load the Surfaces Names to the popup uicontrol
        if ~isempty(space2edit.Surfaces) %if there are surface names to upload
            N=length(space2edit.Surfaces);
            strcellarray=cell(1,N); %initialize the cell container to hold surface names
            for n=1:N
                if isvalid(space2edit.Surfaces{n})
                    strcellarray{n}=space2edit.Surfaces{n}.Name; %load the surface names to a cell array
                end
            end 
            m=1;%initialize counter
            while ~(m>length(strcellarray))
                if isempty(strcellarray{n}), strcellarray(n)=[]; else m=m+1; end %get rid of empty cells so that char(strcellarray) works
            end
            surfsPop.String=char(strcellarray); %transfer the names to the popup uicontrol
        end
        
        %Load the RefractiveIndxFcn
        if ~isempty(space2edit.RefractiveIndxFcn)
            str=func2str(space2edit.RefractiveIndxFcn);
            Cpr=strfind(str,')');
            Opr=strfind(str,'(');
            refrctvFcn{1}.String=str(Cpr(1)+1:Opr(2)-1);
            Cbr=strfind(str,']');
            Obr=strfind(str,'[');
            addargcell=cell(1,length(Cbr));
            for n=1:length(Cbr)
                addargcell{n}=str(Obr(n):Cbr(n));
            end
            refrctvFcn{2}.String=char(addargcell);
        end
        
    end

%%
    function savesuccessful = saveSpcGui()
        savesuccessful=false;
        %Save the name string to the SpaceO object
        namestr.String=strtrim(namestr.String);
        if isempty(namestr.String), errordlg('The name entry box is empty. The space still needs a name.'); return; end
        for n=1:length(EnvO.SpaceList)
            if space2edit~=EnvO.SpaceList(n) && strcmp(namestr.String,EnvO.SpaceList(n).Name)
                errordlg('The entered space name is already being used in the environment. Enter a unique name in the name box.'); return;
            end
        end
        space2edit.Name=namestr.String;
        
        %save surfaces to the SpaceO object
        cellsforSurfaces=cell(1,size(surfsPop.String,1));  keepers=true(1,size(surfsPop.String,1));
        for n=1:size(surfsPop.String,1)
            NameOfsrfORdet=strtrim(surfsPop.String(n,:));
            obj1=findobj(EnvO.SurfaceList,'Name',NameOfsrfORdet);
            obj2=findobj(EnvO.DetectorList,'Name',NameOfsrfORdet);
            if ~isempty(obj1)
                cellsforSurfaces{n}=obj1;
                if ~isempty(obj2), errordlg('It appears you have a surface and a detector both having the same name. EditSurfMain SHOULD HAVE CAUGHT THIS. The surface needs to be renamed.'); return; end
            elseif ~isempty(obj2)
                cellsforSurfaces{n}=obj2;
            elseif ~isempty(NameOfsrfORdet) %if there was a valid string found, but it didn't register with any of the system surfaces then do this
                errordlg('One of the listed surfaces or detectors was not found in the environment.'); return;
            else %if no valid string was found then it must have been blank space, so don't keep it
                keepers(n)=false;
            end
        end
        space2edit.Surfaces=cellsforSurfaces(keepers);
                
        
        
        %save the refractive index function to the SpaceO object
        refrctvFcn{1}.String=strtrim(refrctvFcn{1}.String);
            if exist(refrctvFcn{1}.String,'file')~=2 %check that the refractive index function is valid
                if exist(refrctvFcn{1}.String,'builtin')==5
                    warndlg('You might not want to use a standard matlab function for your refractive index solve');
                else
                    errordlg('You need to specify a refractive index solve that exists on the path','Bad Refractive Index Function')
                    return;
                end
            end
            %get any additional arguments
            addarg={};
            for n=1:size(refrctvFcn{2}.String,1)
                addval=str2num(refrctvFcn{2}.String(n,:)); %#ok<ST2NM>
                if ~isempty(addval)
                    addarg=[addarg,{['[',num2str(addval),']']}]; %#ok<AGROW>
                end
            end
            space2edit.RefractiveIndxFcn=str2func(['@(RaysOobj)',refrctvFcn{1}.String,'(RaysOobj',cell2comStr(addarg),')']);
            
        %return the object
        SpcO=space2edit;
        savesuccessful=true;
    end


%%    

    function savcloseSpcGui()
         savesuccessful=saveSpcGui();
         if savesuccessful
             %then close the gui
             delete(fh);
         end
    end
end