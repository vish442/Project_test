% keep non-normalized units children at the top
function knncatt(hobj)%serves as the SizeChangedFcn callback to a graphicsHandle object that calculates the height change of the object in pixels and shifts the children positions up or down by that amount
hobj.Units='Pixels';
heightchange=hobj.Position(4)-hobj.UserData;
hobj.UserData=hobj.Position(4);

hobj.Units='normalized';
for n=1:length(hobj.Children)
    hobj.Children(n).Position(2)=hobj.Children(n).Position(2)+heightchange;
end
end