classdef ClassQuery
    %ClassQuery
    
    properties (Access = private)
        oClassSelector 
        
        c1fhClassFunctionHandles = {}
        c1chColumnHeaders = {}
    end
    
    methods
        function obj = ClassQuery(oClassSelector, c1fhClassFunctionHandles, c1chColumnHeaders)
            %obj = ClassQuery(oClassSelector, c1fhClassFunctionHandles)
            arguments
                oClassSelector (1,1) ClassSelector
                c1fhClassFunctionHandles (1,:) cell
                c1chColumnHeaders (1,:) cell
            end
            
            
            obj.oClassSelector = oClassSelector;
            obj.c1fhClassFunctionHandles = c1fhClassFunctionHandles;
            
            obj.c1chColumnHeaders = c1chColumnHeaders;
        end
        
        function [c1vxResults, voSelectedObjects] = Execute(obj, oParentObject)
            %[c2xResults, c1oSelectedObjects] = execute(obj, oParentObject)
            
            voSelectedObjects = obj.oClassSelector.GetSelectedObjects(oParentObject);
            
            dNumSelectedObjects = length(voSelectedObjects);
            dNumResultsPerObject = length(obj.c1fhClassFunctionHandles);
            
            c1vxResults = cell(1, dNumResultsPerObject);
            
            if dNumSelectedObjects > 0
                vbColumnIsCellArray = false(1,dNumResultsPerObject);
                
                for dResultIndex=1:dNumResultsPerObject
                    fhFn = obj.c1fhClassFunctionHandles{dResultIndex};
                    c1xResultsForAllObjects = cell(dNumSelectedObjects,1);
                    
                    bAllScalar = true;
                    
                    for dObjectIndex=1:dNumSelectedObjects
                        c1xResultsForAllObjects{dObjectIndex} = fhFn(voSelectedObjects(dObjectIndex));
                        
                        if ~isscalar(c1xResultsForAllObjects{dObjectIndex})
                            bAllScalar = false;
                        end
                    end
                                        
                    % if all are scalar, convert to vector
                    if bAllScalar
                        vxResultsForAllObjects = repmat(c1xResultsForAllObjects{1}, dNumSelectedObjects, 1);
                        
                        for dObjectIndex=1:dNumSelectedObjects
                            vxResultsForAllObjects(dObjectIndex) = c1xResultsForAllObjects{dObjectIndex};
                        end
                        
                        c1vxResults{dResultIndex} = vxResultsForAllObjects;
                    else
                        c1vxResults{dResultIndex} = c1xResultsForAllObjects;
                    end
                end
            end
        end
        
        function chParentClass = GetParentClass(obj)
            chParentClass = obj.oClassSelector.GetParentClass();
        end
        
        function c1chColumnHeaders = GetColumnHeaders(obj)
            c1chColumnHeaders = cell(2, length(obj.c1chColumnHeaders));
            
            c1chColumnHeaders(2,:) = obj.c1chColumnHeaders;
        end
    end
end

