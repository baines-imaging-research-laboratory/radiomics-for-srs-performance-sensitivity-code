classdef ClassSelector
    %ClassSelector
        
    properties (SetAccess = immutable, GetAccess = private)
        chParentClass
        fhSelectorFunctionHandle
        c1oSelectorFunctionParams
    end
    
    methods (Access = public)
        
        function obj = ClassSelector(chParentClass, fhSelectorFunctionHandle, varargin)
            %obj = ClassSelector(fhSelectorFunctionHandle, varargin)
            
            obj.chParentClass = chParentClass;
            obj.fhSelectorFunctionHandle = fhSelectorFunctionHandle;
            obj.c1oSelectorFunctionParams = varargin;
        end
        
        function chParentClass = GetParentClass(obj)
            %chParentClass = getParentClass(obj)
            
            chParentClass = obj.chParentClass;
        end
        
        function voSelectedObjects = GetSelectedObjects(obj, oParentObject)
            if isa(oParentObject, obj.chParentClass)
                hFn = obj.fhSelectorFunctionHandle;
                
                if isempty(obj.c1oSelectorFunctionParams)
                    voSelectedObjects = hFn(oParentObject);
                else
                    voSelectedObjects = hFn(oParentObject, obj.c1oSelectorFunctionParams(:));
                end
                
                if ~isvector(voSelectedObjects)
                    error(...
                        'ClassSelector:getSelection:InvalidSelectionFunction',...
                        ['The provided selection function of ', func2str(hFn), ' for class ', class(oParentObject), ' did not return the required output of a vector or single object']);                
                end
            else
                error(...
                    'ClassSelector:getSelection:InvalidParentObject',...
                    ['The provided parent object of class ', class(oParentObject), ' did not match the required parent class of ', obj.chParentClass]);
            end
        end
    end
end

