classdef VolumeMethodOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString  
        chCalculationParameter
    end
    
    enumeration
        VoxelVolumes ('Voxel Volumes', 'voxel') % volume = (number of voxels) x (volume of voxel)
        % Currently unavailable:
        %FitMesh      ('Fit Mesh') % find the triangular mesh for isotropic voxels and then find the area of this mesh (ensure it is a closed mesh)
    end
    
    methods (Access = public)
        
        function enum = VolumeMethodOptions(chParameterFileString, chCalculationParameter)
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

