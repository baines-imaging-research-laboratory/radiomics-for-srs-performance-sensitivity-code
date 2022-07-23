classdef SurfaceAreaMethodOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString 
        chCalculationParameter
    end
    
    enumeration
        % Current unavailable:
        %VoxelFaces ('VoxelFaces') % surface area is found by finding voxel faces that are between true and false voxels and adding up their face areas
        FitMesh    ('Fit Mesh', 'mesh') % surface area is found by finding triangular mesh on isotropic voxels and then summing up the area of each triangular face
    end
    
    methods (Access = public)
        
        function enum = SurfaceAreaMethodOptions(chParameterFileString, chCalculationParameter)
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

