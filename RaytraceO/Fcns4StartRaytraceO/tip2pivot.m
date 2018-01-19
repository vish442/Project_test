
    function tip2pivot(fg,ax)
        dcmobj=datacursormode(fg);
        CI=getCursorInfo(dcmobj);
        if isempty(CI)
            errordlg('A datatip should already be in the figure.  Use the Data Cursor tool at the top of the figure to create one, then retry.')
            return;
        end
        if any(size(CI)>[1,1])
            errordlg('Only one datatip can be in the figure to use this feature. There are currently multiple datatips. Delete unwanted ones and retry.')
            return;
        end
        if all(size(CI)==[1,1])
            camtarget(ax,CI.Position);
        end
    end