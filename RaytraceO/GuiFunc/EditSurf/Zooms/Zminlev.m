


function Zminlev(guiP,currlevel,levelheight,pb,mb)
%Delete all items from the current level
remtags({['ZLc',num2str(currlevel)],['ZL',num2str(currlevel)]},guiP);%remtags applys '-regexp' arg to findobj
%Move buttons up
pb.UserData=currlevel-1;
pb.Position(2)=pb.Position(2)+levelheight;
mb.Position(2)=mb.Position(2)+levelheight;
guiP.Units='pixels'; currheight=guiP.Position(4);guiP.Units='normalized';
if (currheight-mb.Position(2))<5
    mb.Visible='off';
end
end