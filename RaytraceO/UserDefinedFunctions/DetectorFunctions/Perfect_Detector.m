function [DetectedPositionsNx3,DetectedPowersNx1]=Perfect_Detector(RaysO,~)
DetectedPositionsNx3=RaysO.RayPositions;
DetectedPowersNx1=RaysO.RayPowers;
end