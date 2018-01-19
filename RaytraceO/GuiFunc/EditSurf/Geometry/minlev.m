


function minlev(guiP,currlevel,levelheight,pb,mb,i_or_n)
delete(findobj(guiP,'Tag',[i_or_n,'sGt',num2str(currlevel)]));
delete(findobj(guiP,'Tag',[i_or_n,'sGe',num2str(currlevel)]));
pb.UserData=currlevel-1;
pb.Position(2)=pb.Position(2)+levelheight;
mb.Position(2)=mb.Position(2)+levelheight;
guiP.Units='pixels'; currheight=guiP.Position(4);guiP.Units='normalized';
if (currheight-mb.Position(2))<70
    mb.Visible='off';
end
end