function camorbit2(fgr,ONorOFFstr)
switch lower(ONorOFFstr)
    case 'on'
        fgr.UserData=fgr.CurrentPoint; %save the OLD current point (this is key)
        fgr.WindowButtonDownFcn=@(hobj,evd)setmotionF(hobj);
        fgr.WindowButtonUpFcn=@(hobj,evd)clearmoF(hobj);
        
    case 'off'
        fgr.WindowButtonDownFcn=@setmotion;
        fgr.WindowButtonUpFcn='';
    otherwise
        error('Unrecognized second argument string for camorbit2')
end


end


function setmotionF(fgr)
fgr.UserData=fgr.CurrentPoint;
fgr.WindowButtonMotionFcn=@(hobj,evd)wbm(hobj);
end

function clearmoF(fgr)
fgr.WindowButtonMotionFcn='';
end


function wbm(fgr)
camorbit(fgr.UserData(1)-fgr.CurrentPoint(1),fgr.UserData(2)-fgr.CurrentPoint(2))
fgr.UserData=fgr.CurrentPoint;
end
