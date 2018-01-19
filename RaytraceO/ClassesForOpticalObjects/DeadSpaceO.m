classdef DeadSpaceO < SpaceO
    properties
        
    end
    
    methods
        function SpcO = DeadSpaceO()
            SpcO.Name='EnvironmentDeadSpace';
        end
        
        function propagateRayset(~)
            warning('A DeadSpaceO object ought not to call the propagateRayset function. Nothing happens here.')
        end
        
        function Indices=FindIndicesForRayset(~,RaysO)
            Indices=ones(RaysO.NumRays,1);
        end
        
        function addRaysToSpace(SpcO,RaysO,varargin)
            removeWeakRays(SpcO.Environment, RaysO);
            if RaysO.NumRays>0
                joinRaysetsAndSaveInFirst(SpcO.SpcRayset,RaysO)
            end
            %we leave SpcO.hasRays at false in case any other function
            %tries to identify rays to propagate here
        end
        
    end
    
    events
        
    end
end