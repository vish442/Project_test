

function addlev(guiP,currlevel,levelheight,pb,mb,i_or_n)
guiP.Units='pixels'; currheight=guiP.Position(4);guiP.Units='normalized';
atlevel=currlevel+1;
suffixes={'st','nd','rd','th'};
if strcmpi(i_or_n,'i'), usestr='The first three arguments of intersect solves are always reserved for RayPositionsNx3, RayDirectionsNx3, and WindowingFcnHndl'; else usestr='The first argument of any surface normal solve is always reserved for SurfacePositionsNx3'; end
if strcmpi(i_or_n,'i'), lu=3; else lu=1; end

uicontrol(guiP,'Style','Text','Position',[36,currheight-56-levelheight*atlevel,290,16],...
    'HorizontalAlignment','left','Tag',[i_or_n,'sGt',num2str(atlevel)],'String',...
    ['The ',num2str(atlevel),suffixes{min(atlevel,4)},' geometric argument needed for the above function:']);

uicontrol(guiP,'Style','Edit','Position',[36,currheight-72-levelheight*atlevel,280,19],...
    'HorizontalAlignment','left','Tag',[i_or_n,'sGe',num2str(atlevel)],'String',['Put the ',num2str(atlevel),suffixes{min(atlevel,4)},' geometric input arg here.'],...
    'TooltipString',['This should be the ',num2str(atlevel+lu),suffixes{min(atlevel+lu,4)},' argument of the specified function. ',usestr]);

pb.Position(2)=pb.Position(2)-levelheight;
mb.Position(2)=mb.Position(2)-levelheight;
if (currheight-mb.Position(2))>70
    mb.Visible='on';
end
pb.UserData=atlevel;
end
