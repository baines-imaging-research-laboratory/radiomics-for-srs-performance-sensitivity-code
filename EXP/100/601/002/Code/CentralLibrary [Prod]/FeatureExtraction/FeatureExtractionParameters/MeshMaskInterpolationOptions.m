classdef MeshMaskInterpolationOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString 
        chCalculationParameter
    end
    
    enumeration
        Interp3D    ('3D Interpolation', 'interpolate3D') 
        Levelsets   ('Levelsets', 'levelsets')
        None        ('None', 'none')
    end
    
    methods (Access = public)
        
        function enum = MeshMaskInterpolationOptions(chParameterFileString, chCalculationParameter)
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

