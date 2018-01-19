function remtags(tagstringcellarray,parentobj)
for n=1:length(tagstringcellarray)
    delete(findobj(parentobj,'-regexp','Tag',tagstringcellarray{n}));
end
end