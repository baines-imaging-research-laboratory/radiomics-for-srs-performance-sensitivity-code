classdef ExportColumnGroup < handle
    %ExportColumnGroup
    
    properties
        exportColumns = {} % cell array of ExportColumn
        
        imagingStudyIdentifier
        imagingSeriesIdentifier
        contourIdentifier
        
        columnGroupPrefix = '' % will be added infront of default category header
    end
    
    methods
        function obj = ExportColumnGroup(categories, imagingStudyIdentifier, imagingSeriesIdentifier, contourIdentifier, columnGroupPrefix)
            %obj = ExportColumnGroup(category, imagingStudyIdentifier, imagingSeriesIdentifier, contourIdentifier, columnGroupPrefix)
            numCategories = length(categories);
            
            exportColumns = cell(numCategories,1);
            
            for i=1:numCategories
                exportColumns{i} = ExportColumn(categories(i));
            end
            
            obj.exportColumns = exportColumns;
        
            obj.imagingStudyIdentifier = imagingStudyIdentifier;
            obj.imagingSeriesIdentifier = imagingSeriesIdentifier;
            obj.contourIdentifier = contourIdentifier;
            
            obj.columnGroupPrefix = columnGroupPrefix;
        end
        
        function headers = getColumnHeaders(obj)
            numCols = obj.getNumberOfColumns();
            headers = cell(1,numCols);
            
            for i=1:numCols
                if isempty(obj.columnGroupPrefix)
                    headers{i} = obj.exportColumns{i}.category.columnHeader;
                else
                    headers{i} = [obj.columnGroupPrefix, ' ', obj.exportColumns{i}.category.columnHeader];
                end
            end
        end
        
        function numColumns = getNumberOfColumns(obj)
            numColumns = length(obj.exportColumns);
        end
        
        function colIndex = setColumnNumbers(obj, colIndex)
            for i=1:obj.getNumberOfColumns
                obj.exportColumns{i}.setColumnNumber(colIndex);
                
                colIndex = colIndex + 1;
            end
        end
        
        function studies = getImagingStudies(obj, patient)
            studies = obj.imagingStudyIdentifier.getStudiesFromPatient(patient);
        end
        
        function series = getImagingSeries(obj, study)
            series = obj.imagingSeriesIdentifier.getSeriesFromStudy(study);
        end
        
        function contours = getContours(obj, series)
            contours = obj.contourIdentifier.getContoursFromSeries(series);
        end
    end
    
    methods (Static)
        function sheetHeaders = columnGroupsToHeaders(columnGroups)
            numColumns = ExportColumnGroup.getNumberOfColumnsForGroups(columnGroups);
            
            sheetHeaders = cell(1, numColumns);
            
            colIndex = 1;
            
            for i=1:length(columnGroups)
                numColumnsInGroup = columnGroups{i}.getNumberOfColumns();
                
                sheetHeaders(1,colIndex : colIndex + numColumnsInGroup - 1) =...
                    columnGroups{i}.getColumnHeaders;
                
                colIndex = colIndex + numColumnsInGroup;
            end
        end
        
        function numColumns = getNumberOfColumnsForGroups(columnGroups)
            numColumns = 0;
            
            for i=1:length(columnGroups)
                numColumns = numColumns + length(columnGroups{i}.exportColumns);
            end
        end
        
        function [] = setColumnNumbersForColumnGroups(columnGroups)
            colIndex = 1;
            
            for i=1:length(columnGroups)
                colIndex = columnGroups{i}.setColumnNumbers(colIndex);
            end
        end
    end
end

