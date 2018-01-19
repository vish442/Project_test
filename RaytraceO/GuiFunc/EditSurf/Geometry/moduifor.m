function moduifor(iFuncBox_h,nFuncBox_h,iguiP,nguiP,icurrlevel,ncurrlevel,levelheight,ipb,npb,imb,nmb)
surftypes=['Plane             ';...
            'Sphere            ';...
            'Cylinder          ';...
            'Paraloid_Symmetric'];
sel=listdlg('PromptString','Choose which surface type you want for this surface:','ListString',surftypes,'SelectionMode','single');

%------- begin
%Try to get both iguiP and nguiP boxes to have their current size updated
%to fit the current stretch of the figure by temporarily changing their
%visibility settings to 'on', and then changing them back to their original
%settings (this is needed since we add buttons to both iguiP and nguiP
%below, and if this is done without having current stretch size accounted
%for, things get messed up):
istate=iguiP.Visible;nstate=nguiP.Visible;iguiP.Visible='on';iguiP.Visible=istate;nguiP.Visible='on';nguiP.Visible=nstate;
%------- end - it works!

switch sel
    case 1
        iFuncBox_h.String='RayIntersects_Plane';
        nFuncBox_h.String='SurfNormals_Plane';
        setlev(iguiP,2,icurrlevel,levelheight,ipb,imb,'i');
        setlev(nguiP,1,ncurrlevel,levelheight,npb,nmb,'n');
        set(findobj(iguiP,'Tag','isGe1'),'String','Put any plane point here in x y z format');
        set(findobj(iguiP,'Tag','isGe2'),'String','Put plane surface-normal direction here in x y z format');
        set(findobj(nguiP,'Tag','nsGe1'),'String','Put plane surface-normal direction (again) here in x y z format');
        
    case 2
        iFuncBox_h.String='RayIntersects_Sphere';
        nFuncBox_h.String='SurfNormals_Sphere';
        setlev(iguiP,2,icurrlevel,levelheight,ipb,imb,'i');
        setlev(nguiP,1,ncurrlevel,levelheight,npb,nmb,'n');
        set(findobj(iguiP,'Tag','isGe1'),'String','Put sphere center point here in x y z format');
        set(findobj(iguiP,'Tag','isGe2'),'String','Put sphere radius here');
        set(findobj(nguiP,'Tag','nsGe1'),'String','Put sphere center point (again) here in x y z format');
        
    case 3
        iFuncBox_h.String='RayIntersects_Cylinder';
        nFuncBox_h.String='SurfNormals_Cylinder';
        setlev(iguiP,3,icurrlevel,levelheight,ipb,imb,'i');
        setlev(nguiP,2,ncurrlevel,levelheight,npb,nmb,'n');
        set(findobj(iguiP,'Tag','isGe1'),'String','Put any cylinder axis point here in x y z format');
        set(findobj(iguiP,'Tag','isGe2'),'String','Put cylinder axis direction here in x y z format');
        set(findobj(iguiP,'Tag','isGe3'),'String','Put cylinder radius here');
        set(findobj(nguiP,'Tag','nsGe1'),'String','Put any cylinder axis point (again) here in x y z format');
        set(findobj(nguiP,'Tag','nsGe2'),'String','Put cylinder axis direction (again) here in x y z format');
        
    case 4
        iFuncBox_h.String='RayIntersects_ParabaloidSymmetric';
        nFuncBox_h.String='SurfNormals_ParabaloidSymmetric';
        setlev(iguiP,2,icurrlevel,levelheight,ipb,imb,'i');
        setlev(nguiP,2,ncurrlevel,levelheight,npb,nmb,'n');
        set(findobj(iguiP,'Tag','isGe1'),'String','Put parabaloid vertex point here in x y z format');
        set(findobj(iguiP,'Tag','isGe2'),'String','Put parabaloid focus point here in x y z format');
        set(findobj(nguiP,'Tag','nsGe1'),'String','Put parabaloid vertex point (again) here in x y z format');
        set(findobj(nguiP,'Tag','nsGe2'),'String','Put parabaloid focus point (again) here in x y z format');
        
    otherwise
        error('We don''t have a treatment for that case yet')
end
end