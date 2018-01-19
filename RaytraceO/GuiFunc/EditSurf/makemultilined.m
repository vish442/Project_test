%this function helps split up strings... not sure if this is used by
%RaytraceO still or not
function outputstringarray=makemultilined(inputstring,numlines)
numcharsmin=ceil(length(inputstring)/numlines);
k=length(inputstring);
linends=zeros(numlines+1,1);
cellofstrings=cell(1,numlines);
for n=2:numlines+1
    linends(n)=numcharsmin+linends(n-1);
    counter=0;
    if linends(n)>=k
        linends(n)=k;
    else
        while inputstring(linends(n)+counter)~=char(32)
            if linends(n)+counter>=k
                break;
            end
            counter=counter+1;
        end
        linends(n)=linends(n)+counter;
    end
    
    if linends(n-1)==linends(n);
        cellofstrings{n-1}=' ';
    else
        cellofstrings{n-1}=inputstring((linends(n-1)+1):linends(n));
    end
    
end
outputstringarray=char(cellofstrings);

end