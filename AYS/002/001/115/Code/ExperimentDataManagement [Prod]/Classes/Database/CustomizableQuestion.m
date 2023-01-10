classdef (Abstract) CustomizableQuestion < matlab.mixin.Copyable
    %CustomizableQuestion
    
    properties (SetAccess = immutable)
        label = '' % string
        default = []
        hotkey = ''
    end
       
    properties (SetAccess = protected)
        handle
    end
    
    methods (Access = public)
        function obj = CustomizableQuestion(label, default, hotkey)
            %CustomizableQuestion(label, default, hotkey)
            obj.label = label;
            obj.default = default;
            obj.hotkey = hotkey;
        end
        
        function bool = isHotkey(obj, hotkey)
            bool = strcmp(obj.hotkey, hotkey);
        end
        
        function label = getLabel(obj)
            label = obj.label;
        end
        
        function default = getDefault(obj)
            default = obj.default;
        end
        
        function setHandle(obj, handle)
            obj.handle = handle;
        end
    end
    
    methods (Abstract)
        applyHotkey(obj)
    end
end

