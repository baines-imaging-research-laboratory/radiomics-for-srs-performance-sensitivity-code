classdef DropDownQuestion < CustomizableQuestion
    %DropDownQuestion
    
    properties (SetAccess = immutable)
        options = {} % cell array of strings
    end
    
    methods (Access = public)
        function obj = DropDownQuestion(label, options, default, hotkey)
            %DropDownQuestion(label, options, default, hotkey) Construct an instance of this class
            obj = obj@CustomizableQuestion(label, default, hotkey);
            
            obj.options = options;            
        end
        
        function [] = applyHotkey(obj)
            items = obj.handle.Items;
            numItems = length(items);
            
            index = 0;
            
            for i=1:numItems
                if strcmp(obj.handle.Value, obj.handle.Items{i})
                    index = i;
                    break;
                end
            end
            
            index = mod(index,numItems) + 1;
            
            obj.handle.Value = items{index};
        end
        
        function options = getOptions(obj)
            options = obj.options;
        end
    end
end

