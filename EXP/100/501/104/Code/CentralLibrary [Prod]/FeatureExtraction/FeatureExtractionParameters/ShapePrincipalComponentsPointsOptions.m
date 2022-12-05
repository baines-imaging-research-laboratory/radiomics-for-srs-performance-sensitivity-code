classdef ShapePrincipalComponentsPointsOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString
        chCalculationParameter
    end
    
    enumeration
        AllVoxelCentres      ('All Voxel Centres', 'all') % principal components found using all voxel centres
        ExteriorVoxelCentres ('Fit Polygon/Mesh Vertices', 'exterior') % principal components found using only voxel centres that have a false voxel next to at least one face (3D: 6 connectivity, not 26 connectivity; 2D: 4 connectivity, not 8 connectivity)
    end
    
    methods (Access = public)
        
        function enum = ShapePrincipalComponentsPointsOptions(chParameterFileString, chCalculationParameter)
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

