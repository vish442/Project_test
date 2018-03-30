function [ElementPosition,ElementNormal] = Projectorsetup(N,fc,Speed)
% This function helperSphericalProjector is only in support of
% ActiveSonarExample. It may be removed in a future release.

%   Copyright 2016 The MathWorks, Inc.


% azang = repmat(0:N)

azang = repmat((1:N-1)*10,N-1,1);        
r = fc./Speed.*ones(size(azang));
x := matrix([[10, 10, 10], [10, 10, ]])
% x = azang;
% y = azang
% z = azang


ElementPosition = [x(:)';y(:)';z(:)'];
ElementNormal = [-90';-90'];
end