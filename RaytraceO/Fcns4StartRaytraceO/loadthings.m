    
    function loadthings()
        if strcmpi(questdlg('Load another system?'),'yes')
            [FILENAME, PATHNAME] = uigetfile('*.fig','Open a previously saved optical system');
            if ischar(FILENAME)
                    envOfigs=openfig([PATHNAME,FILENAME]);
                    EnvO=envOfigs(1).UserData; %UserData is stored with the environment handle during the save operation so that it can be used here
                    addTTBrEventListeners(envOfigs(1).UserData) %restore listeners - they aren't saved in a save operation
                    pushbutton11=findobj(envOfigs,'TooltipString','Reload Optical System');
                    pushbutton11.ClickedCallback=@(hobj,cbd)reloadEnvO(EnvO);
            end
            
        end
    end