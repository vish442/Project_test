function interactiveSurfOpacity(fgr,srf)
delete(srf.UserData);%delete the prior sliderbar
if strcmpi(fgr.SelectionType,'alt')
srf.UserData=uicontrol(fgr,'Style','slider','min',.01,'Position',[fgr.CurrentPoint,15,80],'Value',srf.FaceAlpha,'Callback',@(hobj,evd)alteropacity(hobj,srf));
end
    
    function alteropacity(hobj,srf)
        srf.EdgeAlpha=hobj.Value;
        srf.FaceAlpha=hobj.Value;
    end

end


