function [paths,dop,aloss,rcvang,srcang] = helperBellhopArrivals(OperatingFrequency,BottomLoss,TwoWay)
% This function helperBellhopArrivals is only in support of
% ActiveSonarExample. It may be removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

numPaths = 10;
paths = zeros(3,numPaths);

fid = fopen('MunkB_eigenray_Arr.arr', 'r');% open the file
%Read information from the file header. Read frequencies (freq), number of
%source depths (Nsd), number of receiver depths (Nrd), and number of
%receiver ranges (Nrr).
header = fscanf(fid,'%f %i %i %i',4);
Nsd  = header(2);  
Nrd  = header(3);   
Nrr  = header(4);   

% Read sournce and receiver depths and receiver range
[~]   = fscanf(fid,'%f',Nsd);  
[~]   = fscanf(fid,'%f',Nrd);   
[~]   = fscanf(fid,'%f',Nrr);   
[~]   = fscanf(fid,'%i',1); 
Narr  = fscanf(fid,'%i',1);	

if Narr > 0  
  arrivalData = fscanf(fid,'%f',[8,Narr]);
  Narr = min(Narr,numPaths);
  paths(3,:) = -1*20*log10(abs(arrivalData(1,1:Narr).*exp(1i*arrivalData(2,1:Narr)*pi/180)));
  paths(1,:) = arrivalData(3,1:Narr) + 1i*arrivalData(4,1:Narr);
  srcang = [zeros(1,numPaths);arrivalData(5,1:Narr)];
  rcvang = [zeros(1,numPaths);arrivalData(6,1:Narr)];
  NumTopBnc = arrivalData(7,1:Narr);
  NumBotBnc = arrivalData(8,1:Narr);
end

fclose( fid );

paths(2,:) = sqrt(db2mag(repmat(-BottomLoss,1,numPaths))).^NumBotBnc.*...
  (-1).^(NumTopBnc);

dop = ones(1,numPaths);

aloss = [OperatingFrequency zeros(1,numPaths)];

if TwoWay
  paths(1,:) = 2*paths(1,:);
  paths(2,:) = paths(2,:).^2;
  paths(3,:) = 2*paths(3,:);
end

end
