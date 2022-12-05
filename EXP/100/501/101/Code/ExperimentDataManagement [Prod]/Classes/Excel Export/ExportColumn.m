classdef ExportColumn < handle
    %ExportColumn
    
    properties
        category % ExportCategories entry
                
        columnNumber = 0
    end
    
    methods
        function obj = ExportColumn(category)
            %obj = ExportColumn(category)
            obj.category = category;
        end
        
        function colNum = getColumnNumber(obj)
            colNum = obj.columnNumber;
        end
        
        function [] = setColumnNumber(obj, colNumber)
            obj.columnNumber = colNumber;
        end
    end
    
    methods (Static)
        function bool = columnsContainAssociatedClass(columns, classObject)
            bool = false;
            
            className = class(classObject);
            
            for i=1:length(columns)
                if strcmp(class(columns{i}.category.associatedClass), className)
                    bool = true;
                    break;
                end
            end
        end
    end
end

