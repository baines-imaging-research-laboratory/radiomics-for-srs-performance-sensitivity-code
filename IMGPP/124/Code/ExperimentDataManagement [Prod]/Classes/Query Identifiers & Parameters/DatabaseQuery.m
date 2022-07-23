classdef DatabaseQuery
    %DatabaseQuery
    
    properties (SetAccess = immutable, GetAccess = private)
        bMinimalRowFilling = false
    end
    
    properties (Access = private)
        voClassQueries (1,:) ClassQuery = ClassQuery.empty(1,0)
        vbClassQueryComplete (1,:) logical = logical.empty(1,0)
    end
    
    methods (Access = public)
        function obj = DatabaseQuery(voClassQueries, bMinimalRowFilling)
            arguments
                voClassQueries (1,:) ClassQuery
                bMinimalRowFilling (1,1) logical = false
            end
            
            %obj = DatabaseQuery(voClassQueries, varargin)
            obj.voClassQueries = voClassQueries;
            obj.vbClassQueryComplete = false(size(voClassQueries));
            
            obj.bMinimalRowFilling = bMinimalRowFilling;
        end
        
        function [c1vxResults, c2chHeaders] = Execute(obj, oParentObj)
            %c2xResults = execute(obj, oParentObj)
            
            if obj.AllQueriesComplete
                c1vxResults = {};
                c2chHeaders = {};
            else
                dMatchIndex = 0;
                dNumMatches = 0;
                
                for dQueryIndex=1:length(obj.voClassQueries)
                    if isa(oParentObj, obj.voClassQueries(dQueryIndex).GetParentClass())
                        dMatchIndex = dQueryIndex;
                        dNumMatches = dNumMatches + 1;
                    end
                end
                
                if dNumMatches < 1
                    error(...
                        'DatabaseQuery:Execute:NoClassMatchFound',...
                        ['No queries found for parent class: ', class(oParentObj)]);
                elseif dNumMatches > 2
                    error(...
                        'DatabasseQuery:Execute:MultipleClassMatchesFound',...
                        [num2str(dNumMatches), ' query matches for parent class ', class(oParentObj), ' were found. Only a single query for each parent class is valid']);
                else
                    % get results for parent object and selected objects to
                    % perform next level of query on
                    [c1vxParentObjectResults, voSelectedObjects] = obj.voClassQueries(dMatchIndex).Execute(oParentObj);
                    
                    c2chParentObjectHeaders = obj.voClassQueries(dMatchIndex).GetColumnHeaders();                    
                    
                    
                    obj.vbClassQueryComplete(dMatchIndex) = true;
                    
                    
                    % pre-allocate the cell arrays to store results of
                    % next level of query on the selected objects
                    dNumSelectedObjects = length(voSelectedObjects);
                    c1c1vxPerSelectedObjectResults = cell(dNumSelectedObjects,1);
                    
                    c2chPerSelectedObjectHeaders = {};
                    
                    
                    % get query results for each selected object
                    for dSelectedObjectIndex=1:dNumSelectedObjects
                        [c2xSelectedObjectResults, c2chSelectedObjectHeaders] = obj.Execute(voSelectedObjects(dSelectedObjectIndex));
                        
                        c1c1vxPerSelectedObjectResults{dSelectedObjectIndex} = c2xSelectedObjectResults;
                        
                        if numel(c2chSelectedObjectHeaders) > numel(c2chPerSelectedObjectHeaders)
                            c2chPerSelectedObjectHeaders = c2chSelectedObjectHeaders;
                        end
                    end
                    
                    if isa(oParentObj,'StudyDatabase')
                        x = 1;
                    end
                    
                    if isempty(c1c1vxPerSelectedObjectResults) || isempty(c1c1vxPerSelectedObjectResults{1})
                        c1vxResults = c1vxParentObjectResults;
                        c2chHeaders = c2chParentObjectHeaders;
                    else
                        c2chHeaders = [c2chParentObjectHeaders, c2chPerSelectedObjectHeaders];
                        
                        % find size of array to hold ALL of the query results from
                        % the selected objects
                        dNumSelectedObjectResultColumns = max(cellfun(@(x) size(x,2), c1c1vxPerSelectedObjectResults));
                        
                        
                        dNumSelectedObjectResultRows = 0;
                        
                        for dSelectedObjectIndex=1:dNumSelectedObjects
                            dNumSelectedObjectResultRows = dNumSelectedObjectResultRows + size(c1c1vxPerSelectedObjectResults{dSelectedObjectIndex}{1},1);
                        end
                        
                        dNumParentObjectResultColumns = size(c1vxParentObjectResults,2);
                        
                        % allocate the cell array to hold all of the results
                        c1vxResults = cell(1, dNumSelectedObjectResultColumns + dNumParentObjectResultColumns);
                        
                        % figure out how to pre-allocate columns
                        if obj.bMinimalRowFilling % have to use cell arrays in order to have "gaps"
                            for dColumnIndex=1:length(c1vxResults)
                                c1vxResults{dColumnIndex} = cell(dNumSelectedObjectResultRows, 1);
                            end
                        else % can use vectors, if possible
                            for dColumnIndex=1:length(c1vxResults)
                                if dColumnIndex <= dNumParentObjectResultColumns
                                    if iscell(c1vxParentObjectResults{dColumnIndex})
                                        c1vxResults{dColumnIndex} = cell(dNumSelectedObjectResultRows, 1);
                                    else
                                        c1vxResults{dColumnIndex} = repmat(c1vxParentObjectResults{dColumnIndex}(1), dNumSelectedObjectResultRows, 1);
                                    end
                                else
                                    bIsNotCellInAllSelectedObjectResults = true;
                                    
                                    dSelectedObjectColumnIndex = dColumnIndex - dNumParentObjectResultColumns;
                                    
                                    for dSelectedObjectIndex=1:length(c1c1vxPerSelectedObjectResults)
                                        c1vxSelectedObjectResults = c1c1vxPerSelectedObjectResults{dSelectedObjectIndex};
                                        
                                        if iscell(c1vxSelectedObjectResults{dSelectedObjectColumnIndex})
                                            bIsNotCellInAllSelectedObjectResults = false;
                                            break;
                                        end
                                    end
                                    
                                    if bIsNotCellInAllSelectedObjectResults % allocate vector
                                        c1vxResults{dColumnIndex} = repmat(c1c1vxPerSelectedObjectResults{1}{dSelectedObjectColumnIndex}(1), dNumSelectedObjectResultRows, 1);
                                    else % allocate cells
                                        c1vxResults{dColumnIndex} = cell(dNumSelectedObjectResultRows,1);
                                    end
                                end
                            end
                        end
                        
                        % add each selected objects results to the cell array
                        dResultsRowIndex = 1;
                        
                        for dSelectedObjectIndex=1:dNumSelectedObjects
                            dNumRowsToInsert = size(c1c1vxPerSelectedObjectResults{dSelectedObjectIndex}{1},1);
                            
                            % copy the parent results into each row
                            if obj.bMinimalRowFilling || dNumRowsToInsert == 0% only fill in results for the top row
                                for dColumnIndex=1:dNumParentObjectResultColumns
                                    if iscell(c1vxParentObjectResults{dColumnIndex})
                                        xVal = c1vxParentObjectResults{dColumnIndex}{dSelectedObjectIndex};
                                    else
                                        xVal = c1vxParentObjectResults{dColumnIndex}(dSelectedObjectIndex);
                                    end
                                    
                                    c1vxResults{dColumnIndex}{dResultsRowIndex} = xVal;
                                end
                            else
                                for dColumnIndex=1:dNumParentObjectResultColumns
                                    if iscell(c1vxResults{dColumnIndex}) % inserting into cell
                                        if iscell(c1vxParentObjectResults{dColumnIndex}) % getting from cell
                                            c1xVal = c1vxParentObjectResults{dColumnIndex}(dSelectedObjectIndex);
                                        else % getting from vector
                                            c1xVal = {c1vxParentObjectResults{dColumnIndex}(dSelectedObjectIndex)};
                                        end
                                        
                                        c1vxResults{dColumnIndex}(dResultsRowIndex : dResultsRowIndex + dNumRowsToInsert - 1) = c1xVal;
                                    else % inserting into vector
                                        % if inserting into vector, we'll
                                        % also be grabbing from a vector
                                        
                                        c1vxResults{dColumnIndex}(dResultsRowIndex : dResultsRowIndex + dNumRowsToInsert - 1) = ...
                                            c1vxParentObjectResults{dColumnIndex}(dSelectedObjectIndex);
                                    end
                                end                                
                            end
                            
                            
                            if dNumRowsToInsert == 0 % there were no selected object results
                                
                                dResultsRowIndex = dResultsRowIndex + 1;
                            else
                                % copy over the results from selected object and
                                % then clear them out
                                try
                                    for dColumnIndex=dNumParentObjectResultColumns+1 :  dNumParentObjectResultColumns+ 1 + size(c1c1vxPerSelectedObjectResults{dSelectedObjectIndex}, 2) - 1
                                        c1vxSelectedObjectResults = c1c1vxPerSelectedObjectResults{dSelectedObjectIndex};
                                        vxResultColumn = c1vxSelectedObjectResults{dColumnIndex-dNumParentObjectResultColumns};
                                        
                                        if iscell(c1vxResults{dColumnIndex}) % inserting into cell
                                            if iscell(vxResultColumn) % getting from cell
                                                c1vxResults{dColumnIndex}(dResultsRowIndex : dResultsRowIndex + dNumRowsToInsert - 1) = ...
                                                    vxResultColumn;
                                            else % getting from vector
                                                for dRowIndex=dResultsRowIndex : dResultsRowIndex + dNumRowsToInsert - 1
                                                    c1vxResults{dColumnIndex}{dRowIndex} = vxResultColumn(dRowIndex-dResultsRowIndex+1);
                                                end
                                            end
                                        else % inserting into vector
                                            % getting from vector is
                                            % assumed here
                                             c1vxResults{dColumnIndex}(dResultsRowIndex : dResultsRowIndex + dNumRowsToInsert - 1) = vxResultColumn;
                                        end
                                    end
                                catch e
                                    disp(e); 
                                end
                                
                                % clear out result
                                c1c1vxPerSelectedObjectResults{dSelectedObjectIndex} = [];
                                
                                % update row counter
                                dResultsRowIndex = dResultsRowIndex + dNumRowsToInsert;
                            end
                        end
                    end
                end
            end
        end
    end
    
    
    methods (Access = ?StudyDatabase, Static = true)
        
        function c2xResults = ConvertResultsToStringOrNumeric(c2xResults)
            for dElementIndex=1:numel(c2xResults)
                xElement = c2xResults{dElementIndex};
                
                if ~(...
                        ischar(xElement) ||...
                        islogical(xElement) ||...
                        isempty(xElement) ||...
                        ( ~isvector(xElement) && isnumeric(xElement) ))
                    
                    if isenum(xElement)
                        c2xResults{dElementIndex} = char(xElement);
                    elseif isdatetime(xElement)
                        c2xResults{dElementIndex} = datestr(xElement, Constants.dateExportFormat);
                    elseif ( isvector(xElement) && isnumeric(xElement) )
                        c2xResults{dElementIndex} = num2str(xElement);
                    elseif iscell(xElement) && ~isempty(xElement)
                        if CellArrayUtils.AreAllIndexClassesEqual(xElement) && ischar(xElement{1})
                            c2xResults{dElementIndex} = CellArrayUtils.convertCellArrayOfStringsToNewlineSeparatedString(xElement);
                        end
                    else
                        error(...
                            'DatabaseQuery:convertResultsToStringOrNumeric:InvalidObject',...
                            'Invalid object to convert to a string');
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        
        function bAllComplete = AllQueriesComplete(obj)
            bAllComplete = all(obj.vbClassQueryComplete);
        end 
    end
end
