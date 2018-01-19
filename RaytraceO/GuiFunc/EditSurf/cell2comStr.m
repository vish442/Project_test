function outputstr=cell2comStr(cellarrayofstrings) %used in EditSurfMain to make function handles, enabling them to put additional arguments into strings for the eval function
outputstr='';
for n=1:length(cellarrayofstrings)
    outputstr=[outputstr,',',cellarrayofstrings{n}]; %#ok<AGROW>
end
end
    