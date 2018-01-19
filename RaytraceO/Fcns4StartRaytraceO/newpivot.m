    function newpivot(ax)
        uipt=inputdlg(['The current viewing pivot point on the axes is [',num2str(camtarget(ax)),']. What new pivot point do you want to use?']);
        if ~isempty(uipt), nppt=str2num(uipt{1}); else nppt='whatevs'; end %#ok<ST2NM>
        if isnumeric(nppt) && all(size(nppt)==[1,3])
            camtarget(ax,nppt);
        end
    end