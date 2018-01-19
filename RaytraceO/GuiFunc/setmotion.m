function setmotion(fgr,~)
set(fgr,'WindowButtonUpFcn',@clearWBMotion);
fgr.UserData=fgr.CurrentPoint; %save the OLD current point (this is key)
switch fgr.SelectionType
    case {'open','alt'}
        set(fgr,'WindowButtonMotionFcn',@camrorbit)
    case 'normal'
        set(fgr,'WindowButtonMotionFcn',@camrpan)
end
end

function camrorbit(fgr,~)
camorbit(fgr.UserData(1)-fgr.CurrentPoint(1),fgr.UserData(2)-fgr.CurrentPoint(2));
fgr.UserData=fgr.CurrentPoint;
end

function camrpan(fgr,~)
camdolly((fgr.UserData(1)-fgr.CurrentPoint(1))/fgr.Position(3)*2.5,(fgr.UserData(2)-fgr.CurrentPoint(2))/fgr.Position(3)*2.5,0);
fgr.UserData=fgr.CurrentPoint;
end

function clearWBMotion(fgr,~)
set(fgr,'WindowButtonMotionFcn','')
end