classdef AreaMethodOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString
        chCalculationParameter
    end
    
    enumeration
        PixelAreas          ('Pixel Areas', 'pixel') % area = (number of pixels) x (pixel area)
        FitPolygon          ('Fit Polygon', 'polygon') % area is found by fitting a polygon to the mask and then finding it's area
        % Currently unavailable:
        % ContouringPolygons  ('Contouring Polygons') % area is found by taking the original contouring poylgons and finding their area
    end
    
    methods (Access = public)
        
        function enum = AreaMethodOptions(chParameterFileString, chCalculationParameter)
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

