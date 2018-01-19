function makePanelCurrent(cellarrayofPanels,whichpanel)
    for n=1:length(cellarrayofPanels)
        if n==whichpanel
            cellarrayofPanels{n}.Visible='on';
        else
            cellarrayofPanels{n}.Visible='off';
        end
    end
end
