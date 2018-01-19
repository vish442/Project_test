
    function savethings(EnvOmain)
        [FILENAME, PATHNAME] = uiputfile('*.fig','Save current optics to file');
        if ischar(FILENAME)
            EnvOmain.EnvFig.Name=[FILENAME,' - Optical System View']; %change figure heading
            EnvOmain.EnvTTBo.ParentFigure.Name=[FILENAME,' - RaytraceO objects']; %change figure heading
            EnvOmain.EnvFig.UserData=EnvOmain; %save so the environment object can be accessed by loadthings to load the event listeners
            EnvOmain.EnvTTBo.ParentFigure.UserData=EnvOmain; %insurance, in case the preceeding line doesn't save to the figure that loadthings picks
            savefig([EnvOmain.EnvFig,EnvOmain.EnvTTBo.ParentFigure],[PATHNAME,FILENAME]);
        end
    end