function [ElementPosition,ElementNormal] = Projectorsetup(N,fc,Speed)
% This function helperSphericalProjector is only in support of
% ActiveSonarExample. It may be removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

azang = repmat(0:N)

r = fc/Speed*ones(size(azang));

x = r
y = 0.*sind(azang);
z = 0.*sind(azang);

ElementPosition = [x(:)';y(:)';z(:)'];
ElementNormal = [0';0'];