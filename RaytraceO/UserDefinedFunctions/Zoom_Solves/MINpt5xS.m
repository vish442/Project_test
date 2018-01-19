%ActualZoomVariable=MINpt5xS(EnvironmentZoomVariable,scale)
%EnvironmentZoomVariable is the value between 0 and 1 held by the
%environment.
%ActualZoomVariable is the actual zoom distance or rotation angle that
%results after EnvironmentZoomVariable is modified by the function.
%
%This function performs the following: 
%     ActualZoomVariable=(EnvironmentZoomVariable-.5)*scale

function ActualZoomVariable=MINpt5xS(EnvironmentZoomVariable,scale)
ActualZoomVariable=(EnvironmentZoomVariable-.5)*scale;
end