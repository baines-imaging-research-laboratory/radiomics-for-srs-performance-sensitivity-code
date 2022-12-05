classdef MeshMaskInterpolationVoxelSizeSourceOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString 
        chCalculationParameter
    end
    
    enumeration
        Min ('Min Voxel Dimension', 'min') 
        Max ('Max Voxel Dimension', 'max')
    end
    
    methods (Access = public)
        
        function enum = MeshMaskInterpolationVoxelSizeSourceOptions(chParameterFileString, chCalculationParameter)
            enum.chParameterFileString = chParameterFileString;       
            enum.chCalculationParameter = chCalculationParameter;
        end
        
        function chParameterFileString = GetParameterFileString(enum)
            chParameterFileString = enum.chParameterFileString;
        end
        
        function chCalculationParameter = GetCalculationParameter(enum)
            chCalculationParameter = enum.chCalculationParameter;
        end
    end
end

