classdef PerimeterMethodOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString
        chCalculationParameter
    end
    
    enumeration
        PixelEdges          ('Pixel Edges', 'pixel') % perimeter is found by tracing the boundary between true and false pixels and adding up the lengths of the segments making up this boundary
        FitPolygon          ('Fit Polygon', 'polygon') % perimeter is found by finding the polygon that best fits the mask and finding its perimeter
        % Currently unavailable:
        %ContouringPolygons  ('Longest Run Length') % perimeter is found by using the polygons originally used for contouring
    end
    
    methods (Access = public)
        
        function enum = PerimeterMethodOptions(chParameterFileString, chCalculationParameter)
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

