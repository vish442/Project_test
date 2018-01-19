classdef RaysetO < handle
    properties
        NumRays=0;
        RayPowers
        RayPositions
        RayDirections
        RayWavelengths
        RAYnS
        RayOpticalPathlengths
        WaveCountMod1 % *possibly* a more accurate representation of phase.  This is the OPD divided by the wavelength then modded by 1.  It gets modded at every surface encounter.
    end
    
    methods
        %the creator function
        function RaysO = RaysetO()
%             RaysO.NumRays=0;
        end
        function diditwork=testthis(RaysO,somvar)
            RaysO.RayOpticalPathlengths=0;
            c=somvar;
            
            pause;
            diditwork='well?';
        end
        % Add the parts of another rayset to this one
        function joinRaysetsAndSaveInFirst(RaysetA,RaysetB)
            RaysetA.NumRays=RaysetA.NumRays+RaysetB.NumRays;
            RaysetA.RayPowers=[RaysetA.RayPowers;RaysetB.RayPowers];
            RaysetA.RayPositions=[RaysetA.RayPositions;RaysetB.RayPositions];
            RaysetA.RayDirections=[RaysetA.RayDirections;RaysetB.RayDirections];
            RaysetA.RayWavelengths=[RaysetA.RayWavelengths;RaysetB.RayWavelengths];
            RaysetA.RAYnS=[RaysetA.RAYnS;RaysetB.RAYnS];
            RaysetA.RayOpticalPathlengths=[RaysetA.RayOpticalPathlengths;RaysetB.RayOpticalPathlengths];
            RaysetA.WaveCountMod1=[RaysetA.WaveCountMod1;RaysetB.WaveCountMod1];
        end
        
        function removeRays(RaysO,Indices)
            if islogical(Indices)
                RaysO.NumRays=RaysO.NumRays-sum(Indices);
            else
                RaysO.NumRays=RaysO.NumRays-length(Indices);
            end
            RaysO.RayPowers(Indices)=[];
            RaysO.RayPositions(Indices,:)=[];
            RaysO.RayDirections(Indices,:)=[];
            RaysO.RayWavelengths(Indices)=[];
            RaysO.RAYnS(Indices)=[];
            RaysO.RayOpticalPathlengths(Indices)=[];
            RaysO.WaveCountMod1(Indices)=[];
        end
        
        function subRayset=makeSubRayset(RaysO,Indices)
            subRayset=RaysetO;
            if islogical(Indices)
                subRayset.NumRays=sum(Indices);
            else
                subRayset.NumRays=length(Indices);
            end
            subRayset.RayPowers=RaysO.RayPowers(Indices);
            subRayset.RayPositions=RaysO.RayPositions(Indices,:);
            subRayset.RayDirections=RaysO.RayDirections(Indices,:);
            subRayset.RayWavelengths=RaysO.RayWavelengths(Indices);
            subRayset.RAYnS=RaysO.RAYnS(Indices);
            subRayset.RayOpticalPathlengths=RaysO.RayOpticalPathlengths(Indices);
            subRayset.WaveCountMod1=RaysO.WaveCountMod1(Indices);
        end
        
        
        function clearAllRays(RaysO)
            RaysO.NumRays=0;
            RaysO.RayPowers=[];
            RaysO.RayPositions=[];
            RaysO.RayDirections=[];
            RaysO.RayWavelengths=[];
            RaysO.RAYnS=[];
            RaysO.RayOpticalPathlengths=[];
            RaysO.WaveCountMod1=[];
        end
        
        function InvalidsIndices=normalizeRayDirectionVectors(RayO) %this function normalizes all the direction vectors except those that are very small, which are identified as invalids on the output 
            vectorsizes=sum(RayO.RayDirections.^2,2).^(1/2);
            InvalidsIndices=find(vectorsizes<1e-9);
            vectorsizes(InvalidsIndices)=1;
            RayO.RayDirections=RayO.RayDirections./((vectorsizes)*[1,1,1]);
        end
        
        function polarizeRayset(RaysO, OtherPolarizationParameters) %filler function for later use
            RaysO.RayPolarizations=OtherPolarizationParameters;
        end
    
    end
    
    events
        removed
    end
end