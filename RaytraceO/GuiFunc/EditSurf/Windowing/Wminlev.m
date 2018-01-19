


function Wminlev(guiP,currlevel,levelheight,pb,mb)
%Delete all items from the current level
remtags({['WL',num2str(currlevel)],['WP',num2str(currlevel)],['WS',num2str(currlevel)],['WC',num2str(currlevel)]},guiP);
%Move buttons up
pb.UserData=currlevel-1;
pb.Position(2)=pb.Position(2)+levelheight;
mb.Position(2)=mb.Position(2)+levelheight;
guiP.Units='pixels'; currheight=guiP.Position(4);guiP.Units='normalized';
if (currheight-mb.Position(2))<5
    mb.Visible='off';
end
end