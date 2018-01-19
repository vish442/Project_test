function setlev(guiP,tolev,currlevel,levelheight,pb,mb,i_or_n)
steps=tolev-currlevel;
if steps<0
    for n=1:abs(steps)
        minlev(guiP,pb.UserData,levelheight,pb,mb,i_or_n);
    end
elseif steps>0
    for n=1:steps
        addlev(guiP,pb.UserData,levelheight,pb,mb,i_or_n);
    end
end
end